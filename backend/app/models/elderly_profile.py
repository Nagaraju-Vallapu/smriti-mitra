from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.database import Base


class ElderlyProfile(Base):
    __tablename__ = "elderly_profile"

    profile_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(
        Integer,
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
        unique=True
    )

    age = Column(Integer)
    accessibility_mode = Column(
        String(50),
        default="high_contrast"
    )
    emergency_contact = Column(String(20))
    preferred_language = Column(
        String(50),
        default="English"
    )

    
    user = relationship(
    "User",
    back_populates="elderly_profile"
)