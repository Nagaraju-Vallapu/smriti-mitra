from pydantic import BaseModel, EmailStr
from typing import Optional


class UserCreate(BaseModel):
    name: str
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    password: str
    language: str = "English"


class UserResponse(BaseModel):
    user_id: int
    name: str
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    language: str
    created_at: object

    class Config:
        from_attributes = True