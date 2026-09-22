import sys
import numpy as np
from pathlib import Path
import pandas as pd

# Project path
PROJECT_ROOT = Path(__file__). resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
        sys.path.insert(0, str(PROJECT_ROOT))

# Import project modules
from config.substances import SUBSTANCES
from src.simulation.signal_models import (
        generate_cv,
        generate_dpv,
        generate_swv
)
from src.features.feature_extraction import (
        extract_feature,
        FEATURE_NAME,
)

# Dataset configuration
CONCENTRATIONS = [0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0]
PH_VALUES = [6.0, 6.5, 7.0, 7.5, 8.0]
SEEDS = list(range(10))
METHODS = ["CV", "DVP", "SWV"]

#Output directory
OUTPUT_DIR = PROJECT_ROOT / "data" / "simulated"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

#Generate one sample
def generate_one_sample(substance_name, concentration, ph, method, seed,):
        params = SUBSTANCES[substance_name]
        if method =="CV":
                voltage, current = generate_cv(params=params, concentration=concentration, ph=ph, seed=seed,)
        elif method == "DVP":
                voltage, current = generate_dpv(params=params, concentration=concentration, ph=ph, seed=seed,)
        elif method == "SWV":
                voltage, current = generate_swv(params=params, concentration=concentration, ph=ph, seed=seed,)
        else:
                raise ValueError(f"Unknown method: {method}")

        # Extract 15 features
        features = extract_feature(voltage, current,)

        # Build one dataset row
        row = {
                "substance": substance_name,
                "concentration": concentration,
                "pH": ph,
                "method": method,
                "seed": seed,
        }

        # Add 15 features
        for features_name in FEATURE_NAME:
                row[features_name] = features[features_name]
        return row, voltage, current

def generate_method_dataset(method):
        rows = []
        voltage_signals = []
        current_signals = []
        total = (len(SUBSTANCES) * len(CONCENTRATIONS) * len(PH_VALUES) * len(SEEDS))
        current_number = 0
        print()
        print(f"GENERATING {method} DATASET")
        for substance_name in SUBSTANCES:
                for concentration in CONCENTRATIONS:
                        for ph in PH_VALUES:
                                for seed in SEEDS:
                                        current_number += 1
                                        (row, voltage, current) = generate_one_sample(substance_name=substance_name, concentration=concentration, ph=ph, method=method, seed=seed,)
                                        rows.append(row)
                                        voltage_signals.append(voltage)
                                        current_signals.append(current)
                                        if (current_number % 100 == 0 or current_number == total):
                                                print(
                                                        f"[{current_number: 04d}/{total}]"
                                                        f"{substance_name:<15}"
                                                        f"conc={concentration:<5}"
                                                        f"pH={ph:<3}"
                                                        f"seed={seed}"
                                                )
        voltage_signals = np.asarray(voltage_signals, dtype=np.float32,)
        current_signals = np.asarray(current_signals, dtype=np.float32,)
        df = pd.DataFrame(rows)
        print()
        print(f"Feature dataframe shape: {df.shape}")
        print(f"Curent signal shape:"
              f"{current_signals.shape}")
        if len(df) != len(voltage_signals):
                raise ValueError("Number of feature rows and signals do not match!")
        if len(df) != len(current_signals):
                raise ValueError("Number of feature rows and signals do not match!")
        if not np.all(np.isfinite(voltage_signals)):
                raise ValueError("Voltage contains NaN or Inf!")
        if not np.all(np.isfinite(current_signals)):
                raise ValueError("Current contains NaN or Inf")
        return (df, voltage_signals, current_signals,)

# Save dataset
def save_dataset(df, voltage_signals, current_signals, method,):
        method_dir = OUTPUT_DIR / method
        method_dir.mkdir(parents=True, exist_ok=True,)
        feature_file=(method_dir / f"{method.lower()}_features.csv")
        df.to_csv(feature_file, index=False,)
        signal_file = (method_dir / f"{method.lower()}_signals.npz")
        np.savez_compressed(signal_file, voltage=voltage_signals, current=current_signals,)

        print()
        print(f"Saved features: "
                f"{feature_file}")
        print(f"Saved signals: "
                f"{signal_file}")
        print(f"Feature shape: "
                f"{df.shape}")
        print(f"Voltage shape: "
                f"{voltage_signals.shape}")
        print(
                f"Current shape: "
                f"{current_signals.shape}")

# Main
def main():
        print()
        print("ELECTROCHEMICAL SYNTHETIC DATASET GENERATOR")
        print()
        print("Substances:")
        print(list(SUBSTANCES.keys()))
        print()
        print("Concentrations:")
        print(CONCENTRATIONS)
        print()
        print("pH:")
        print(PH_VALUES)
        print()
        print("Seeds:")
        print(SEEDS)
        print()
        print("Methods:")
        print(METHODS)

        # Generate each method
        for method in METHODS:
                (df, voltage_signals, current_signals,) = generate_method_dataset(method)
                save_dataset(df, voltage_signals, current_signals, method,)

        # Complete
        print()
        print("=" * 70)
        print("DATASET GENERATION COMPLETE")
        print()
        print(f"Output directory:\n"
        f"{OUTPUT_DIR}")

# ENTRY POINT
if __name__ == "__main__":
        main()