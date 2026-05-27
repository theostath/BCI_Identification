import numpy as np

from bci_identification.pipeline import compute_profiles, run_pipeline

FS = 160
NSAMP = 3840  # 24 s -> 2 epochs of 12 s
NS, NCH = 5, 8
N_FEATURES = NCH * (NCH - 1) // 2  # 28


def separable_dataset(ns=NS, nch=NCH, nsamp=NSAMP, seed=0):
    """Subject-distinctive multichannel data.

    Each subject linearly mixes three fixed alpha-band oscillators (9/10/11 Hz)
    through a subject-specific random mixing matrix, plus tiny noise. The
    resulting connectivity pattern is graded, stable within a subject (genuine
    pairs match), and differs across subjects (impostor pairs do not)."""
    t = np.arange(nsamp) / FS
    sources = np.vstack([
        np.sin(2 * np.pi * 9 * t),
        np.sin(2 * np.pi * 10 * t),
        np.sin(2 * np.pi * 11 * t),
    ])  # (3, nsamp), all inside the alpha band
    data = np.zeros((ns, nch, nsamp))
    for s in range(ns):
        mixing = np.random.default_rng(2000 + s).standard_normal((nch, 3))  # fixed per subject
        noise = np.random.default_rng(seed * 100 + s).standard_normal((nch, nsamp)) * 0.01
        data[s] = mixing @ sources + noise
    return data


def test_compute_profiles_shape():
    data = separable_dataset()
    prof = compute_profiles(data, band="alpha", metric="PLV", fs=FS, apply_car=True)
    assert prof.shape == (NS, 2, N_FEATURES)


def test_run_pipeline_outputs():
    eo = separable_dataset(seed=1)
    ec = separable_dataset(seed=1)
    res = run_pipeline(eo, ec, band="alpha", metric="PLV", fs=FS, apply_car=False)
    dim = 2 * NS * 2
    assert res["score_matrix"].shape == (dim, dim)
    assert res["eer"].shape == (2, 2)
    assert np.all((res["eer"] >= 0) & (res["eer"] <= 1))


def test_separable_subjects_give_low_eer():
    # Same fixed mixing per subject across both tasks -> easy identification.
    eo = separable_dataset(seed=2)
    ec = separable_dataset(seed=2)
    res = run_pipeline(eo, ec, band="alpha", metric="COR", fs=FS, apply_car=False)
    assert np.all(res["eer"] < 0.3)
