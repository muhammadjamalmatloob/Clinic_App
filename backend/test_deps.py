import asyncio
from app.db.session import async_session_factory
from app.models.clinic import Dependent
from sqlalchemy import select

async def run():
    async with async_session_factory() as s:
        res = await s.execute(select(Dependent))
        deps = res.scalars().all()
        for d in deps:
            print(f"Dep: {d.full_name}, Guardian: {d.guardian_id}")
        if not deps:
            print("No dependents found in the database.")

if __name__ == "__main__":
    asyncio.run(run())
