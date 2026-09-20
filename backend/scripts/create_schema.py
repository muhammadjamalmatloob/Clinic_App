import asyncio

from app.db.session import engine
from app.models import Base
import app.models


async def main() -> None:
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    print("database_schema: created_or_already_exists")
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(main())