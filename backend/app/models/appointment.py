from datetime import date, time
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import Date, Enum, ForeignKey, Text, Time
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.dependent import Dependent
    from app.models.medical_record import MedicalRecord
    from app.models.prescription import Prescription
    from app.models.profile import Profile
    from app.models.service import Service


class Appointment(TimestampMixin, Base):
    __tablename__ = "appointments"

    patient_id: Mapped[UUID] = mapped_column(ForeignKey("profiles.id", ondelete="CASCADE"))
    dependent_id: Mapped[UUID | None] = mapped_column(ForeignKey("dependents.id"), nullable=True)
    service_id: Mapped[UUID] = mapped_column(ForeignKey("services.id"))
    doctor_id: Mapped[UUID | None] = mapped_column(ForeignKey("profiles.id"), nullable=True)
    appointment_date: Mapped[date] = mapped_column(Date, nullable=False)
    appointment_time: Mapped[time] = mapped_column(Time, nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(
        Enum("requested", "confirmed", "completed", "cancelled", name="appointment_status"),
        default="requested",
        nullable=False,
    )

    patient: Mapped["Profile"] = relationship(
        back_populates="appointments", foreign_keys=[patient_id]
    )
    dependent: Mapped["Dependent | None"] = relationship(back_populates="appointments")
    service: Mapped["Service"] = relationship(back_populates="appointments")
    medical_records: Mapped[list["MedicalRecord"]] = relationship(back_populates="appointment")
    prescriptions: Mapped[list["Prescription"]] = relationship(back_populates="appointment")
