from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class ArticleCreate(BaseModel):
    title: str
    summary: str
    content: str


class ArticleResponse(ORMModel):
    id: UUID
    title: str
    summary: str
    content: str
    author_id: UUID
    created_at: datetime
