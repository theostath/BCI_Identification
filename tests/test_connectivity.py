import numpy as np
import pytest

from bci_identification.connectivity import connectivity_matrix
from bci_identification.config import METRICS

FS = 160
N = 1920  # 12 s @ 160 Hz
T = np.arange(N) / FS


def sine(freq, phase=0.0):
    return np.sin(2 * np.pi * freq * T + phase)


@pytest.mark.parametrize("metric", METRICS)
def test_shape_symmetry_zero_diagonal(metric):
    rng = np.random.default_rng(1)
    epoch = rng.standard_normal((4, N))
    mat = connectivity_matrix(epoch, metric)
    assert mat.shape == (4, 4)
    np.testing.assert_allclose(mat, mat.T, atol=1e-9)        # symmetric
    np.testing.assert_allclose(np.diag(mat), 0.0, atol=1e-9)  # zero diagonal


def test_plv_phase_locked_is_one():
    epoch = np.vstack([sine(10), sine(10, phase=np.pi / 4)])
    mat = connectivity_matrix(epoch, "PLV")
    assert mat[0, 1] > 0.95


def test_plv_distinct_frequencies_is_low():
    epoch = np.vstack([sine(10), sine(23)])
    mat = connectivity_matrix(epoch, "PLV")
    assert mat[0, 1] < 0.3


def test_pli_constant_lag_is_one():
    # A constant non-zero phase lag has a constant sign of sin(dphi) -> PLI ~ 1.
    epoch = np.vstack([sine(10), sine(10, phase=np.pi / 4)])
    mat = connectivity_matrix(epoch, "PLI")
    assert mat[0, 1] > 0.95


def test_cor_identical_is_one_negated_is_minus_one():
    base = sine(10)
    epoch = np.vstack([base, base, -base])
    mat = connectivity_matrix(epoch, "COR")
    assert mat[0, 1] == pytest.approx(1.0, abs=1e-6)
    assert mat[0, 2] == pytest.approx(-1.0, abs=1e-6)


def test_aec_identical_is_one():
    base = sine(10) + 0.5 * sine(7)  # non-trivial envelope
    epoch = np.vstack([base, base])
    mat = connectivity_matrix(epoch, "AEC")
    assert mat[0, 1] > 0.99


def test_aecc_in_range_and_symmetric():
    rng = np.random.default_rng(2)
    epoch = rng.standard_normal((5, N))
    mat = connectivity_matrix(epoch, "AECc")
    assert np.all(mat >= -1.0001) and np.all(mat <= 1.0001)
    np.testing.assert_allclose(mat, mat.T, atol=1e-9)


def test_coh_identical_is_high():
    base = sine(10) + 0.3 * sine(25)
    epoch = np.vstack([base, base])
    mat = connectivity_matrix(base[None].repeat(2, 0) * 0 + epoch, "COH")
    assert mat[0, 1] > 0.95


def test_unknown_metric_raises():
    with pytest.raises(ValueError):
        connectivity_matrix(np.random.randn(3, N), "NOPE")
