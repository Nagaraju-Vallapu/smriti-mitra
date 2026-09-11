import pandas as pd
import numpy as np

# --------------------------------------------------
# 1. Load the raw gameplay dataset
# --------------------------------------------------

input_path = "ai_ml/data/game_performance.csv"

df = pd.read_csv(input_path)

print("=" * 60)
print("FEATURE ENGINEERING")
print("=" * 60)

print(f"\nOriginal shape: {df.shape}")


# --------------------------------------------------
# 2. Calculate mistake rate
# --------------------------------------------------

df["mistake_rate"] = (
    df["mistakes"] / df["attempts"].replace(0, np.nan)
)

df["mistake_rate"] = df["mistake_rate"].fillna(0)


# --------------------------------------------------
# 3. Calculate time efficiency
# --------------------------------------------------
# Lower completion time is generally better.
# We calculate efficiency separately for each game
# so games with different durations are comparable.

group_max_time = df.groupby("game_id")["completion_time"].transform("max")

df["time_efficiency"] = (
    1 - (df["completion_time"] / group_max_time)
)

df["time_efficiency"] = (
    df["time_efficiency"].clip(0, 1) * 100
)


# --------------------------------------------------
# 4. Calculate adaptive performance score
# --------------------------------------------------
# Higher accuracy + higher score + fewer mistakes
# + better time efficiency = better performance.

df["performance_score"] = (
    0.35 * df["accuracy"]
    + 0.35 * df["score"]
    + 0.15 * (100 - df["mistake_rate"] * 100)
    + 0.15 * df["time_efficiency"]
)

df["performance_score"] = (
    df["performance_score"]
    .clip(0, 100)
    .round(2)
)


# --------------------------------------------------
# 5. Select ML-relevant columns
# --------------------------------------------------

ml_columns = [
    "user_id",
    "game_id",
    "difficulty_level",
    "score",
    "accuracy",
    "completion_time",
    "mistakes",
    "attempts",
    "completed",
    "mistake_rate",
    "time_efficiency",
    "performance_score",
    "recommended_difficulty"
]

ml_df = df[ml_columns].copy()


# --------------------------------------------------
# 6. Save ML-ready dataset
# --------------------------------------------------

output_path = "ai_ml/data/ml_ready_game_performance.csv"

ml_df.to_csv(output_path, index=False)


# --------------------------------------------------
# 7. Display results
# --------------------------------------------------

print(f"\nML-ready shape: {ml_df.shape}")

print("\nNew features:")
print("- mistake_rate")
print("- time_efficiency")
print("- performance_score")

print("\nPerformance Score Statistics:")
print(
    ml_df["performance_score"].describe()
)

print("\nRecommended Difficulty Distribution:")
print(
    ml_df["recommended_difficulty"].value_counts()
)

print(f"\nSaved to:")
print(output_path)

print("\n" + "=" * 60)
print("FEATURE ENGINEERING COMPLETE")
print("=" * 60)