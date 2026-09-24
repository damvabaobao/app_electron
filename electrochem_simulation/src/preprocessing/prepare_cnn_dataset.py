import sys
from pathlib import Path
import numpy as np
import pandas as pd

#Project path
PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
        sys.path.insert(0, str(PROJECT_ROOT))

# Dataset path
RAW_DATA_DIR = PROJECT_ROOT / "data" / "simulated"
OUTPUT_DIR = PROJECT_ROOT / "data" / "cnn_ready"

# Methods
METHODS = ["CV", "DVP", "SWV"]

# SUBSTANCE LABEL
SUBSTANCES = ["dopamine", "uric_acid", "ascorbic_acid", "glucose", "copper", "aluminum",]
LABEL_MAP = {substance: index for index, substance in enumerate(SUBSTANCES)}

# Train / Validation / Test
TRAIN_RATIO = 0.70
VAL_RATIO = 0.15
TEST_RATIO = 0.15

# Load data
def load_method_dataset(method):
        method_dir = RAW_DATA_DIR / method
        feature_file = (method_dir / f"{method.lower()}_features.csv")
        signal_file = (method_dir / f"{method.lower()}_signals.npz")
        print()
        print(f"LOADING {method}")
        print(f"Feature file:")
        print(feature_file)
        print(f"Signal file:")
        print(signal_file)
        if not feature_file.exists():
                raise FileNotFoundError(f"Feature dataset not found:\n{feature_file}")
        if not signal_file.exists():
                raise FileNotFoundError(f"Signal dataset not found:\n{signal_file}")
        df = pd.read_csv(feature_file)
        signals = np.load(signal_file)
        voltage = signals["voltage"]
        current = signals["current"]
        print()
        print(f"Feature shape : {df.shape}")
        print(f"Voltage shape : {voltage.shape}")
        print(f"Current shape : {current.shape}")
        return df, voltage, current

# Validate data
def validate_dataset(df, voltage, current, method):
        print()
        print(f"VALIDATING {method}")

        # Sample count
        if len(df) != len(current):
                raise ValueError(f"{method}: feature rows and voltage signals"
                                 f"do not match!")
        if len(df) != len(voltage):
                raise ValueError(f"{method}: feature rows and voltage signals"
                                 f"do not match!")
        print("Sample count: OK")

        # NaN / InF
        if df.isna().any().any():
                raise ValueError(f"{method}: feature dataset contains NaN!")
        if not np.all(np.isfinite(voltage)):
                raise ValueError(f"{method}: voltage contains NaN or InF!")
        if not np.all(np.isfinite(current)):
                raise ValueError(f"{method}: current contains NaN or InF!")
        print("NaN / InF check: OK!")

        #Substance
        unlnown_substances = set(df["substance"]) - set(SUBSTANCES)
        if unlnown_substances:
                raise ValueError(f"Unknown substances: {unlnown_substances}")
        print("Substance labels: OK!")

        # Label distribution
        print()
        print("SUBSTANCE DISTRIBUTION")
        print(df["substance"].value_counts().sort_index())

# Normalize signal
def normalize_signal(current):
        current = current.astype(np.float32)
        minimum = np.min(current, axis=1, keepdims=True)
        maximum = np.max(current, axis=1, keepdims=True)
        signal_range = maximum - minimum

        # Avoid division by zero
        signal_range[signal_range < 1e-12] = 1.0
        normalized = (current - minimum) / signal_range
        return normalized.astype(np.float32)

# Create labels
def create_labels(df):
        labels = np.array([LABEL_MAP[substance] for substance in df["substance"]], dtype=np.int64)
        return labels

#Staeatified split
def stratified_split(df):
        train_indices =[]
        val_indices =[]
        test_indices =[]
        rng = np.random.default_rng(42)
        for substance in SUBSTANCES:
                indices = np.where(df["substance"].values == substance)[0]
                rng.shuffle(indices)
                n = len(indices)
                n_train = int(n * TRAIN_RATIO)
                n_val = int(n * VAL_RATIO)
                train_part = indices[: n_train]
                val_part = indices[n_train: n_train + n_val]
                test_part = indices[n_train + n_val:]
                train_indices.extend(train_part)
                val_indices.extend(val_part)
                test_indices.extend(test_part)
        train_indices = np.array(train_indices, dtype=np.int64)
        val_indices = np.array(val_indices, dtype=np.int64)
        test_indices = np.array(test_indices, dtype=np.int64)

        # Shuffle each split
        rng.shuffle(train_indices)
        rng.shuffle(val_indices)
        rng.shuffle(test_indices)
        return (train_indices, val_indices, test_indices)

# Save dataset
def save_dataset(method, X, y, df, train_indices, val_indices, test_indices):
        output_dir = OUTPUT_DIR / method
        output_dir.mkdir(parents=True, exist_ok=True)

        # Split signals
        X_train = X[train_indices]
        X_val = X[val_indices]
        X_test = X[test_indices]

        # Split labels
        y_train = y[train_indices]
        y_val = y[val_indices]
        y_test = y[test_indices]

        # Save numpy arrays
        np.save(output_dir / "X_train.npy", X_train)
        np.save(output_dir / "X_val.npy", X_val)
        np.save(output_dir / "X_test.npy", X_test)
        np.save(output_dir / "y_train.npy", y_train)
        np.save(output_dir / "y_val.npy", y_val)
        np.save(output_dir / "y_test.npy", y_test)

        # Save metadata
        metadata_train = df.iloc[train_indices].copy()
        metadata_val = df.iloc[val_indices].copy()
        metadata_test = df.iloc[test_indices].copy()
        metadata_train["split"] = "train"
        metadata_val["split"] = "val"
        metadata_test["split"] = "test"

        metadata = pd.concat([metadata_train, metadata_val, metadata_test], ignore_index=True)
        metadata["label"] = metadata["substance"].map(LABEL_MAP)
        metadata.to_csv(output_dir / "metadata.csv", index=False)

        # Print shapes
        print()
        print("SAVED DATASET")
        print(f"Output : {output_dir}")

        print()
        print("Train:")
        print(f"X_train : {X_train.shape}")
        print(f"y_train : {y_train.shape}")
        print()
        print("Validation:")
        print(f"X_val : {X_val.shape}")
        print(f"y_val : {y_val.shape}")
        print()
        print(f"X_test : {X_test.shape}")
        print(f"y_test : {y_test.shape}")

# Prepare one method
def prepare_method(method):
        df, voltage, current = load_method_dataset(method)
        validate_dataset(df, voltage, current, method)
        print()
        print("NORMALIZING CURRENT SIGNAL")
        X = normalize_signal(current)
        print(f"Normalize signal shape: {X.shape}")
        print(f"Normalized minimun: {X.min():.6f}")
        print(f"Normalized maximum: {X.max():.6f}")

        # Labels
        y = create_labels(df)
        print()
        print("LABEL MAP")
        for substance, label in LABEL_MAP.items():
                print(f"{label} -> {substance}")

        # Split
        (train_indices, val_indices, test_indices) = stratified_split(df)
        print()
        print("SPLIT")
        print(f"Train : {len(train_indices)}")
        print(f"Validation : {len(val_indices)}")
        print(f"Test : {len(test_indices)}")

        # Save
        save_dataset(method=method, X=X, y=y, df=df, train_indices=train_indices, val_indices=val_indices, test_indices=test_indices)

# Main
def main():
        print()
        print("CNN 1D DATASET PREPARATION")
        print()
        print(f"Raw dataset:")
        print(RAW_DATA_DIR)
        print()
        print(f"Output dataset:")
        print(OUTPUT_DIR)
        print()
        print("Methods:")
        print(METHODS)
        for method in METHODS:
                prepare_method(method)
        print()
        print("CNN DATASET PREPARATION COMPLETE")
        print()
        print(f"Output directory:\n{OUTPUT_DIR}")

# Entry point
if __name__ == "__main__":
        main()



