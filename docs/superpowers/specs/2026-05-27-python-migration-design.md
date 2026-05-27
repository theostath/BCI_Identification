# Python migration — design

**Date:** 2026-05-27
**Branch:** `python-migration`
**Status:** Approved (pending implementation plan)

## Goal

Port the MATLAB EEG-biometrics pipeline (`code/*.m`) to an idiomatic Python
package. The port reproduces the same methodology — CAR spatial filtering,
band-pass filtering, functional-connectivity feature extraction, Euclidean
similarity scoring, and Equal Error Rate (EER) evaluation — but uses standard
Python scientific libraries rather than transcribing the MATLAB line by line.

## Key decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Fidelity | Idiomatic equivalent + parity-test hooks | Faithful to the algorithms; not bit-identical to MATLAB. |
| EDF I/O | MNE-Python (`mne.io.read_raw_edf`) | The EEG-standard reader. |
| DSP / math | numpy + scipy | CAR, FIR band-pass, Hilbert, coherence, connectivity. |
| Interface | Installable package + CLI | Most maintainable and testable. |
| Validation | Sample-EDF integration test + synthetic property-based unit tests | User can drop a few real `.edf` files; unit tests need no external data. |
| Plotting | Optional, via `--plot` (matplotlib) | Reproduce the key README figures on demand. |

## Pipeline (mirrors the MATLAB stages)

1. **Load** — `mne.io.read_raw_edf`, keep first 64 channels and first 9600
   samples (60 s @ 160 Hz). Two tasks per subject: R01 = eyes open (EO),
   R02 = eyes closed (EC).
2. **CAR** — subtract the per-sample mean across channels.
3. **Band-pass** — 5 bands (delta 1–4, theta 4–8, alpha 8–13, beta 13–30,
   gamma 30–45 Hz). FIR design (`scipy.signal.firwin`) applied zero-phase
   (`filtfilt`), mirroring the MATLAB `eegfilt` (FIR + zero-phase).
4. **Epoching** — split each 60 s recording into 5 non-overlapping 12 s epochs
   (1920 samples each).
5. **Connectivity** — per subject/epoch/band/metric, a symmetric 64×64 matrix:
   - **PLV** — `abs(mean(exp(i·Δφ)))`, phases from `hilbert`.
   - **PLI** — `abs(mean(sign(sin(Δφ))))`.
   - **COR** — Pearson correlation of the raw signals.
   - **AEC** — Pearson correlation of Hilbert amplitude envelopes.
   - **AECc** — orthogonalized (leakage-corrected) AEC, symmetrized over the
     two orthogonalization directions.
   - **COH** — mean magnitude-squared coherence (`scipy.signal.coherence`).
6. **Feature vector** — flatten the lower triangle (matching the MATLAB `i>j`
   ordering) into a length `64·63/2 = 2016` vector.
7. **Score matrix** — pairwise similarity over all (task, subject, epoch)
   combinations: `1090×1090` (2 tasks × 109 subjects × 5 epochs);
   `score = 1/(1 + euclidean_distance)`.
8. **EER** — split scores into genuine/impostor per task-pair (EO–EO, EC–EC,
   EO–EC), sweep a threshold to get FAR/FRR curves, then derive the EER (point
   of minimum |FAR − FRR|) and AUC. Output a 2×2 EER matrix plus FAR/FRR/AUC.

## Architecture

```
src/bci_identification/
  __init__.py
  config.py          # NCH=64, FS=160, T=60, NS=109, EPOCH=12; BANDS dict; METRICS list
  io.py              # load_recording(path); load_dataset(data_dir, n_subjects)
  preprocessing.py   # car(data); bandpass(data, fs, lo, hi)
  epoching.py        # split_epochs(data, fs, epoch_s)
  connectivity.py    # connectivity_matrix(epoch, metric); _plv/_pli/_cor/_aec/_aecc/_coh
  orthogonalization.py  # orthogonalize(x, y)
  features.py        # feature_vector(conmat)
  scoring.py         # score_matrix(profiles_eo, profiles_ec)
  evaluation.py      # genuine_impostor_scores(); far_frr(); eer_matrix()
  pipeline.py        # run_one(band, metric, ...); run_all(...)
  cli.py             # argparse entry point
  plotting.py        # optional matplotlib helpers (connectivity, ROC, EER heatmap)
tests/
  test_preprocessing.py
  test_connectivity.py
  test_features.py
  test_scoring.py
  test_evaluation.py
  test_integration.py   # uses tests/data/*.edf if present, else pytest.skip
  conftest.py           # synthetic-signal fixtures
pyproject.toml
README-python.md   # install + CLI usage for the Python port (kept separate
                   # from the MATLAB-focused main README)
```

### Vectorization

The MATLAB computes each 64×64 matrix with explicit nested loops. A naive
transcription would be very slow in Python. PLV/PLI/COR/AEC are vectorized with
numpy (phase/envelope matrices, `np.corrcoef`); COH and AECc remain pairwise
(per-pair scipy coherence / orthogonalization) but only over the 2016
upper-triangle pairs. Results stay mathematically equivalent to the MATLAB.

### Data shapes

- Recording: `(n_channels=64, n_samples=9600)`.
- Dataset per task: `(n_subjects, 64, 9600)`.
- Epoch: `(64, 1920)`; connectivity: `(64, 64)`; feature vector: `(2016,)`.
- Feature profiles per (metric, band, task): `(n_subjects, n_epochs, 2016)`.
- Score matrix per (metric, band): `(1090, 1090)`.

## CLI

```
bci-identify run --data-dir <path> --metric PLV --band alpha \
    --car/--no-car --out results/ [--plot]
```

- `--metric` accepts a metric name or `all`; `--band` accepts a band name or `all`.
- `--car/--no-car` is the MATLAB `flag` toggle (CAR-filtered vs raw input).
- Results saved as `.npz` (score matrix, EER/FAR/FRR/AUC) and `.csv` (EER summary).
- `--plot` writes the connectivity matrix, ROC curve, and EER heatmap to `out/`.

## Testing

**Unit (synthetic, no external data):**
- Identical signals → PLV = 1 and COR = 1; anti-phase → COR = −1; independent
  noise → low PLV/PLI.
- AEC of identical envelopes → 1.
- `feature_vector` length is 2016 and ordering matches the MATLAB lower triangle.
- `score_matrix` is symmetric; identical inputs give `1/(1+0) = 1`.
- `far_frr` outputs lie in [0, 1]; EER ∈ [0, 1].

**Integration (real data):**
- `test_integration.py` runs load → … → EER on the sample `.edf` files placed
  in `tests/data/`; asserts output shapes and sane value ranges. Skips cleanly
  (`pytest.skip`) when no data is present, so CI without data still passes.
- Sample EDFs are gitignored via the existing `*.edf` rule.

## Non-goals

- Not bit-identical to the MATLAB output.
- Not porting the interactive `eegplot` viewer or every inline MATLAB plot cell.
- No GPU or multiprocessing (vectorized numpy is sufficient).

## Open items / future work

- Optional true numerical-parity tests against exported MATLAB reference
  outputs, if those are produced later (hooks left in `test_integration.py`).
