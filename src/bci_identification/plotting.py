"""Optional matplotlib figures reproducing the key README plots.

Requires the ``plot`` extra (``pip install bci-identification[plot]``).
Generates, per (band, metric): the score matrix, the ROC curves, and the
EER heatmap.
"""

from __future__ import annotations

import os

import numpy as np


def save_figures(result: dict, band: str, metric: str, out_dir: str) -> list[str]:
    """Write the score-matrix, ROC, and EER figures for one result.

    Returns the list of file paths written.
    """
    import matplotlib

    matplotlib.use("Agg")  # safe default for non-interactive use
    import matplotlib.pyplot as plt

    os.makedirs(out_dir, exist_ok=True)
    stem = f"{band}_{metric}"
    paths: list[str] = []

    # 1) Score matrix
    fig, ax = plt.subplots()
    im = ax.imshow(result["score_matrix"], aspect="auto")
    fig.colorbar(im, ax=ax)
    ax.set_title(f"Score matrix ({metric}, {band})")
    ax.set_xlabel("sample index")
    ax.set_ylabel("sample index")
    p = os.path.join(out_dir, f"{stem}_score.png")
    fig.savefig(p, dpi=120, bbox_inches="tight")
    plt.close(fig)
    paths.append(p)

    # 2) ROC curves (FAR vs FRR) for the three task pairings
    fig, ax = plt.subplots()
    for name, (far, frr, _) in result["curves"].items():
        ax.plot(far, frr, label=name)
    ax.set_title(f"ROC ({metric}, {band})")
    ax.set_xlabel("FAR")
    ax.set_ylabel("FRR")
    ax.legend()
    p = os.path.join(out_dir, f"{stem}_roc.png")
    fig.savefig(p, dpi=120, bbox_inches="tight")
    plt.close(fig)
    paths.append(p)

    # 3) EER heatmap (2x2)
    fig, ax = plt.subplots()
    im = ax.imshow(result["eer"], vmin=0, vmax=0.5)
    fig.colorbar(im, ax=ax)
    ax.set_xticks([0, 1], ["EO", "EC"])
    ax.set_yticks([0, 1], ["EO", "EC"])
    for i in range(2):
        for j in range(2):
            ax.text(j, i, f"{result['eer'][i, j]:.3f}", ha="center", va="center", color="w")
    ax.set_title(f"EER matrix ({metric}, {band})")
    p = os.path.join(out_dir, f"{stem}_eer.png")
    fig.savefig(p, dpi=120, bbox_inches="tight")
    plt.close(fig)
    paths.append(p)

    return paths
