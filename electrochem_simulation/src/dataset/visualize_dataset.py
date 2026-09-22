import sys
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Project path
PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
        sys.path.insert(0, str(PROJECT_ROOT))

# Dataset path
DATASET_DIR = (PROJECT_ROOT / "data" / "simulated")

# Output path
ANALYSIS_DIR = (PROJECT_ROOT / "data" / "analysis")
SUBSTANCE_DIR = (ANALYSIS_DIR / "substance")
CONCENTRATION_DIR = (ANALYSIS_DIR / "concentration")
PH_DIR = (ANALYSIS_DIR / "ph")
CORRELATION_DIR = (ANALYSIS_DIR / "correlation")

# Create directories
for directory in [ANALYSIS_DIR, SUBSTANCE_DIR, CONCENTRATION_DIR, PH_DIR, CORRELATION_DIR,]:
        directory.mkdir(parents=True, exist_ok=True)

# Methods
METHODS = ["CV", "DVP", "SWV",]

#features
FEATURE_COLUMNS = [   "meanCurrent", "stdCurrent", "maxCurrent", "minCurrent", "meanVoltage", "voltageRange", "meanGradient", "maxGradient", "minGradient", "peakCurrent", "peakPotential", "peakWidth", "peakArea", "peakProminence", "peakSymmetry",]

#Load dataset
def load_dataset(method):
        filepath = (DATASET_DIR / method / f"{method.lower()}_features.csv")
        print()
        print(f"Loanding{method}:")
        print(filepath)
        if not filepath.exists():
                raise FileNotFoundError(f"Dataset not found: \n(filepath)")
        df = pd.read_csv(filepath)
        print(f"Shape: {df.shape}")
        return df

# Plot feature by substance
def plot_feature_by_substance(df, method, feature,):
        plt.figure(figsize=(11, 6))
        substances = sorted(df["substance"].unique())
        data = []
        labels = []
        for substance in substances:
                values = df.loc[df["substance"] == substance, feature]
                data.append(values)
                labels.append(substance)
        plt.boxplot(data, tick_labels=labels)
        plt.xlabel("Substance")
        plt.ylabel(feature)
        plt.title(f"{method} - {feature} by Substance")
        plt.xticks(rotation=30, ha="right")
        plt.tight_layout()
        output_file = (SUBSTANCE_DIR / f"{method}_{feature}_substance.png")
        plt.savefig(output_file, dpi=150)
        plt.close()

# Plot feature by concentration
def plot_feature_by_concentration(df, method, feature,):
        plt.figure(figsize=(10, 6))
        substances = sorted(df["substance"].unique())
        for substance in substances:
                subset = df[df["substance"] == substance]
                grouped = (subset.groupby("concentration")[feature].mean())
                plt.plot(grouped.index, grouped.values, marker="o", label=substance)
        plt.xlabel("Concentration")
        plt.ylabel(feature)
        plt.title(f"{method} - {feature} vs Concentration")
        plt.legend(fontsize=8)
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        output_file = (CONCENTRATION_DIR / f"{method}_{feature}_concentration.png")
        plt.savefig(output_file, dpi=150)
        plt.close()

# Plot feature bt ph
def plot_feature_by_ph(df, method, feature,):
        plt.figure(figsize=(10, 6))
        substances = sorted(df["substance"].unique())
        for substance in substances:
                subset = df[df["substance"] == substance]
                grouped = (subset.groupby("ph")[feature].mean())
                plt.plot(grouped.index, grouped.values, marker="o", label=substance)
        plt.xlabel("ph")
        plt.ylabel(feature)
        plt.title(f"{method} - {feature} vs ph")
        plt.legend(fontsize=8)
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        output_file = (PH_DIR / f"{method}_{feature}_ph.png")
        plt.savefig(output_file, dpi=150)
        plt.close()

# Correlation matrix
def plot_correlation(df, method,):
        correlation = (df[FEATURE_COLUMNS].corr())
        plt.figure(figsize=(12, 10))
        image = plt.imshow(correlation, aspect="auto", interpolation="nearest")
        plt.colorbar(image, label = "Correlation")
        plt.xticks(range(len(FEATURE_COLUMNS)), FEATURE_COLUMNS, rotation=90)
        plt.yticks(range(len(FEATURE_COLUMNS)), FEATURE_COLUMNS)
        plt.title(f"{method} - Feature Correlation Matrx")
        plt.tight_layout()
        output_file = (CORRELATION_DIR / f"{method}_correlation.png")
        plt.savefig(output_file, dpi=150)
        plt.close()
        return correlation

# Save correlation table
def save_correlation_table(correlation, method):
        output_file = (CORRELATION_DIR / f"{method}_correlation.csv")
        correlation.to_csv(output_file)

# Print high correlations
def print_high_correlations(correlation, method,):
        print()
        print(f"{method} - HIGH FEATURE CORRELATIONS")
        pairs = []
        for i in range(len(correlation.columns)):
                for j in range(i + 1, len(correlation.columns)):
                        feature_a = (correlation.columns[i])
                        feature_b = (correlation.columns[j])
                        value = correlation.iloc[i, j]
                        if abs(value) >= 0.90:
                                pairs.append((feature_a, feature_b, value))
        pairs.sort(key=lambda x: abs(x[2]), reverse=True)
        if not pairs:
                print("No correlation >= 0.90")
        else:
                for(feature_a, feature_b, value) in pairs:
                        print(f"{feature_a:<20}"
                              f"{feature_b:<20}"
                              f"{value: .4f}")

# Run visualization
def visualize_method(method):
        df = load_dataset(method)
        print()
        print(f"VISUALIZING{method}")

        # Generate plots
        for feature in FEATURE_COLUMNS:
                print(f"Processing: {feature}")
                plot_feature_by_substance(df, method, feature)
                plot_feature_by_concentration(df, method, feature)
                plot_feature_by_ph(df, method, feature)

        # Correlation
        correlation = plot_correlation(df, method)
        save_correlation_table(correlation, method)
        print_high_correlations(correlation, method)

# Main
def main():
        print()
        print("ELECREOCHEMICAL DATASET VISUALIZATION")
        print()
        print(f"Dataset:\v{DATASET_DIR}")
        print()
        print(f"Output:\n{ANALYSIS_DIR}")

        # Run all methods
        for method in METHODS:
                visualize_method(method)

        # Summary
        print()
        print("VISUALIZATION COMPLETE")
        print()
        print(f"Analysis directory:\n"
              f"{ANALYSIS_DIR}")

# Entry point
if __name__ =="__main__":
        main()

