from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.orm import relationship

from app.database import Base


class CognitiveGame(Base):
    __tablename__ = "cognitive_game"

    game_id = Column(Integer, primary_key=True, index=True)

    game_name = Column(String(100), nullable=False)
    category = Column(String(50), nullable=False)
    description = Column(Text)

    difficulty_level = Column(
        Integer,
        nullable=False,
        default=1
    )

    sessions = relationship(
        "GameSession",
        back_populates="game"
    )