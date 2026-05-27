"""EDF loading via MNE-Python.

Mirrors the MATLAB ``import_eeg_data.m`` / ``edfread.m``: read the PhysioNet
``eegmmidb`` baseline runs (R01 = eyes open, R02 = eyes closed), keeping the
first ``n_channels`` channels and ``n_samples`` samples.

``mne`` is imported lazily so the rest of the package (and the unit tests) work
without it installed.
"""

from __future__ import annotations

import os

import numpy as np

from .config import NCH, N_SAMPLES, NS


def subject_filename(subject: int, run: int) -> str:
    """PhysioNet EDF filename for a 1-based subject and run, e.g. ``S001R01.edf``."""
    return f"S{subject:03d}R{run:02d}.edf"


def load_recording(path: str, n_channels: int = NCH, n_samples: int = N_SAMPLES) -> np.ndarray:
    """Read one EDF recording into a ``(n_channels, n_samples)`` array."""
    import mne  # lazy: only needed when actually reading data

    raw = mne.io.read_raw_edf(path, preload=True, verbose="ERROR")
    data = raw.get_data()  # (channels, samples)
    return np.asarray(data[:n_channels, :n_samples], dtype=float)


def load_dataset(
    data_dir: str,
    n_subjects: int = NS,
    run_eo: int = 1,
    run_ec: int = 2,
    n_channels: int = NCH,
    n_samples: int = N_SAMPLES,
):
    """Load the eyes-open and eyes-closed datasets from a directory of EDFs.

    Returns
    -------
    (eo, ec) : ndarrays of shape (n_subjects, n_channels, n_samples).
    """
    eo = np.zeros((n_subjects, n_channels, n_samples))
    ec = np.zeros((n_subjects, n_channels, n_samples))
    for idx in range(n_subjects):
        subject = idx + 1
        eo[idx] = load_recording(
            os.path.join(data_dir, subject_filename(subject, run_eo)),
            n_channels, n_samples,
        )
        ec[idx] = load_recording(
            os.path.join(data_dir, subject_filename(subject, run_ec)),
            n_channels, n_samples,
        )
    return eo, ec
