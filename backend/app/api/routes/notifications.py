from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.models.notification import Notification
from app.schemas.notification import NotificationCreate, NotificationResponse

router = APIRouter()


@router.post("/", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
async def create_notification(
    notification_in: NotificationCreate,
    profile_id: UUID,
    session: AsyncSession = Depends(get_session),
):
    notification = Notification(
        profile_id=profile_id,
        title=notification_in.title,
        message=notification_in.message,
        notification_type=notification_in.notification_type,
    )
    session.add(notification)
    await session.commit()
    await session.refresh(notification)
    return notification


@router.get("/{profile_id}", response_model=List[NotificationResponse])
async def read_notifications(
    profile_id: UUID,
    session: AsyncSession = Depends(get_session),
):
    result = await session.execute(
        select(Notification)
        .filter(Notification.profile_id == profile_id)
        .order_by(Notification.created_at.desc())
    )
    return result.scalars().all()
