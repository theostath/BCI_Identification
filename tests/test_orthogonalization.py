import numpy as np

from bci_identification.orthogonalization import orthogonalize


def test_preserves_length():
    x = np.random.randn(500)
    y = np.random.randn(500)
    assert orthogonalize(x, y).shape == y.shape


def test_collinear_signal_orthogonalizes_to_zero():
    # y is a pure scaling of x -> removing the slope component leaves ~0.
    x = np.random.randn(500)
    y = 3.0 * x
    np.testing.assert_allclose(orthogonalize(x, y), 0.0, atol=1e-9)


def test_residual_has_no_linear_component_on_x():
    # After orthogonalization, the best-fit slope of the residual on x is ~0.
    rng = np.random.default_rng(0)
    x = rng.standard_normal(1000)
    y = 2.0 * x + rng.standard_normal(1000)
    y_orth = orthogonalize(x, y)
    slope = np.polyfit(x, y_orth, 1)[0]
    assert abs(slope) < 1e-9
