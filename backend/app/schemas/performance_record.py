from pydantic import BaseModel
from typing import Optional


class PerformanceRecordCreate(BaseModel):
    session_id: int
    score: Optional[float] = None
    accuracy: Optional[float] = None
    reaction_time: Optional[float] = None
    difficulty: Optional[int] = None


class PerformanceRecordResponse(BaseModel):
    record_id: int
    session_id: int
    score: Optional[float] = None
    accuracy: Optional[float] = None
    reaction_time: Optional[float] = None
    difficulty: Optional[int] = None
    recorded_at: object

    class Config:
        from_attributes = True