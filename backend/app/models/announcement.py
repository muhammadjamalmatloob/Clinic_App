from datetime import datetime
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import DateTime, Enum, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.profile import Profile


class Announcement(TimestampMixin, Base):
    __tablename__ = "announcements"

    created_by_id: Mapped[UUID] = mapped_column(ForeignKey("profiles.id"), nullable=False)
    message: Mapped[str] = mapped_column(Text, nullable=False)
    audience: Mapped[str] = mapped_column(
        Enum("waiting_patients", "all_patients", name="announcement_audience"),
        default="waiting_patients",
        nullable=False,
    )
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    created_by: Mapped["Profile"] = relationship(back_populates="announcements")
