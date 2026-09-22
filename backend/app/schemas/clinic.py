from datetime import date, datetime, time
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class ProfileResponse(ORMModel):
    id: UUID
    email: str
    full_name: str
    phone_number: str
    role: str
    is_active: bool


class ProfileUpdate(BaseModel):
    full_name: str | None = None
    phone_number: str | None = None


class DependentCreate(BaseModel):
    guardian_id: UUID
    full_name: str
    relationship_type: str
    age: int | None = Field(default=None, ge=0, le=150)


class DependentUpdate(BaseModel):
    full_name: str | None = None
    relationship_type: str | None = None
    age: int | None = Field(default=None, ge=0, le=150)


class DependentResponse(ORMModel):
    id: UUID
    guardian_id: UUID
    full_name: str
    relationship_type: str
    age: int | None


class ServiceCreate(BaseModel):
    name: str
    description: str | None = None
    duration_minutes: int = Field(default=30, gt=0)
    price_min: Decimal | None = Field(default=None, ge=0)
    price_max: Decimal | None = Field(default=None, ge=0)


class ServiceResponse(ORMModel):
    id: UUID
    name: str
    description: str | None
    duration_minutes: int
    price_min: Decimal | None
    price_max: Decimal | None
    is_active: bool


class QueueResponse(ORMModel):
    id: UUID
    queue_date: date
    status: str
    last_token_number: int
    current_token_id: UUID | None


class QueueTokenCreate(BaseModel):
    patient_id: UUID | None = None
    dependent_id: UUID | None = None


class QueueTokenResponse(ORMModel):
    id: UUID
    queue_session_id: UUID
    patient_id: UUID | None
    dependent_id: UUID | None
    patient_name: str | None = None
    dependent_name: str | None = None
    token_number: int
    status: str
    issued_at: datetime
    estimated_wait_minutes: int
    called_at: datetime | None
    completed_at: datetime | None


class QueueStatusUpdate(BaseModel):
    status: str = Field(pattern="^(active|paused|closed)$")


class AppointmentCreate(BaseModel):
    patient_id: UUID
    dependent_id: UUID | None = None
    service_id: UUID
    appointment_date: date
    appointment_time: time
    reason: str | None = None


class AppointmentStatusUpdate(BaseModel):
    status: str = Field(pattern="^(requested|confirmed|completed|cancelled)$")


class AppointmentResponse(ORMModel):
    id: UUID
    patient_id: UUID
    dependent_id: UUID | None
    patient_name: str | None = None
    dependent_name: str | None = None
    service_id: UUID
    doctor_id: UUID | None
    appointment_date: date
    appointment_time: time
    reason: str | None
    status: str


class VaccinationCreate(BaseModel):
    vaccine_name: str
    due_date: date | None = None
    completed_date: date | None = None
    status: str = Field(default="upcoming", pattern="^(upcoming|completed)$")


class VaccinationUpdate(BaseModel):
    due_date: date | None = None
    completed_date: date | None = None
    status: str | None = Field(default=None, pattern="^(upcoming|completed)$")


class VaccinationResponse(ORMModel):
    id: UUID
    dependent_id: UUID
    vaccine_name: str
    due_date: date | None
    completed_date: date | None
    status: str


class MedicalRecordCreate(BaseModel):
    patient_id: UUID
    dependent_id: UUID | None = None
    appointment_id: UUID | None = None
    record_type: str = Field(pattern="^(lab_report|ultrasound|prescription)$")
    title: str
    record_date: date
    file_url: str | None = None


class MedicalRecordResponse(ORMModel):
    id: UUID
    patient_id: UUID
    dependent_id: UUID | None
    appointment_id: UUID | None
    record_type: str
    title: str
    record_date: date
    file_url: str | None


class MedicationCreate(BaseModel):
    patient_id: UUID
    dependent_id: UUID | None = None
    medicine_name: str
    dosage: str
    schedule: str
    start_date: date
    end_date: date | None = None


class MedicationUpdate(BaseModel):
    is_taken: bool | None = None
    schedule: str | None = None
    end_date: date | None = None


class MedicationResponse(ORMModel):
    id: UUID
    patient_id: UUID
    dependent_id: UUID | None
    medicine_name: str
    dosage: str
    schedule: str
    is_taken: bool
    start_date: date
    end_date: date | None


class PrescriptionItemCreate(BaseModel):
    medicine_name: str
    dosage: str
    frequency: str
    duration: str
    instructions: str | None = None


class PrescriptionCreate(BaseModel):
    patient_id: UUID
    appointment_id: UUID | None = None
    doctor_id: UUID
    notes: str | None = None
    items: list[PrescriptionItemCreate] = Field(min_length=1)


class PrescriptionItemResponse(ORMModel):
    id: UUID
    medicine_name: str
    dosage: str
    frequency: str
    duration: str
    instructions: str | None


class PrescriptionResponse(ORMModel):
    id: UUID
    patient_id: UUID
    appointment_id: UUID | None
    doctor_id: UUID
    notes: str | None
    issued_at: datetime
    items: list[PrescriptionItemResponse]


class AnnouncementCreate(BaseModel):
    created_by_id: UUID
    message: str
    audience: str = Field(default="waiting_patients", pattern="^(waiting_patients|all_patients)$")
    expires_at: datetime | None = None


class AnnouncementResponse(ORMModel):
    id: UUID
    created_by_id: UUID
    message: str
    audience: str
    expires_at: datetime | None


class FeedbackCreate(BaseModel):
    patient_id: UUID
    appointment_id: UUID | None = None
    rating: int = Field(ge=1, le=5)
    comment: str | None = None


class FeedbackResponse(ORMModel):
    id: UUID
    patient_id: UUID
    appointment_id: UUID | None
    rating: int
    comment: str | None


class DailyAnalyticsResponse(BaseModel):
    date: date
    total_patients: int
    average_wait_minutes: float
    completion_rate: float
    pending_count: int
