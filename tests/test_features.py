import numpy as np

from bci_identification.features import feature_vector


def test_length_is_n_choose_2():
    nch = 64
    mat = np.random.randn(nch, nch)
    vec = feature_vector(mat)
    assert vec.shape == (nch * (nch - 1) // 2,)


def test_matlab_lower_triangle_ordering():
    # MATLAB collects ConMat(i,j) for i>j, row by row:
    # (2,1),(3,1),(3,2),... -> 0-indexed (1,0),(2,0),(2,1),...
    mat = np.arange(16, dtype=float).reshape(4, 4)
    vec = feature_vector(mat)
    expected = [mat[1, 0], mat[2, 0], mat[2, 1], mat[3, 0], mat[3, 1], mat[3, 2]]
    np.testing.assert_array_equal(vec, expected)
