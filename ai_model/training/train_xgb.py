import os
import json
import joblib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from xgboost import XGBClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    classification_report,
    confusion_matrix
)

# 0. PATH
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR,"electrochemical_xgb_15features.csv")
MODEL_DIR = os.path.join(BASE_DIR,"models_xgb_15features")
FIG_DIR = os.path.join(MODEL_DIR,"figures")
os.makedirs(MODEL_DIR,exist_ok=True)
os.makedirs(FIG_DIR,exist_ok=True)

# 1. 15 FEATURES
FEATURES = [
    "meanCurrent",
    "stdCurrent",
    "maxCurrent",
    "minCurrent",
    "meanVoltage",
    "voltageRange",
    "meanGradient",
    "maxGradient",
    "minGradient",
    "peakCurrent",
    "peakPotential",
    "peakWidth",
    "peakArea",
    "peakProminence",
    "peakSymmetry"
]
TARGET = "substance"
# 2. VALUES
def values(model):
    print()
    print("=" * 70)
    print("VALUES - TRAINING / VALIDATION LOSS")
    print("=" * 70)
    # Lấy evaluation history
    evals_result = model.evals_result()
    # validation_0 = TRAIN
    train_loss = np.array(
        evals_result[
            "validation_0"
        ]["mlogloss"]
    )
    # validation_1 = VALIDATION
    validation_loss = np.array(
        evals_result[
            "validation_1"
        ]["mlogloss"]
    )
    # Tạo bảng values
    values_df = pd.DataFrame({
        "iteration":
            np.arange(
                len(train_loss)
            ),
        "train_mlogloss":
            train_loss,
        "validation_mlogloss":
            validation_loss
    })
    # Save CSV
    values_path = os.path.join(
        MODEL_DIR,
        "values.csv"
    )
    values_df.to_csv(
        values_path,
        index=False
    )
    # Best validation loss
    best_iteration = int(np.argmin(validation_loss))
    best_train_loss = float(train_loss[best_iteration])
    best_validation_loss = float(validation_loss[best_iteration])
    print(f"Best iteration       : "f"{best_iteration}")
    print(f"Train mlogloss       : "f"{best_train_loss:.6f}")
    print(f"Validation mlogloss  : "f"{best_validation_loss:.6f}")
    # Vẽ loss curve
    plt.figure(figsize=(10, 6))
    plt.plot(values_df["iteration"],values_df["train_mlogloss"],label="Train mlogloss")
    plt.plot(values_df["iteration"],values_df["validation_mlogloss"],label="Validation mlogloss")
    plt.axvline(
        best_iteration,
        linestyle="--",
        label=(f"Best iteration = "f"{best_iteration}")
    )
    plt.xlabel("Boosting Round")
    plt.ylabel("Multiclass Log Loss")
    plt.title("XGBoost Training / Validation Loss")
    plt.legend()
    plt.grid(alpha=0.25)
    plt.tight_layout()
    loss_path = os.path.join( FIG_DIR, "loss_curve.png")
    plt.savefig(loss_path,dpi=300,bbox_inches="tight")
    plt.close()
    print(f"Values saved : {values_path}")
    print(f"Loss curve   : {loss_path}")
    return (values_df,best_iteration,best_validation_loss)
# 3. LOAD DATASET
if not os.path.exists(CSV_PATH):
    raise FileNotFoundError(
        f"\nKhông tìm thấy:\n"
        f"{CSV_PATH}\n\n"
        "Hãy đặt file train_xgb.py "
        "cùng thư mục với "
        "electrochemical_xgb_15features.csv."
    )
df = pd.read_csv(CSV_PATH)
# 4. VALIDATE DATASET
required = (FEATURES + ["substance","chemical_group","concentration_mM"])
missing = [ column for column in required if column not in df.columns]
if missing:
    raise ValueError(
        "CSV thiếu cột: "
        + ", ".join(missing)
    )
df = df.dropna(subset=FEATURES + [TARGET]).copy()
print("=" * 70)
print("DATASET")
print("=" * 70)
print(f"Samples        : "f"{len(df):,}")
print(f"Features       : "f"{len(FEATURES)}")
print(f"Substances     : "f"{df[TARGET].nunique()}")
print(f"Concentrations : "f"{df['concentration_mM'].nunique()}")
# 5. TRAIN / VALIDATION / TEST SPLIT
rng = np.random.default_rng(42)
train_parts = []
validation_parts = []
test_parts = []
for (substance,concentration), group in df.groupby(
    ["substance","concentration_mM"],
    sort=False
):
    # Shuffle
    indices = rng.permutation(len(group))
    n = len(group)
    # 70% TRAIN
    n_train = int(n * 0.70)
    # 15% VALIDATION
    n_validation = int(n * 0.15)
    # Đảm bảo không để train rỗng
    n_train = max(1,n_train)
    # Các index
    train_idx = indices[:n_train]
    validation_idx = indices[
        n_train:
        n_train + n_validation
    ]
    test_idx = indices[n_train + n_validation:]
    # Nếu test bị rỗng, lấy ít nhất 1 mẫu
    if len(test_idx) == 0:
        test_idx = validation_idx[
            -1:
        ]
        validation_idx = validation_idx[:-1]
    train_parts.append(
        group.iloc[
            train_idx
        ]
    )
    validation_parts.append(
        group.iloc[
            validation_idx
        ]
    )
    test_parts.append(group.iloc[test_idx])
train_df = pd.concat(train_parts,ignore_index=True)
validation_df = pd.concat(validation_parts,ignore_index=True)
test_df = pd.concat(test_parts,ignore_index=True)
print()
print("=" * 70)
print("TRAIN / VALIDATION / TEST")
print("=" * 70)
print(f"Train      : "f"{len(train_df):,}")
print(f"Validation : "f"{len(validation_df):,}")
print(f"Test       : "f"{len(test_df):,}")
print()
print(f"Train ratio      : "f"{len(train_df) / len(df):.3f}")
print(f"Validation ratio : "f"{len(validation_df) / len(df):.3f}")
print(f"Test ratio       : "f"{len(test_df) / len(df):.3f}")
# 6. X / y
X_train = train_df[FEATURES].astype(np.float32)
X_validation = validation_df[FEATURES].astype(np.float32)
X_test = test_df[FEATURES].astype(np.float32)
# 7. LABEL ENCODER
encoder = LabelEncoder()
y_train = encoder.fit_transform(train_df[TARGET])
y_validation = encoder.transform(validation_df[TARGET])
y_test = encoder.transform(test_df[TARGET])
num_classes = len(encoder.classes_)
print()
print(f"Classes: "f"{num_classes}")
if num_classes != 100:
    print()
    print("WARNING:")
    print("Dataset không có đúng ""100 chất.")
# 8. XGBOOST MODEL
print()
print("=" * 70)
print("XGBOOST TRAINING")
print("=" * 70)
model = XGBClassifier(
    n_estimators=500,
    max_depth=7,
    learning_rate=0.04,
    subsample=0.85,
    colsample_bytree=0.85,
    min_child_weight=2,
    gamma=0.05,
    reg_alpha=0.05,
    reg_lambda=1.0,
    objective="multi:softprob",
    num_class=num_classes,
    eval_metric="mlogloss",
    tree_method="hist",
    random_state=42,
    n_jobs=-1
)
# 9. TRAIN
model.fit(
    X_train,
    y_train,
    eval_set=[(X_train,y_train),(X_validation,y_validation)],verbose=False)
# 10. VALUES
values_df, best_iteration, best_validation_loss = values(model)
# 11. TEST
y_train_pred = model.predict(X_train)
y_validation_pred = model.predict(X_validation)
y_test_pred = model.predict(X_test)
# 12. METRICS
metrics = {
    "train_accuracy":
        accuracy_score(
            y_train,
            y_train_pred
        ),
    "validation_accuracy":
        accuracy_score(
            y_validation,
            y_validation_pred
        ),
    "test_accuracy":
        accuracy_score(
            y_test,
            y_test_pred
        ),
    "test_macro_precision":
        precision_score(
            y_test,
            y_test_pred,
            average="macro",
            zero_division=0
        ),
    "test_macro_recall":
        recall_score(
            y_test,
            y_test_pred,
            average="macro",
            zero_division=0
        ),
    "test_macro_f1":
        f1_score(
            y_test,
            y_test_pred,
            average="macro",
            zero_division=0
        ),
    "test_weighted_precision":
        precision_score(
            y_test,
            y_test_pred,
            average="weighted",
            zero_division=0
        ),
    "test_weighted_recall":
        recall_score(
            y_test,
            y_test_pred,
            average="weighted",
            zero_division=0
        ),
    "test_weighted_f1":
        f1_score(
            y_test,
            y_test_pred,
            average="weighted",
            zero_division=0
        )
}
print()
print("=" * 70)
print("FINAL MODEL PERFORMANCE")
print("=" * 70)
for key, value in metrics.items(): print(f"{key:28s}: "f"{value:.6f}")
# 13. CLASSIFICATION REPORT
report = classification_report(
    y_test,
    y_test_pred,
    labels=np.arange(
        num_classes
    ),
    target_names=
        encoder.classes_,
    output_dict=True,
    zero_division=0
)
report_df = pd.DataFrame(
    report
).transpose()
report_df.to_csv(
    os.path.join(
        MODEL_DIR,
        "classification_report.csv"
    )
)
class_metrics = report_df.loc[
    encoder.classes_,
    [
        "precision",
        "recall",
        "f1-score"
    ]
]
class_metrics.to_csv(
    os.path.join(
        MODEL_DIR,
        "per_class_metrics.csv"
    )
)
# 14. CONFUSION MATRIX
cm = confusion_matrix(
    y_test,
    y_test_pred,
    labels=np.arange(num_classes))
pd.DataFrame(cm,index=encoder.classes_,columns=encoder.classes_).to_csv(os.path.join(MODEL_DIR,"confusion_matrix.csv"))
size = max(18,min(35,num_classes * 0.35))
plt.figure(figsize=(size,size))
plt.imshow(cm,interpolation="nearest",aspect="auto")
plt.title(f"XGBoost Confusion Matrix - "f"{num_classes} Classes")
plt.xlabel("Predicted class")
plt.ylabel("True class")
plt.xticks(np.arange(num_classes),encoder.classes_,rotation=90,fontsize=5)
plt.yticks(np.arange(num_classes),encoder.classes_,fontsize=5)
plt.colorbar()
plt.tight_layout()
plt.savefig(
    os.path.join(
        FIG_DIR,
        "confusion_matrix_100_classes.png"
    ),
    dpi=300,
    bbox_inches="tight")
plt.close()
# 15. PRECISION / RECALL / F1
x = np.arange(num_classes)
names = encoder.classes_
for (metric_name,title,filename) in [
    (
        "precision",
        "Precision per Substance",
        "precision_per_class.png"
    ),
    (
        "recall",
        "Recall per Substance",
        "recall_per_class.png"
    ),
    (
        "f1-score",
        "F1 Score per Substance",
        "f1_per_class.png"
    )
]:
    plt.figure(figsize=(18, 7))
    plt.bar(x,class_metrics[metric_name])
    plt.title(title)
    plt.xlabel("Substance")
    plt.ylabel(metric_name)
    plt.ylim(0, 1.05)
    plt.xticks(
        x,
        names,
        rotation=90,
        fontsize=5
    )
    plt.tight_layout()
    plt.savefig(
        os.path.join(FIG_DIR,filename),dpi=300,bbox_inches="tight")
    plt.close()
# 16. FEATURE IMPORTANCE
importance_df = pd.DataFrame({"feature":FEATURES,"importance":model.feature_importances_}).sort_values("importance",ascending=False)
importance_df.to_csv(os.path.join(MODEL_DIR,"feature_importance.csv"),index=False)
plt.figure(figsize=(11, 7))
plt.barh(importance_df["feature"],importance_df["importance"])
plt.gca().invert_yaxis()
plt.title("XGBoost Feature Importance - 15 Features")
plt.xlabel("Importance")
plt.ylabel("Feature")
plt.tight_layout()
plt.savefig(
    os.path.join(FIG_DIR,"feature_importance_15_features.png"),
    dpi=300,
    bbox_inches="tight"
)
plt.close()
print()
print("=" * 70)
print("FEATURE IMPORTANCE")
print("=" * 70)
print(importance_df.to_string(index=False))
# 17. SAVE MODEL
model_path = os.path.join(MODEL_DIR,"xgb_15features.pkl")
encoder_path = os.path.join(MODEL_DIR,"label_encoder.pkl")
features_path = os.path.join(MODEL_DIR,"feature_names.pkl")
metadata_path = os.path.join(MODEL_DIR,"model_metadata.json")
joblib.dump(model,model_path)
joblib.dump(encoder,encoder_path)
joblib.dump(FEATURES,features_path)
# 18. METADATA
metadata = {
    "model":
        "XGBoost",
    "number_of_classes":
        int(num_classes),
    "classes":
        encoder.classes_.tolist(),
    "number_of_features":
        len(FEATURES),
    "features":
        FEATURES,
    "target":
        TARGET,
    "train_samples":
        int(len(train_df)),
    "validation_samples":
        int(len(validation_df)),
    "test_samples":
        int(len(test_df)),
    "train_ratio":
        0.70,
    "validation_ratio":
        0.15,
    "test_ratio":
        0.15,
    "best_iteration":
        int(best_iteration),
    "best_validation_mlogloss":
        float(best_validation_loss),
    **{
        key: float(value)
        for key, value in metrics.items()
    },
    "random_state":
        42,
    "note":
        "Physics-informed synthetic electrochemical dataset. "
        "Test set is kept separate from training and validation."
}
with open(metadata_path,"w", encoding="utf-8") as f:json.dump(metadata,f,ensure_ascii=False,indent=4)
# 19. RELOAD TEST
loaded_model = joblib.load(model_path)
loaded_encoder = joblib.load(encoder_path)
loaded_features = joblib.load(features_path)
assert (loaded_features==FEATURES)
assert (len(loaded_encoder.classes_)==num_classes)
sample = X_test.iloc[[0]]
pred_id = loaded_model.predict(sample)[0]
pred_name = loaded_encoder.inverse_transform([pred_id])[0]
confidence = float(np.max(loaded_model.predict_proba(sample)[0]))
# 20. FINAL OUTPUT
print()
print("=" * 70)
print("SAVED FILES")
print("=" * 70)
print(model_path)
print(encoder_path)
print(features_path)
print(os.path.join(MODEL_DIR,"values.csv"))
print(os.path.join(FIG_DIR,"loss_curve.png"))
print()
print(f"Reload test prediction : "f"{pred_name}")
print(f"Reload test confidence : "f"{confidence:.4f}")
print()
print("Training finished successfully.")