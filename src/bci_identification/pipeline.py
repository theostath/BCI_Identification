"""End-to-end orchestration of the identification pipeline.

Ties together preprocessing -> band-pass -> epoching -> connectivity ->
feature vectors -> scoring -> EER, for a single ``(band, metric)`` or a full
sweep over all bands and metrics.
"""

from __future__ import annotations

import numpy as np

from .config import BANDS, EPOCH, FS, METRICS
from .connectivity import connectivity_matrix
from .epoching import split_epochs
from .evaluation import eer_matrix
from .features import feature_vector
from .preprocessing import bandpass, car
from .scoring import score_matrix


def compute_profiles(dataset, band, metric, fs=FS, epoch_s=EPOCH, apply_car=True):
    """Feature profiles for one task dataset.

    Parameters
    ----------
    dataset : ndarray, shape (n_subjects, n_channels, n_samples)
    band : str
        Key into :data:`config.BANDS`.
    metric : str
        Connectivity metric name.

    Returns
    -------
    ndarray, shape (n_subjects, n_epochs, n_features).
    """
    dataset = np.asarray(dataset, dtype=float)
    lo, hi = BANDS[band]
    profiles = []
    for recording in dataset:
        data = car(recording) if apply_car else recording
        filtered = bandpass(data, fs, lo, hi)
        epochs = split_epochs(filtered, fs, epoch_s)
        vectors = [feature_vector(connectivity_matrix(ep, metric)) for ep in epochs]
        profiles.append(np.stack(vectors))
    return np.stack(profiles)


def run_pipeline(eo, ec, band, metric, fs=FS, epoch_s=EPOCH, apply_car=True):
    """Run the full pipeline for one ``(band, metric)`` pairing.

    Returns the :func:`evaluation.eer_matrix` result dict with an added
    ``"score_matrix"`` entry.
    """
    prof_eo = compute_profiles(eo, band, metric, fs, epoch_s, apply_car)
    prof_ec = compute_profiles(ec, band, metric, fs, epoch_s, apply_car)
    scores = score_matrix(prof_eo, prof_ec)
    n_subjects, n_epochs = prof_eo.shape[0], prof_eo.shape[1]
    result = eer_matrix(scores, n_subjects, n_epochs)
    result["score_matrix"] = scores
    return result


def run_sweep(eo, ec, bands=None, metrics=None, fs=FS, epoch_s=EPOCH, apply_car=True):
    """Run :func:`run_pipeline` for every (band, metric) combination.

    Returns
    -------
    dict keyed by ``(band, metric)`` -> result dict.
    """
    bands = bands or list(BANDS)
    metrics = metrics or list(METRICS)
    results = {}
    for band in bands:
        for metric in metrics:
            results[(band, metric)] = run_pipeline(
                eo, ec, band, metric, fs, epoch_s, apply_car
            )
    return results
