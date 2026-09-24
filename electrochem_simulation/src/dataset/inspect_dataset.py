import sys
from pathlib import Path
import numpy as np
import pandas as pd

#Project path
PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
        sys.path.insert(0, str(PROJECT_ROOT))
DATASET_DIR = PROJECT_ROOT / "data" / "simulated"
METHODS = ["CV", "DVP", "SWV"]

# Check one method
def inspect_method(method):
        print()
        print(f"INSPECTING {method}")
        method_dir = DATASET_DIR / method
        feature_file = method_dir / f"{method.lower()}_features.csv"
        signal_file = method_dir / f"{method.lower()}_signals.npz"

        #Load feature dataset
        print()
        print("Loangding feature dataset")
        df = pd.read_csv(feature_file)
        print(f"Feature shape: {df.shape}")

        #Load signal dataset
        print()
        print("Loangding signal dataset")
        data = np.load(signal_file)
        voltage = data["voltage"]
        current = data["current"]
        print(f"Voltage shape: {voltage.shape}")
        print(f"Current shape: {current.shape}")

        #Check sample count
        print()
        print("Check sample count")
        if len(df) == len(voltage) == len(current):
                print("OK: Number of samples matches.")
        else:
                print("ERROR: Sample count does NOT match.")

        # Check NaN / InF
        print()
        print("Check NaN / InF")
        feature_values = df.select_dtypes(include=[np.number]).values
        print("Feature InF:", np.isnan(feature_values).sum())
        print("Feature InF:", np.isinf(feature_values).sum())
        print("Voltage NaN:", np.isnan(voltage).sum())
        print("Voltage InF:", np.isinf(voltage).sum())
        print("Current NaN:", np.isnan(current).sum())
        print("Current InF:", np.isinf(current).sum())

        # Substance distribution
        print()
        print("SUVSTANCE DISTRIBUTION")
        print(df["substance"].value_counts().sort_index())

        # Concentration distribution
        print()
        print("CONCENTRATION DISTRIBUTION")
        print(df["concentration"].value_counts().sort_index())

        #pH distribution
        print()
        print("pH DISTRIBUTION")
        print(df["pH"].value_counts().sort_index())

        # Signal statistics
        print()
        print("SIGNAL STATISTICS")
        print(f"Current minimum : {current.min():.8f}")
        print(f"Current maximum : {current.mean():.8f}")
        print(f"Current mean : {current.max():.8f}" )
        print(f"Current std : {current.std():.8f}")

        # Signal variation
        print()
        print("SIGNAL VARIATION")
        signal_mean = current.mean(axis=1)
        signal_std = current.std(axis=1)
        signal_max = current.max(axis=1)
        signal_min = current.min(axis=1)
        print(f"Mean of sample means : {signal_mean.mean():.8f}")
        print(f"Mean sample std : {signal_std.mean():.8f}")
        print(f"Global max : {signal_max.max():.8f}")
        print(f"Global min : {signal_min.min():.8f}")

        # First samples
        print()
        print("FIRST 5 SAMPLES")
        print(df[["substance", "concentration", "pH", "method", "seed"]].head())

# Main
def main():
        print()
        print("ELECTROCHEMICAL DATASET INSPECTION")
        print(f"Dataset directory:")
        print(DATASET_DIR)
        for method in METHODS:
                inspect_method(method)
        print()
        print("INSPECTION COMPLETE")

if __name__ == "__main__":
        main()