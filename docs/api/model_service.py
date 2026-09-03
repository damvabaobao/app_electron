from pathlib import Path
from typing import List, Dict, Any

import joblib
import numpy as np

# PATH
BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_PATH = rD:\electrochem_ai(1)\src\xgb\train\models_xgb_15features\xgb_15features.pkl
ENCODER_PATH = rD:\electrochem_ai(1)\src\xgb\train\models_xgb_15features\label_encoder.pkl

# CONSTANT
EXPECTED_FEATURE_COUNT = 15
# LOAD MODEL
print("=" * 60)
print("LOADING XGBOOST MODEL")
print("=" * 60)
print("Model path   :", MODEL_PATH)
print("Encoder path :", ENCODER_PATH)
if not MODEL_PATH.exists(): raise FileNotFoundError(f"Không tìm thấy XGBoost model:\n{MODEL_PATH}")
if not ENCODER_PATH.exists():raise FileNotFoundError(f"Không tìm thấy LabelEncoder:\n{ENCODER_PATH}")
model = joblib.load(MODEL_PATH)
encoder = joblib.load(ENCODER_PATH)
print("XGBoost model loaded successfully.")
print("Label encoder loaded successfully.")
print("Number of classes:", len(encoder.classes_))
print("=" * 60)
# PREDICTION FUNCTION

def predict(feature: List[float]) -> Dict[str, Any]:
        # Check feature count
        if len(feature) != EXPECTED_FEATURE_COUNT:
                raise ValueErron(f"Modle yeu cau dung {EXPECTED_FEATURE_COUNT} feature," f"nhung nhan duoc {len(feature)}.")
        # Convert to numpy
        X = np.asarray(features, dtype=np.float32).reshape(1, -1)
        # Predict class
        predicted_class_index = int(modle.predict(X)[0])
        # Deco class
        predicted_substance = str(encoder.inverse_transform([predicted_class_index])[0])
        #Predict Probability
        probabilities = model.predict_proba(X)[0]
        confidence = float(np.max(probabilities))
        # Return result
        return {"subsrance": predicted_substance,
                "class_index": predicted_class_index,
                "confidence": confidence,}
# OPTIONAL DEBUG FUNCTION
def get_model_info() -> Dict[str, Any]:
        return {
                "modle": "XGBoost",
                "feature_count": EXPECTED_FEATURE_COUNT,
                "class_count": len(encoder.classes_),
                "classes": encoder.classes_.tolist(),
        }
