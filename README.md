# BCI_Identification

Biometric identification using BCI systems

This is a repository about my undergraduate thesis (University of Patras, Electrical and Computer Engineering).

You can find the pdf of the thesis here: https://nemertes.lis.upatras.gr/jspui/handle/10889/14472

The general structure of the code is the following:
1) Data Collection (EEG)
2) Preprocessing (spatial filtering - CAR - / frequency filtering - bandpass -)
3) Feature Extraction (compute various functional connectivity metrics)
4) Classification (compute a score via Euclidean distance, define a threshold vector for decision making and find EER matrix)


## Data

To download the data, go here: https://physionet.org/content/eegmmidb/1.0.0/

You want the data from every subject (S001-S109), and the first two runs (R01 = baseline run eyes open and R02 = baseline run eyes closed).

Once the zip file is downloaded, you unzip it and put these files (only .edf, not .edf.event) in the same directory as the code, so you can read them properly.

## Prerequisites

To run this code you need Matlab 2017b version, or a newer one.

## Code

The code is written in Matlab and is in the "code" directory. In the main_programm.m you will find everything you need with explanatory commenting.

Some information about the functions that are beeing used:

>import_eeg_data.m : Convert .edf (European Data Format) files to matrices.    [+edfread.m]

>CAR.m : Apply CAR (Common Average Referencing) filter (spatial filter) to the raw EEG (ElectroEncephaloGraphy) data.

>eegfilt.m : Apply bandpass filter to seperate EEG data into specific bands.

Bands:
delta band = [1-4 Hz], theta band = [4-8 Hz], alpha band = [8-13 Hz], beta band = [13-30 Hz], gamma band = [30-45 Hz]

In line 75 of main_programm.m you can choose a flag  = 0 if you want to apply this process in the spatial filtered data (CAR), or choose a flag = 1 if you want to apply this process in the raw EEG data.

>ConnectivityMatrix.m : Compute connectivity matrix for each subject, each epoch and each frequency band.

Functional Connectivity (FC) Metrics:
1) PLV (Phase Locking Value)
2) PLI (Phase Lag Index)
3) COR (Pearson's Correlation Coefficient)
4) AEC (Amplitude Envelope Correlation)
5) AECc (AEC corrected version)
6) COH (Spectral Coherence)

>FeatureVector.m : Extract feature vectors from the upper triangular connectivity matrix

>CalcScoreMatrix.m : Calculate score matrix for each FC metric using the Euclidean distance.

>EERMatrix.m : Calculate EER (Equal Error Rate) matrix for each metric in each band. This function, also, returns the FAR (False Accept Rate) and FRR (False Rejection Rate) for each metric and each band.    [Genuine_Impostor_Scores.m and Calculate_FAR_FRR.m]

EER is the point of the ROC (Receiver Operating Characteristic) curve where FAR == FRR.

From line 676 and below there are some prints to see the results.

## Examples (Images)

1) Raw EEG data from all 64 channels from subject 1 during the baseline run with eyes open. The duration here is 12 seconds.

![image](https://user-images.githubusercontent.com/24894934/113600967-6c60e300-9649-11eb-93a7-73ab7ed388b6.png)

2) Zoom in to see the data from 1 channel.

![image](https://user-images.githubusercontent.com/24894934/113601150-a3cf8f80-9649-11eb-9744-c215f09685be.png)

3) After preprocessing, you can see the same data filtered in delta band [1-4 Hz].

![image](https://user-images.githubusercontent.com/24894934/113601263-c5307b80-9649-11eb-91bf-1739200fb92d.png)

4) Functional connectivity matrix for the PLV metric. It is from subject 1, in alpha band, during the baseline run with eyes closed.

![image](https://user-images.githubusercontent.com/24894934/113601365-e5603a80-9649-11eb-9d20-2f8ce0a3be59.png)

5) Extracting the feature vector from the upper triangular matrix of the last photo.

![image](https://user-images.githubusercontent.com/24894934/113601501-16d90600-964a-11eb-8e51-375016add299.png)

6) Score matrix for PLV metric in alpha band. This includes scores for 5 epochs, 109 subjects and 2 tasks (eyes open, eyes closed).

![image](https://user-images.githubusercontent.com/24894934/113601575-2fe1b700-964a-11eb-9b8d-31b5ee82119e.png)

7) Example of FAR and FRR values depending on the threshold value.

![image](https://user-images.githubusercontent.com/24894934/113601715-5e5f9200-964a-11eb-84f0-6781a0fbb2d8.png)

8) Example of a ROC curve.

![image](https://user-images.githubusercontent.com/24894934/113601794-759e7f80-964a-11eb-8144-68fff6a95586.png)

9) Finally, example of an EER matrix. The value 0 is the best for EER.

![image](https://user-images.githubusercontent.com/24894934/113601824-83ec9b80-964a-11eb-9af3-40281636081b.png)



