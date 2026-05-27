"""Split a recording into non-overlapping epochs.

Mirrors STEP 3 of the MATLAB ``main_program.m``.
"""

from __future__ import annotations

import numpy as np


def split_epochs(data: np.ndarray, fs: int, epoch_s: int) -> np.ndarray:
    """Cut ``data`` into contiguous non-overlapping epochs.

    Parameters
    ----------
    data : ndarray, shape (n_channels, n_samples)
    fs : int
        Sampling rate (Hz).
    epoch_s : int
        Epoch length in seconds.

    Returns
    -------
    ndarray, shape (n_epochs, n_channels, epoch_samples).
        Any trailing samples that do not fill a whole epoch are dropped.
    """
    data = np.asarray(data, dtype=float)
    n_channels, n_samples = data.shape
    epoch_samples = fs * epoch_s
    n_epochs = n_samples // epoch_samples
    usable = n_epochs * epoch_samples
    trimmed = data[:, :usable]
    # (n_channels, n_epochs, epoch_samples) -> (n_epochs, n_channels, epoch_samples)
    return trimmed.reshape(n_channels, n_epochs, epoch_samples).transpose(1, 0, 2)
