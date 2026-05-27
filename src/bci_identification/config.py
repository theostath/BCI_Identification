"""Pipeline constants and band/metric definitions.

These mirror the hardcoded values in the MATLAB ``main_program.m``.
"""

from __future__ import annotations

NCH: int = 64          # number of EEG channels
FS: int = 160          # sampling rate (Hz)
T: int = 60            # recording duration (seconds)
NS: int = 109          # number of subjects
EPOCH: int = 12        # epoch length (seconds)

N_SAMPLES: int = FS * T          # 9600 samples per recording
EPOCH_SAMPLES: int = FS * EPOCH  # 1920 samples per epoch
N_EPOCHS: int = T // EPOCH       # 5 non-overlapping epochs

# Frequency bands as (low_hz, high_hz).
BANDS: dict[str, tuple[float, float]] = {
    "delta": (1.0, 4.0),
    "theta": (4.0, 8.0),
    "alpha": (8.0, 13.0),
    "beta": (13.0, 30.0),
    "gamma": (30.0, 45.0),
}

# Functional-connectivity metrics.
METRICS: list[str] = ["PLV", "PLI", "COR", "AEC", "AECc", "COH"]

# Number of unique off-diagonal channel pairs (feature-vector length).
N_FEATURES: int = NCH * (NCH - 1) // 2  # 2016
