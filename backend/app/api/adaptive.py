from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.adaptive import (
    AdaptiveRecommendationRequest,
    AdaptiveRecommendationResponse
)

from app.services.adaptive_service import (
    get_adaptive_recommendation
)


router = APIRouter(
    prefix="/api/adaptive",
    tags=["Adaptive Recommendation"]
)


@router.post(
    "/recommend",
    response_model=AdaptiveRecommendationResponse
)
def recommend_game(
    data: AdaptiveRecommendationRequest,
    db: Session = Depends(get_db),
):

    try:
        result = get_adaptive_recommendation(
            data.model_dump(),
            db,
        )

        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Adaptive recommendation failed: {str(e)}"
        )