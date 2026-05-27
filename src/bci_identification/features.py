"""Feature-vector extraction from a connectivity matrix.

Mirrors the MATLAB ``FeatureVector.m``: collect the lower triangle (``i>j``)
row by row into a 1-D vector of length ``n_channels*(n_channels-1)/2``.
"""

from __future__ import annotations

import numpy as np


def feature_vector(conmat: np.ndarray) -> np.ndarray:
    """Flatten the strict lower triangle of ``conmat`` into a feature vector.

    Parameters
    ----------
    conmat : ndarray, shape (n_channels, n_channels)

    Returns
    -------
    ndarray, shape (n_channels*(n_channels-1)/2,)
    """
    conmat = np.asarray(conmat, dtype=float)
    nch = conmat.shape[0]
    return conmat[np.tril_indices(nch, k=-1)]
