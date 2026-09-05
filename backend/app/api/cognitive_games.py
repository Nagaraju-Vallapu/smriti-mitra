from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import CognitiveGame

from app.schemas.cognitive_game import (
    CognitiveGameCreate,
    CognitiveGameUpdate,
    CognitiveGameResponse
)


router = APIRouter(
    prefix="/api/cognitive-games",
    tags=["Cognitive Games"]
)


@router.post("/", response_model=CognitiveGameResponse)
def create_cognitive_game(
    game: CognitiveGameCreate,
    db: Session = Depends(get_db)
):

    new_game = CognitiveGame(
        game_name=game.game_name,
        category=game.category,
        description=game.description,
        difficulty_level=game.difficulty_level
    )

    db.add(new_game)
    db.commit()
    db.refresh(new_game)

    return new_game


@router.get("/", response_model=list[CognitiveGameResponse])
def get_cognitive_games(
    db: Session = Depends(get_db)
):
    return db.query(CognitiveGame).order_by(
        CognitiveGame.game_id
    ).all()


@router.get("/{game_id}", response_model=CognitiveGameResponse)
def get_cognitive_game(
    game_id: int,
    db: Session = Depends(get_db)
):

    game = db.query(CognitiveGame).filter(
        CognitiveGame.game_id == game_id
    ).first()

    if not game:
        raise HTTPException(
            status_code=404,
            detail="Cognitive game not found"
        )

    return game


@router.patch("/{game_id}", response_model=CognitiveGameResponse)
def update_cognitive_game(
    game_id: int,
    game_data: CognitiveGameUpdate,
    db: Session = Depends(get_db)
):

    game = db.query(CognitiveGame).filter(
        CognitiveGame.game_id == game_id
    ).first()

    if not game:
        raise HTTPException(
            status_code=404,
            detail="Cognitive game not found"
        )

    if game_data.game_name is not None:
        game.game_name = game_data.game_name

    if game_data.category is not None:
        game.category = game_data.category

    if game_data.description is not None:
        game.description = game_data.description

    if game_data.difficulty_level is not None:
        if not 1 <= game_data.difficulty_level <= 10:
            raise HTTPException(
                status_code=400,
                detail="Difficulty level must be between 1 and 10"
            )

        game.difficulty_level = game_data.difficulty_level

    db.commit()
    db.refresh(game)

    return game