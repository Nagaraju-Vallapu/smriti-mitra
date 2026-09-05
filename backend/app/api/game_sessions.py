from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User, CognitiveGame, GameSession

from app.schemas.game_session import (
    GameSessionCreate,
    GameSessionUpdate,
    GameSessionResponse
)


router = APIRouter(
    prefix="/api/game-sessions",
    tags=["Game Sessions"]
)


@router.post("/", response_model=GameSessionResponse)
def create_game_session(
    session: GameSessionCreate,
    db: Session = Depends(get_db)
):

    # Check whether user exists
    user = db.query(User).filter(
        User.user_id == session.user_id
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    # Check whether game exists
    game = db.query(CognitiveGame).filter(
        CognitiveGame.game_id == session.game_id
    ).first()

    if not game:
        raise HTTPException(
            status_code=404,
            detail="Cognitive game not found"
        )

    new_session = GameSession(
        user_id=session.user_id,
        game_id=session.game_id
    )

    db.add(new_session)
    db.commit()
    db.refresh(new_session)

    return new_session


@router.get("/", response_model=list[GameSessionResponse])
def get_game_sessions(
    db: Session = Depends(get_db)
):
    return db.query(GameSession).all()


@router.get("/{session_id}", response_model=GameSessionResponse)
def get_game_session(
    session_id: int,
    db: Session = Depends(get_db)
):

    session = db.query(GameSession).filter(
        GameSession.session_id == session_id
    ).first()

    if not session:
        raise HTTPException(
            status_code=404,
            detail="Game session not found"
        )

    return session


@router.patch("/{session_id}", response_model=GameSessionResponse)
def update_game_session(
    session_id: int,
    session_data: GameSessionUpdate,
    db: Session = Depends(get_db)
):

    session = db.query(GameSession).filter(
        GameSession.session_id == session_id
    ).first()

    if not session:
        raise HTTPException(
            status_code=404,
            detail="Game session not found"
        )

    if session_data.end_time is not None:
        session.end_time = session_data.end_time

    if session_data.score is not None:
        session.score = session_data.score

    if session_data.accuracy is not None:
        session.accuracy = session_data.accuracy

    if session_data.reaction_time is not None:
        session.reaction_time = session_data.reaction_time

    db.commit()
    db.refresh(session)

    return session