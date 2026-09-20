import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError

from app.core.config import settings
from app.db.session import get_session
from app.models import Profile
from app.schemas.auth import GoogleLoginRequest, LoginRequest, RegisterRequest

router = APIRouter()
bearer_scheme = HTTPBearer(auto_error=False)


def _auth_url(path: str) -> str:
    if not settings.supabase_url:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Supabase Auth URL is not configured. Set SUPABASE_URL.",
        )
    if not settings.supabase_anon_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Supabase Auth key is not configured. Set SUPABASE_ANON_KEY from Supabase Dashboard > Project Settings > API.",
        )
    return f"{settings.supabase_url.rstrip('/')}/auth/v1/{path}"


async def _supabase_request(path: str, payload: dict, access_token: str | None = None) -> dict:
    headers = {"apikey": settings.supabase_anon_key, "Content-Type": "application/json"}
    if access_token:
        headers["Authorization"] = f"Bearer {access_token}"
    async with httpx.AsyncClient(timeout=15) as client:
        response = await client.post(_auth_url(path), json=payload, headers=headers)
    if response.is_error:
        detail = response.json().get("msg") or response.json().get("error_description") or "Authentication failed"
        raise HTTPException(status_code=response.status_code, detail=detail)
    return response.json()


async def _supabase_get(path: str, access_token: str) -> dict:
    headers = {
        "apikey": settings.supabase_anon_key,
        "Authorization": f"Bearer {access_token}",
    }
    async with httpx.AsyncClient(timeout=15) as client:
        response = await client.get(_auth_url(path), headers=headers)
    if response.is_error:
        raise HTTPException(status_code=response.status_code, detail="Invalid access token")
    return response.json()


@router.post("/auth/register", tags=["auth"])
async def register(payload: RegisterRequest, session: AsyncSession = Depends(get_session)) -> dict:
    response = await _supabase_request(
        "signup",
        {
            "email": payload.email,
            "password": payload.password,
            "data": {"full_name": payload.full_name, "phone_number": payload.phone_number},
        },
    )
    user = response.get("user")
    if user and user.get("id"):
        profile = Profile(
            id=user["id"],
            email=payload.email,
            full_name=payload.full_name,
            phone_number=payload.phone_number,
            role="patient",
        )
        session.add(profile)
        try:
            await session.commit()
        except IntegrityError as error:
            await session.rollback()
            raise HTTPException(status_code=409, detail="Application profile already exists") from error
    return response


@router.post("/auth/login", tags=["auth"])
async def login(payload: LoginRequest) -> dict:
    return await _supabase_request(
        "token?grant_type=password", {"email": payload.email, "password": payload.password}
    )


@router.get("/auth/me", tags=["auth"])
async def current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> dict:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Bearer token required")
    return await _supabase_get("user", credentials.credentials)


@router.post("/auth/google", tags=["auth"])
async def google_login(payload: GoogleLoginRequest) -> dict:
    return await _supabase_request("token?grant_type=id_token", {"id_token": payload.id_token})


@router.post("/auth/logout", status_code=status.HTTP_204_NO_CONTENT, tags=["auth"])
async def logout(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> None:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Bearer token required")
    await _supabase_request("logout", {}, credentials.credentials)
