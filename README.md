# BCI Identification with EEG Baseline Recordings

This repository contains the MATLAB implementation used for an undergraduate thesis at the University of Patras on biometric identification with EEG-based brain-computer interface data.

The pipeline uses resting-state baseline EEG recordings from PhysioNet and follows four main stages:

1. Data loading from EDF files
2. Preprocessing with Common Average Referencing (CAR) and bandpass filtering
3. Functional connectivity feature extraction
4. Score-based biometric evaluation with ROC and EER analysis

Thesis reference: https://nemertes.lis.upatras.gr/jspui/handle/10889/14472

## Dataset

This project uses the EEG Motor Movement/Imagery Dataset from PhysioNet:

- Dataset overview: https://physionet.org/content/eegmmidb/1.0.0/
- Access/download page: https://physionet.org/content/eegmmidb/1.0.0/S106/

The code in this repository uses only the two baseline runs for each subject:

- `R01`: baseline, eyes open
- `R02`: baseline, eyes closed

For the full experiment, you need baseline EDF files for all subjects:

- `S001R01.edf` to `S109R01.edf`
- `S001R02.edf` to `S109R02.edf`

Only the `.edf` files are required. The `.edf.event` files are not used by this code.

## Prerequisites

- MATLAB R2017b or newer
- Signal Processing Toolbox

The code uses MATLAB signal-processing functions such as `hilbert` and `mscohere`, so the toolbox requirement is important.

## Repository Layout

- `README.md`
- `code/main_program.m`: main entry point
- `code/import_eeg_data.m`: EDF loading and validation
- `code/ConnectivityMatrix.m`: connectivity metrics
- `code/FeatureVector.m`: upper-triangular feature extraction
- `code/CalcScoreMatrix.m`: similarity scoring with Euclidean distance
- `code/EERMatrix.m`: EER, FAR, FRR, and AUC computation

## Configuration

The main script includes a configuration block near the top of `code/main_program.m`:

- `data_dir`: directory that contains the EDF files
- `Ns`: number of subjects to process
- `epoch`: non-overlapping epoch length in seconds
- `use_car`: enable or disable CAR preprocessing
- `enable_plots`: enable or disable plotting
- `enable_optional_distribution_plot`: optionally use `PlotDistributionOfGenuineImpScores.m` if you add that helper yourself

By default, `data_dir` points to the `code` directory, so the easiest setup is to place the EDF files there.

## Quick Smoke Test

Use this path first before attempting the full 109-subject run.

1. Download these files from PhysioNet:
   - `S001R01.edf`
   - `S001R02.edf`
   - `S002R01.edf`
   - `S002R02.edf`
   - `S003R01.edf`
   - `S003R02.edf`
2. Place them in `BCI_Identification/code`, or another folder and update `data_dir`.
3. Open `code/main_program.m`.
4. Set:
   - `Ns = 3`
   - `enable_plots = true` or `false`, depending on whether you want figures
5. Run the script from MATLAB.

## Full Experiment

For the full experiment:

1. Download `R01` and `R02` EDF files for all subjects `S001` through `S109`.
2. Place them in the configured `data_dir`.
3. Set `Ns = 109` in `code/main_program.m`.
4. Run the script.

The full run is computationally expensive. It computes multiple connectivity metrics across five frequency bands, five epochs per subject, and two baseline tasks. Start with the smoke test unless you already know the full dataset is available and the runtime is acceptable on your machine.

## How to Run Locally

In MATLAB:

1. Open the repository.
2. Open `code/main_program.m`.
3. Confirm that `data_dir` points to the folder that contains the EDF files.
4. Adjust `Ns` for either the smoke test or the full run.
5. Press Run, or execute:

```matlab
run('code/main_program.m')
```

If you prefer, you can also change MATLAB's current folder to `code` and run:

```matlab
main_program
```

## Output

The script computes:

- Functional connectivity matrices
- Feature vectors
- Similarity score matrices
- FAR and FRR curves
- EER matrices
- AUC values

If `enable_plots` is set to `true`, the script also produces a large number of figures for inspection.

## Functional Connectivity Metrics

The implementation evaluates the following metrics:

1. PLV: Phase Locking Value
2. PLI: Phase Lag Index
3. COR: Pearson correlation coefficient
4. AEC: Amplitude Envelope Correlation
5. AECc: corrected AEC
6. COH: Spectral coherence

The analysis is repeated for five EEG frequency bands:

- Delta: `1-4 Hz`
- Theta: `4-8 Hz`
- Alpha: `8-13 Hz`
- Beta: `13-30 Hz`
- Gamma: `30-45 Hz`

## Notes

- `main_program.m` is the correct entry-point filename.
- `import_eeg_data.m` now validates missing files and reports which EDF path is missing.
- `CalcScoreMatrix.m` uses Euclidean distance for scoring.
- The optional distribution plot helper is not included in this repository. If you do not have that file, keep `enable_optional_distribution_plot = false`.

## Example Figures

1. Raw EEG data from all 64 channels from subject 1 during the baseline run with eyes open

![Raw EEG](https://user-images.githubusercontent.com/24894934/113600967-6c60e300-9649-11eb-93a7-73ab7ed388b6.png)

2. Zoomed view of one channel

![Single channel](https://user-images.githubusercontent.com/24894934/113601150-a3cf8f80-9649-11eb-9744-c215f09685be.png)

3. Delta-band EEG after preprocessing

![Delta band](https://user-images.githubusercontent.com/24894934/113601263-c5307b80-9649-11eb-91bf-1739200fb92d.png)

4. Functional connectivity matrix example

![Connectivity matrix](https://user-images.githubusercontent.com/24894934/113601365-e5603a80-9649-11eb-9d20-2f8ce0a3be59.png)

5. Feature vector example

![Feature vector](https://user-images.githubusercontent.com/24894934/113601501-16d90600-964a-11eb-8e51-375016add299.png)

6. Score matrix example

![Score matrix](https://user-images.githubusercontent.com/24894934/113601575-2fe1b700-964a-11eb-9b8d-31b5ee82119e.png)

7. FAR and FRR example

![FAR/FRR](https://user-images.githubusercontent.com/24894934/113601715-5e5f9200-964a-11eb-84f0-6781a0fbb2d8.png)

8. ROC curve example

![ROC curve](https://user-images.githubusercontent.com/24894934/113601794-759e7f80-964a-11eb-8144-68fff6a95586.png)

9. EER matrix example

![EER matrix](https://user-images.githubusercontent.com/24894934/113601824-83ec9b80-964a-11eb-9af3-40281636081b.png)
