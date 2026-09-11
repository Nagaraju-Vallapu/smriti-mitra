import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix
)

# --------------------------------------------------
# 1. Load ML-ready dataset
# --------------------------------------------------

input_path = "ai_ml/data/ml_ready_game_performance.csv"

df = pd.read_csv(input_path)

print("=" * 60)
print("SMRITI MITRA - MODEL TRAINING")
print("=" * 60)

print(f"\nDataset shape: {df.shape}")


# --------------------------------------------------
# 2. Select features and target
# --------------------------------------------------

features = [
    "score",
    "accuracy",
    "completion_time",
    "mistakes",
    "attempts",
    "mistake_rate",
    "time_efficiency",
    "game_id",
    "difficulty_level"
]

target = "recommended_difficulty"

X = df[features]
y = df[target]


# --------------------------------------------------
# 3. Separate numerical and categorical features
# --------------------------------------------------

numeric_features = [
    "score",
    "accuracy",
    "completion_time",
    "mistakes",
    "attempts",
    "mistake_rate",
    "time_efficiency"
]

categorical_features = [
    "game_id",
    "difficulty_level"
]


# --------------------------------------------------
# 4. Encode categorical features
# --------------------------------------------------

preprocessor = ColumnTransformer(
    transformers=[
        (
            "categorical",
            OneHotEncoder(handle_unknown="ignore"),
            categorical_features
        )
    ],
    remainder="passthrough"
)


# --------------------------------------------------
# 5. Create Random Forest model
# --------------------------------------------------

model = RandomForestClassifier(
    n_estimators=200,
    random_state=42,
    class_weight="balanced",
    max_depth=10
)


# --------------------------------------------------
# 6. Create complete ML pipeline
# --------------------------------------------------

pipeline = Pipeline(
    steps=[
        ("preprocessor", preprocessor),
        ("model", model)
    ]
)


# --------------------------------------------------
# 7. Train-test split
# --------------------------------------------------

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.20,
    random_state=42,
    stratify=y
)

print(f"Training samples: {len(X_train)}")
print(f"Testing samples: {len(X_test)}")


# --------------------------------------------------
# 8. Train model
# --------------------------------------------------

print("\nTraining Random Forest...")

pipeline.fit(X_train, y_train)

print("Training complete!")


# --------------------------------------------------
# 9. Make predictions
# --------------------------------------------------

y_pred = pipeline.predict(X_test)


# --------------------------------------------------
# 10. Evaluate model
# --------------------------------------------------

accuracy = accuracy_score(y_test, y_pred)

print("\n" + "=" * 60)
print("MODEL EVALUATION")
print("=" * 60)

print(f"\nAccuracy: {accuracy:.4f}")

print("\nClassification Report:")
print(
    classification_report(
        y_test,
        y_pred,
        digits=4
    )
)

print("\nConfusion Matrix:")

labels = ["easy", "medium", "hard"]

cm = confusion_matrix(
    y_test,
    y_pred,
    labels=labels
)

print("             Predicted")
print("             easy  medium  hard")

for label, row in zip(labels, cm):
    print(
        f"Actual {label:<6} "
        f"{row[0]:>4}   "
        f"{row[1]:>6}   "
        f"{row[2]:>4}"
    )

# --------------------------------------------------
# 11. Save trained model
# --------------------------------------------------

model_path = "ai_ml/models/difficulty_model.pkl"

joblib.dump(pipeline, model_path)

print(f"\nModel saved to: {model_path}")

print("\n" + "=" * 60)
print("TRAINING COMPLETE")
print("=" * 60)  

