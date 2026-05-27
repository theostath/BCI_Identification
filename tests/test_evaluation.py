import numpy as np
import pytest

from bci_identification.evaluation import (
    genuine_impostor_scores,
    far_frr,
    eer_matrix,
)


def labeled_score_matrix(ns, ne):
    """Score matrix where same-subject pairs = 1.0 and impostor pairs = 0.0."""
    half = ns * ne
    subj = np.concatenate([np.repeat(np.arange(ns), ne)] * 2)
    dim = 2 * half
    mat = np.zeros((dim, dim))
    for i in range(dim):
        for j in range(dim):
            if i != j and subj[i] == subj[j]:
                mat[i, j] = 1.0
    return mat


def test_genuine_impostor_counts_and_values():
    ns, ne = 2, 2
    mat = labeled_score_matrix(ns, ne)
    g1, i1, g2, i2, g3, i3 = genuine_impostor_scores(mat, ns, ne)

    # within-task genuine = C(ne,2)*ns ; cross genuine = ne*ne*ns
    assert len(g1) == (ne * (ne - 1) // 2) * ns == 2
    assert len(g3) == 2
    assert len(g2) == ne * ne * ns == 8
    # within-task total pairs C(half,2)=6 -> 4 impostor each; cross 16 -> 8 impostor
    assert len(i1) == 4 and len(i3) == 4
    assert len(i2) == 8
    # genuine pairs are the 1.0 cells, impostor pairs the 0.0 cells
    assert np.all(g1 == 1.0) and np.all(g2 == 1.0) and np.all(g3 == 1.0)
    assert np.all(i1 == 0.0) and np.all(i2 == 0.0) and np.all(i3 == 0.0)


def test_far_frr_in_unit_range_and_monotonic():
    genuine = np.array([0.8, 0.85, 0.9, 0.95])
    impostor = np.array([0.1, 0.15, 0.2, 0.25])
    far, frr, thres = far_frr(genuine, impostor)
    assert far.shape == frr.shape == thres.shape
    assert np.all((far >= 0) & (far <= 1))
    assert np.all((frr >= 0) & (frr <= 1))
    # As the threshold rises, more genuine are rejected (FRR up) and fewer
    # impostors accepted (FAR down).
    assert np.all(np.diff(frr) >= 0)
    assert np.all(np.diff(far) <= 0)


def test_eer_zero_for_separable_scores():
    res = eer_matrix(labeled_score_matrix(3, 2), 3, 2)
    assert res["eer"].shape == (2, 2)
    assert res["auc"].shape == (2, 2)
    # Perfectly separable -> EER ~ 0 everywhere.
    assert np.all(res["eer"] < 1e-6)
    # EER matrix is symmetric (cross-task entry mirrored).
    np.testing.assert_allclose(res["eer"], res["eer"].T, atol=1e-12)
