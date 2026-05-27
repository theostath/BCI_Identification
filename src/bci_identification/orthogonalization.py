"""Linear orthogonalization of one signal with respect to another.

Mirrors the MATLAB ``orthogonalization.m`` (Fraschini's leakage correction):
fit ``y(t) = a + b*x(t)`` by least squares and return ``y(t) - b*x(t)``
(the slope component is removed; the intercept is kept).
"""

from __future__ import annotations

import numpy as np


def orthogonalize(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Return ``y`` with its linear-slope component on ``x`` removed.

    Parameters
    ----------
    x, y : ndarray, shape (n_samples,)

    Returns
    -------
    ndarray, shape (n_samples,)
    """
    x = np.asarray(x, dtype=float).ravel()
    y = np.asarray(y, dtype=float).ravel()
    design = np.column_stack([np.ones_like(x), x])
    coef, *_ = np.linalg.lstsq(design, y, rcond=None)
    slope = coef[1]
    return y - slope * x
