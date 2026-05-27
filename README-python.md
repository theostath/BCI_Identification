# BCI_Identification — Python port

![Python](https://img.shields.io/badge/Python-3.10%2B-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/status-research--prototype-blue)

An idiomatic Python reimplementation of the MATLAB EEG functional-connectivity
biometric-identification pipeline. Same methodology (CAR → band-pass → epoching
→ functional connectivity → Euclidean-style similarity scoring → Equal Error
Rate), built on `mne` (EDF I/O) and `numpy`/`scipy` (DSP and connectivity).

> The original MATLAB implementation lives in [`code/`](code/) and is described
> in the main [README](README.md). This document covers the Python port only.

## Install

```bash
python -m pip install -e .          # core (numpy, scipy, mne)
python -m pip install -e ".[plot]"  # + matplotlib for --plot
python -m pip install -e ".[dev]"   # + pytest for the test suite
```

Requires Python ≥ 3.10.

## Data

Download the PhysioNet *EEG Motor Movement/Imagery* dataset
(<https://physionet.org/content/eegmmidb/1.0.0/>): subjects S001–S109, runs
**R01** (baseline eyes-open) and **R02** (baseline eyes-closed). Put the `.edf`
files in one directory and point `--data-dir` at it.

## Usage

```bash
# One band / one metric, with CAR, saving results + figures
bci-identify run --data-dir ./edf --metric PLV --band alpha --car --out results/ --plot

# Full sweep over all 6 metrics × 5 bands, without CAR
bci-identify run --data-dir ./edf --metric all --band all --no-car

# Equivalent module form
python -m bci_identification run --data-dir ./edf
```

`--car/--no-car` is the MATLAB `flag` toggle (CAR-filtered vs raw input).
Results are written as per-pairing `.npz` files (`score_matrix`, `eer`, `auc`)
plus an `eer_summary.csv`; `--plot` adds score-matrix, ROC, and EER figures.

### Library use

```python
from bci_identification.io import load_dataset
from bci_identification.pipeline import run_pipeline

eo, ec = load_dataset("./edf", n_subjects=109)
result = run_pipeline(eo, ec, band="alpha", metric="PLV", apply_car=True)
print(result["eer"])      # 2x2: [EO-EO, cross; cross, EC-EC]
```

## Project layout

```
src/bci_identification/
  config.py          constants (NCH, FS, T, NS, EPOCH) + BANDS + METRICS
  io.py              load_recording / load_dataset (MNE read_raw_edf)
  preprocessing.py   car(); bandpass()  (scipy firwin + filtfilt, zero-phase)
  epoching.py        split_epochs()
  connectivity.py    connectivity_matrix() -> PLV/PLI/COR/AEC/AECc/COH
  orthogonalization.py  orthogonalize()  (used by AECc)
  features.py        feature_vector()  (lower triangle -> length-2016 vector)
  scoring.py         score_matrix()  (1/(1+distance) similarity)
  evaluation.py      genuine_impostor_scores(); far_frr(); eer_matrix()
  pipeline.py        run_pipeline(); run_sweep()
  cli.py             command-line entry point
  plotting.py        optional matplotlib figures
tests/               property-based unit tests + optional sample-EDF integration
```

## MATLAB → Python mapping

| MATLAB | Python |
|--------|--------|
| `import_eeg_data.m` / `edfread.m` | `io.load_dataset` / `io.load_recording` |
| `CAR.m` | `preprocessing.car` |
| `eegfilt.m` | `preprocessing.bandpass` |
| epoching loop (STEP 3) | `epoching.split_epochs` |
| `ConnectivityMatrix.m` | `connectivity.connectivity_matrix` |
| `orthogonalization.m` | `orthogonalization.orthogonalize` |
| `FeatureVector.m` | `features.feature_vector` |
| `CalcScoreMatrix.m` | `scoring.score_matrix` |
| `Genuine_Impostor_Scores.m` | `evaluation.genuine_impostor_scores` |
| `Calculate_FAR_FRR.m` | `evaluation.far_frr` |
| `EERMatrix.m` | `evaluation.eer_matrix` |

## Notes on fidelity

This is an *idiomatic* port, not a bit-for-bit translation:

- **Distance metric.** `CalcScoreMatrix.m` computes `sum(sqrt((x-y).^2))`, which
  is the **L1 (Manhattan)** distance despite being named `Euclidian`. The port
  reproduces this (`score_matrix(..., distance="cityblock")`, the default); pass
  `distance="euclidean"` for the true Euclidean distance the prose describes.
- **Band-pass.** `scipy.signal.firwin` + `filtfilt` (zero-phase FIR), following
  `eegfilt`'s FIR design rather than copying its exact tap computation.
- **Correlation.** Uses `numpy.corrcoef` (the `1/(N-1)` Pearson form); the
  MATLAB AECc used a `1/N` normalization — a negligible difference at N=1920.

## Tests

```bash
python -m pytest            # unit tests run with no external data
```

Unit tests are property-based on synthetic signals (e.g. identical signals →
PLV = 1, anti-phase → COR = −1). `tests/test_integration.py` runs the full
load→EER path on real `.edf` files placed in `tests/data/`, and skips cleanly
when none are present.
