from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_session
from app.models.article import Article
from app.schemas.blog import ArticleCreate, ArticleResponse

router = APIRouter()


@router.post("/", response_model=ArticleResponse, status_code=status.HTTP_201_CREATED)
async def create_article(
    article_in: ArticleCreate,
    author_id: UUID,
    session: AsyncSession = Depends(get_session),
):
    article = Article(
        title=article_in.title,
        summary=article_in.summary,
        content=article_in.content,
        author_id=author_id,
    )
    session.add(article)
    await session.commit()
    await session.refresh(article)
    return article


@router.get("/", response_model=List[ArticleResponse])
async def read_articles(
    session: AsyncSession = Depends(get_session),
):
    result = await session.execute(
        select(Article).order_by(Article.created_at.desc())
    )
    return result.scalars().all()
