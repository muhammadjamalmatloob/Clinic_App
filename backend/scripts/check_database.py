import asyncio

import asyncpg

from app.core.config import settings
from app.db.session import check_database_connection


async def main() -> None:
    transaction_pooler_ok = False
    try:
        transaction_pooler_ok = await check_database_connection()
    except Exception as error:
        print(f"transaction pooler: FAILED ({type(error).__name__}: {error})")

    direct_pooler_ok = False
    try:
        direct_connection = await asyncpg.connect(settings.direct_url)
        try:
            direct_pooler_ok = await direct_connection.fetchval("SELECT 1") == 1
        finally:
            await direct_connection.close()
    except Exception as error:
        print(f"direct pooler: FAILED ({type(error).__name__}: {error})")

    if transaction_pooler_ok:
        print("transaction pooler: True")
    if direct_pooler_ok:
        print("direct pooler: True")

    if not transaction_pooler_ok or not direct_pooler_ok:
        raise SystemExit(1)


if __name__ == "__main__":
    asyncio.run(main())