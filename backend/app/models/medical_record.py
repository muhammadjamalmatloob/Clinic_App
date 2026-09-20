from datetime import date
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import Date, Enum, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.appointment import Appointment
    from app.models.dependent import Dependent
    from app.models.profile import Profile


class MedicalRecord(TimestampMixin, Base):
    __tablename__ = "medical_records"

    patient_id: Mapped[UUID] = mapped_column(ForeignKey("profiles.id", ondelete="CASCADE"))
    dependent_id: Mapped[UUID | None] = mapped_column(ForeignKey("dependents.id"), nullable=True)
    appointment_id: Mapped[UUID | None] = mapped_column(ForeignKey("appointments.id"), nullable=True)
    record_type: Mapped[str] = mapped_column(
        Enum("lab_report", "ultrasound", "prescription", name="medical_record_type"), nullable=False
    )
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    record_date: Mapped[date] = mapped_column(Date, nullable=False)
    file_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_by_id: Mapped[UUID | None] = mapped_column(ForeignKey("profiles.id"), nullable=True)

    patient: Mapped["Profile"] = relationship(
        back_populates="medical_records", foreign_keys=[patient_id]
    )
    dependent: Mapped["Dependent | None"] = relationship(back_populates="medical_records")
    appointment: Mapped["Appointment | None"] = relationship(back_populates="medical_records")
