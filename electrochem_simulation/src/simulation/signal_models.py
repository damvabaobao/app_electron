
"""
Synthetic electrochemical signal models
========================================

This module generates simplified synthetic electrochemical
waveforms for:

    1. Cyclic Voltammetry (CV)
    2. Differential Pulse Voltammetry (DPV)
    3. Square Wave Voltammetry (SWV)

IMPORTANT:
These are simplified simulation models.

They are NOT intended to reproduce a real electrochemical
cell exactly.

The purpose at this stage is to create a controllable dataset
for developing and testing the machine-learning pipeline.

Later, the parameters should be calibrated using real AD5941
measurements.
"""

import numpy as np

# GENERAL UTILITIES


def gaussian_peak(x, center, amplitude, width, asymmetry=0.0):
    """
    Generate an asymmetric Gaussian-like peak.

    Parameters
    ----------
    x : numpy.ndarray
        X-axis.

    center : float
        Peak position.

    amplitude : float
        Peak amplitude.

    width : float
        Peak width.

    asymmetry : float
        Controls asymmetry of the peak.

    Returns
    -------
    numpy.ndarray
        Peak signal.
    """

    sigma_left = width
    sigma_right = width * (1.0 + asymmetry)

    signal = np.zeros_like(x)

    left = x <= center
    right = x > center

    signal[left] = amplitude * np.exp(
        -0.5 * ((x[left] - center) / sigma_left) ** 2
    )

    signal[right] = amplitude * np.exp(
        -0.5 * ((x[right] - center) / sigma_right) ** 2
    )

    return signal


def apply_baseline(x, baseline):
    """
    Generate a small slowly varying baseline.
    """

    normalized_x = (x - x.min()) / (x.max() - x.min())

    return (
        baseline
        + 0.002 * normalized_x
        + 0.001 * np.sin(2 * np.pi * normalized_x)
    )


def apply_noise(signal, noise_level, rng):
    """
    Add Gaussian measurement noise.
    """

    noise_std = max(
        np.max(np.abs(signal)) * noise_level,
        1e-8
    )

    noise = rng.normal(
        loc=0.0,
        scale=noise_std,
        size=len(signal)
    )

    return signal + noise


def concentration_factor(concentration):
    """
    Convert concentration into a nonlinear current scaling factor.

    The relationship is approximately proportional but includes
    mild saturation so the simulated data is not perfectly linear.
    """

    concentration = max(concentration, 1e-6)

    return (
        concentration
        / (1.0 + 0.08 * concentration)
    )


def calculate_peak_potential(params, ph):
    """
    Estimate peak potential as a function of pH.

    This is a simplified representation of the fact that
    electrochemical peak potential can depend on proton activity.
    """

    reference_ph = 7.0

    delta_ph = ph - reference_ph

    return (
        params["base_peak_potential"]
        + params["ph_potential_shift"] * delta_ph
    )


def calculate_current_scale(params, ph, concentration):
    """
    Calculate current amplitude based on concentration and pH.
    """

    reference_ph = 7.0

    delta_ph = ph - reference_ph

    ph_factor = (
        1.0
        + params["ph_current_factor"] * delta_ph
    )

    concentration_factor_value = concentration_factor(
        concentration
    )

    return (
        params["current_scale"]
        * concentration_factor_value
        * ph_factor
    )


# CYCLIC VOLTAMMETRY


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
    Generate a simplified cyclic voltammogram.

    Parameters
    ----------
    params : dict
        Substance parameters from substances.py.

    concentration : float
        Concentration in arbitrary simulation units.

    ph : float
        Solution pH.

    n_points : int
        Number of voltage points.

    voltage_start : float
        Starting potential in volts.

    voltage_vertex : float
        Positive vertex potential in volts.

    seed : int or None
        Random seed.

    Returns
    -------
    voltage : numpy.ndarray
    current : numpy.ndarray
    """

    rng = np.random.default_rng(seed)

    # Forward scan


    forward = np.linspace(
        voltage_start,
        voltage_vertex,
        n_points // 2
    )

    # Reverse scan


    reverse = np.linspace(
        voltage_vertex,
        voltage_start,
        n_points - len(forward)
    )

    voltage = np.concatenate([
        forward,
        reverse
    ])

    # Electrochemical parameters


    peak_potential = calculate_peak_potential(
        params,
        ph
    )

    amplitude = calculate_current_scale(
        params,
        ph,
        concentration
    )

    width = params["peak_width"]

    asymmetry = params["peak_asymmetry"]

    baseline = apply_baseline(
        voltage,
        params["baseline"]
    )


    # Oxidation peak


    oxidation_peak = gaussian_peak(
        voltage,
        peak_potential,
        amplitude,
        width,
        asymmetry
    )

    # Reduction peak


    reduction_potential = (
        peak_potential
        + params["reduction_shift"]
    )

    reduction_amplitude = (
        -amplitude
        * params["reduction_ratio"]
    )

    reduction_peak = gaussian_peak(
        voltage,
        reduction_potential,
        abs(reduction_amplitude),
        width * 1.05,
        asymmetry
    )

    reduction_peak *= np.where(
        voltage <= peak_potential,
        1.0,
        0.0
    )

    # Direction-dependent behavior


    direction = np.ones_like(voltage)

    direction[len(forward):] = -1.0

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

    # Final signal


    current = (
        baseline
        + oxidation_component
        - reduction_component
    )

    # Add small capacitive-like background.
    current += (
        0.002
        * direction
        * (voltage - voltage.mean())
    )

    # Add measurement noise.
    current = apply_noise(
        current,
        params["noise_level"],
        rng
    )

    return voltage, current


# DIFFERENTIAL PULSE VOLTAMMETRY

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
    Generate a simplified Differential Pulse Voltammogram.

    DPV is represented as a baseline plus localized differential
    current peaks.
    """

    rng = np.random.default_rng(seed)

    voltage = np.linspace(
        voltage_start,
        voltage_end,
        n_points
    )

    peak_potential = calculate_peak_potential(
        params,
        ph
    )

    amplitude = calculate_current_scale(
        params,
        ph,
        concentration
    )

    baseline = apply_baseline(
        voltage,
        params["baseline"] * 0.5
    )

    # DPV has a sharper peak than the corresponding CV peak.
    width = params["peak_width"] * 0.55

    peak = gaussian_peak(
        voltage,
        peak_potential,
        amplitude,
        width,
        params["peak_asymmetry"]
    )

    # Small secondary contribution.
    secondary_peak = gaussian_peak(
        voltage,
        peak_potential + 0.10,
        amplitude * 0.08,
        width * 1.5,
        params["peak_asymmetry"]
    )

    current = (
        baseline
        + peak
        + secondary_peak
    )

    current = apply_noise(
        current,
        params["noise_level"] * 0.75,
        rng
    )

    return voltage, current

# SQUARE WAVE VOLTAMMETRY


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
    Generate a simplified Square Wave Voltammogram.

    The waveform is modeled as a staircase potential with
    an electrochemical current response.
    """

    rng = np.random.default_rng(seed)

    voltage = np.linspace(
        voltage_start,
        voltage_end,
        n_points
    )

    peak_potential = calculate_peak_potential(
        params,
        ph
    )

    amplitude = calculate_current_scale(
        params,
        ph,
        concentration
    )

    baseline = apply_baseline(
        voltage,
        params["baseline"] * 0.4
    )

    # SWV generally produces a narrow response.
    width = params["peak_width"] * 0.65

    forward_peak = gaussian_peak(
        voltage,
        peak_potential,
        amplitude,
        width,
        params["peak_asymmetry"]
    )

    backward_peak = gaussian_peak(
        voltage,
        peak_potential - 0.035,
        amplitude * params["reduction_ratio"] * 0.35,
        width * 1.1,
        params["peak_asymmetry"]
    )

    current = (
        baseline
        + forward_peak
        - backward_peak
    )

    # Simulated square-wave modulation.
    square_wave = np.sign(
        np.sin(
            np.linspace(
                0,
                2 * np.pi * 20,
                n_points
            )
        )
    )

    current += (
        square_wave
        * amplitude
        * 0.025
    )

    current = apply_noise(
        current,
        params["noise_level"] * 0.70,
        rng
    )

    return voltage, current

# QUICK TEST


if __name__ == "__main__":

    from pathlib import Path
    import sys
    import matplotlib.pyplot as plt

    # Allow importing config from project root.
    PROJECT_ROOT = Path(__file__).resolve().parents[2]

    sys.path.insert(
        0,
        str(PROJECT_ROOT)
    )

    from config.substances import SUBSTANCES

    # Test parameters

    substance_name = "dopamine"

    concentration = 0.5

    ph = 7.0

    params = SUBSTANCES[substance_name]

    # Generate signals

    cv_voltage, cv_current = generate_cv(
        params,
        concentration,
        ph,
        seed=42
    )

    dpv_voltage, dpv_current = generate_dpv(
        params,
        concentration,
        ph,
        seed=42
    )

    swv_voltage, swv_current = generate_swv(
        params,
        concentration,
        ph,
        seed=42
    )

    # Plot


    plt.figure(figsize=(10, 5))

    plt.plot(
        cv_voltage,
        cv_current
    )

    plt.xlabel("Potential (V)")

    plt.ylabel("Current (a.u.)")

    plt.title(
        f"Simulated CV - {params['display_name']} "
        f"| Concentration={concentration} "
        f"| pH={ph}"
    )

    plt.grid(True)

    plt.tight_layout()

    plt.show()

    plt.figure(figsize=(10, 5))

    plt.plot(
        dpv_voltage,
        dpv_current
    )

    plt.xlabel("Potential (V)")

    plt.ylabel("Differential Current (a.u.)")

    plt.title(
        f"Simulated DPV - {params['display_name']} "
        f"| Concentration={concentration} "
        f"| pH={ph}"
    )

    plt.grid(True)

    plt.tight_layout()

    plt.show()

    plt.figure(figsize=(10, 5))

    plt.plot(
        swv_voltage,
        swv_current
    )

    plt.xlabel("Potential (V)")

    plt.ylabel("Current (a.u.)")

    plt.title(
        f"Simulated SWV - {params['display_name']} "
        f"| Concentration={concentration} "
        f"| pH={ph}"
    )

    plt.grid(True)

    plt.tight_layout()

    plt.show()

