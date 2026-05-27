import numpy as np
import pytest

from bci_identification.preprocessing import car, bandpass


def test_car_preserves_shape():
    data = np.random.randn(64, 1920)
    assert car(data).shape == data.shape


def test_car_zeroes_common_average():
    # After CAR the across-channel mean at every sample must be ~0.
    data = np.random.randn(64, 500)
    out = car(data)
    np.testing.assert_allclose(out.mean(axis=0), 0.0, atol=1e-12)


def test_car_identical_channels_become_zero():
    # If every channel is identical, the common average IS the signal,
    # so CAR removes everything.
    one = np.random.randn(1, 300)
    data = np.repeat(one, 8, axis=0)
    np.testing.assert_allclose(car(data), 0.0, atol=1e-12)


def test_bandpass_preserves_shape():
    data = np.random.randn(8, 1920)
    assert bandpass(data, fs=160, lo=8, hi=13).shape == data.shape


def test_bandpass_keeps_in_band_attenuates_out_of_band():
    fs = 160
    t = np.arange(0, 12, 1 / fs)
    in_band = np.sin(2 * np.pi * 10 * t)   # 10 Hz -> inside alpha (8-13)
    out_band = np.sin(2 * np.pi * 40 * t)  # 40 Hz -> outside alpha
    signal = (in_band + out_band)[None, :]

    filtered = bandpass(signal, fs=fs, lo=8, hi=13)[0]

    # In-band component should be largely retained; out-of-band suppressed.
    # Compare RMS of the filtered output against each pure component.
    rms = lambda x: np.sqrt(np.mean(x**2))
    # Most of the retained energy should resemble the 10 Hz component.
    corr_in = np.corrcoef(filtered, in_band)[0, 1]
    corr_out = np.corrcoef(filtered, out_band)[0, 1]
    assert corr_in > 0.9
    assert abs(corr_out) < 0.2
    assert rms(filtered) < rms(signal[0])  # out-of-band energy removed
