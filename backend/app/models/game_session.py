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


class GameSession(Base):
    __tablename__ = "game_session"

    session_id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    user_id = Column(
        Integer,
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False
    )

    game_id = Column(
        Integer,
        ForeignKey("cognitive_game.game_id", ondelete="CASCADE"),
        nullable=False
    )

    start_time = Column(
        DateTime,
        nullable=False,
        server_default=func.now()
    )

    end_time = Column(DateTime)

    score = Column(Numeric(6, 2))

    accuracy = Column(Numeric(5, 2))

    reaction_time = Column(Numeric(10, 2))

    user = relationship(
        "User",
        backref="game_sessions"
    )

    game = relationship(
        "CognitiveGame",
        back_populates="sessions"
    )

    performance_records = relationship(
        "PerformanceRecord",
        back_populates="session"
    )