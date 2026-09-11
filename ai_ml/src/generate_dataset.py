import numpy as np
import pandas as pd
from datetime import datetime, timedelta

# Reproducibility
np.random.seed(42)

# Configuration
NUM_USERS = 100
GAMES = ["memory_match", "pattern_recall", "routine_order"]
DIFFICULTIES = ["easy", "medium", "hard"]

records = []

# Cognitive area mapping
cognitive_area = {
    "memory_match": "memory",
    "pattern_recall": "attention",
    "routine_order": "sequencing"
}

# Generate gameplay records
for user_num in range(1, NUM_USERS + 1):

    user_id = f"U{user_num:03d}"

    # Each user plays multiple sessions
    for session_num in range(30):

        game_id = np.random.choice(GAMES)
        difficulty = np.random.choice(DIFFICULTIES)

        # Difficulty affects expected performance
        difficulty_effect = {
            "easy": 0,
            "medium": -8,
            "hard": -16
        }

        # Generate accuracy
        accuracy = np.random.normal(
            85 + difficulty_effect[difficulty],
            10
        )

        accuracy = np.clip(accuracy, 35, 100)

        # Generate attempts
        attempts = np.random.randint(5, 16)

        # Generate mistakes based on accuracy
        mistakes = round(
            attempts * (1 - accuracy / 100)
        )

        mistakes = max(0, min(mistakes, attempts))

        # Generate score
        if game_id == "memory_match":
            score = 100 - (mistakes * 8)
        else:
            score = 100 - (mistakes * 10)

        score = np.clip(score, 0, 100)

        # Generate completion time
        base_time = {
            "easy": 35,
            "medium": 50,
            "hard": 70
        }

        completion_time = np.random.normal(
            base_time[difficulty],
            12
        )

        completion_time = max(10, round(completion_time))

        # Completion status
        completed = np.random.choice(
            [True, False],
            p=[0.95, 0.05]
        )

        # Timestamp
        timestamp = datetime.now() - timedelta(
            days=np.random.randint(0, 90),
            hours=np.random.randint(0, 24)
        )

        records.append({
            "user_id": user_id,
            "game_id": game_id,
            "difficulty_level": difficulty,
            "score": score,
            "accuracy": round(accuracy, 2),
            "completion_time": completion_time,
            "mistakes": mistakes,
            "attempts": attempts,
            "completed": completed,
            "timestamp": timestamp,
            "cognitive_area": cognitive_area[game_id]
        })


# Create DataFrame
df = pd.DataFrame(records)

# Calculate derived features
df["mistake_rate"] = (
    df["mistakes"] / df["attempts"]
).round(3)

df["performance_score"] = (
    0.4 * df["accuracy"] +
    0.4 * df["score"] +
    0.2 * (100 - df["mistake_rate"] * 100)
).clip(0, 100).round(2)


# Determine recommended difficulty
def recommend_difficulty(row):

    performance = row["performance_score"]
    current = row["difficulty_level"]

    if performance >= 80:
        if current == "easy":
            return "medium"
        elif current == "medium":
            return "hard"
        else:
            return "hard"

    elif performance < 60:
        if current == "hard":
            return "medium"
        elif current == "medium":
            return "easy"
        else:
            return "easy"

    else:
        return current


df["recommended_difficulty"] = df.apply(
    recommend_difficulty,
    axis=1
)


# Save dataset
output_path = "ai_ml/data/game_performance.csv"

df.to_csv(output_path, index=False)

print("Dataset generated successfully!")
print(f"Rows: {len(df)}")
print(f"Columns: {len(df.columns)}")
print(f"Saved to: {output_path}")

print("\nFirst 5 rows:")
print(df.head())

print("\nRecommended difficulty distribution:")
print(df["recommended_difficulty"].value_counts())