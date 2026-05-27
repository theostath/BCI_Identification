"""Integration test on real PhysioNet EDF data.

Drop a few baseline recordings (e.g. S001R01.edf, S001R02.edf, S002R01.edf,
S002R02.edf) into ``tests/data/`` to exercise the full load -> EER path on real
signals. Without them, the test skips cleanly so CI stays green.

Parity-test hook: if MATLAB reference outputs are exported later, add assertions
comparing them against the pipeline result here.
"""

from __future__ import annotations

import os

import numpy as np
import pytest

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")


def _available_subjects(n_max=2):
    """Return the count of consecutive subjects (from S001) with both runs present."""
    pytest.importorskip("mne")
    count = 0
    for idx in range(1, n_max + 1):
        eo = os.path.join(DATA_DIR, f"S{idx:03d}R01.edf")
        ec = os.path.join(DATA_DIR, f"S{idx:03d}R02.edf")
        if os.path.exists(eo) and os.path.exists(ec):
            count += 1
        else:
            break
    return count


def test_full_pipeline_on_sample_edf():
    n = _available_subjects(2)
    if n < 2:
        pytest.skip("No sample .edf files in tests/data/ (need >=2 subjects).")

    from bci_identification.io import load_dataset
    from bci_identification.pipeline import run_pipeline

    eo, ec = load_dataset(DATA_DIR, n_subjects=n)
    assert eo.shape[1:] == (64, 9600)

    res = run_pipeline(eo, ec, band="alpha", metric="PLV", apply_car=True)
    dim = 2 * n * 5
    assert res["score_matrix"].shape == (dim, dim)
    assert res["eer"].shape == (2, 2)
    assert np.all((res["eer"] >= 0) & (res["eer"] <= 1))
    # Scores are similarities in (0, 1].
    off_diag = res["score_matrix"][~np.eye(dim, dtype=bool)]
    assert np.all((off_diag > 0) & (off_diag <= 1))
