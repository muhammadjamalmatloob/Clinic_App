from datetime import date, time
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import Date, ForeignKey, String, Time
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.dependent import Dependent
    from app.models.profile import Profile


class Medication(TimestampMixin, Base):
    __tablename__ = "medications"

    patient_id: Mapped[UUID] = mapped_column(ForeignKey("profiles.id", ondelete="CASCADE"))
    dependent_id: Mapped[UUID | None] = mapped_column(ForeignKey("dependents.id"), nullable=True)
    medicine_name: Mapped[str] = mapped_column(String(200), nullable=False)
    dosage: Mapped[str] = mapped_column(String(100), nullable=False)
    schedule: Mapped[str] = mapped_column(String(200), nullable=False)
    is_taken: Mapped[bool] = mapped_column(default=False, nullable=False)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[date | None] = mapped_column(Date, nullable=True)

    patient: Mapped["Profile"] = relationship(foreign_keys=[patient_id])
    dependent: Mapped["Dependent | None"] = relationship(back_populates="medications")
