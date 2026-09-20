# Clinic API

FastAPI backend for the clinic token and queue management system.

## Structure

```text
backend/
├── app/
│   ├── api/              # Versioned HTTP routers and route handlers
│   ├── core/             # Settings and cross-cutting application concerns
│   ├── db/               # Database engine, sessions, and migrations
│   ├── models/           # Frontend-aligned SQLAlchemy database models
│   ├── repositories/     # Data-access abstractions
│   ├── schemas/          # Pydantic request and response schemas
│   ├── services/         # Business logic
│   └── main.py           # FastAPI application entry point
├── tests/                # API and service tests
├── .env.example
├── pyproject.toml
└── requirements.txt
```

The model layer currently contains only the entities represented by the Flutter application: profiles, daily queues and tokens, dependents, vaccinations, services, appointments, medical records, medications, prescriptions, announcements, and feedback.

## Run locally

From this `backend` directory in PowerShell:

```powershell
py -3.13 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
Copy-Item .env.example .env
uvicorn app.main:app --reload
```

Set `DATABASE_URL` to the Supabase transaction-mode pooler URL for application traffic and `DIRECT_URL` to the session-mode URL for migrations. URL-encode special characters in the database password.

Open `http://127.0.0.1:8000/docs` for interactive API documentation.

Health check:

```text
GET http://127.0.0.1:8000/api/v1/health
```

Run tests:

```powershell
pytest
```
