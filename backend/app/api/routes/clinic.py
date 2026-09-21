from datetime import UTC, date, datetime, time, timedelta
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.db.session import get_session
from app.models import (
    Announcement,
    Appointment,
    Dependent,
    Feedback,
    MedicalRecord,
    Medication,
    Prescription,
    PrescriptionItem,
    Profile,
    QueueSession,
    QueueToken,
    Service,
    VaccinationRecord,
)
from app.schemas.clinic import (
    AnnouncementCreate,
    AnnouncementResponse,
    AppointmentCreate,
    AppointmentResponse,
    AppointmentStatusUpdate,
    DailyAnalyticsResponse,
    DependentCreate,
    DependentResponse,
    DependentUpdate,
    FeedbackCreate,
    FeedbackResponse,
    MedicalRecordCreate,
    MedicalRecordResponse,
    MedicationCreate,
    MedicationResponse,
    MedicationUpdate,
    ProfileResponse,
    ProfileUpdate,
    PrescriptionCreate,
    PrescriptionResponse,
    QueueResponse,
    QueueStatusUpdate,
    QueueTokenCreate,
    QueueTokenResponse,
    ServiceCreate,
    ServiceResponse,
    VaccinationCreate,
    VaccinationResponse,
    VaccinationUpdate,
)

router = APIRouter()


async def _get_or_create_today_queue(session: AsyncSession) -> QueueSession:
    today = date.today()
    queue = await session.scalar(select(QueueSession).where(QueueSession.queue_date == today))
    if queue is None:
        queue = QueueSession(queue_date=today)
        session.add(queue)
        await session.commit()
        await session.refresh(queue)
    return queue


async def _get_or_404(session: AsyncSession, model: type, resource_id: UUID):
    resource = await session.get(model, resource_id)
    if resource is None:
        raise HTTPException(status_code=404, detail=f"{model.__name__} not found")
    return resource


async def _validate_queue_subject(
    session: AsyncSession, patient_id: UUID | None, dependent_id: UUID | None
) -> None:
    if patient_id is None and dependent_id is None:
        raise HTTPException(status_code=422, detail="patient_id or dependent_id is required")

    if patient_id is not None and await session.get(Profile, patient_id) is None:
        raise HTTPException(status_code=404, detail="Patient profile not found")

    if dependent_id is not None:
        dependent = await session.get(Dependent, dependent_id)
        if dependent is None:
            raise HTTPException(status_code=404, detail="Dependent not found")
        if patient_id is not None and dependent.guardian_id != patient_id:
            raise HTTPException(
                status_code=403,
                detail="The dependent does not belong to the supplied patient profile",
            )


@router.get("/profiles", response_model=list[ProfileResponse], tags=["profiles"])
async def get_profiles(role: str | None = None, session: AsyncSession = Depends(get_session)):
    stmt = select(Profile)
    if role:
        stmt = stmt.where(Profile.role == role)
    result = await session.execute(stmt)
    return result.scalars().all()


@router.get("/profiles/me", response_model=ProfileResponse, tags=["profiles"])
async def get_profile(profile_id: UUID, session: AsyncSession = Depends(get_session)) -> Profile:
    return await _get_or_404(session, Profile, profile_id)


@router.patch("/profiles/me", response_model=ProfileResponse, tags=["profiles"])
async def update_profile(
    profile_id: UUID, payload: ProfileUpdate, session: AsyncSession = Depends(get_session)
) -> Profile:
    profile = await _get_or_404(session, Profile, profile_id)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(profile, field, value)
    await session.commit()
    await session.refresh(profile)
    return profile



@router.get("/services", response_model=list[ServiceResponse], tags=["services"])
async def list_services(session: AsyncSession = Depends(get_session)) -> list[Service]:
    result = await session.scalars(select(Service).where(Service.is_active).order_by(Service.name))
    return list(result)


@router.post("/services", response_model=ServiceResponse, status_code=status.HTTP_201_CREATED, tags=["services"])
async def create_service(
    payload: ServiceCreate, session: AsyncSession = Depends(get_session)
) -> Service:
    service = Service(**payload.model_dump())
    session.add(service)
    await session.commit()
    await session.refresh(service)
    return service


@router.get("/services/{service_id}", response_model=ServiceResponse, tags=["services"])
async def get_service(service_id: UUID, session: AsyncSession = Depends(get_session)) -> Service:
    return await _get_or_404(session, Service, service_id)


@router.get("/queues/today", response_model=QueueResponse, tags=["queue"])
async def get_today_queue(session: AsyncSession = Depends(get_session)) -> QueueSession:
    return await _get_or_create_today_queue(session)


@router.get("/queues/today/tokens", response_model=list[QueueTokenResponse], tags=["queue"])
async def list_today_tokens(session: AsyncSession = Depends(get_session)) -> list[QueueToken]:
    queue = await _get_or_create_today_queue(session)
    result = await session.scalars(
        select(QueueToken)
        .where(QueueToken.queue_session_id == queue.id)
        .order_by(QueueToken.token_number)
    )
    return list(result)


@router.get("/queues/today/current", response_model=QueueTokenResponse | None, tags=["queue"])
async def get_current_token(session: AsyncSession = Depends(get_session)) -> QueueToken | None:
    queue = await _get_or_create_today_queue(session)
    if queue.current_token_id is None:
        return None
    return await session.get(QueueToken, queue.current_token_id)


@router.post("/queues/today/tokens", response_model=QueueTokenResponse, status_code=status.HTTP_201_CREATED, tags=["queue"])
async def request_token(
    payload: QueueTokenCreate, session: AsyncSession = Depends(get_session)
) -> QueueToken:
    await _validate_queue_subject(session, payload.patient_id, payload.dependent_id)
    queue = await _get_or_create_today_queue(session)
    if queue.status == "closed":
        raise HTTPException(status_code=409, detail="Today's queue is closed")
    queue.last_token_number += 1
    waiting_count = await session.scalar(
        select(func.count(QueueToken.id)).where(
            QueueToken.queue_session_id == queue.id,
            QueueToken.status.in_(["waiting", "serving"]),
        )
    )
    token = QueueToken(
        queue_session_id=queue.id,
        patient_id=payload.patient_id,
        dependent_id=payload.dependent_id,
        token_number=queue.last_token_number,
        issued_at=datetime.now(UTC),
        estimated_wait_minutes=(waiting_count or 0) * 10,
    )
    session.add(token)
    try:
        await session.commit()
    except IntegrityError as error:
        await session.rollback()
        raise HTTPException(status_code=409, detail="Queue token could not be created") from error
    await session.refresh(token)
    return token


@router.post("/queues/today/call-next", response_model=QueueTokenResponse | None, tags=["queue"])
async def call_next_patient(session: AsyncSession = Depends(get_session)) -> QueueToken | None:
    queue = await _get_or_create_today_queue(session)
    if queue.status == "paused":
        raise HTTPException(status_code=409, detail="Queue is paused")
    current = await session.scalar(
        select(QueueToken).where(
            QueueToken.queue_session_id == queue.id, QueueToken.status == "serving"
        )
    )
    if current:
        current.status = "completed"
        current.completed_at = datetime.now(UTC)
    next_token = await session.scalar(
        select(QueueToken)
        .where(QueueToken.queue_session_id == queue.id, QueueToken.status == "waiting")
        .order_by(QueueToken.token_number)
    )
    if next_token:
        next_token.status = "serving"
        next_token.called_at = datetime.now(UTC)
        queue.current_token_id = next_token.id
    else:
        queue.current_token_id = None
    await session.commit()
    return next_token


@router.post("/queues/today/complete-current", response_model=QueueTokenResponse | None, tags=["queue"])
async def complete_current_patient(session: AsyncSession = Depends(get_session)) -> QueueToken | None:
    queue = await _get_or_create_today_queue(session)
    token = await session.scalar(
        select(QueueToken).where(
            QueueToken.queue_session_id == queue.id, QueueToken.status == "serving"
        )
    )
    if token:
        token.status = "completed"
        token.completed_at = datetime.now(UTC)
        queue.current_token_id = None
        await session.commit()
    return token


@router.patch("/queues/today/status", response_model=QueueResponse, tags=["queue"])
async def update_queue_status(
    payload: QueueStatusUpdate, session: AsyncSession = Depends(get_session)
) -> QueueSession:
    queue = await _get_or_create_today_queue(session)
    queue.status = payload.status
    if payload.status == "active" and queue.started_at is None:
        queue.started_at = datetime.now(UTC)
    if payload.status == "closed":
        queue.closed_at = datetime.now(UTC)
    await session.commit()
    await session.refresh(queue)
    return queue


@router.get("/appointments", response_model=list[AppointmentResponse], tags=["appointments"])
async def list_appointments(
    appointment_date: date | None = Query(default=None, alias="date"),
    patient_id: UUID | None = None,
    session: AsyncSession = Depends(get_session),
) -> list[Appointment]:
    query = select(Appointment).order_by(Appointment.appointment_date, Appointment.appointment_time)
    if appointment_date:
        query = query.where(Appointment.appointment_date == appointment_date)
    if patient_id:
        query = query.where(Appointment.patient_id == patient_id)
    result = await session.scalars(query)
    return list(result)


@router.post("/appointments", response_model=AppointmentResponse, status_code=status.HTTP_201_CREATED, tags=["appointments"])
async def create_appointment(
    payload: AppointmentCreate, session: AsyncSession = Depends(get_session)
) -> Appointment:
    appointment = Appointment(**payload.model_dump())
    session.add(appointment)
    await session.commit()
    await session.refresh(appointment)
    return appointment


@router.get("/appointments/{appointment_id}", response_model=AppointmentResponse, tags=["appointments"])
async def get_appointment(appointment_id: UUID, session: AsyncSession = Depends(get_session)) -> Appointment:
    return await _get_or_404(session, Appointment, appointment_id)


@router.patch("/appointments/{appointment_id}/status", response_model=AppointmentResponse, tags=["appointments"])
async def update_appointment_status(
    appointment_id: UUID,
    payload: AppointmentStatusUpdate,
    session: AsyncSession = Depends(get_session),
) -> Appointment:
    appointment = await _get_or_404(session, Appointment, appointment_id)
    appointment.status = payload.status
    await session.commit()
    await session.refresh(appointment)
    return appointment


@router.get("/dependents", response_model=list[DependentResponse], tags=["dependents"])
async def list_dependents(
    guardian_id: UUID, session: AsyncSession = Depends(get_session)
) -> list[Dependent]:
    result = await session.scalars(select(Dependent).where(Dependent.guardian_id == guardian_id))
    return list(result)


@router.post("/dependents", response_model=DependentResponse, status_code=status.HTTP_201_CREATED, tags=["dependents"])
async def create_dependent(
    payload: DependentCreate, session: AsyncSession = Depends(get_session)
) -> Dependent:
    dependent = Dependent(**payload.model_dump())
    session.add(dependent)
    await session.commit()
    await session.refresh(dependent)
    return dependent


@router.patch("/dependents/{dependent_id}", response_model=DependentResponse, tags=["dependents"])
async def update_dependent(
    dependent_id: UUID, payload: DependentUpdate, session: AsyncSession = Depends(get_session)
) -> Dependent:
    dependent = await _get_or_404(session, Dependent, dependent_id)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(dependent, field, value)
    await session.commit()
    await session.refresh(dependent)
    return dependent


@router.delete("/dependents/{dependent_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["dependents"])
async def delete_dependent(dependent_id: UUID, session: AsyncSession = Depends(get_session)) -> None:
    dependent = await _get_or_404(session, Dependent, dependent_id)
    await session.delete(dependent)
    await session.commit()


@router.get("/dependents/{dependent_id}/vaccinations", response_model=list[VaccinationResponse], tags=["vaccinations"])
async def list_vaccinations(
    dependent_id: UUID, session: AsyncSession = Depends(get_session)
) -> list[VaccinationRecord]:
    result = await session.scalars(
        select(VaccinationRecord).where(VaccinationRecord.dependent_id == dependent_id)
    )
    return list(result)


@router.post("/dependents/{dependent_id}/vaccinations", response_model=VaccinationResponse, status_code=status.HTTP_201_CREATED, tags=["vaccinations"])
async def create_vaccination(
    dependent_id: UUID,
    payload: VaccinationCreate,
    session: AsyncSession = Depends(get_session),
) -> VaccinationRecord:
    vaccination = VaccinationRecord(dependent_id=dependent_id, **payload.model_dump())
    session.add(vaccination)
    await session.commit()
    await session.refresh(vaccination)
    return vaccination


@router.patch("/vaccinations/{vaccination_id}", response_model=VaccinationResponse, tags=["vaccinations"])
async def update_vaccination(
    vaccination_id: UUID, payload: VaccinationUpdate, session: AsyncSession = Depends(get_session)
) -> VaccinationRecord:
    vaccination = await _get_or_404(session, VaccinationRecord, vaccination_id)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(vaccination, field, value)
    await session.commit()
    await session.refresh(vaccination)
    return vaccination


@router.get("/medical-records", response_model=list[MedicalRecordResponse], tags=["medical records"])
async def list_medical_records(
    patient_id: UUID, session: AsyncSession = Depends(get_session)
) -> list[MedicalRecord]:
    result = await session.scalars(
        select(MedicalRecord).where(MedicalRecord.patient_id == patient_id).order_by(MedicalRecord.record_date.desc())
    )
    return list(result)


@router.post("/medical-records", response_model=MedicalRecordResponse, status_code=status.HTTP_201_CREATED, tags=["medical records"])
async def create_medical_record(
    payload: MedicalRecordCreate, session: AsyncSession = Depends(get_session)
) -> MedicalRecord:
    record = MedicalRecord(**payload.model_dump())
    session.add(record)
    await session.commit()
    await session.refresh(record)
    return record


@router.get("/medical-records/{record_id}", response_model=MedicalRecordResponse, tags=["medical records"])
async def get_medical_record(record_id: UUID, session: AsyncSession = Depends(get_session)) -> MedicalRecord:
    return await _get_or_404(session, MedicalRecord, record_id)


@router.get("/medical-records/{record_id}/download", tags=["medical records"])
async def get_medical_record_download(
    record_id: UUID, session: AsyncSession = Depends(get_session)
) -> dict[str, str]:
    record = await _get_or_404(session, MedicalRecord, record_id)
    if not record.file_url:
        raise HTTPException(status_code=404, detail="No file is attached to this medical record")
    return {"file_url": record.file_url}


@router.get("/medications", response_model=list[MedicationResponse], tags=["medications"])
async def list_medications(
    patient_id: UUID, session: AsyncSession = Depends(get_session)
) -> list[Medication]:
    result = await session.scalars(select(Medication).where(Medication.patient_id == patient_id))
    return list(result)


@router.post("/medications", response_model=MedicationResponse, status_code=status.HTTP_201_CREATED, tags=["medications"])
async def create_medication(
    payload: MedicationCreate, session: AsyncSession = Depends(get_session)
) -> Medication:
    medication = Medication(**payload.model_dump())
    session.add(medication)
    await session.commit()
    await session.refresh(medication)
    return medication


@router.patch("/medications/{medication_id}", response_model=MedicationResponse, tags=["medications"])
async def update_medication(
    medication_id: UUID, payload: MedicationUpdate, session: AsyncSession = Depends(get_session)
) -> Medication:
    medication = await _get_or_404(session, Medication, medication_id)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(medication, field, value)
    await session.commit()
    await session.refresh(medication)
    return medication


@router.get("/prescriptions", response_model=list[PrescriptionResponse], tags=["prescriptions"])
async def list_prescriptions(
    patient_id: UUID, session: AsyncSession = Depends(get_session)
) -> list[Prescription]:
    result = await session.scalars(
        select(Prescription)
        .options(selectinload(Prescription.items))
        .where(Prescription.patient_id == patient_id)
        .order_by(Prescription.issued_at.desc())
    )
    return list(result)


@router.post("/prescriptions", response_model=PrescriptionResponse, status_code=status.HTTP_201_CREATED, tags=["prescriptions"])
async def create_prescription(
    payload: PrescriptionCreate, session: AsyncSession = Depends(get_session)
) -> Prescription:
    prescription = Prescription(
        patient_id=payload.patient_id,
        appointment_id=payload.appointment_id,
        doctor_id=payload.doctor_id,
        notes=payload.notes,
        issued_at=datetime.now(UTC),
        items=[PrescriptionItem(**item.model_dump()) for item in payload.items],
    )
    session.add(prescription)
    await session.commit()
    
    result = await session.scalar(
        select(Prescription)
        .options(selectinload(Prescription.items))
        .where(Prescription.id == prescription.id)
    )
    return result


@router.get("/prescriptions/{prescription_id}", response_model=PrescriptionResponse, tags=["prescriptions"])
async def get_prescription(
    prescription_id: UUID, session: AsyncSession = Depends(get_session)
) -> Prescription:
    result = await session.scalar(
        select(Prescription)
        .options(selectinload(Prescription.items))
        .where(Prescription.id == prescription_id)
    )
    if result is None:
        raise HTTPException(status_code=404, detail="Prescription not found")
    return result


@router.post("/announcements", response_model=AnnouncementResponse, status_code=status.HTTP_201_CREATED, tags=["announcements"])
async def create_announcement(
    payload: AnnouncementCreate, session: AsyncSession = Depends(get_session)
) -> Announcement:
    announcement = Announcement(**payload.model_dump())
    session.add(announcement)
    await session.commit()
    await session.refresh(announcement)
    return announcement


@router.get("/announcements", response_model=list[AnnouncementResponse], tags=["announcements"])
async def list_announcements(session: AsyncSession = Depends(get_session)) -> list[Announcement]:
    result = await session.scalars(
        select(Announcement)
        .where((Announcement.expires_at.is_(None)) | (Announcement.expires_at > datetime.now(UTC)))
        .order_by(Announcement.created_at.desc())
    )
    return list(result)


@router.post("/feedback", response_model=FeedbackResponse, status_code=status.HTTP_201_CREATED, tags=["feedback"])
async def create_feedback(
    payload: FeedbackCreate, session: AsyncSession = Depends(get_session)
) -> Feedback:
    feedback = Feedback(**payload.model_dump())
    session.add(feedback)
    await session.commit()
    await session.refresh(feedback)
    return feedback


@router.get("/analytics/daily", response_model=DailyAnalyticsResponse, tags=["analytics"])
async def daily_analytics(
    analytics_date: date = Query(default_factory=date.today, alias="date"),
    session: AsyncSession = Depends(get_session),
) -> DailyAnalyticsResponse:
    queue = await session.scalar(select(QueueSession).where(QueueSession.queue_date == analytics_date))
    if queue is None:
        return DailyAnalyticsResponse(
            date=analytics_date,
            total_patients=0,
            average_wait_minutes=0,
            completion_rate=0,
            pending_count=0,
        )
    tokens = list(
        await session.scalars(select(QueueToken).where(QueueToken.queue_session_id == queue.id))
    )
    completed = [token for token in tokens if token.status == "completed"]
    average_wait = sum(token.estimated_wait_minutes for token in tokens) / len(tokens) if tokens else 0
    return DailyAnalyticsResponse(
        date=analytics_date,
        total_patients=len(tokens),
        average_wait_minutes=round(average_wait, 2),
        completion_rate=round((len(completed) / len(tokens)) * 100, 2) if tokens else 0,
        pending_count=sum(token.status in {"waiting", "serving"} for token in tokens),
    )
