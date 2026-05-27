"""Genuine/impostor split, FAR/FRR curves, and the EER matrix.

Mirrors the MATLAB ``Genuine_Impostor_Scores.m``, ``Calculate_FAR_FRR.m``,
and ``EERMatrix.m``.

Sample ordering (set by :func:`bci_identification.scoring.score_matrix`):
the first ``n_subjects * n_epochs`` rows are the eyes-open (EO, "Task 1")
samples, the next block the eyes-closed (EC, "Task 2") samples, each ordered
subject-major then epoch-minor. Two samples are *genuine* when they share a
subject, *impostor* otherwise.
"""

from __future__ import annotations

import numpy as np


def _subject_task_labels(n_subjects: int, n_epochs: int):
    half = n_subjects * n_epochs
    subj_one_task = np.repeat(np.arange(n_subjects), n_epochs)
    subjects = np.concatenate([subj_one_task, subj_one_task])
    tasks = np.concatenate([np.zeros(half, int), np.ones(half, int)])
    return subjects, tasks, half


def genuine_impostor_scores(score_mat, n_subjects, n_epochs):
    """Split scores into genuine/impostor lists for the three task cases.

    Returns
    -------
    (g_eo, i_eo, g_cross, i_cross, g_ec, i_ec) : tuple of 1-D ndarrays
        genuine/impostor scores for EO-EO, EO-EC (cross), and EC-EC.
    """
    score_mat = np.asarray(score_mat, dtype=float)
    subjects, tasks, half = _subject_task_labels(n_subjects, n_epochs)
    dim = 2 * half

    g_eo, i_eo, g_cross, i_cross, g_ec, i_ec = ([] for _ in range(6))

    for i in range(dim):
        for j in range(i + 1, dim):
            same = subjects[i] == subjects[j]
            s = score_mat[i, j]
            if tasks[i] == 0 and tasks[j] == 0:          # EO vs EO
                (g_eo if same else i_eo).append(s)
            elif tasks[i] == 1 and tasks[j] == 1:        # EC vs EC
                (g_ec if same else i_ec).append(s)
            else:                                         # EO vs EC (cross)
                (g_cross if same else i_cross).append(s)

    arr = lambda x: np.asarray(x, dtype=float)
    return arr(g_eo), arr(i_eo), arr(g_cross), arr(i_cross), arr(g_ec), arr(i_ec)


def far_frr(genuine, impostor):
    """False-accept and false-reject rates over a swept threshold.

    A score strictly greater than the threshold is *accepted*; ``<=`` is
    rejected. Returns ``(far, frr, thresholds)``.
    """
    genuine = np.asarray(genuine, dtype=float)
    impostor = np.asarray(impostor, dtype=float)

    lo = min(genuine.min(), impostor.min())
    hi = max(genuine.max(), impostor.max())
    n_thres = genuine.size + impostor.size
    step = (hi - lo) / n_thres * 10.0  # matches the MATLAB *10 speed-up
    thresholds = np.arange(lo, hi - step, step)

    # FRR = fraction of genuine at or below threshold (false rejects)
    # FAR = fraction of impostor above threshold (false accepts)
    frr = np.array([np.mean(genuine <= t) for t in thresholds])
    far = np.array([np.mean(impostor > t) for t in thresholds])
    return far, frr, thresholds


def _eer_point(far, frr):
    diff = np.abs(far - frr)
    k = int(np.argmin(diff))  # first index of the minimum
    return (far[k] + frr[k]) / 2.0


def eer_matrix(score_mat, n_subjects, n_epochs):
    """Equal Error Rate and AUC per task pairing.

    Returns
    -------
    dict with keys:
        ``eer``  : 2x2 ndarray  ([0,0]=EO-EO, [1,1]=EC-EC, [0,1]=[1,0]=cross)
        ``auc``  : 2x2 ndarray  (same layout)
        ``curves`` : {"eo": (far,frr,thres), "ec": ..., "cross": ...}
    """
    g_eo, i_eo, g_cross, i_cross, g_ec, i_ec = genuine_impostor_scores(
        score_mat, n_subjects, n_epochs
    )

    far_eo, frr_eo, th_eo = far_frr(g_eo, i_eo)
    far_cr, frr_cr, th_cr = far_frr(g_cross, i_cross)
    far_ec, frr_ec, th_ec = far_frr(g_ec, i_ec)

    eer = np.zeros((2, 2))
    eer[0, 0] = _eer_point(far_eo, frr_eo)
    eer[1, 1] = _eer_point(far_ec, frr_ec)
    eer[0, 1] = eer[1, 0] = _eer_point(far_cr, frr_cr)

    auc = np.zeros((2, 2))
    auc[0, 0] = abs(np.trapezoid(frr_eo, far_eo))
    auc[1, 1] = abs(np.trapezoid(frr_ec, far_ec))
    auc[0, 1] = auc[1, 0] = abs(np.trapezoid(frr_cr, far_cr))

    return {
        "eer": eer,
        "auc": auc,
        "curves": {
            "eo": (far_eo, frr_eo, th_eo),
            "ec": (far_ec, frr_ec, th_ec),
            "cross": (far_cr, frr_cr, th_cr),
        },
    }
