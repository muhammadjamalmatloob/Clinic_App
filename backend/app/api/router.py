from fastapi import APIRouter

from app.api.routes import auth, clinic, health, ai, articles, notifications


api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(auth.router)
api_router.include_router(clinic.router)
api_router.include_router(ai.router, prefix="/ai")
api_router.include_router(articles.router, prefix="/articles", tags=["articles"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["notifications"])
