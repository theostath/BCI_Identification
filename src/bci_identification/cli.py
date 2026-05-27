"""Command-line entry point.

Example
-------
    bci-identify run --data-dir ./edf --metric PLV --band alpha --out results/
    bci-identify run --data-dir ./edf --metric all --band all --plot
"""

from __future__ import annotations

import argparse
import csv
import os

import numpy as np

from .config import BANDS, METRICS, NS


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="bci-identify",
        description="EEG functional-connectivity biometric identification.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    run = sub.add_parser("run", help="Run the identification pipeline.")
    run.add_argument("--data-dir", required=True, help="Directory of PhysioNet .edf files.")
    run.add_argument(
        "--metric", default="all", choices=[*METRICS, "all"],
        help="Connectivity metric (default: all).",
    )
    run.add_argument(
        "--band", default="all", choices=[*BANDS, "all"],
        help="Frequency band (default: all).",
    )
    run.add_argument(
        "--car", action=argparse.BooleanOptionalAction, default=True,
        help="Apply Common Average Referencing (default: on).",
    )
    run.add_argument("--n-subjects", type=int, default=NS, help="Number of subjects to load.")
    run.add_argument("--out", default="results", help="Output directory (default: results).")
    run.add_argument("--plot", action="store_true", help="Save figures (requires matplotlib).")
    return parser


def main(argv=None) -> int:
    args = build_parser().parse_args(argv)

    # Imported here so `build_parser` (and its tests) stay free of heavy deps.
    from .io import load_dataset
    from .pipeline import run_sweep

    bands = list(BANDS) if args.band == "all" else [args.band]
    metrics = list(METRICS) if args.metric == "all" else [args.metric]

    print(f"Loading {args.n_subjects} subjects from {args.data_dir} ...")
    eo, ec = load_dataset(args.data_dir, n_subjects=args.n_subjects)

    print(f"Running bands={bands} metrics={metrics} (CAR={args.car}) ...")
    results = run_sweep(eo, ec, bands=bands, metrics=metrics, apply_car=args.car)

    os.makedirs(args.out, exist_ok=True)
    _save_results(results, args.out)
    if args.plot:
        _save_plots(results, args.out)
    print(f"Done. Results written to {args.out}/")
    return 0


def _save_results(results, out_dir: str) -> None:
    summary_path = os.path.join(out_dir, "eer_summary.csv")
    with open(summary_path, "w", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow(["band", "metric", "eer_eo", "eer_ec", "eer_cross"])
        for (band, metric), res in results.items():
            eer = res["eer"]
            writer.writerow([band, metric, eer[0, 0], eer[1, 1], eer[0, 1]])
            np.savez(
                os.path.join(out_dir, f"{band}_{metric}.npz"),
                score_matrix=res["score_matrix"],
                eer=res["eer"],
                auc=res["auc"],
            )


def _save_plots(results, out_dir: str) -> None:
    from . import plotting

    for (band, metric), res in results.items():
        plotting.save_figures(res, band, metric, out_dir)


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
