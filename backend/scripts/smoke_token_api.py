import asyncio
from uuid import uuid4

import httpx
from sqlalchemy import delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import async_session_factory
from app.main import app
from app.models import Profile, QueueToken


async def main() -> None:
    email = f"smoke-{uuid4()}@example.com"
    profile_id = uuid4()

    async with async_session_factory() as session:
        profile = Profile(
            id=profile_id,
            email=email,
            full_name="Token Smoke Test",
            phone_number="0000000000",
            role="patient",
        )
        session.add(profile)
        await session.commit()

    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as client:
        invalid_response = await client.post(
            "/api/v1/queues/today/tokens",
            json={"patient_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6"},
        )
        print("invalid_status:", invalid_response.status_code)
        print("invalid_body:", invalid_response.json())

        response = await client.post(
            "/api/v1/queues/today/tokens",
            json={"patient_id": str(profile_id)},
        )
        print("status:", response.status_code)
        print("body:", response.json())

    async with async_session_factory() as session:
        await session.execute(delete(QueueToken).where(QueueToken.patient_id == profile_id))
        await session.execute(delete(Profile).where(Profile.id == profile_id))
        await session.commit()

    if invalid_response.status_code != 404 or response.status_code != 201:
        raise SystemExit(1)


if __name__ == "__main__":
    asyncio.run(main())
