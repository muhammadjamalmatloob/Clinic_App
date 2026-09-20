from datetime import date, datetime
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import Date, DateTime, Enum, ForeignKey, Integer, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.dependent import Dependent
    from app.models.profile import Profile


class QueueSession(TimestampMixin, Base):
    __tablename__ = "queue_sessions"

    queue_date: Mapped[date] = mapped_column(Date, nullable=False, unique=True)
    status: Mapped[str] = mapped_column(
        Enum("not_started", "active", "paused", "closed", name="queue_status"),
        default="not_started",
        nullable=False,
    )
    last_token_number: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    current_token_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("queue_tokens.id", use_alter=True, name="fk_queue_current_token"), nullable=True
    )
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    closed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_by_id: Mapped[UUID | None] = mapped_column(ForeignKey("profiles.id"), nullable=True)

    tokens: Mapped[list["QueueToken"]] = relationship(
        back_populates="queue_session", foreign_keys="QueueToken.queue_session_id"
    )
    current_token: Mapped["QueueToken | None"] = relationship(
        foreign_keys=[current_token_id], post_update=True
    )
    created_by: Mapped["Profile | None"] = relationship(back_populates="created_queues")


class QueueToken(TimestampMixin, Base):
    __tablename__ = "queue_tokens"
    __table_args__ = (UniqueConstraint("queue_session_id", "token_number"),)

    queue_session_id: Mapped[UUID] = mapped_column(ForeignKey("queue_sessions.id", ondelete="CASCADE"))
    patient_id: Mapped[UUID | None] = mapped_column(ForeignKey("profiles.id"), nullable=True)
    dependent_id: Mapped[UUID | None] = mapped_column(ForeignKey("dependents.id"), nullable=True)
    token_number: Mapped[int] = mapped_column(Integer, nullable=False)
    status: Mapped[str] = mapped_column(
        Enum("waiting", "serving", "completed", "cancelled", "paused", name="token_status"),
        default="waiting",
        nullable=False,
    )
    issued_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    estimated_wait_minutes: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    called_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    served_by_id: Mapped[UUID | None] = mapped_column(ForeignKey("profiles.id"), nullable=True)

    queue_session: Mapped["QueueSession"] = relationship(
        back_populates="tokens", foreign_keys=[queue_session_id]
    )
    patient: Mapped["Profile | None"] = relationship(
        back_populates="queue_tokens", foreign_keys=[patient_id]
    )
    dependent: Mapped["Dependent | None"] = relationship(back_populates="queue_tokens")
