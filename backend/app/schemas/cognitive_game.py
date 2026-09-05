from pydantic import BaseModel
from typing import Optional


class CognitiveGameCreate(BaseModel):
    game_name: str
    category: str
    description: Optional[str] = None
    difficulty_level: int = 1


class CognitiveGameUpdate(BaseModel):
    game_name: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    difficulty_level: Optional[int] = None


class CognitiveGameResponse(BaseModel):
    game_id: int
    game_name: str
    category: str
    description: Optional[str] = None
    difficulty_level: int

    class Config:
        from_attributes = True