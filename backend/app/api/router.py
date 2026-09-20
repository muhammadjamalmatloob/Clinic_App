from fastapi import APIRouter

from app.api.routes import auth, clinic, health


api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(auth.router)
api_router.include_router(clinic.router)
