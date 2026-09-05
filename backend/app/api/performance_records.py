from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import GameSession, PerformanceRecord

from app.schemas.performance_record import (
    PerformanceRecordCreate,
    PerformanceRecordResponse
)


router = APIRouter(
    prefix="/api/performance-records",
    tags=["Performance Records"]
)


@router.post("/", response_model=PerformanceRecordResponse)
def create_performance_record(
    record: PerformanceRecordCreate,
    db: Session = Depends(get_db)
):

    # Check whether game session exists
    session = db.query(GameSession).filter(
        GameSession.session_id == record.session_id
    ).first()

    if not session:
        raise HTTPException(
            status_code=404,
            detail="Game session not found"
        )

    new_record = PerformanceRecord(
        session_id=record.session_id,
        score=record.score,
        accuracy=record.accuracy,
        reaction_time=record.reaction_time,
        difficulty=record.difficulty
    )

    db.add(new_record)
    db.commit()
    db.refresh(new_record)

    return new_record


@router.get("/", response_model=list[PerformanceRecordResponse])
def get_performance_records(
    db: Session = Depends(get_db)
):
    return db.query(PerformanceRecord).all()


@router.get(
    "/{record_id}",
    response_model=PerformanceRecordResponse
)
def get_performance_record(
    record_id: int,
    db: Session = Depends(get_db)
):

    record = db.query(PerformanceRecord).filter(
        PerformanceRecord.record_id == record_id
    ).first()

    if not record:
        raise HTTPException(
            status_code=404,
            detail="Performance record not found"
        )

    return record