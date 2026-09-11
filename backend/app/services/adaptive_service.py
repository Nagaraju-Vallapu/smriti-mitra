from pathlib import Path
import sys

# --------------------------------------------------
# Add project root to Python path
# --------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[3]

AI_ML_SRC = PROJECT_ROOT / "ai_ml" / "src"

if str(AI_ML_SRC) not in sys.path:
    sys.path.append(str(AI_ML_SRC))


# --------------------------------------------------
# Import ML prediction function
# --------------------------------------------------

from predict import predict_recommendation


# --------------------------------------------------
# Adaptive recommendation service
# --------------------------------------------------

def get_adaptive_recommendation(game_data: dict):
    """
    Send game performance data to the ML recommendation engine.
    """

    return predict_recommendation(game_data)