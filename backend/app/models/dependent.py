from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.appointment import Appointment
    from app.models.medical_record import MedicalRecord
    from app.models.medication import Medication
    from app.models.profile import Profile
    from app.models.queue import QueueToken
    from app.models.vaccination import VaccinationRecord


class Dependent(TimestampMixin, Base):
    __tablename__ = "dependents"

    guardian_id: Mapped[UUID] = mapped_column(ForeignKey("profiles.id", ondelete="CASCADE"))
    full_name: Mapped[str] = mapped_column(String(200), nullable=False)
    relationship_type: Mapped[str] = mapped_column(String(50), nullable=False)
    age: Mapped[int | None] = mapped_column(nullable=True)

    guardian: Mapped["Profile"] = relationship(back_populates="dependents")
    queue_tokens: Mapped[list["QueueToken"]] = relationship(back_populates="dependent")
    appointments: Mapped[list["Appointment"]] = relationship(back_populates="dependent")
    medical_records: Mapped[list["MedicalRecord"]] = relationship(back_populates="dependent")
    medications: Mapped[list["Medication"]] = relationship(back_populates="dependent")
    vaccination_records: Mapped[list["VaccinationRecord"]] = relationship(back_populates="dependent")
