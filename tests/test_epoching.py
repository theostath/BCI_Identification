import numpy as np

from bci_identification.epoching import split_epochs


def test_split_shape():
    data = np.random.randn(64, 9600)
    epochs = split_epochs(data, fs=160, epoch_s=12)
    # 60 s / 12 s = 5 epochs of 1920 samples.
    assert epochs.shape == (5, 64, 1920)


def test_split_is_contiguous_non_overlapping():
    data = np.arange(64 * 9600, dtype=float).reshape(64, 9600)
    epochs = split_epochs(data, fs=160, epoch_s=12)
    np.testing.assert_array_equal(epochs[0], data[:, 0:1920])
    np.testing.assert_array_equal(epochs[1], data[:, 1920:3840])
    np.testing.assert_array_equal(epochs[4], data[:, 4 * 1920 : 5 * 1920])


def test_split_drops_incomplete_trailing_epoch():
    # 9700 samples -> still only 5 full 1920-sample epochs (100 leftover dropped).
    data = np.random.randn(64, 9700)
    epochs = split_epochs(data, fs=160, epoch_s=12)
    assert epochs.shape[0] == 5
