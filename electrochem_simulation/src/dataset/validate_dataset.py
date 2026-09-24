import sys
from pathlib import Path
import numpy as np
import pandas as pd

# PROJECT PATH
PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
        sys.path.insert(0, str(PROJECT_ROOT))

# DATASET PATH
DATASET_DIR = PROJECT_ROOT / "data" / "simulated"
METHODS = ["CV", "DVP", "SWV",]

# EXPECTED COLUMNS
METADATA_COLUMNS = ["substance", "concentration", "pH", "method", "seed",]
FEATURE_COLUMNS = [ "meanCurrent", "stdCurrent", "maxCurrent", "minCurrent", "meanVoltage", "voltageRange", "meanGradient", "maxGradient", "minGradient", "peakCurrent", "peakPotential", "peakWidth", "peakArea", "peakProminence", "peakSymmetry",]
EXPECTED_COLUMNS = (METADATA_COLUMNS+ FEATURE_COLUMNS)

# PRINT SECTION
def print_section(title):
        print()
        print("=" *70)
        print(title)
        print("=" * 70)

# LOAD DATASET
def load_dataset(method):
        filename = (f"{method.lower()}_features.csv")
        filepath = (DATASET_DIR / method / filename)
        print()
        print(f"Loading: {filepath}")
        if not filepath.exists():
                raise FileNotFoundError(f"Dataset not found:\n{filepath}")
        df = pd.read_csv(filepath)
        return df

# BASIC INFORMATION
def check_basic_info(df, method):
        print_section(f"{method} - BASIC INFORMATION")
        print(f"Rows: {len(df)}")
        print(f"Columns: {len(df.columns)}")
        print()
        print("Columns:")

        for i, column in enumerate(df.columns, start=1):
                print(f"{i:02d}.{column}")

# CHECK COLUMN STRUCTURE
def check_columns(df, method):
        print_section(f"{method} - COLUMN CHECK")
        actual_columns = list(df.columns)
        missing_columns = [column
                        for column in EXPECTED_COLUMNS
                        if column not in actual_columns]
        extra_columns = [column
                        for column in actual_columns
                        if column not in EXPECTED_COLUMNS]
        if not missing_columns:
                print("Missing columns : NONE")
        else:
                print("Missing columns:")
                for column in missing_columns:
                        print(f" - {column}")

        if not extra_columns:
                print("Extra columns : NONE")
        else:
                print("Extra columns:")
                for column in extra_columns:
                        print(f" - {column}")

# CHECK MISSING VALUES
def check_missing_values(df, method):
        print_section(f"{method} - MISSING VALUES")
        missing = df.isna().sum()
        total_missing = (missing.sum())
        print(f"Total missing values:"
              f"{total_missing}")
        if total_missing > 0:
                print()
                for column, count in missing.items():
                        if count > 0:
                                print(f"{column:<20} : {count}")
        else:
                print("Result: PASS")

# Check inf values
def check_infinite_values(df, method):
        print_section(f"{method} - INFINITE VALUES")
        numeric_df = df.reindex(columns=FEATURE_COLUMNS).apply(
                pd.to_numeric, errors="coerce"
        )
        inf_mask = np.isinf(numeric_df.to_numpy())
        total_inf = (inf_mask.sum())
        print(f"Total infinite values:"
              f"{total_inf}")
        if total_inf == 0:
                print("Result: PASS")
        else:
                print("Columns containing infinity:")
                for column in FEATURE_COLUMNS:
                        count = np.isinf(numeric_df[column].to_numpy()).sum()
                        if count > 0:
                                print(f"{column:<20} : {count}")

# CHECK DUPLICATES
def check_duplicates(df, method):
        print_section(f"{method} - DUPLICATE CHECK")
        duplicate_count = (df.duplicated().sum())
        print(f"Duplicate rows:"
              f"{duplicate_count}")
        if duplicate_count == 0:
                print("Result: PASS")
        else:
                print("Warning: Duplicate rows detected")

# CHECK SUBSTAMCES
def check_substances(df, method):
        print_section(f"{method} - SUBSTANCE DISTRBUTION")
        counts = (df["substance"].value_counts().sort_index())
        print(counts.to_string())
        print()
        print(f"Number of substances:"
              f"{df['substance'].nunique()}")

# CHECK CONCENTRATION
def check_concentration(df, method):
        print_section(f"{method} - CONCENTRATION DISTRBUTION")
        values = (sorted(df['concentration'].unique()))
        print("Concentrations:")
        print(values)
        print()
        print(f"Number of concentration levels:"
              f"{len(values)}")

# CHECK PH
def check_ph(df, method):
        print_section(f"{method} - pH DISTRIBUTION")
        values = (sorted(df["ph"].unique()))
        print("pH values:")
        print(values)
        print()
        print(f"Number of pH levels:"
              f"{len(values)}")

# CHECK SEEDS
def check_seed(df, method):
        print_section(f"{method} - SEED DISTRIBUTION")
        values = (sorted(df["seed"].unique()))
        print("Seeds:")
        print(values)
        print()
        print(f"Number of seeds:"
              f"{len(values)}")

# CHECK FEATURE STATISTICS
def check_feature_statistics(df, method):
        print_section(f"{method} - FEATURE STATISTICS")
        feature_df = df[FEATURE_COLUMNS]
        statistics = feature_df.describe().T
        print(statistics[["mean", "std", "min", "max",]].to_string())

# CHECK INVALID NUMERIC VALUES
def check_invalid_numeric(df, method):
        print_section(f"{method} - NUMERIC VALIDATION")
        problems = []
        for feature in FEATURE_COLUMNS:
                values = pd.to_numeric(df[feature], errors="coerce")
                invalid = (values.isna().sum())
                if invalid > 0:
                        problems.append((feature, invalid))
        if not problems:
                print("All feature columns are numeric.")
                print("Result: PASS")
        else:
                print("Invalid numeric values:")
                for feature, count in problems:
                        print(f"{feature:<20} : {count}")

# CHECK TARGET COMBINATIONS
def check_combinations(df, method):
        print_section(f"{method} - CONDITION COMBINATIONS")
        combinations = (df[["substance", "concentration", "ph", "seed",]].drop_duplicates())
        print(f"Unique condition combinations:"
              f"{len(combinations)}")
        expected = (df["substance"].nunique() * df["concentration"].nunique() * df["ph"].nunique() * df["seed"].nunique())
        print(f"Expected combinations"
              f"{expected}")
        if len(combinations) == expected:
                print("Result: PASS")
        else:
                print("Warning: combination count"
                      "does not match expectation")

# RUN VALIDATION
def validate_method(method):
        df = load_dataset(method)
        check_basic_info(df, method)
        check_columns(df, method)
        check_missing_values(df, method)
        check_infinite_values(df, method)
        check_duplicates(df, method)
        check_substances(df, method)
        check_concentration(df, method)
        check_ph(df, method)
        check_seed(df, method)
        check_feature_statistics(df, method)
        check_invalid_numeric(df, method)
        check_combinations(df, method)
        return df

# MAIN
def main():
        print()
        print("=" *70)
        print("ELECTROCHEM DATASET VALIDATION")
        print("=" *70)
        print()
        print(f"Dataset directory:\n"
                f"{DATASET_DIR}")
        datasets = {}
        for method in METHODS:
                datasets[method] = validate_method(method)

        # FINAL SUMMARY
        print_section("FINAL DATASET SUMMARY")
        for method, df in datasets.items():
                print(f"{method:<5}"
                        f"rows={len(df):<5}"
                        f"columns={len(df.columns)}")
        print()
        print("=" * 70)
        print("VALIDATION COMPLETE")
        print("=" *70)

# ENTRY POINT
if __name__ == "__main__":
        main()

