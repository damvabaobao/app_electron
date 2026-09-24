"""
Synthetic electrochemical signal models
========================================

Synthetic models for:

    1. Cyclic Voltammetry (CV)
    2. Differential Pulse Voltammetry (DPV)
    3. Square Wave Voltammetry (SWV)

The purpose is to generate controllable synthetic
electrochemical signals for machine-learning experiments.

IMPORTANT
---------
These models are simplified simulations.

They are NOT intended to reproduce a real electrochemical
cell exactly.

The current version introduces controlled measurement-to-
measurement variation so that the same substance does not
produce an identical waveform every time.

Later, these parameters should be calibrated against
real AD5941 measurements.
"""

import numpy as np
from pathlib import Path

# ============================================================
# GENERAL UTILITIES
# ============================================================

def gaussian_peak(
    x,
    center,
    amplitude,
    width,
    asymmetry=0.0
):
    """
    Generate an asymmetric Gaussian-like peak.
    """

    width = max(float(width), 1e-6)

    sigma_left = width
    sigma_right = width * (1.0 + asymmetry)

    sigma_right = max(sigma_right, 1e-6)

    signal = np.zeros_like(x, dtype=np.float64)

    left = x <= center
    right = x > center

    signal[left] = amplitude * np.exp(
        -0.5 * ((x[left] - center) / sigma_left) ** 2
    )

    signal[right] = amplitude * np.exp(
        -0.5 * ((x[right] - center) / sigma_right) ** 2
    )

    return signal


def apply_baseline(
    x,
    baseline,
    rng=None,
    variation_strength=0.0
):
    """
    Generate a slowly varying baseline.

    variation_strength controls measurement-to-measurement
    baseline variation.
    """

    x_range = x.max() - x.min()

    if x_range == 0:
        normalized_x = np.zeros_like(x)
    else:
        normalized_x = (
            (x - x.min()) / x_range
        )

    # Random baseline offset
    baseline_offset = 0.0

    if rng is not None and variation_strength > 0:
        baseline_offset = rng.normal(
            0.0,
            abs(baseline) * variation_strength + 1e-6
        )

    # Small slope variation
    slope_scale = 1.0

    if rng is not None and variation_strength > 0:
        slope_scale = rng.normal(
            1.0,
            variation_strength
        )

    # Small sinusoidal variation
    phase = 0.0

    if rng is not None and variation_strength > 0:
        phase = rng.uniform(
            -np.pi,
            np.pi
        )

    return (
        baseline
        + baseline_offset
        + 0.002
        * slope_scale
        * normalized_x
        + 0.001
        * np.sin(
            2 * np.pi * normalized_x + phase
        )
    )


def apply_noise(
    signal,
    noise_level,
    rng
):
    """
    Add Gaussian measurement noise.
    """

    signal_scale = np.max(
        np.abs(signal)
    )

    noise_std = max(
        signal_scale * noise_level,
        1e-8
    )

    noise = rng.normal(
        loc=0.0,
        scale=noise_std,
        size=len(signal)
    )

    return signal + noise


def concentration_factor(
    concentration
):
    """
    Convert concentration into a nonlinear current
    scaling factor.

    The relationship is approximately proportional,
    with mild saturation.
    """

    concentration = max(
        concentration,
        1e-6
    )

    return (
        concentration
        / (1.0 + 0.08 * concentration)
    )


# ============================================================
# ELECTROCHEMICAL PARAMETER CALCULATIONS
# ============================================================

def calculate_peak_potential(
    params,
    ph
):
    """
    Calculate nominal peak potential from pH.
    """

    reference_ph = 7.0

    delta_ph = (
        ph - reference_ph
    )

    return (
        params["base_peak_potential"]
        + params["ph_potential_shift"]
        * delta_ph
    )


def calculate_current_scale(
    params,
    ph,
    concentration
):
    """
    Calculate nominal current amplitude.
    """

    reference_ph = 7.0

    delta_ph = (
        ph - reference_ph
    )

    ph_factor = (
        1.0
        + params["ph_current_factor"]
        * delta_ph
    )

    concentration_factor_value = (
        concentration_factor(
            concentration
        )
    )

    return (
        params["current_scale"]
        * concentration_factor_value
        * ph_factor
    )


# ============================================================
# CONTROLLED PARAMETER VARIATION
# ============================================================

def get_randomized_peak_potential(
    params,
    ph,
    rng,
    variation=0.015
):
    """
    Add small random variation to the nominal peak
    potential.

    variation is expressed in volts.

    Example:
        nominal = 0.200 V
        variation = 0.015 V

    The generated peak may move slightly around
    the nominal position.
    """

    nominal = calculate_peak_potential(
        params,
        ph
    )

    random_shift = rng.normal(
        loc=0.0,
        scale=variation
    )

    return nominal + random_shift


def get_randomized_amplitude(
    params,
    ph,
    concentration,
    rng,
    variation=0.08
):
    """
    Add controlled amplitude variation.

    variation = 0.08 means approximately 8% standard
    deviation around the nominal amplitude.
    """

    nominal = calculate_current_scale(
        params,
        ph,
        concentration
    )

    random_scale = rng.normal(
        loc=1.0,
        scale=variation
    )

    random_scale = max(
        random_scale,
        0.70
    )

    return nominal * random_scale


def get_randomized_width(
    params,
    rng,
    variation=0.08
):
    """
    Add controlled variation to peak width.
    """

    nominal = params["peak_width"]

    random_scale = rng.normal(
        loc=1.0,
        scale=variation
    )

    random_scale = max(
        random_scale,
        0.70
    )

    return nominal * random_scale


def get_randomized_asymmetry(
    params,
    rng,
    variation=0.08
):
    """
    Add small variation to peak asymmetry.
    """

    nominal = params["peak_asymmetry"]

    random_value = rng.normal(
        loc=nominal,
        scale=variation
    )

    return random_value


# ============================================================
# CYCLIC VOLTAMMETRY
# ============================================================

def generate_cv(
    params,
    concentration,
    ph,
    n_points=1000,
    voltage_start=-0.6,
    voltage_vertex=0.8,
    seed=None
):
    """
    Generate a synthetic Cyclic Voltammogram.

    Controlled variation is applied to:

        - peak potential
        - amplitude
        - peak width
        - asymmetry
        - baseline
        - noise
    """

    rng = np.random.default_rng(
        seed
    )

    # --------------------------------------------------------
    # Voltage waveform
    # --------------------------------------------------------

    forward = np.linspace(
        voltage_start,
        voltage_vertex,
        n_points // 2
    )

    reverse = np.linspace(
        voltage_vertex,
        voltage_start,
        n_points - len(forward)
    )

    voltage = np.concatenate(
        [
            forward,
            reverse
        ]
    )

    # --------------------------------------------------------
    # Randomized electrochemical parameters
    # --------------------------------------------------------

    peak_potential = (
        get_randomized_peak_potential(
            params,
            ph,
            rng,
            variation=0.012
        )
    )

    amplitude = (
        get_randomized_amplitude(
            params,
            ph,
            concentration,
            rng,
            variation=0.08
        )
    )

    width = (
        get_randomized_width(
            params,
            rng,
            variation=0.08
        )
    )

    asymmetry = (
        get_randomized_asymmetry(
            params,
            rng,
            variation=0.04
        )
    )

    # --------------------------------------------------------
    # Baseline
    # --------------------------------------------------------

    baseline = apply_baseline(
        voltage,
        params["baseline"],
        rng=rng,
        variation_strength=0.08
    )

    # --------------------------------------------------------
    # Oxidation peak
    # --------------------------------------------------------

    oxidation_peak = gaussian_peak(
        voltage,
        peak_potential,
        amplitude,
        width,
        asymmetry
    )

    # --------------------------------------------------------
    # Reduction peak
    # --------------------------------------------------------

    reduction_potential = (
        peak_potential
        + params["reduction_shift"]
        + rng.normal(
            0.0,
            0.008
        )
    )

    reduction_amplitude = (
        -amplitude
        * params["reduction_ratio"]
    )

    reduction_width = (
        width
        * rng.normal(
            1.05,
            0.05
        )
    )

    reduction_peak = gaussian_peak(
        voltage,
        reduction_potential,
        abs(reduction_amplitude),
        reduction_width,
        asymmetry
    )

    reduction_peak *= np.where(
        voltage <= peak_potential,
        1.0,
        0.0
    )

    # --------------------------------------------------------
    # Scan direction
    # --------------------------------------------------------

    direction = np.ones_like(
        voltage
    )

    direction[
        len(forward):
    ] = -1.0

    oxidation_component = (
        oxidation_peak
        * np.where(
            direction > 0,
            1.0,
            0.80
        )
    )

    reduction_component = (
        reduction_peak
        * np.where(
            direction < 0,
            1.0,
            0.0
        )
    )

    # --------------------------------------------------------
    # Capacitive/background component
    # --------------------------------------------------------

    capacitive_scale = rng.normal(
        1.0,
        0.10
    )

    capacitive_component = (
        0.002
        * capacitive_scale
        * direction
        * (
            voltage
            - voltage.mean()
        )
    )

    # --------------------------------------------------------
    # Final current
    # --------------------------------------------------------

    current = (
        baseline
        + oxidation_component
        - reduction_component
        + capacitive_component
    )

    # --------------------------------------------------------
    # Noise
    # --------------------------------------------------------

    noise_scale = rng.normal(
        1.0,
        0.10
    )

    noise_scale = max(
        noise_scale,
        0.70
    )

    current = apply_noise(
        current,
        params["noise_level"]
        * noise_scale,
        rng
    )

    return voltage, current


# ============================================================
# DIFFERENTIAL PULSE VOLTAMMETRY
# ============================================================

def generate_dpv(
    params,
    concentration,
    ph,
    n_points=500,
    voltage_start=-0.6,
    voltage_end=0.8,
    seed=None
):
    """
    Generate a synthetic Differential Pulse Voltammogram.
    """

    rng = np.random.default_rng(
        seed
    )

    voltage = np.linspace(
        voltage_start,
        voltage_end,
        n_points
    )

    # --------------------------------------------------------
    # Randomized parameters
    # --------------------------------------------------------

    peak_potential = (
        get_randomized_peak_potential(
            params,
            ph,
            rng,
            variation=0.010
        )
    )

    amplitude = (
        get_randomized_amplitude(
            params,
            ph,
            concentration,
            rng,
            variation=0.07
        )
    )

    width = (
        get_randomized_width(
            params,
            rng,
            variation=0.08
        )
    )

    asymmetry = (
        get_randomized_asymmetry(
            params,
            rng,
            variation=0.04
        )
    )

    # --------------------------------------------------------
    # Baseline
    # --------------------------------------------------------

    baseline = apply_baseline(
        voltage,
        params["baseline"] * 0.5,
        rng=rng,
        variation_strength=0.08
    )

    # DPV sharper peak
    dpv_width = (
        width * 0.55
    )

    peak = gaussian_peak(
        voltage,
        peak_potential,
        amplitude,
        dpv_width,
        asymmetry
    )

    # --------------------------------------------------------
    # Secondary contribution
    # --------------------------------------------------------

    secondary_shift = rng.normal(
        0.10,
        0.015
    )

    secondary_amplitude = (
        amplitude
        * rng.normal(
            0.08,
            0.015
        )
    )

    secondary_peak = gaussian_peak(
        voltage,
        peak_potential
        + secondary_shift,
        secondary_amplitude,
        dpv_width * 1.5,
        asymmetry
    )

    # --------------------------------------------------------
    # Final signal
    # --------------------------------------------------------

    current = (
        baseline
        + peak
        + secondary_peak
    )

    noise_scale = rng.normal(
        1.0,
        0.10
    )

    noise_scale = max(
        noise_scale,
        0.70
    )

    current = apply_noise(
        current,
        params["noise_level"]
        * 0.75
        * noise_scale,
        rng
    )

    return voltage, current


# ============================================================
# SQUARE WAVE VOLTAMMETRY
# ============================================================

def generate_swv(
    params,
    concentration,
    ph,
    n_points=800,
    voltage_start=-0.6,
    voltage_end=0.8,
    seed=None
):
    """
    Generate a synthetic Square Wave Voltammogram.
    """

    rng = np.random.default_rng(
        seed
    )

    voltage = np.linspace(
        voltage_start,
        voltage_end,
        n_points
    )

    # --------------------------------------------------------
    # Randomized parameters
    # --------------------------------------------------------

    peak_potential = (
        get_randomized_peak_potential(
            params,
            ph,
            rng,
            variation=0.010
        )
    )

    amplitude = (
        get_randomized_amplitude(
            params,
            ph,
            concentration,
            rng,
            variation=0.07
        )
    )

    width = (
        get_randomized_width(
            params,
            rng,
            variation=0.08
        )
    )

    asymmetry = (
        get_randomized_asymmetry(
            params,
            rng,
            variation=0.04
        )
    )

    # --------------------------------------------------------
    # Baseline
    # --------------------------------------------------------

    baseline = apply_baseline(
        voltage,
        params["baseline"] * 0.4,
        rng=rng,
        variation_strength=0.08
    )

    # --------------------------------------------------------
    # Main peak
    # --------------------------------------------------------

    forward_peak = gaussian_peak(
        voltage,
        peak_potential,
        amplitude,
        width * 0.65,
        asymmetry
    )

    # --------------------------------------------------------
    # Backward component
    # --------------------------------------------------------

    backward_shift = rng.normal(
        0.035,
        0.008
    )

    backward_amplitude = (
        amplitude
        * params["reduction_ratio"]
        * rng.normal(
            0.35,
            0.04
        )
    )

    backward_peak = gaussian_peak(
        voltage,
        peak_potential
        - backward_shift,
        backward_amplitude,
        width * 0.72,
        asymmetry
    )

    # --------------------------------------------------------
    # Square wave modulation
    # --------------------------------------------------------

    wave_cycles = rng.integers(
        18,
        24
    )

    phase = rng.uniform(
        -np.pi,
        np.pi
    )

    square_wave = np.sign(
        np.sin(
            np.linspace(
                0,
                2 * np.pi * wave_cycles,
                n_points
            )
            + phase
        )
    )

    modulation_scale = rng.normal(
        0.025,
        0.004
    )

    modulation_scale = max(
        modulation_scale,
        0.01
    )

    square_component = (
        square_wave
        * amplitude
        * modulation_scale
    )

    # --------------------------------------------------------
    # Final signal
    # --------------------------------------------------------

    current = (
        baseline
        + forward_peak
        - backward_peak
        + square_component
    )

    noise_scale = rng.normal(
        1.0,
        0.10
    )

    noise_scale = max(
        noise_scale,
        0.70
    )

    current = apply_noise(
        current,
        params["noise_level"]
        * 0.70
        * noise_scale,
        rng
    )

    return voltage, current


# ============================================================
# QUICK TEST
# ============================================================

if __name__ == "__main__":

    import matplotlib.pyplot as plt

    PROJECT_ROOT = (
        Path(__file__).resolve().parents[2]
    )

    import sys

    if str(PROJECT_ROOT) not in sys.path:
        sys.path.insert(
            0,
            str(PROJECT_ROOT)
        )

    from config.substances import SUBSTANCES

    substance_name = "dopamine"

    concentration = 0.5

    ph = 7.0

    params = SUBSTANCES[
        substance_name
    ]

    # --------------------------------------------------------
    # Generate signals
    # --------------------------------------------------------

    cv_voltage_1, cv_current_1 = generate_cv(
        params,
        concentration,
        ph,
        seed=1
    )

    cv_voltage_2, cv_current_2 = generate_cv(
        params,
        concentration,
        ph,
        seed=2
    )

    cv_voltage_3, cv_current_3 = generate_cv(
        params,
        concentration,
        ph,
        seed=3
    )

    # --------------------------------------------------------
    # Plot CV variation
    # --------------------------------------------------------

    plt.figure(
        figsize=(10, 5)
    )

    plt.plot(
        cv_voltage_1,
        cv_current_1,
        label="Seed 1"
    )

    plt.plot(
        cv_voltage_2,
        cv_current_2,
        label="Seed 2"
    )

    plt.plot(
        cv_voltage_3,
        cv_current_3,
        label="Seed 3"
    )

    plt.xlabel(
        "Potential (V)"
    )

    plt.ylabel(
        "Current (a.u.)"
    )

    plt.title(
        "Synthetic CV Variation - "
        f"{params['display_name']} "
        f"| Concentration={concentration} "
        f"| pH={ph}"
    )

    plt.legend()

    plt.grid(True)

    plt.tight_layout()

    plt.show()

    # --------------------------------------------------------
    # DPV
    # --------------------------------------------------------

    dpv_voltage, dpv_current = generate_dpv(
        params,
        concentration,
        ph,
        seed=42
    )

    plt.figure(
        figsize=(10, 5)
    )

    plt.plot(
        dpv_voltage,
        dpv_current
    )

    plt.xlabel(
        "Potential (V)"
    )

    plt.ylabel(
        "Differential Current (a.u.)"
    )

    plt.title(
        f"Simulated DPV - "
        f"{params['display_name']} "
        f"| Concentration={concentration} "
        f"| pH={ph}"
    )

    plt.grid(True)

    plt.tight_layout()

    plt.show()

    # --------------------------------------------------------
    # SWV
    # --------------------------------------------------------

    swv_voltage, swv_current = generate_swv(
        params,
        concentration,
        ph,
        seed=42
    )

    plt.figure(
        figsize=(10, 5)
    )

    plt.plot(
        swv_voltage,
        swv_current
    )

    plt.xlabel(
        "Potential (V)"
    )

    plt.ylabel(
        "Current (a.u.)"
    )

    plt.title(
        f"Simulated SWV - "
        f"{params['display_name']} "
        f"| Concentration={concentration} "
        f"| pH={ph}"
    )

    plt.grid(True)

    plt.tight_layout()

    plt.show()