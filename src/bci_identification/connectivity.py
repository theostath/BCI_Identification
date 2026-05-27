"""Functional-connectivity matrices.

Mirrors the MATLAB ``ConnectivityMatrix.m``. Each function returns a symmetric
``(n_channels, n_channels)`` matrix with a zero diagonal (only the unique
off-diagonal pairs carry information, matching the MATLAB ``i<j`` fill).
"""

from __future__ import annotations

import numpy as np
from scipy.signal import coherence, hilbert

from .orthogonalization import orthogonalize


def _zero_diag(mat: np.ndarray) -> np.ndarray:
    np.fill_diagonal(mat, 0.0)
    return mat


def _pearson(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.corrcoef(a, b)[0, 1])


def _plv(data: np.ndarray) -> np.ndarray:
    phase = np.angle(hilbert(data, axis=-1))
    z = np.exp(1j * phase)                       # (nch, T)
    n = data.shape[1]
    plv = np.abs(z @ z.conj().T) / n             # mean over time of exp(i*dphi)
    return _zero_diag(np.real(plv))


def _pli(data: np.ndarray) -> np.ndarray:
    phase = np.angle(hilbert(data, axis=-1))
    dphi = phase[:, None, :] - phase[None, :, :]  # (nch, nch, T)
    pli = np.abs(np.mean(np.sign(np.sin(dphi)), axis=-1))
    return _zero_diag(pli)


def _cor(data: np.ndarray) -> np.ndarray:
    return _zero_diag(np.corrcoef(data))


def _aec(data: np.ndarray) -> np.ndarray:
    env = np.abs(hilbert(data, axis=-1))
    return _zero_diag(np.corrcoef(env))


def _aecc(data: np.ndarray) -> np.ndarray:
    nch = data.shape[0]
    env = np.abs(hilbert(data, axis=-1))
    mat = np.zeros((nch, nch))
    for i in range(nch):
        for j in range(i + 1, nch):
            x, y = data[i], data[j]
            x_orth_amp = np.abs(orthogonalize(x, y))
            aec1 = _pearson(env[i], x_orth_amp)
            y_orth_amp = np.abs(orthogonalize(y, x))
            aec2 = _pearson(y_orth_amp, env[j])
            mat[i, j] = mat[j, i] = (aec1 + aec2) / 2.0
    return mat


def _coh(data: np.ndarray) -> np.ndarray:
    nch = data.shape[0]
    mat = np.zeros((nch, nch))
    for i in range(nch):
        for j in range(i + 1, nch):
            _, cxy = coherence(data[i], data[j])
            mat[i, j] = mat[j, i] = float(np.mean(cxy))
    return mat


_DISPATCH = {
    "PLV": _plv,
    "PLI": _pli,
    "COR": _cor,
    "AEC": _aec,
    "AECc": _aecc,
    "COH": _coh,
}


def connectivity_matrix(epoch: np.ndarray, metric: str) -> np.ndarray:
    """Compute the connectivity matrix for one epoch and metric.

    Parameters
    ----------
    epoch : ndarray, shape (n_channels, n_samples)
    metric : str
        One of ``PLV``, ``PLI``, ``COR``, ``AEC``, ``AECc``, ``COH``.

    Returns
    -------
    ndarray, shape (n_channels, n_channels) — symmetric, zero diagonal.
    """
    try:
        fn = _DISPATCH[metric]
    except KeyError:
        raise ValueError(f"Unknown metric {metric!r}; expected one of {list(_DISPATCH)}")
    return fn(np.asarray(epoch, dtype=float))
