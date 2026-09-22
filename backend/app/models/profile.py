from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import Boolean, Enum, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.announcement import Announcement
    from app.models.appointment import Appointment
    from app.models.dependent import Dependent
    from app.models.feedback import Feedback
    from app.models.medical_record import MedicalRecord
    from app.models.prescription import Prescription
    from app.models.queue import QueueSession, QueueToken


class Profile(TimestampMixin, Base):
    __tablename__ = "profiles"

    email: Mapped[str] = mapped_column(String(320), unique=True, nullable=False)
    full_name: Mapped[str] = mapped_column(String(200), nullable=False)
    phone_number: Mapped[str] = mapped_column(String(30), nullable=False)
    role: Mapped[str] = mapped_column(
        Enum("patient", "staff", "admin", name="profile_role"), default="patient", nullable=False
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    dependents: Mapped[list["Dependent"]] = relationship(back_populates="guardian")
    queue_tokens: Mapped[list["QueueToken"]] = relationship(
        back_populates="patient", foreign_keys="QueueToken.patient_id"
    )
    appointments: Mapped[list["Appointment"]] = relationship(
        back_populates="patient", foreign_keys="Appointment.patient_id"
    )
    medical_records: Mapped[list["MedicalRecord"]] = relationship(
        back_populates="patient", foreign_keys="MedicalRecord.patient_id"
    )
    prescriptions: Mapped[list["Prescription"]] = relationship(
        back_populates="patient", foreign_keys="Prescription.patient_id"
    )
    announcements: Mapped[list["Announcement"]] = relationship(back_populates="created_by")
    feedback: Mapped[list["Feedback"]] = relationship(back_populates="patient")
    created_queues: Mapped[list["QueueSession"]] = relationship(back_populates="created_by")
