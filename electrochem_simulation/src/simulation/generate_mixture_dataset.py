"""
Synthetic Electrochemical Mixture Dataset Generator
====================================================

Generate multi-label electrochemical mixture signals for:

    - CV
    - DPV
    - SWV

The dataset contains:

    1. Single-substance samples
    2. Binary mixtures
    3. Triple mixtures
    4. 4-substance mixtures
    5. 5-substance mixtures
    6. 6-substance mixtures

Each sample contains:

    - electrochemical signal
    - pH
    - concentration of each substance
    - multi-label target
    - method
    - seed
    - mixture size

The generated dataset is intended for training
multi-label CNN models.
"""

import sys
from pathlib import Path
from itertools import combinations

import numpy as np
import pandas as pd


# ============================================================
# PROJECT PATH
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[2]

if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))


# ============================================================
# PROJECT IMPORTS
# ============================================================

from config.substances import SUBSTANCES

from src.simulation.signal_models import (
    generate_cv,
    generate_dpv,
    generate_swv,
)


# ============================================================
# CONFIGURATION
# ============================================================

METHODS = [
    "CV",
    "DPV",
    "SWV",
]


SUBSTANCE_NAMES = [
    "dopamine",
    "uric_acid",
    "ascorbic_acid",
    "glucose",
    "copper",
    "aluminum",
]


# Concentration values used for each active substance.
CONCENTRATIONS = [
    0.1,
    0.2,
    0.5,
    1.0,
    2.0,
    5.0,
]


# pH values.
PH_VALUES = [
    6.0,
    6.5,
    7.0,
    7.5,
    8.0,
]


# Number of samples generated for every
# substance combination.
SAMPLES_PER_COMBINATION = 20


# Use the same signal length for all methods.
# This will make the later CNN pipeline easier.
N_POINTS = 1000


# Additional mixture-level noise.
MIXTURE_NOISE_LEVEL = 0.015


# Additional random baseline variation.
MIXTURE_BASELINE_LEVEL = 0.002


# Reproducibility.
GLOBAL_SEED = 42


# ============================================================
# OUTPUT DIRECTORY
# ============================================================

OUTPUT_DIR = (
    PROJECT_ROOT
    / "data"
    / "mixture"
)

OUTPUT_DIR.mkdir(
    parents=True,
    exist_ok=True,
)


# ============================================================
# RANDOM GENERATOR
# ============================================================

GLOBAL_RNG = np.random.default_rng(
    GLOBAL_SEED
)


# ============================================================
# HELPER: GENERATE ALL COMBINATIONS
# ============================================================

def generate_combinations():
    """
    Generate every non-empty substance combination.

    For 6 substances:

        6 single
        15 binary
        20 triple
        15 quadruple
        6 quintuple
        1 six-substance

    Total = 63 combinations.
    """

    combinations_list = []

    for mixture_size in range(
        1,
        len(SUBSTANCE_NAMES) + 1
    ):

        for combo in combinations(
            SUBSTANCE_NAMES,
            mixture_size
        ):

            combinations_list.append(
                combo
            )

    return combinations_list


# ============================================================
# HELPER: CREATE MULTI-LABEL
# ============================================================

def create_label(active_substances):
    """
    Create a multi-label vector.

    Example:

        dopamine + uric_acid

    becomes:

        [1, 1, 0, 0, 0, 0]
    """

    label = np.zeros(
        len(SUBSTANCE_NAMES),
        dtype=np.float32
    )

    for substance in active_substances:

        index = SUBSTANCE_NAMES.index(
            substance
        )

        label[index] = 1.0

    return label


# ============================================================
# HELPER: CREATE CONCENTRATION VECTOR
# ============================================================

def create_concentration_vector(
    active_substances,
    concentration_map
):
    """
    Create a concentration vector
    following SUBSTANCE_NAMES order.
    """

    concentrations = np.zeros(
        len(SUBSTANCE_NAMES),
        dtype=np.float32
    )

    for substance in active_substances:

        index = SUBSTANCE_NAMES.index(
            substance
        )

        concentrations[index] = (
            concentration_map[substance]
        )

    return concentrations


# ============================================================
# GENERATE ONE SUBSTANCE SIGNAL
# ============================================================

def generate_single_signal(
    substance_name,
    concentration,
    ph,
    method,
    seed,
):
    """
    Generate one electrochemical signal
    for one substance.
    """

    params = SUBSTANCES[
        substance_name
    ]

    if method == "CV":

        voltage, current = generate_cv(
            params=params,
            concentration=concentration,
            ph=ph,
            n_points=N_POINTS,
            seed=seed,
        )

    elif method == "DPV":

        voltage, current = generate_dpv(
            params=params,
            concentration=concentration,
            ph=ph,
            n_points=N_POINTS,
            seed=seed,
        )

    elif method == "SWV":

        voltage, current = generate_swv(
            params=params,
            concentration=concentration,
            ph=ph,
            n_points=N_POINTS,
            seed=seed,
        )

    else:

        raise ValueError(
            f"Unknown method: {method}"
        )

    return voltage, current


# ============================================================
# ADD MIXTURE VARIATION
# ============================================================

def add_mixture_variation(
    voltage,
    current,
    rng,
):
    """
    Add additional variation after
    combining individual substance signals.

    This represents mixture-level effects
    such as:

        - measurement noise
        - electrode variation
        - baseline drift
        - small environmental variation
    """

    signal_scale = max(
        np.max(np.abs(current)),
        1e-8
    )

    # --------------------------------------------------------
    # Additional Gaussian noise
    # --------------------------------------------------------

    noise_std = (
        signal_scale
        * MIXTURE_NOISE_LEVEL
    )

    noise = rng.normal(
        loc=0.0,
        scale=noise_std,
        size=len(current),
    )

    current = current + noise

    # --------------------------------------------------------
    # Slowly varying baseline drift
    # --------------------------------------------------------

    normalized_voltage = (
        voltage - voltage.min()
    ) / (
        voltage.max() - voltage.min()
    )

    drift = (
        MIXTURE_BASELINE_LEVEL
        * np.sin(
            2
            * np.pi
            * normalized_voltage
        )
    )

    current = current + drift

    return current


# ============================================================
# GENERATE ONE MIXTURE SAMPLE
# ============================================================

def generate_mixture_sample(
    active_substances,
    ph,
    method,
    sample_seed,
):
    """
    Generate one complete mixture sample.
    """

    # --------------------------------------------------------
    # Random generator for this sample
    # --------------------------------------------------------

    rng = np.random.default_rng(
        sample_seed
    )

    # --------------------------------------------------------
    # Random concentration for each active substance
    # --------------------------------------------------------

    concentration_map = {}

    for substance in active_substances:

        concentration = rng.choice(
            CONCENTRATIONS
        )

        concentration_map[
            substance
        ] = float(concentration)

    # --------------------------------------------------------
    # Generate each substance signal
    # --------------------------------------------------------

    component_signals = []

    voltage_reference = None

    for component_index, substance in enumerate(
        active_substances
    ):

        concentration = concentration_map[
            substance
        ]

        # Use different seed for each component.
        component_seed = (
            sample_seed
            + (component_index + 1) * 100000
        )

        voltage, current = (
            generate_single_signal(
                substance_name=substance,
                concentration=concentration,
                ph=ph,
                method=method,
                seed=component_seed,
            )
        )

        if voltage_reference is None:

            voltage_reference = voltage

        else:

            if not np.allclose(
                voltage_reference,
                voltage
            ):

                raise ValueError(
                    "Voltage axes are not identical."
                )

        component_signals.append(
            current
        )

    # --------------------------------------------------------
    # Combine signals
    # --------------------------------------------------------

    mixture_current = np.sum(
        np.asarray(component_signals),
        axis=0,
    )

    # --------------------------------------------------------
    # Add mixture-level variation
    # --------------------------------------------------------

    mixture_current = add_mixture_variation(
        voltage=voltage_reference,
        current=mixture_current,
        rng=rng,
    )

    return (
        voltage_reference,
        mixture_current,
        concentration_map,
    )


# ============================================================
# GENERATE METHOD DATASET
# ============================================================

def generate_method_dataset(
    method,
    combinations_list,
):
    """
    Generate the complete dataset for one method.
    """

    print()
    print("=" * 70)
    print(
        f"GENERATING MIXTURE DATASET - {method}"
    )
    print("=" * 70)

    signals = []
    labels = []
    concentration_vectors = []
    metadata = []

    sample_counter = 0

    total_samples = (
        len(combinations_list)
        * SAMPLES_PER_COMBINATION
    )

    print(
        f"Combinations : {len(combinations_list)}"
    )

    print(
        f"Samples/combo: "
        f"{SAMPLES_PER_COMBINATION}"
    )

    print(
        f"Total samples: {total_samples}"
    )

    # --------------------------------------------------------
    # Generate every combination
    # --------------------------------------------------------

    for combination_index, active_substances in enumerate(
        combinations_list
    ):

        mixture_size = len(
            active_substances
        )

        for repeat_index in range(
            SAMPLES_PER_COMBINATION
        ):

            sample_counter += 1

            # Unique deterministic seed.
            sample_seed = (
                GLOBAL_SEED
                + sample_counter
                + method_index(method) * 1_000_000
            )

            # Random pH.
            ph = float(
                GLOBAL_RNG.choice(
                    PH_VALUES
                )
            )

            # Generate signal.
            (
                voltage,
                current,
                concentration_map,
            ) = generate_mixture_sample(
                active_substances=active_substances,
                ph=ph,
                method=method,
                sample_seed=sample_seed,
            )

            # Multi-label.
            label = create_label(
                active_substances
            )

            # Concentration vector.
            concentration_vector = (
                create_concentration_vector(
                    active_substances,
                    concentration_map,
                )
            )

            # ------------------------------------------------
            # Save arrays
            # ------------------------------------------------

            signals.append(
                current.astype(
                    np.float32
                )
            )

            labels.append(
                label
            )

            concentration_vectors.append(
                concentration_vector
            )

            # ------------------------------------------------
            # Metadata
            # ------------------------------------------------

            metadata_row = {
                "sample_id": sample_counter,
                "method": method,
                "mixture_size": mixture_size,
                "combination_id": combination_index,
                "combination": "+".join(
                    active_substances
                ),
                "pH": ph,
                "seed": sample_seed,
            }

            # Add concentration columns.
            for substance in SUBSTANCE_NAMES:

                metadata_row[
                    f"{substance}_concentration"
                ] = concentration_map.get(
                    substance,
                    0.0
                )

            metadata.append(
                metadata_row
            )

            # ------------------------------------------------
            # Progress
            # ------------------------------------------------

            if (
                sample_counter % 100 == 0
                or sample_counter == total_samples
            ):

                print(
                    f"[{sample_counter:04d}/"
                    f"{total_samples}] "
                    f"{'+'.join(active_substances):<55}"
                )

    # --------------------------------------------------------
    # Convert to numpy
    # --------------------------------------------------------

    signals = np.asarray(
        signals,
        dtype=np.float32
    )

    labels = np.asarray(
        labels,
        dtype=np.float32
    )

    concentration_vectors = np.asarray(
        concentration_vectors,
        dtype=np.float32
    )

    metadata = pd.DataFrame(
        metadata
    )

    # --------------------------------------------------------
    # Validation
    # --------------------------------------------------------

    if not np.all(
        np.isfinite(signals)
    ):

        raise ValueError(
            f"{method}: Signal contains NaN or Inf."
        )

    if not np.all(
        np.isfinite(
            concentration_vectors
        )
    ):

        raise ValueError(
            f"{method}: Concentration contains NaN or Inf."
        )

    if not np.all(
        np.isfinite(labels)
    ):

        raise ValueError(
            f"{method}: Labels contain NaN or Inf."
        )

    print()
    print(
        f"{method} signal shape:"
        f" {signals.shape}"
    )

    print(
        f"{method} label shape:"
        f" {labels.shape}"
    )

    print(
        f"{method} concentration shape:"
        f" {concentration_vectors.shape}"
    )

    print(
        f"{method} metadata shape:"
        f" {metadata.shape}"
    )

    return (
        voltage,
        signals,
        labels,
        concentration_vectors,
        metadata,
    )


# ============================================================
# METHOD INDEX
# ============================================================

def method_index(method):
    """
    Return deterministic index for each method.
    """

    return METHODS.index(
        method
    )


# ============================================================
# SAVE DATASET
# ============================================================

def save_method_dataset(
    method,
    voltage,
    signals,
    labels,
    concentration_vectors,
    metadata,
):
    """
    Save one method dataset.
    """

    method_dir = (
        OUTPUT_DIR
        / method
    )

    method_dir.mkdir(
        parents=True,
        exist_ok=True
    )

    # --------------------------------------------------------
    # Signal
    # --------------------------------------------------------

    signal_file = (
        method_dir
        / "signals.npz"
    )

    np.savez_compressed(
        signal_file,
        voltage=voltage.astype(
            np.float32
        ),
        current=signals.astype(
            np.float32
        ),
    )

    # --------------------------------------------------------
    # Labels
    # --------------------------------------------------------

    label_file = (
        method_dir
        / "labels.npy"
    )

    np.save(
        label_file,
        labels.astype(
            np.float32
        )
    )

    # --------------------------------------------------------
    # Concentrations
    # --------------------------------------------------------

    concentration_file = (
        method_dir
        / "concentrations.npy"
    )

    np.save(
        concentration_file,
        concentration_vectors.astype(
            np.float32
        )
    )

    # --------------------------------------------------------
    # Metadata
    # --------------------------------------------------------

    metadata_file = (
        method_dir
        / "metadata.csv"
    )

    metadata.to_csv(
        metadata_file,
        index=False
    )

    # --------------------------------------------------------
    # Print
    # --------------------------------------------------------

    print()
    print(
        f"Saved {method} dataset:"
    )

    print(
        f"  Signals       : "
        f"{signal_file}"
    )

    print(
        f"  Labels        : "
        f"{label_file}"
    )

    print(
        f"  Concentration : "
        f"{concentration_file}"
    )

    print(
        f"  Metadata      : "
        f"{metadata_file}"
    )


# ============================================================
# MAIN
# ============================================================

def main():

    print()
    print("=" * 70)
    print(
        "ELECTROCHEMICAL MIXTURE DATASET GENERATOR"
    )
    print("=" * 70)

    print()
    print(
        "Substances:"
    )

    for index, substance in enumerate(
        SUBSTANCE_NAMES
    ):

        print(
            f"  {index}: {substance}"
        )

    # --------------------------------------------------------
    # Generate combinations
    # --------------------------------------------------------

    combinations_list = (
        generate_combinations()
    )

    print()
    print(
        f"Total combinations:"
        f" {len(combinations_list)}"
    )

    print()
    print(
        "Combination distribution:"
    )

    for size in range(
        1,
        len(SUBSTANCE_NAMES) + 1
    ):

        count = sum(
            len(combo) == size
            for combo in combinations_list
        )

        print(
            f"  {size} substance(s):"
            f" {count}"
        )

    # --------------------------------------------------------
    # Generate every method
    # --------------------------------------------------------

    for method in METHODS:

        (
            voltage,
            signals,
            labels,
            concentration_vectors,
            metadata,
        ) = generate_method_dataset(
            method=method,
            combinations_list=combinations_list,
        )

        save_method_dataset(
            method=method,
            voltage=voltage,
            signals=signals,
            labels=labels,
            concentration_vectors=concentration_vectors,
            metadata=metadata,
        )

    # --------------------------------------------------------
    # Complete
    # --------------------------------------------------------

    print()
    print("=" * 70)
    print(
        "MIXTURE DATASET GENERATION COMPLETE"
    )
    print("=" * 70)

    print()
    print(
        f"Output directory:"
    )

    print(
        OUTPUT_DIR
    )

    print()


# ============================================================
# ENTRY POINT
# ============================================================

if __name__ == "__main__":

    main()