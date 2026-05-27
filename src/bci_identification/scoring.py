"""Similarity score matrix.

Mirrors the MATLAB ``CalcScoreMatrix.m``.

Note on the distance metric
---------------------------
The MATLAB code computes ``sum(sqrt((x - y).^2))``, which equals
``sum(|x - y|)`` — the L1 (Manhattan) distance — even though the variable is
named ``Euclidian``. We reproduce that behaviour faithfully (``distance``
defaults to ``"cityblock"``). Pass ``distance="euclidean"`` for the true
Euclidean distance the README prose describes.

The score is ``1 / (1 + distance)``; identical profiles score 1.0.
Samples are stacked as ``[all EO profiles, all EC profiles]``, each ordered
subject-major then epoch-minor, and the score matrix is their full pairwise
similarity (``2 * n_subjects * n_epochs`` rows/cols, diagonal zeroed).
"""

from __future__ import annotations

import numpy as np
from scipy.spatial.distance import pdist, squareform


def score_matrix(
    profiles_eo: np.ndarray,
    profiles_ec: np.ndarray,
    distance: str = "cityblock",
) -> np.ndarray:
    """Pairwise similarity scores across both tasks.

    Parameters
    ----------
    profiles_eo, profiles_ec : ndarray, shape (n_subjects, n_epochs, n_features)
        Feature profiles for the eyes-open and eyes-closed tasks.
    distance : str
        Any metric accepted by ``scipy.spatial.distance.pdist``. Defaults to
        ``"cityblock"`` to match the MATLAB implementation.

    Returns
    -------
    ndarray, shape (dim, dim) with ``dim = 2 * n_subjects * n_epochs`` —
        symmetric, zero diagonal.
    """
    eo = np.asarray(profiles_eo, dtype=float)
    ec = np.asarray(profiles_ec, dtype=float)
    n_features = eo.shape[-1]
    eo_flat = eo.reshape(-1, n_features)  # subject-major, epoch-minor
    ec_flat = ec.reshape(-1, n_features)
    samples = np.vstack([eo_flat, ec_flat])

    dist = squareform(pdist(samples, metric=distance))
    scores = 1.0 / (1.0 + dist)
    np.fill_diagonal(scores, 0.0)
    return scores
