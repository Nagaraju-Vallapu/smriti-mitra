from pydantic import BaseModel
from typing import Optional


class ElderlyProfileCreate(BaseModel):
    user_id: int
    age: Optional[int] = None
    accessibility_mode: str = "high_contrast"
    emergency_contact: Optional[str] = None
    preferred_language: str = "English"


class ElderlyProfileResponse(BaseModel):
    profile_id: int
    user_id: int
    age: Optional[int] = None
    accessibility_mode: str
    emergency_contact: Optional[str] = None
    preferred_language: str

    class Config:
        from_attributes = True