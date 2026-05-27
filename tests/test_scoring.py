import numpy as np
import pytest

from bci_identification.scoring import score_matrix


def test_shape_is_two_tasks_by_subjects_by_epochs():
    # (n_subjects=3, n_epochs=2, n_features=4) -> dim = 2*3*2 = 12
    eo = np.random.randn(3, 2, 4)
    ec = np.random.randn(3, 2, 4)
    mat = score_matrix(eo, ec)
    assert mat.shape == (12, 12)


def test_symmetric_with_zero_diagonal():
    eo = np.random.randn(3, 2, 4)
    ec = np.random.randn(3, 2, 4)
    mat = score_matrix(eo, ec)
    np.testing.assert_allclose(mat, mat.T, atol=1e-12)
    np.testing.assert_allclose(np.diag(mat), 0.0, atol=1e-12)


def test_scores_follow_one_over_one_plus_l1():
    # Two subjects, one epoch, 3 features. EC identical to EO.
    eo = np.array([[[0.0, 0.0, 0.0]], [[3.0, 0.0, 0.0]]])  # (2, 1, 3)
    ec = eo.copy()
    mat = score_matrix(eo, ec)
    # Stacked samples: [EO_s0, EO_s1, EC_s0, EC_s1]
    # L1(EO_s0, EO_s1) = 3 -> 1/(1+3) = 0.25
    assert mat[0, 1] == pytest.approx(0.25)
    # EO_s0 vs EC_s0 are identical -> L1 = 0 -> score 1.0
    assert mat[0, 2] == pytest.approx(1.0)
