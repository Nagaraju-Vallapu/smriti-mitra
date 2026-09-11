from pydantic import BaseModel, Field


class AdaptiveRecommendationRequest(BaseModel):
    user_id: str
    game_id: str
    difficulty_level: str
    score: float = Field(ge=0, le=100)
    accuracy: float = Field(ge=0, le=100)
    completion_time: float = Field(gt=0)
    mistakes: int = Field(ge=0)
    attempts: int = Field(gt=0)


class AdaptiveRecommendationResponse(BaseModel):
    user_id: str
    recommended_game: str
    recommended_difficulty: str
    weak_cognitive_area: str
    performance_score: float
    reason: str