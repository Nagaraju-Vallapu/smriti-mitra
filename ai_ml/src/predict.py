import joblib
import pandas as pd
from pathlib import Path


# --------------------------------------------------
# 1. Load trained model
# --------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[2]

model_path = PROJECT_ROOT / "ai_ml" / "models" / "difficulty_model.pkl"

model = joblib.load(model_path)


# --------------------------------------------------
# 2. Cognitive-area mapping
# --------------------------------------------------

cognitive_area = {
    "memory_match": "memory",
    "pattern_recall": "attention",
    "routine_order": "sequencing"
}


# --------------------------------------------------
# 3. Calculate performance score
# --------------------------------------------------

def calculate_performance_score(
    score,
    accuracy,
    mistakes,
    attempts,
    completion_time
):
    mistake_rate = mistakes / max(attempts, 1)

    # Simple time normalization for prototype
    time_score = max(
        0,
        min(100, 100 - completion_time)
    )

    performance = (
        0.35 * accuracy
        + 0.35 * score
        + 0.15 * (100 - mistake_rate * 100)
        + 0.15 * time_score
    )

    return round(
        max(0, min(100, performance)),
        2
    )


# --------------------------------------------------
# 4. Predict recommendation
# --------------------------------------------------

def predict_recommendation(game_data):

    score = game_data["score"]
    accuracy = game_data["accuracy"]
    completion_time = game_data["completion_time"]
    mistakes = game_data["mistakes"]
    attempts = game_data["attempts"]

    mistake_rate = mistakes / max(attempts, 1)

    time_efficiency = max(
        0,
        min(100, 100 - completion_time)
    )

    performance_score = calculate_performance_score(
        score,
        accuracy,
        mistakes,
        attempts,
        completion_time
    )

    # DataFrame must match training features
    input_data = pd.DataFrame([{
        "score": score,
        "accuracy": accuracy,
        "completion_time": completion_time,
        "mistakes": mistakes,
        "attempts": attempts,
        "mistake_rate": mistake_rate,
        "time_efficiency": time_efficiency,
        "game_id": game_data["game_id"],
        "difficulty_level": game_data["difficulty_level"]
    }])

    # ML prediction
    recommended_difficulty = model.predict(
        input_data
    )[0]

    game_id = game_data["game_id"]

    # Current game's cognitive area
    current_area = cognitive_area.get(
        game_id,
        "general cognition"
    )

    # Prototype recommendation logic
    if performance_score < 60:
        recommended_game = game_id
        weak_area = current_area
        reason = (
            "Recent performance suggests that "
            "additional practice at this game "
            "may be beneficial."
        )

    elif performance_score >= 80:
        # Recommend another cognitive area
        if game_id == "memory_match":
            recommended_game = "pattern_recall"
        elif game_id == "pattern_recall":
            recommended_game = "routine_order"
        else:
            recommended_game = "memory_match"

        weak_area = cognitive_area.get(
            recommended_game,
            "general cognition"
        )

        reason = (
            "Strong performance on the current task "
            "allows progression to another cognitive "
            "activity."
        )

    else:
        recommended_game = game_id
        weak_area = current_area
        reason = (
            "Performance is stable. Continue practicing "
            "at an appropriate difficulty."
        )

    return {
        "user_id": game_data["user_id"],
        "recommended_game": recommended_game,
        "recommended_difficulty": recommended_difficulty,
        "weak_cognitive_area": weak_area,
        "performance_score": performance_score,
        "reason": reason
    }


# --------------------------------------------------
# 5. Test prediction
# --------------------------------------------------

if __name__ == "__main__":

    test_game = {
        "user_id": "U001",
        "game_id": "memory_match",
        "difficulty_level": "medium",
        "score": 88,
        "accuracy": 92,
        "completion_time": 38,
        "mistakes": 1,
        "attempts": 10
    }

    result = predict_recommendation(test_game)

    print("\n" + "=" * 60)
    print("SMRITI MITRA - ML RECOMMENDATION")
    print("=" * 60)

    for key, value in result.items():
        print(f"{key}: {value}")

    print("=" * 60)