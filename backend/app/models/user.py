from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.database import Base


class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    phone = Column(String(20), unique=True, nullable=True)
    email = Column(String(150), unique=True, nullable=True)
    password_hash = Column(String, nullable=False)
    language = Column(String(50), default="English")
    created_at = Column(DateTime, server_default=func.now())

    elderly_profile = relationship(
        "ElderlyProfile",
        back_populates="user",
        uselist=False
    )