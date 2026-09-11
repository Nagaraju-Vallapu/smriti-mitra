import pandas as pd

# Load dataset
file_path = "ai_ml/data/game_performance.csv"
df = pd.read_csv(file_path)

print("=" * 60)
print("DATASET VALIDATION")
print("=" * 60)

# 1. Dataset shape
print("\n1. Dataset Shape")
print(df.shape)

# 2. Column names
print("\n2. Columns")
print(df.columns.tolist())

# 3. Data types
print("\n3. Data Types")
print(df.dtypes)

# 4. Missing values
print("\n4. Missing Values")
print(df.isnull().sum())

# 5. Duplicate rows
print("\n5. Duplicate Rows")
print(df.duplicated().sum())

# 6. Numerical summary
print("\n6. Numerical Summary")
print(df.describe())

# 7. Game distribution
print("\n7. Game Distribution")
print(df["game_id"].value_counts())

# 8. Current difficulty distribution
print("\n8. Current Difficulty Distribution")
print(df["difficulty_level"].value_counts())

# 9. Recommended difficulty distribution
print("\n9. Recommended Difficulty Distribution")
print(df["recommended_difficulty"].value_counts())

# 10. Cognitive-area distribution
print("\n10. Cognitive Area Distribution")
print(df["cognitive_area"].value_counts())

# 11. Completion status
print("\n11. Completion Status")
print(df["completed"].value_counts())

# 12. Performance score range
print("\n12. Performance Score")
print(
    f"Minimum: {df['performance_score'].min():.2f}"
)
print(
    f"Maximum: {df['performance_score'].max():.2f}"
)
print(
    f"Average: {df['performance_score'].mean():.2f}"
)

print("\n" + "=" * 60)
print("VALIDATION COMPLETE")
print("=" * 60)