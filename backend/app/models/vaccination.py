from datetime import date
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import Date, Enum, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.dependent import Dependent


class VaccinationRecord(TimestampMixin, Base):
    __tablename__ = "vaccination_records"

    dependent_id: Mapped[UUID] = mapped_column(ForeignKey("dependents.id", ondelete="CASCADE"))
    vaccine_name: Mapped[str] = mapped_column(String(200), nullable=False)
    due_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    completed_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    status: Mapped[str] = mapped_column(
        Enum("upcoming", "completed", name="vaccination_status"), default="upcoming", nullable=False
    )

    dependent: Mapped["Dependent"] = relationship(back_populates="vaccination_records")
