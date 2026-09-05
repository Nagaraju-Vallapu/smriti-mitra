from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class GameSessionCreate(BaseModel):
    user_id: int
    game_id: int


class GameSessionUpdate(BaseModel):
    end_time: Optional[datetime] = None
    score: Optional[float] = None
    accuracy: Optional[float] = None
    reaction_time: Optional[float] = None


class GameSessionResponse(BaseModel):
    session_id: int
    user_id: int
    game_id: int
    start_time: datetime
    end_time: Optional[datetime] = None
    score: Optional[float] = None
    accuracy: Optional[float] = None
    reaction_time: Optional[float] = None

    class Config:
        from_attributes = True