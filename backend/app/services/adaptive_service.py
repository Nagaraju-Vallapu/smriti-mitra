from pathlib import Path
import re
import sys
from datetime import datetime

from fastapi import HTTPException
from sqlalchemy import func
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.models import CognitiveGame, GameSession, PerformanceRecord, User
# --------------------------------------------------
# Add project root to Python path
# --------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[3]

AI_ML_SRC = PROJECT_ROOT / "ai_ml" / "src"

if str(AI_ML_SRC) not in sys.path:
    sys.path.append(str(AI_ML_SRC))


# --------------------------------------------------
# Import ML prediction function
# --------------------------------------------------

from predict import predict_recommendation


# --------------------------------------------------
# Adaptive recommendation service
# --------------------------------------------------

def _resolve_user(db: Session, flutter_user_id: str) -> User:
    """Resolve the mobile U### identifier to an existing database user."""
    match = re.fullmatch(r"U(\d+)", flutter_user_id.strip(), re.IGNORECASE)
    if not match:
        raise HTTPException(
            status_code=404,
            detail=f"User '{flutter_user_id}' could not be resolved",
        )

    database_user_id = int(match.group(1))
    user = db.query(User).filter(User.user_id == database_user_id).first()
    if user is None:
        raise HTTPException(
            status_code=404,
            detail=f"User '{flutter_user_id}' could not be resolved",
        )

    return user


def _resolve_game(db: Session, flutter_game_id: str) -> CognitiveGame:
    normalized_game_id = flutter_game_id.strip().lower()
    game = db.query(CognitiveGame).filter(
        func.lower(
            func.replace(CognitiveGame.game_name, " ", "_")
        ) == normalized_game_id
    ).first()

    if game is None:
        raise HTTPException(
            status_code=404,
            detail=f"Cognitive game '{flutter_game_id}' could not be resolved",
        )

    return game


def _difficulty_number(difficulty_level: str) -> int:
    difficulty = difficulty_level.strip().lower()
    difficulty_map = {
        "easy": 1,
        "medium": 2,
        "hard": 3,
    }

    if difficulty not in difficulty_map:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported difficulty level '{difficulty_level}'",
        )

    return difficulty_map[difficulty]


def _persist_performance(game_data: dict, db: Session) -> None:
    user = _resolve_user(db, game_data["user_id"])
    game = _resolve_game(db, game_data["game_id"])
    difficulty = _difficulty_number(game_data["difficulty_level"])

    try:
        completed_at = datetime.utcnow()
        game_session = GameSession(
            user_id=user.user_id,
            game_id=game.game_id,
            end_time=completed_at,
            score=game_data["score"],
            accuracy=game_data["accuracy"],
            # completion_time is elapsed duration, not reaction time.
            reaction_time=None,
        )
        db.add(game_session)
        db.flush()

        db.add(
            PerformanceRecord(
                session_id=game_session.session_id,
                score=game_data["score"],
                accuracy=game_data["accuracy"],
                difficulty=difficulty,
                reaction_time=None,
            )
        )
        db.commit()
    except SQLAlchemyError as exc:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Game performance could not be persisted: {exc}",
        ) from exc


def get_adaptive_recommendation(
    game_data: dict,
    db: Session,
):
    """
    Persist game performance, then send the original payload to the ML engine.

    The database schema stores an integer generated session_id and has no
    column for Flutter's string session_id, so retries cannot be identified
    safely as the same session without a schema change.
    """
    _persist_performance(game_data, db)

    return predict_recommendation(game_data)