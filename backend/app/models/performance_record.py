from sqlalchemy import (
    Column,
    Integer,
    Numeric,
    DateTime,
    ForeignKey
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.database import Base


class PerformanceRecord(Base):
    __tablename__ = "performance_record"

    record_id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    session_id = Column(
        Integer,
        ForeignKey(
            "game_session.session_id",
            ondelete="CASCADE"
        ),
        nullable=False
    )

    score = Column(Numeric(6, 2))

    accuracy = Column(Numeric(5, 2))

    reaction_time = Column(Numeric(10, 2))

    difficulty = Column(Integer)

    recorded_at = Column(
        DateTime,
        server_default=func.now()
    )

    session = relationship(
        "GameSession",
        back_populates="performance_records"
    )