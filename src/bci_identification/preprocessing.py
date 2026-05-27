"""Spatial (CAR) and spectral (band-pass) preprocessing.

Mirrors the MATLAB ``CAR.m`` and ``eegfilt.m`` (FIR, zero-phase).
"""

from __future__ import annotations

import numpy as np
from scipy.signal import filtfilt, firwin


def car(data: np.ndarray) -> np.ndarray:
    """Common Average Reference: subtract the per-sample mean over channels.

    Parameters
    ----------
    data : ndarray, shape (n_channels, n_samples)

    Returns
    -------
    ndarray of the same shape with the common average removed.
    """
    data = np.asarray(data, dtype=float)
    return data - data.mean(axis=0, keepdims=True)


def _fir_order(fs: int, lo: float) -> int:
    """FIR tap count, following eegfilt's ``3 * fix(srate / locutoff)`` rule."""
    order = 3 * int(fs / lo)
    if order % 2 == 0:  # firwin needs odd length for a band-pass (type-I) filter
        order += 1
    return order


def bandpass(data: np.ndarray, fs: int, lo: float, hi: float) -> np.ndarray:
    """Zero-phase FIR band-pass filter.

    Parameters
    ----------
    data : ndarray, shape (n_channels, n_samples)
    fs : int
        Sampling rate (Hz).
    lo, hi : float
        Band edges (Hz).

    Returns
    -------
    ndarray of the same shape, filtered to ``[lo, hi]``.
    """
    data = np.asarray(data, dtype=float)
    numtaps = _fir_order(fs, lo)
    taps = firwin(numtaps, [lo, hi], pass_zero=False, fs=fs)
    return filtfilt(taps, [1.0], data, axis=-1)
