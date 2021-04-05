# BCI_Identification

Biometric identification using BCI systems

This is a repository about my undergraduate thesis (University of Patras, Electrical and Computer Engineering).

You can find the pdf of the thesis here: https://nemertes.lis.upatras.gr/jspui/handle/10889/14472

The process is: 
## Data

To download the data, go here: https://physionet.org/content/eegmmidb/1.0.0/

You want the data from every subject (S001-S109), and the first two runs (R01 = baseline run eyes open and R02 = baseline run eyes closed).

Once the zip file is downloaded, you unzip it and put these files (only .edf, not .edf.event) in the same directory as the code, so you can read them properly.

## Code

The code is written in Matlab and is in the "code" directory. In the main_programm.m you will find everything you need with explanatory commenting.

>import_eeg_data.m : Convert .edf (European Data Format) files to matrices.
>CAR.m : Apply CAR (Common Average Referencing) filter (spatial filter) to the raw EEG (ElectroEncephaloGraphy) data.
>eegfilt.m : Apply bandpass filter to seperate EEG data into specific bands.
>ConnectivityMatrix.m : Compute connectivity matrix for each subject, each epoch and each frequency band.
>FeatureVector.m : Extract feature vectors from the upper triangular connectivity matrix
>CalcScoreMatrix.m : Calculate score matrix for each FC metric using the Euclidean distance.
>EERMatrix.m : Calculate EER (Equal Error Rate) matrix for each metric in each band. This function, also, returns the FAR (False Accept Rate) and FRR (False Rejection Rate) for each metric and each band.

From line 676 and below there are some prints to see the results.

## Other Info

Bands:
delta band = [1-4 Hz], theta band = [4-8 Hz], alpha band = [8-13 Hz], beta band = [13-30 Hz], gamma band = [30-45 Hz]

Functional Connectivity (FC) Metrics:
1) PLV (Phase Locking Value)
2) PLI (Phase Lag Index)
3) COR (Pearson's Correlation Coefficient)
4) AEC (Amplitude Envelope Correlation)
5) AECc (AEC corrected version)
6) COH (Spectral Coherence)
