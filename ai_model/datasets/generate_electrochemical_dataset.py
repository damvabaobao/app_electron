import numpy as np
import pandas as pd

FEATURES = [
    "meanCurrent", "stdCurrent", "maxCurrent", "minCurrent",
    "meanVoltage", "voltageRange", "meanGradient", "maxGradient",
    "minGradient", "peakCurrent", "peakPotential", "peakWidth",
    "peakArea", "peakProminence", "peakSymmetry"
]

# The complete 100-substance profile table is embedded below.
# Copy the SUBSTANCES list from this generated file if you want to edit
# chemical profiles manually.

SUBSTANCES = [('glucose', 'carbohydrate', 0.55, 0.38, 0.105, 0.96, 0.35, 0.012, 0.55), ('fructose', 'carbohydrate', 0.48, 0.42, 0.11, 0.94, 0.32, 0.013, 0.55), ('sucrose', 'carbohydrate', 0.34, 0.46, 0.12, 0.98, 0.3, 0.014, 0.52), ('lactose', 'carbohydrate', 0.39, 0.44, 0.115, 0.97, 0.31, 0.014, 0.53), ('maltose', 'carbohydrate', 0.43, 0.41, 0.112, 0.96, 0.31, 0.013, 0.54), ('galactose', 'carbohydrate', 0.46, 0.4, 0.108, 0.95, 0.32, 0.013, 0.55), ('ribose', 'carbohydrate', 0.42, 0.37, 0.102, 0.94, 0.3, 0.014, 0.54), ('xylose', 'carbohydrate', 0.4, 0.39, 0.106, 0.94, 0.3, 0.014, 0.54), ('mannose', 'carbohydrate', 0.45, 0.4, 0.109, 0.95, 0.31, 0.013, 0.54), ('arabinose', 'carbohydrate', 0.38, 0.38, 0.108, 0.94, 0.3, 0.014, 0.54), ('ascorbic_acid', 'organic_acid', 1.35, 0.18, 0.075, 0.86, 0.42, 0.018, 0.45), ('citric_acid', 'organic_acid', 0.78, 0.31, 0.095, 0.82, 0.36, 0.016, 0.43), ('acetic_acid', 'organic_acid', 0.28, 0.53, 0.125, 0.74, 0.22, 0.017, 0.42), ('lactic_acid', 'organic_acid', 0.43, 0.48, 0.112, 0.76, 0.27, 0.016, 0.44), ('malic_acid', 'organic_acid', 0.67, 0.35, 0.091, 0.8, 0.34, 0.016, 0.44), ('tartaric_acid', 'organic_acid', 0.72, 0.34, 0.09, 0.81, 0.35, 0.015, 0.44), ('oxalic_acid', 'organic_acid', 0.82, 0.29, 0.082, 0.83, 0.36, 0.015, 0.43), ('succinic_acid', 'organic_acid', 0.63, 0.39, 0.096, 0.79, 0.33, 0.016, 0.44), ('fumaric_acid', 'organic_acid', 0.74, 0.36, 0.088, 0.78, 0.34, 0.016, 0.43), ('benzoic_acid', 'organic_acid', 0.91, 0.58, 0.082, 0.7, 0.38, 0.018, 0.42), ('dopamine', 'biomolecule', 1.55, 0.21, 0.065, 0.72, 0.45, 0.02, 0.46), ('uric_acid', 'biomolecule', 1.2, 0.34, 0.073, 0.75, 0.41, 0.019, 0.45), ('urea', 'biomolecule', 0.24, 0.62, 0.125, 0.8, 0.2, 0.018, 0.5), ('creatinine', 'biomolecule', 0.58, 0.51, 0.09, 0.78, 0.3, 0.017, 0.47), ('glycine', 'amino_acid', 0.49, 0.55, 0.095, 0.82, 0.28, 0.016, 0.5), ('alanine', 'amino_acid', 0.43, 0.58, 0.098, 0.82, 0.26, 0.016, 0.5), ('valine', 'amino_acid', 0.46, 0.61, 0.101, 0.8, 0.27, 0.017, 0.5), ('leucine', 'amino_acid', 0.45, 0.63, 0.103, 0.79, 0.27, 0.017, 0.5), ('isoleucine', 'amino_acid', 0.44, 0.64, 0.104, 0.79, 0.26, 0.017, 0.5), ('serine', 'amino_acid', 0.48, 0.56, 0.096, 0.83, 0.28, 0.016, 0.5), ('threonine', 'amino_acid', 0.47, 0.59, 0.098, 0.82, 0.27, 0.016, 0.5), ('cysteine', 'amino_acid', 0.92, 0.28, 0.078, 0.76, 0.34, 0.02, 0.46), ('methionine', 'amino_acid', 0.76, 0.43, 0.082, 0.75, 0.31, 0.019, 0.47), ('phenylalanine', 'amino_acid', 0.66, 0.49, 0.086, 0.76, 0.3, 0.018, 0.48), ('tyrosine', 'amino_acid', 1.02, 0.31, 0.07, 0.74, 0.38, 0.019, 0.46), ('tryptophan', 'amino_acid', 1.08, 0.37, 0.069, 0.73, 0.39, 0.02, 0.46), ('glutamic_acid', 'amino_acid', 0.62, 0.45, 0.092, 0.84, 0.31, 0.017, 0.47), ('aspartic_acid', 'amino_acid', 0.59, 0.43, 0.091, 0.84, 0.3, 0.017, 0.47), ('lysine', 'amino_acid', 0.41, 0.66, 0.105, 0.86, 0.24, 0.017, 0.51), ('arginine', 'amino_acid', 0.44, 0.69, 0.108, 0.87, 0.24, 0.017, 0.51), ('caffeine', 'food_drug', 1.0, 0.72, 0.08, 0.68, 0.35, 0.018, 0.47), ('paracetamol', 'food_drug', 1.18, 0.56, 0.073, 0.7, 0.39, 0.019, 0.46), ('acetaminophen', 'food_drug', 1.18, 0.56, 0.073, 0.7, 0.39, 0.019, 0.46), ('ibuprofen', 'food_drug', 0.82, 0.66, 0.09, 0.67, 0.33, 0.018, 0.44), ('aspirin', 'food_drug', 0.95, 0.6, 0.083, 0.69, 0.35, 0.019, 0.44), ('sodium_benzoate', 'food_additive', 0.88, 0.58, 0.078, 0.76, 0.34, 0.017, 0.45), ('potassium_sorbate', 'food_additive', 0.84, 0.55, 0.082, 0.88, 0.32, 0.017, 0.45), ('sorbic_acid', 'food_additive', 0.79, 0.52, 0.084, 0.76, 0.31, 0.017, 0.45), ('citric_sodium', 'food_additive', 0.52, 0.38, 0.105, 0.92, 0.25, 0.015, 0.46), ('monosodium_glutamate', 'food_additive', 0.55, 0.47, 0.104, 1.0, 0.25, 0.015, 0.49), ('sodium_chloride', 'electrolyte', 0.16, 0.02, 0.145, 1.45, 0.11, 0.009, 0.5), ('potassium_chloride', 'electrolyte', 0.18, 0.04, 0.14, 1.55, 0.12, 0.009, 0.5), ('calcium_chloride', 'electrolyte', 0.21, 0.08, 0.138, 1.62, 0.14, 0.01, 0.5), ('magnesium_chloride', 'electrolyte', 0.19, 0.11, 0.142, 1.48, 0.13, 0.01, 0.5), ('sodium_bicarbonate', 'electrolyte', 0.24, 0.15, 0.135, 1.22, 0.15, 0.011, 0.5), ('potassium_bicarbonate', 'electrolyte', 0.25, 0.17, 0.133, 1.2, 0.15, 0.011, 0.5), ('sodium_carbonate', 'electrolyte', 0.29, 0.2, 0.13, 1.3, 0.17, 0.011, 0.51), ('potassium_carbonate', 'electrolyte', 0.3, 0.22, 0.128, 1.34, 0.18, 0.011, 0.51), ('ammonium_chloride', 'electrolyte', 0.22, 0.1, 0.137, 1.18, 0.14, 0.01, 0.5), ('ammonium_sulfate', 'electrolyte', 0.24, 0.13, 0.139, 1.28, 0.15, 0.01, 0.5), ('sodium_sulfate', 'electrolyte', 0.2, 0.09, 0.141, 1.38, 0.13, 0.01, 0.5), ('potassium_sulfate', 'electrolyte', 0.22, 0.12, 0.139, 1.42, 0.14, 0.01, 0.5), ('calcium_nitrate', 'electrolyte', 0.25, 0.16, 0.137, 1.35, 0.15, 0.01, 0.5), ('potassium_nitrate', 'electrolyte', 0.23, 0.18, 0.136, 1.31, 0.14, 0.01, 0.5), ('sodium_nitrate', 'electrolyte', 0.22, 0.19, 0.136, 1.3, 0.14, 0.01, 0.5), ('iron_II', 'metal_ion', 1.35, 0.46, 0.066, 1.12, 0.46, 0.021, 0.5), ('iron_III', 'metal_ion', 1.48, 0.52, 0.064, 1.15, 0.48, 0.021, 0.48), ('copper_II', 'metal_ion', 1.3, 0.31, 0.061, 1.08, 0.43, 0.02, 0.49), ('zinc_II', 'metal_ion', 0.95, 0.72, 0.07, 1.1, 0.36, 0.018, 0.5), ('manganese_II', 'metal_ion', 0.86, 0.82, 0.075, 1.04, 0.32, 0.018, 0.5), ('nickel_II', 'metal_ion', 1.05, 0.61, 0.067, 1.06, 0.37, 0.019, 0.49), ('cobalt_II', 'metal_ion', 1.12, 0.54, 0.065, 1.08, 0.39, 0.019, 0.49), ('silver_I', 'metal_ion', 1.4, 0.69, 0.058, 1.02, 0.45, 0.02, 0.49), ('lead_II', 'metal_ion', 1.16, 0.78, 0.071, 0.98, 0.4, 0.021, 0.49), ('cadmium_II', 'metal_ion', 1.1, 0.82, 0.069, 0.99, 0.4, 0.02, 0.49), ('ethanol', 'organic_solvent', 0.19, 0.69, 0.13, 0.45, 0.15, 0.018, 0.5), ('methanol', 'organic_solvent', 0.22, 0.62, 0.126, 0.48, 0.17, 0.018, 0.5), ('propanol', 'organic_solvent', 0.2, 0.74, 0.133, 0.43, 0.15, 0.018, 0.5), ('isopropanol', 'organic_solvent', 0.21, 0.76, 0.132, 0.42, 0.16, 0.018, 0.5), ('butanol', 'organic_solvent', 0.18, 0.81, 0.137, 0.4, 0.14, 0.019, 0.5), ('acetone', 'organic_solvent', 0.24, 0.57, 0.125, 0.44, 0.18, 0.017, 0.5), ('glycerol', 'organic_solvent', 0.31, 0.51, 0.118, 0.5, 0.22, 0.016, 0.5), ('ethylene_glycol', 'organic_solvent', 0.27, 0.48, 0.116, 0.53, 0.2, 0.016, 0.5), ('propylene_glycol', 'organic_solvent', 0.25, 0.54, 0.12, 0.51, 0.19, 0.016, 0.5), ('formaldehyde', 'organic_compound', 0.52, 0.35, 0.102, 0.62, 0.28, 0.017, 0.47), ('hydrogen_peroxide', 'oxidizer', 1.42, 0.12, 0.064, 0.8, 0.47, 0.022, 0.46), ('sodium_hypochlorite', 'oxidizer', 1.18, 0.25, 0.078, 1.18, 0.42, 0.02, 0.47), ('potassium_permanganate', 'oxidizer', 1.6, 0.67, 0.055, 1.3, 0.52, 0.022, 0.48), ('potassium_dichromate', 'oxidizer', 1.52, 0.59, 0.057, 1.24, 0.5, 0.022, 0.48), ('sodium_thiosulfate', 'redox_salt', 0.72, 0.39, 0.086, 1.15, 0.31, 0.016, 0.49), ('potassium_iodide', 'redox_salt', 0.81, 0.43, 0.082, 1.25, 0.34, 0.017, 0.49), ('sodium_iodide', 'redox_salt', 0.78, 0.41, 0.083, 1.22, 0.33, 0.017, 0.49), ('sodium_metabisulfite', 'redox_salt', 0.67, 0.33, 0.09, 1.16, 0.29, 0.016, 0.48), ('sodium_sulfite', 'redox_salt', 0.63, 0.36, 0.091, 1.18, 0.28, 0.016, 0.48), ('sodium_nitrite', 'redox_salt', 0.91, 0.48, 0.078, 1.15, 0.36, 0.018, 0.49), ('hydroquinone', 'phenolic', 1.3, 0.29, 0.064, 0.66, 0.43, 0.02, 0.45), ('catechol', 'phenolic', 1.36, 0.24, 0.061, 0.68, 0.45, 0.02, 0.45), ('resorcinol', 'phenolic', 1.08, 0.38, 0.07, 0.67, 0.37, 0.019, 0.45), ('phenol', 'phenolic', 0.72, 0.52, 0.08, 0.64, 0.3, 0.018, 0.45), ('pyrogallol', 'phenolic', 1.48, 0.2, 0.059, 0.65, 0.48, 0.021, 0.44)]

def generate_dataset(
    samples_per_concentration=30,
    concentrations_mM=None,
    seed=42,
    output_csv="electrochemical_xgb_15features.csv"
):
    rng = np.random.default_rng(seed)

    if concentrations_mM is None:
        concentrations_mM = [0.01, 0.03, 0.1, 0.3, 1.0, 3.0, 10.0, 30.0]

    rows = []
    voltage = np.linspace(-1.0, 1.0, 500)

    for name, group, activity, potential, width, conductivity, baseline, intrinsic_noise, symmetry in SUBSTANCES:
        for conc in concentrations_mM:
            conc_factor = (conc / (conc + 4.0)) ** 0.78
            signal_amp = activity * (0.18 + 2.40 * conc_factor)

            for _ in range(samples_per_concentration):
                potential_shift = rng.normal(0, 0.018 + 0.004*np.log10(1+conc))
                width_sample = width * rng.lognormal(0, 0.07)
                amp_sample = signal_amp * rng.lognormal(0, 0.09)
                cond = conductivity * rng.lognormal(0, 0.06)
                baseline_sample = baseline * (0.75 + 0.35 * cond)
                noise_sigma = intrinsic_noise * (1.0 + 0.10*np.log10(1+conc)) / np.sqrt(max(cond, 0.35))

                peak_v = np.clip(potential + potential_shift, -0.90, 0.90)
                skew = np.clip(rng.normal(symmetry, 0.035), 0.80, 1.15)
                left_w = width_sample * (1.0 + (1.0-skew)*0.45)
                right_w = width_sample * (1.0 + (skew-1.0)*0.45)

                peak = np.where(
                    voltage <= peak_v,
                    np.exp(-0.5*((voltage-peak_v)/left_w)**2),
                    np.exp(-0.5*((voltage-peak_v)/right_w)**2)
                )

                drift_slope = rng.normal(0, 0.018)
                drift_curve = rng.normal(0, 0.010) * voltage**2

                current = (
                    baseline_sample + drift_slope*voltage +
                    drift_curve + amp_sample*peak
                )
                current += rng.normal(0, noise_sigma, size=len(voltage))

                if rng.random() < 0.12:
                    idx = rng.integers(50, 450)
                    disturbance = rng.normal(0, noise_sigma*2.5, size=7)
                    lo, hi = max(0, idx-3), min(len(current), idx+4)
                    current[lo:hi] += disturbance[:hi-lo]

                gradient = np.gradient(current, voltage)
                peak_idx = int(np.argmax(current))
                peak_current = float(current[peak_idx])
                peak_potential = float(voltage[peak_idx])

                baseline_est = float(np.quantile(current, 0.15))
                prominence = max(peak_current-baseline_est, 0.0)
                half_level = baseline_est + prominence/2
                above = np.where(current >= half_level)[0]

                if len(above) >= 2:
                    peak_width = float(voltage[above[-1]]-voltage[above[0]])
                else:
                    peak_width = float(width_sample*2.355)

                peak_area = float(np.trapz(np.maximum(current-baseline_est, 0), voltage))

                if len(above):
                    left_dist = peak_potential-voltage[above[0]]
                    right_dist = voltage[above[-1]]-peak_potential
                else:
                    left_dist = right_dist = width_sample

                peak_symmetry = float(
                    np.clip((left_dist+1e-6)/(right_dist+1e-6), 0.5, 2.0)
                )

                rows.append({
                    "meanCurrent": np.mean(current),
                    "stdCurrent": np.std(current),
                    "maxCurrent": np.max(current),
                    "minCurrent": np.min(current),
                    "meanVoltage": np.mean(voltage),
                    "voltageRange": np.max(voltage)-np.min(voltage),
                    "meanGradient": np.mean(gradient),
                    "maxGradient": np.max(gradient),
                    "minGradient": np.min(gradient),
                    "peakCurrent": peak_current,
                    "peakPotential": peak_potential,
                    "peakWidth": peak_width,
                    "peakArea": peak_area,
                    "peakProminence": prominence,
                    "peakSymmetry": peak_symmetry,
                    "substance": name,
                    "chemical_group": group,
                    "concentration_mM": conc
                })

    df = pd.DataFrame(rows)
    df.to_csv(output_csv, index=False)
    print(f"Saved {len(df):,} samples to {output_csv}")
    print("Features:", FEATURES)
    return df

if __name__ == "__main__":
    # Example: 100 × 8 × 100 = 80,000 samples
    generate_dataset(
        samples_per_concentration=100,
        concentrations_mM=[0.01, 0.03, 0.1, 0.3, 1.0, 3.0, 10.0, 30.0],
        seed=123,
        output_csv="electrochemical_xgb_15features_80k.csv"
    )
