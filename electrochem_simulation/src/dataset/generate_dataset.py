import sys
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
                "ph": ph,
                "method": method,
                "seed": seed,
        }

        # Add 15 features
        for features_name in FEATURE_NAME:
                row[features_name] = features[features_name]
        return row

def generate_method_dataset(method):
        rows = []
        total = (len(SUBSTANCES) * len(CONCENTRATIONS) * len(PH_VALUES) * len(SEEDS))
        current_number = 0
        print()
        print("=" * 70)
        print(f"GENERATING {method} DATASET")
        print("=" *70)
        for substance_name in SUBSTANCES:
                for concentration in CONCENTRATIONS:
                        for ph in PH_VALUES:
                                for seed in SEEDS:
                                        current_number += 1
                                        row = generate_one_sample(substance_name=substance_name, concentration=concentration, ph=ph, method=method, seed=seed,)
                                        rows.append(row)
                                        if (current_number % 100 == 0 or current_number == total):
                                                print(
                                                        f"[{current_number: 04d}/{total}]"
                                                        f"{substance_name:<15}"
                                                        f"conc={concentration:<5}"
                                                        f"pH={ph:<3}"
                                                        f"seed={seed}"
                                                )
        return pd.DataFrame(rows)

# Save dataset
def save_dataset(df, method):
        method_dir = OUTPUT_DIR / method
        method_dir.mkdir(parents=True, exist_ok=True,)
        output_file=(method_dir / f"{method.lower()}_features.csv")
        df.to_csv(output_file, index=False,)

        print()
        print(f"Saved: {output_file}")
        print(f"Shape: {df.shape}")

# Main
def main():
        print()
        print("=" *70)
        print("ELECTROCHEMICAL SYNTHETIC DATASET GENERATOR")
        print("=" * 70)

        print()
        print("Concentrations:")
        print(CONCENTRATIONS)

        print()
        print("pH:")
        print(PH_VALUES)

        print()
        print("Seeds:")
        print(PH_VALUES)

        print()
        print("Seeds:")
        print(SEEDS)

        print()
        print("Methods:")
        print(METHODS)

# Generate each electrochemical method
for method in METHODS:
        df = generate_method_dataset(method)
        save_dataset(df, method)

        #Summary
        print()
        print("=" *70)
        print("DATASET GENERATION COMPLETE")
        print("=" *70)

        print()
        print(f"Output directory:\n{OUTPUT_DIR}")

# ENTRY POINT
if __name__ == "__main__":
        main()