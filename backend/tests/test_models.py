from sqlalchemy.orm import configure_mappers

from app.models import Base
import app.models


def test_frontend_models_register_expected_tables() -> None:
    configure_mappers()

    expected_tables = {
        "profiles",
        "queue_sessions",
        "queue_tokens",
        "dependents",
        "vaccination_records",
        "services",
        "appointments",
        "medical_records",
        "medications",
        "prescriptions",
        "prescription_items",
        "announcements",
        "feedback",
    }

    assert set(Base.metadata.tables) == expected_tables
