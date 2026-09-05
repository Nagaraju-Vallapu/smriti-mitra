from fastapi import FastAPI, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session
from app.api.users import router as users_router
from app.api.elderly_profiles import router as elderly_profiles_router
from app.api.game_sessions import router as game_sessions_router
from app.api.performance_records import (
    router as performance_records_router
)
from app.api.reminders import router as reminders_router
from app.api.cognitive_games import router as cognitive_games_router

from app.database import get_db

from app.models import (
    User,
    ElderlyProfile,
    Caregiver,
    HealthWorker,
    CognitiveGame,
    GameSession,
    PerformanceRecord
)


app = FastAPI(
    title="SMRITI MITRA API",
    description="Backend API for the SMRITI MITRA cognitive assistance platform",
    version="1.0.0"
)

app.include_router(users_router)
app.include_router(elderly_profiles_router)
app.include_router(game_sessions_router)
app.include_router(performance_records_router)
app.include_router(reminders_router)
app.include_router(cognitive_games_router)

@app.get("/")
def root():
    return {
        "message": "SMRITI MITRA API is running",
        "status": "success"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }


@app.get("/db-test")
def database_test(db: Session = Depends(get_db)):
    result = db.execute(text("SELECT 1"))

    return {
        "database": "connected",
        "test_result": result.scalar()
    }