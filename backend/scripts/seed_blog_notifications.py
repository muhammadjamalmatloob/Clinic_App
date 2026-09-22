import asyncio
from sqlalchemy import select
from app.db.session import async_session_factory
from app.models.article import Article
from app.models.notification import Notification
from app.models.profile import Profile

async def seed_db():
    async with async_session_factory() as db:
        # 1. Add Articles (Assuming an admin exists, otherwise skip or create)
        result = await db.execute(select(Profile).filter(Profile.role == "admin"))
        admin = result.scalars().first()
        if admin:
            articles = [
                Article(title="Healthy Eating During Pregnancy", summary="Nutrition tips for a healthy journey.", content="Full content here...", author_id=admin.id),
                Article(title="Postpartum Recovery", summary="What to expect and how to take care of yourself.", content="Full content here...", author_id=admin.id),
                Article(title="Childhood Milestones", summary="Tracking your baby's first year of development.", content="Full content here...", author_id=admin.id),
            ]
            db.add_all(articles)

        # 3. Add Notifications for the first patient profile
        result = await db.execute(select(Profile).filter(Profile.role == "patient"))
        patient = result.scalars().first()
        if patient:
            notifications = [
                Notification(profile_id=patient.id, title="Appointment Confirmed", message="Your appointment is confirmed.", notification_type="appointment"),
                Notification(profile_id=patient.id, title="Dr. Rukhsana Update", message="Running 15 minutes late.", notification_type="system"),
                Notification(profile_id=patient.id, title="Lab Results Ready", message="Ultrasound results available.", notification_type="lab"),
                Notification(profile_id=patient.id, title="Reminder", message="Take your prescribed Iron Supplements.", notification_type="reminder"),
            ]
            db.add_all(notifications)
                
        await db.commit()
        print("Database seeded with Articles and Notifications!")

if __name__ == "__main__":
    asyncio.run(seed_db())
