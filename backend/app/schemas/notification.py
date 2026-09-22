from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class NotificationCreate(BaseModel):
    title: str
    message: str
    notification_type: str


class NotificationResponse(ORMModel):
    id: UUID
    profile_id: UUID
    title: str
    message: str
    notification_type: str
    is_read: bool
    created_at: datetime
