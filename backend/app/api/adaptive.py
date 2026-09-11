from fastapi import APIRouter, HTTPException

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
def recommend_game(data: AdaptiveRecommendationRequest):

    try:
        result = get_adaptive_recommendation(
            data.model_dump()
        )

        return result

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Adaptive recommendation failed: {str(e)}"
        )