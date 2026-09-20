import asyncio

import asyncpg

from app.core.config import settings


async def main() -> None:
    connection = await asyncpg.connect(settings.direct_url)
    try:
        print("direct_connection: true")
        for table in ("profiles", "queue_sessions", "queue_tokens"):
            exists = await connection.fetchval("select to_regclass($1)", f"public.{table}")
            print(f"{table}: {exists}")
    finally:
        await connection.close()


if __name__ == "__main__":
    asyncio.run(main())
