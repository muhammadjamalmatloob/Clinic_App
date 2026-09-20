from collections.abc import AsyncGenerator

from sqlalchemy import text
from sqlalchemy.engine import make_url
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import settings


def _async_database_url(database_url: str) -> str:
	"""Use asyncpg with a standard PostgreSQL URL from environment configuration."""
	url = make_url(database_url)
	query = dict(url.query)
	query.pop("pgbouncer", None)
	return str(url.set(drivername="postgresql+asyncpg", query=query))


if not settings.database_url:
	raise RuntimeError("DATABASE_URL is not configured. Copy .env.example to .env first.")


is_transaction_pooler = "pgbouncer=true" in settings.database_url.lower()
engine = create_async_engine(
	_async_database_url(settings.database_url),
	pool_pre_ping=True,
	connect_args={"statement_cache_size": 0} if is_transaction_pooler else {},
)
async_session_factory = async_sessionmaker(engine, expire_on_commit=False)


async def get_session() -> AsyncGenerator[AsyncSession, None]:
	async with async_session_factory() as session:
		yield session


async def check_database_connection() -> bool:
	async with engine.connect() as connection:
		result = await connection.execute(text("SELECT 1"))
		return result.scalar_one() == 1
