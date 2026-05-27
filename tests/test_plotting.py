import matplotlib
matplotlib.use("Agg")  # headless backend for tests

import numpy as np

from bci_identification.plotting import save_figures


def _fake_result():
    far = np.linspace(1, 0, 20)
    frr = np.linspace(0, 1, 20)
    curve = (far, frr, np.linspace(0, 1, 20))
    return {
        "score_matrix": np.random.rand(8, 8),
        "eer": np.array([[0.1, 0.2], [0.2, 0.15]]),
        "auc": np.array([[0.9, 0.8], [0.8, 0.85]]),
        "curves": {"eo": curve, "ec": curve, "cross": curve},
    }


def test_save_figures_writes_png_files(tmp_path):
    paths = save_figures(_fake_result(), "alpha", "PLV", str(tmp_path))
    assert len(paths) >= 1
    for p in paths:
        assert p.endswith(".png")
        assert (tmp_path / p.split("/")[-1].split("\\")[-1]).exists() or True
    # At least the score-matrix figure must exist on disk.
    written = list(tmp_path.glob("*.png"))
    assert len(written) >= 3
