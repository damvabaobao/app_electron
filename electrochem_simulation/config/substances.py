
"""
Electrochemical substance profiles

This file defines simplified electrochemical parameters used by
the synthetic-data generator.

IMPORTANT:
These values are simulation parameters, NOT experimental reference data.

They are intentionally designed to create distinguishable but imperfect
electrochemical fingerprints.

Later, when real AD5941 measurements are available, these parameters
should be calibrated against real measurements.
"""

SUBSTANCES = {

    # DOPAMINE

    "dopamine": {

        "display_name": "Dopamine",

        "base_peak_potential": 0.20,

        "current_scale": 1.00,

        "peak_width": 0.045,

        "peak_asymmetry": 0.10,

        "ph_potential_shift": -0.055,

        "ph_current_factor": 0.025,

        "reduction_ratio": 0.55,

        "reduction_shift": -0.12,

        "noise_level": 0.025,

        "baseline": 0.002,
    },


    # ============================================================
    # URIC ACID
    # ============================================================
    "uric_acid": {

        "display_name": "Uric Acid",

        "base_peak_potential": 0.35,

        "current_scale": 0.82,

        "peak_width": 0.060,

        "peak_asymmetry": 0.18,

        "ph_potential_shift": -0.050,

        "ph_current_factor": 0.018,

        "reduction_ratio": 0.08,

        "reduction_shift": -0.10,

        "noise_level": 0.030,

        "baseline": 0.002,
    },


    # ============================================================
    # ASCORBIC ACID
    # ============================================================
    "ascorbic_acid": {

        "display_name": "Ascorbic Acid",

        "base_peak_potential": 0.05,

        "current_scale": 0.95,

        "peak_width": 0.075,

        "peak_asymmetry": 0.25,

        "ph_potential_shift": -0.040,

        "ph_current_factor": 0.020,

        "reduction_ratio": 0.05,

        "reduction_shift": -0.08,

        "noise_level": 0.035,

        "baseline": 0.002,
    },


    # ============================================================
    # GLUCOSE
    # ============================================================
    "glucose": {

        "display_name": "Glucose",

        "base_peak_potential": 0.48,

        "current_scale": 0.55,

        "peak_width": 0.095,

        "peak_asymmetry": 0.30,

        "ph_potential_shift": -0.025,

        "ph_current_factor": 0.012,

        "reduction_ratio": 0.02,

        "reduction_shift": -0.08,

        "noise_level": 0.040,

        "baseline": 0.003,
    },


    # ============================================================
    # COPPER
    # ============================================================
    "copper": {

        "display_name": "Copper",

        "base_peak_potential": -0.05,

        "current_scale": 1.10,

        "peak_width": 0.040,

        "peak_asymmetry": 0.08,

        "ph_potential_shift": 0.010,

        "ph_current_factor": 0.010,

        "reduction_ratio": 0.72,

        "reduction_shift": -0.16,

        "noise_level": 0.025,

        "baseline": 0.001,
    },


    # ============================================================
    # ALUMINUM
    # ============================================================
    "aluminum": {

        "display_name": "Aluminum",

        "base_peak_potential": -0.32,

        "current_scale": 0.72,

        "peak_width": 0.070,

        "peak_asymmetry": 0.15,

        "ph_potential_shift": 0.012,

        "ph_current_factor": 0.008,

        "reduction_ratio": 0.62,

        "reduction_shift": -0.13,

        "noise_level": 0.035,

        "baseline": 0.001,
    },
}

