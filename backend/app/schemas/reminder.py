from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class ReminderCreate(BaseModel):
    user_id: int
    reminder_type: str
    message: str
    scheduled_time: datetime


class ReminderUpdate(BaseModel):
    reminder_type: Optional[str] = None
    message: Optional[str] = None
    scheduled_time: Optional[datetime] = None
    completed: Optional[bool] = None


class ReminderResponse(BaseModel):
    reminder_id: int
    user_id: int
    reminder_type: str
    message: str
    scheduled_time: datetime
    completed: bool

    class Config:
        from_attributes = True