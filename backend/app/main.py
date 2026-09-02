from fastapi import FastAPI, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

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