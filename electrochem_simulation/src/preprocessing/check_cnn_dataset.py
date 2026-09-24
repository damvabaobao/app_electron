import sys
from pathlib import Path
import numpy as np
import pandas as pd

# PROJECT PATH
PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
        sys.path.insert(0, str(PROJECT_ROOT))

# DATASET PATH
CNN_DATASET_DIR = PROJECT_ROOT / "data" / "cnn_ready"
METHODS = ["CV", "DVP", "SWV"]
SUBSTANCES = ["dopamine", "uric_acid", "ascorbic_acid", "glucose", "copper", "aluminum",]
LABEL_MAP = {substance: index for index, substance in enumerate(SUBSTANCES)}

# LOAD DATASET
def load_method(method):
        method_dir = CNN_DATASET_DIR / method
        print()
        print(f"CHECKING {method}")
        print(f"Directory:")
        print(method_dir)
        # Files
        X_train_file = method_dir / "X_train.npy"
        X_val_file = method_dir / "X_val.npy"
        X_test_file = method_dir / "X_test.npy"
        y_train_file = method_dir / "y_train.npy"
        y_val_file = method_dir / "y_val.npy"
        y_test_file = method_dir / "y_test.npy"
        metadata_file = method_dir / "metadata.csv"

        files = [X_train_file, X_val_file,X_test_file, y_train_file, y_val_file, y_test_file, metadata_file,]
        for file in files:
                if not file.exists():
                        raise FileNotFoundError(f"Missing file:\n{file}")
        # Load arrays
        X_train = np.load(X_train_file)
        X_val = np.load(X_val_file)
        X_test = np.load(X_test_file)
        y_train = np.load(y_train_file)
        y_val = np.load(y_val_file)
        y_test = np.load(y_test_file)

        # Load metadata
        metadata = pd.read_csv(metadata_file)
        return (X_train, X_val, X_test, y_train, y_val, y_test, metadata,)

# CHECK SHAPES
def check_shapes(X_train, X_val, X_test, y_train, y_val, y_test, metadata,):
        print()
        print("SHAPES")
        print(f"X_train : {X_train.shape}")
        print(f"y_train : {y_train.shape}")
        print(f"X_val   : {X_val.shape}")
        print(f"y_val   : {y_val.shape}")
        print(f"X_test  : {X_test.shape}")
        print(f"y_test  : {y_test.shape}")
        print(f"Metadata: {metadata.shape}")

        # X/y matching
        if len(X_train) != len(y_train):
                raise ValueError("X_train and y_train sample count mismatch!")
        if len(X_val) != len(y_val):
                raise ValueError("X_val and y_val sample count mismatch!")
        if len(X_test) != len(y_test):
                raise ValueError("X_test and y_test sample count mismatch!")
        print("Shape consistency: OK")

# CHECK DATA TYPES
def check_dtype(X_train, X_val, X_test, y_train, y_val, y_test,):
        print()
        print("DATA TYPES")
        print(f"X_train dtype : {X_train.dtype}")
        print(f"X_val dtype   : {X_val.dtype}")
        print(f"X_test dtype  : {X_test.dtype}")
        print(f"y_train dtype : {y_train.dtype}")
        print(f"y_val dtype   : {y_val.dtype}")
        print(f"y_test dtype  : {y_test.dtype}")

# CHECK NAN / INF
def check_nan_inf(X_train, X_val, X_test, y_train, y_val, y_test,):
        print()
        print("NAN / INF CHECK")
        datasets = {"X_train": X_train, "X_val": X_val, "X_test": X_test, "y_train": y_train, "y_val": y_val, "y_test": y_test,}

        for name, data in datasets.items():
                nan_count = np.isnan(data).sum()
                inf_count = np.isinf(data).sum()

        print(f"{name:<10} "
            f"NaN={nan_count:<6} "
            f"Inf={inf_count}"
        )
        if nan_count > 0:
                raise ValueError(
                        f"{name} contains NaN!")
        if inf_count > 0:
                raise ValueError(f"{name} contains Inf!")
        print("NaN / Inf check: OK")
# CHECK LABELS
def check_labels(y_train, y_val, y_test,):
        print()
        print("LABEL CHECK")
        valid_labels = set(range(len(SUBSTANCES)))
        for name, labels in [("Train", y_train), ("Validation", y_val), ("Test", y_test),]:
                unique_labels = set(labels.tolist())
                print()
                print(name)
        for label in sorted(unique_labels):
                count = np.sum(labels == label)
                substance = SUBSTANCES[label]

                print(
                f"{label} -> "
                f"{substance:<15} "
                f"{count}")
        unknown = unique_labels - valid_labels
        if unknown:
                raise ValueError(f"{name} contains unknown labels: "f"{unknown}")
        print()
        print("Label check: OK")

# CHECK SIGNAL RANGE
def check_signal_range(X_train, X_val, X_test,):
        print()
        print("SIGNAL RANGE")
        datasets = {"Train": X_train, "Validation": X_val, "Test": X_test,}
        for name, data in datasets.items():
                print()
                print(name)
                print(f"Minimum : {data.min():.8f}")
                print(f"Maximum : {data.max():.8f}")
                print(f"Mean    : {data.mean():.8f}")
                print(f"Std     : {data.std():.8f}")

# CHECK METADATA
def check_metadata(metadata):
        print()
        print("METADATA CHECK")
        print(f"Metadata samples: " f"{len(metadata)}")
        required_columns = ["substance", "concentration", "pH", "method", "seed", "split", "label",]
        for column in required_columns:
                if column not in metadata.columns:
                        raise ValueError(f"Missing metadata column: " f"{column}")
        print("Required columns: OK")

        print()
        print("Split distribution")
        print(metadata["split"].value_counts().sort_index())
        print()
        print("Substance distribution")
        print(metadata["substance"].value_counts().sort_index())
        print()
        print("Split × Substance")
        table = pd.crosstab(metadata["split"], metadata["substance"],)
        print(table)

# CHECK DUPLICATES
def check_duplicates(X_train, X_val, X_test,):
        print()
        print("DUPLICATE CHECK")
        train_unique = len(np.unique(X_train, axis=0))
        val_unique = len(np.unique(X_val, axis=0))
        test_unique = len(np.unique(X_test, axis=0))
        print(f"Train unique samples: "f"{train_unique}/{len(X_train)}")
        print(f"Val unique samples  : "f"{val_unique}/{len(X_val)}")
        print(f"Test unique samples : "f"{test_unique}/{len(X_test)}")
# CHECK ONE METHOD
def inspect_method(method):
        (X_train, X_val, X_test, y_train, y_val, y_test, metadata,) = load_method(method)
        check_shapes(X_train, X_val, X_test, y_train, y_val, y_test, metadata,)
        check_dtype(X_train, X_val, X_test, y_train, y_val, y_test,)
        check_nan_inf(X_train, X_val, X_test, y_train, y_val, y_test,)
        check_labels(y_train, y_val, y_test,)
        check_signal_range(X_train, X_val, X_test,)
        check_metadata(metadata)
        check_duplicates(X_train, X_val, X_test,)

# MAIN
def main():
        print()
        print("CNN 1D DATASET INSPECTION")
        print()
        print("Dataset:")
        print(CNN_DATASET_DIR)
        print()
        print("Methods:")
        print(METHODS)
        for method in METHODS:
                inspect_method(method)
        print()
        print("CNN DATASET INSPECTION COMPLETE")

# ENTRY POINT
if __name__ == "__main__":
        main()