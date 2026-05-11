% Thesis: Biometric system using EEG data
% Name: Theodoros - Panagiotis Stathakopoulos
% University of Patras, Department of Electrical and Computer Engineering

clear;
clc;

%% Configuration
% Update these values to switch between a fast smoke test and the full
% experiment.
script_dir = fileparts(mfilename('fullpath'));
data_dir = script_dir; % Default: EDF files live next to the MATLAB code.

Nch = 64; % Number of EEG channels
Fs = 160; % Sampling rate (Hz)
T = 60; % Signal duration (sec)
Ns = 109; % Number of subjects
epoch = 12; % Non-overlapping epoch duration (sec)

use_car = true;
enable_plots = true;
enable_optional_distribution_plot = false;

if mod(T, epoch) ~= 0
    error('main_program:InvalidEpoch', ...
        'The signal duration T must be divisible by epoch.');
end

%% -- STEP 1: READ THE DATA --
% 64 channels, 160 Hz, 1 minute duration, 109 subjects, 2 baseline
% recordings (eyes open / eyes closed)
[raw_dataEO,raw_dataEC] = import_eeg_data(Ns, Nch, Fs, T, data_dir);

%% Plot raw EEG data of the 1st subject.
if enable_plots
    figure();
    t = 0:1/Fs:1; % Time vector with 1 second duration.

    subplot(3,1,1);
    s1 = raw_dataEC(1,1:161,1);
    plot(t,s1);

    subplot(3,1,2);
    s2 = raw_dataEC(2,1:161,1);
    plot(t,s2);

    subplot(3,1,3);
    s3 = raw_dataEC(3,1:161,1);
    plot(t,s3);

    xlabel('Time (seconds)');
    ylabel('Amplitude (?V)');
    title('EEG signals (raw data from 3 channels)');

    eegplot(raw_dataEO(:,:,1), 'winlength', 12, ...
        'plottitle', 'Raw EEG data of subject No 1 (all channels)');
end

%% -- STEP 2a (PREPROCESSING): CAR (Common Average Referencing) --
[CAR_EO,CAR_EC] = CAR(raw_dataEO,raw_dataEC);

%% Plot CAR-filtered EEG data of the 1st subject.
if enable_plots
    eegplot(CAR_EO(:,:,1), 'winlength', 12, ...
        'plottitle', 'Raw EEG data of subject No 1 (all channels) - With CAR');
end

%% -- STEP 2b (PREPROCESSING): BANDPASS FILTERING --
% Delta band: 1-4 Hz
% Theta band: 4-8 Hz
% Alpha band: 8-13 Hz
% Beta band: 13-30 Hz
% Gamma band: 30-45 Hz

% Initialize matrices.

filtered_dataEO_delta = zeros(Nch,Fs*T,Ns) ;
filtered_dataEC_delta = zeros(Nch,Fs*T,Ns) ;

filtered_dataEO_theta = zeros(Nch,Fs*T,Ns) ;
filtered_dataEC_theta = zeros(Nch,Fs*T,Ns) ;

filtered_dataEO_alpha = zeros(Nch,Fs*T,Ns) ;
filtered_dataEC_alpha = zeros(Nch,Fs*T,Ns) ;

filtered_dataEO_beta = zeros(Nch,Fs*T,Ns) ;
filtered_dataEC_beta = zeros(Nch,Fs*T,Ns) ;

filtered_dataEO_gamma = zeros(Nch,Fs*T,Ns) ;
filtered_dataEC_gamma = zeros(Nch,Fs*T,Ns) ;

% arguments for eegfilt: (data, data sampling rate (Hz), low cutoff freq (Hz), high cutoff
% freq (Hz), frames per epochs [0 if data is 1 epoch])

for i=1:Ns
% With CAR
    if use_car
        % Delta band
        filtered_dataEO_delta(:,:,i) = eegfilt(CAR_EO(:,:,i), Fs, 1, 4, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_delta(:,:,i) = eegfilt(CAR_EC(:,:,i), Fs, 1, 4, 0, 0, 0, 'fir1', 0); % eyes closed

        % Theta band
        filtered_dataEO_theta(:,:,i) = eegfilt(CAR_EO(:,:,i), Fs, 4, 8, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_theta(:,:,i) = eegfilt(CAR_EC(:,:,i), Fs, 4, 8, 0, 0, 0, 'fir1', 0); % eyes closed

        % Alpha band
        filtered_dataEO_alpha(:,:,i) = eegfilt(CAR_EO(:,:,i), Fs, 8, 13, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_alpha(:,:,i) = eegfilt(CAR_EC(:,:,i), Fs, 8, 13, 0, 0, 0, 'fir1', 0); % eyes closed

        % Beta band
        filtered_dataEO_beta(:,:,i) = eegfilt(CAR_EO(:,:,i), Fs, 13, 30, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_beta(:,:,i) = eegfilt(CAR_EC(:,:,i), Fs, 13, 30, 0, 0, 0, 'fir1', 0); % eyes closed

        % Gamma band
        filtered_dataEO_gamma(:,:,i) = eegfilt(CAR_EO(:,:,i), Fs, 30, 45, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_gamma(:,:,i) = eegfilt(CAR_EC(:,:,i), Fs, 30, 45, 0, 0, 0, 'fir1', 0); % eyes closed
 
% Without CAR
    else
        % Delta band
        filtered_dataEO_delta(:,:,i) = eegfilt(raw_dataEO(:,:,i), Fs, 1, 4, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_delta(:,:,i) = eegfilt(raw_dataEC(:,:,i), Fs, 1, 4, 0, 0, 0, 'fir1', 0); % eyes closed

        % Theta band
        filtered_dataEO_theta(:,:,i) = eegfilt(raw_dataEO(:,:,i), Fs, 4, 8, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_theta(:,:,i) = eegfilt(raw_dataEC(:,:,i), Fs, 4, 8, 0, 0, 0, 'fir1', 0); % eyes closed

        % Alpha band
        filtered_dataEO_alpha(:,:,i) = eegfilt(raw_dataEO(:,:,i), Fs, 8, 13, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_alpha(:,:,i) = eegfilt(raw_dataEC(:,:,i), Fs, 8, 13, 0, 0, 0, 'fir1', 0); % eyes closed

        % Beta band
        filtered_dataEO_beta(:,:,i) = eegfilt(raw_dataEO(:,:,i), Fs, 13, 30, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_beta(:,:,i) = eegfilt(raw_dataEC(:,:,i), Fs, 13, 30, 0, 0, 0, 'fir1', 0); % eyes closed

        % Gamma band
        filtered_dataEO_gamma(:,:,i) = eegfilt(raw_dataEO(:,:,i), Fs, 30, 45, 0, 0, 0, 'fir1', 0); % eyes open
        filtered_dataEC_gamma(:,:,i) = eegfilt(raw_dataEC(:,:,i), Fs, 30, 45, 0, 0, 0, 'fir1', 0); % eyes closed
    end
end

%% Plot the filtered EEG data of the 1st subject.
if enable_plots
    eegplot(filtered_dataEO_delta(:,:,1), 'winlength', 12, ...
        'plottitle', 'EEG data of subject No 1 (all channels) - Delta band');
end

%% -- STEP 3 (EPOCHS): SPLIT THE DATA INTO 5 NON-OVERLAPPING 12-SECOND EPOCHS --
EpSam = Fs*epoch; % Epoch length in samples.

%Initialize matrices.

EO_delta_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;
EC_delta_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;

EO_theta_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;
EC_theta_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;
 
EO_alpha_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;
EC_alpha_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;

EO_beta_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;
EC_beta_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;

EO_gamma_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;
EC_gamma_epoch = zeros(Nch,EpSam,Ns,T/epoch) ;

for i=1:Ns
    for j=1:(T/epoch)
        % Eyes Open: EO
        EO_delta_epoch(:,:,i,j) = filtered_dataEO_delta(:,(1+(j-1)*EpSam):(j*EpSam),i);
        EO_theta_epoch(:,:,i,j) = filtered_dataEO_theta(:,(1+(j-1)*EpSam):(j*EpSam),i);
        EO_alpha_epoch(:,:,i,j) = filtered_dataEO_alpha(:,(1+(j-1)*EpSam):(j*EpSam),i);
        EO_beta_epoch(:,:,i,j) = filtered_dataEO_beta(:,(1+(j-1)*EpSam):(j*EpSam),i);
        EO_gamma_epoch(:,:,i,j) = filtered_dataEO_gamma(:,(1+(j-1)*EpSam):(j*EpSam),i);
         
        % Eyes Closed: EC
        EC_delta_epoch(:,:,i,j) = filtered_dataEC_delta(:,(1+(j-1)*EpSam):(j*EpSam),i);
        EC_theta_epoch(:,:,i,j) = filtered_dataEC_theta(:,(1+(j-1)*EpSam):(j*EpSam),i);
        EC_alpha_epoch(:,:,i,j) = filtered_dataEC_alpha(:,(1+(j-1)*EpSam):(j*EpSam),i);
        EC_beta_epoch(:,:,i,j) = filtered_dataEC_beta(:,(1+(j-1)*EpSam):(j*EpSam),i);
        EC_gamma_epoch(:,:,i,j) = filtered_dataEC_gamma(:,(1+(j-1)*EpSam):(j*EpSam),i);
    end
end

%% -- STEP 4: COMPUTE CONNECTIVITY MATRIX FOR EACH SUBJECT, EACH EPOCH AND EACH FREQUENCY BAND --

%6 Functional Connectivity Metrics:
% 1) PLV (Phase Locking Value)
% 2) PLI (Phase Lag Index)
% 3) COR (Pearson's Correlation Coefficient)
% 4) AEC (Amplitude Envelope Correlation)
% 5) AECc (AEC corrected version)
% 6) COH (Spectral Coherence)

%Initialize matrices.

% Delta band
CONN_PLV_EO_delta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLV_EC_delta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_PLI_EO_delta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLI_EC_delta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COR_EO_delta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COR_EC_delta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AEC_EO_delta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AEC_EC_delta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AECc_EO_delta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AECc_EC_delta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COH_EO_delta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COH_EC_delta = zeros(Nch,Nch,Ns,T/epoch) ;

% Theta band
CONN_PLV_EO_theta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLV_EC_theta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_PLI_EO_theta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLI_EC_theta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COR_EO_theta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COR_EC_theta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AEC_EO_theta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AEC_EC_theta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AECc_EO_theta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AECc_EC_theta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COH_EO_theta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COH_EC_theta = zeros(Nch,Nch,Ns,T/epoch) ;

% Alpha band
CONN_PLV_EO_alpha = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLV_EC_alpha = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_PLI_EO_alpha = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLI_EC_alpha = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COR_EO_alpha = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COR_EC_alpha = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AEC_EO_alpha = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AEC_EC_alpha = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AECc_EO_alpha = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AECc_EC_alpha = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COH_EO_alpha = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COH_EC_alpha = zeros(Nch,Nch,Ns,T/epoch) ;

% Beta band
CONN_PLV_EO_beta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLV_EC_beta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_PLI_EO_beta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLI_EC_beta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COR_EO_beta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COR_EC_beta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AEC_EO_beta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AEC_EC_beta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AECc_EO_beta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AECc_EC_beta = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COH_EO_beta = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COH_EC_beta = zeros(Nch,Nch,Ns,T/epoch) ;

% Gamma band
CONN_PLV_EO_gamma = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLV_EC_gamma = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_PLI_EO_gamma = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_PLI_EC_gamma = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COR_EO_gamma = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COR_EC_gamma = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AEC_EO_gamma = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AEC_EC_gamma = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_AECc_EO_gamma = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_AECc_EC_gamma = zeros(Nch,Nch,Ns,T/epoch) ;

CONN_COH_EO_gamma = zeros(Nch,Nch,Ns,T/epoch) ;
CONN_COH_EC_gamma = zeros(Nch,Nch,Ns,T/epoch) ;

for i=1:Ns
    for j=1:(T/epoch)
        % Eyes Open: EO
            % Delta band
        CONN_PLV_EO_delta(:,:,i,j) = ConnectivityMatrix(EO_delta_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EO_delta(:,:,i,j) = ConnectivityMatrix(EO_delta_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EO_delta(:,:,i,j) = ConnectivityMatrix(EO_delta_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EO_delta(:,:,i,j) = ConnectivityMatrix(EO_delta_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EO_delta(:,:,i,j) = ConnectivityMatrix(EO_delta_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EO_delta(:,:,i,j) = ConnectivityMatrix(EO_delta_epoch(:,:,i,j),'COH',Nch,Fs,epoch);
        
            % Theta band
        CONN_PLV_EO_theta(:,:,i,j) = ConnectivityMatrix(EO_theta_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EO_theta(:,:,i,j) = ConnectivityMatrix(EO_theta_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EO_theta(:,:,i,j) = ConnectivityMatrix(EO_theta_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EO_theta(:,:,i,j) = ConnectivityMatrix(EO_theta_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EO_theta(:,:,i,j) = ConnectivityMatrix(EO_theta_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EO_theta(:,:,i,j) = ConnectivityMatrix(EO_theta_epoch(:,:,i,j),'COH',Nch,Fs,epoch);
        
            % Alpha band
        CONN_PLV_EO_alpha(:,:,i,j) = ConnectivityMatrix(EO_alpha_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EO_alpha(:,:,i,j) = ConnectivityMatrix(EO_alpha_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EO_alpha(:,:,i,j) = ConnectivityMatrix(EO_alpha_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EO_alpha(:,:,i,j) = ConnectivityMatrix(EO_alpha_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EO_alpha(:,:,i,j) = ConnectivityMatrix(EO_alpha_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EO_alpha(:,:,i,j) = ConnectivityMatrix(EO_alpha_epoch(:,:,i,j),'COH',Nch,Fs,epoch);
        
           % Beta band
        CONN_PLV_EO_beta(:,:,i,j) = ConnectivityMatrix(EO_beta_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EO_beta(:,:,i,j) = ConnectivityMatrix(EO_beta_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EO_beta(:,:,i,j) = ConnectivityMatrix(EO_beta_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EO_beta(:,:,i,j) = ConnectivityMatrix(EO_beta_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EO_beta(:,:,i,j) = ConnectivityMatrix(EO_beta_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EO_beta(:,:,i,j) = ConnectivityMatrix(EO_beta_epoch(:,:,i,j),'COH',Nch,Fs,epoch);

           % Gamma band
        CONN_PLV_EO_gamma(:,:,i,j) = ConnectivityMatrix(EO_gamma_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EO_gamma(:,:,i,j) = ConnectivityMatrix(EO_gamma_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EO_gamma(:,:,i,j) = ConnectivityMatrix(EO_gamma_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EO_gamma(:,:,i,j) = ConnectivityMatrix(EO_gamma_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EO_gamma(:,:,i,j) = ConnectivityMatrix(EO_gamma_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EO_gamma(:,:,i,j) = ConnectivityMatrix(EO_gamma_epoch(:,:,i,j),'COH',Nch,Fs,epoch);
        
        
        %Eyes Closed: EC
           % Delta band
        CONN_PLV_EC_delta(:,:,i,j) = ConnectivityMatrix(EC_delta_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EC_delta(:,:,i,j) = ConnectivityMatrix(EC_delta_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EC_delta(:,:,i,j) = ConnectivityMatrix(EC_delta_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EC_delta(:,:,i,j) = ConnectivityMatrix(EC_delta_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EC_delta(:,:,i,j) = ConnectivityMatrix(EC_delta_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EC_delta(:,:,i,j) = ConnectivityMatrix(EC_delta_epoch(:,:,i,j),'COH',Nch,Fs,epoch);

            % Theta band
        CONN_PLV_EC_theta(:,:,i,j) = ConnectivityMatrix(EC_theta_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EC_theta(:,:,i,j) = ConnectivityMatrix(EC_theta_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EC_theta(:,:,i,j) = ConnectivityMatrix(EC_theta_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EC_theta(:,:,i,j) = ConnectivityMatrix(EC_theta_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EC_theta(:,:,i,j) = ConnectivityMatrix(EC_theta_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EC_theta(:,:,i,j) = ConnectivityMatrix(EC_theta_epoch(:,:,i,j),'COH',Nch,Fs,epoch);
        
            % Alpha band
        CONN_PLV_EC_alpha(:,:,i,j) = ConnectivityMatrix(EC_alpha_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EC_alpha(:,:,i,j) = ConnectivityMatrix(EC_alpha_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EC_alpha(:,:,i,j) = ConnectivityMatrix(EC_alpha_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EC_alpha(:,:,i,j) = ConnectivityMatrix(EC_alpha_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EC_alpha(:,:,i,j) = ConnectivityMatrix(EC_alpha_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EC_alpha(:,:,i,j) = ConnectivityMatrix(EC_alpha_epoch(:,:,i,j),'COH',Nch,Fs,epoch);
        
           % Beta band
        CONN_PLV_EC_beta(:,:,i,j) = ConnectivityMatrix(EC_beta_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EC_beta(:,:,i,j) = ConnectivityMatrix(EC_beta_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EC_beta(:,:,i,j) = ConnectivityMatrix(EC_beta_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EC_beta(:,:,i,j) = ConnectivityMatrix(EC_beta_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EC_beta(:,:,i,j) = ConnectivityMatrix(EC_beta_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EC_beta(:,:,i,j) = ConnectivityMatrix(EC_beta_epoch(:,:,i,j),'COH',Nch,Fs,epoch);
        
           % Gamma band
        CONN_PLV_EC_gamma(:,:,i,j) = ConnectivityMatrix(EC_gamma_epoch(:,:,i,j),'PLV',Nch,Fs,epoch);
        CONN_PLI_EC_gamma(:,:,i,j) = ConnectivityMatrix(EC_gamma_epoch(:,:,i,j),'PLI',Nch,Fs,epoch);
        CONN_COR_EC_gamma(:,:,i,j) = ConnectivityMatrix(EC_gamma_epoch(:,:,i,j),'COR',Nch,Fs,epoch);
        CONN_AEC_EC_gamma(:,:,i,j) = ConnectivityMatrix(EC_gamma_epoch(:,:,i,j),'AEC',Nch,Fs,epoch);
        CONN_AECc_EC_gamma(:,:,i,j) = ConnectivityMatrix(EC_gamma_epoch(:,:,i,j),'AECc',Nch,Fs,epoch);
        CONN_COH_EC_gamma(:,:,i,j) = ConnectivityMatrix(EC_gamma_epoch(:,:,i,j),'COH',Nch,Fs,epoch);        
    end
end

%% Plot a sample connectivity matrix.
if enable_plots
    figure();
    imagesc(CONN_PLV_EC_alpha(:,:,1,1));
    colorbar
    title('Functional Connectivity Matrix: PLV, Eyes Closed, alpha band');
    xlabel('Number of channels');
    ylabel('Number of channels');
end

%% -- STEP 5: FUNCTIONAL CONNECTIVITY PROFILES (feature vectors) --

% Ftiaxnw dianysma xaraktiristikwn apo anw trigwniko pinaka tou
% prohgoumenou vhmatos (FC Matrix).

% Initialize matrices.

    % Delta band
FCprofile_PLV_EO_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EO_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EO_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EO_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EO_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EO_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);

FCprofile_PLV_EC_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EC_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EC_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EC_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EC_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EC_delta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);

    % Theta band
FCprofile_PLV_EO_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EO_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EO_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EO_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EO_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EO_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);

FCprofile_PLV_EC_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EC_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EC_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EC_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EC_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EC_theta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);

    % Alpha band
FCprofile_PLV_EO_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EO_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EO_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EO_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EO_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EO_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);

FCprofile_PLV_EC_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EC_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EC_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EC_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EC_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EC_alpha = zeros(Nch*(Nch-1)/2,Ns,T/epoch);

    % Beta band
FCprofile_PLV_EO_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EO_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EO_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EO_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EO_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EO_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);

FCprofile_PLV_EC_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EC_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EC_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EC_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EC_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EC_beta = zeros(Nch*(Nch-1)/2,Ns,T/epoch);

    % Gamma band
FCprofile_PLV_EO_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EO_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EO_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EO_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EO_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EO_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);

FCprofile_PLV_EC_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_PLI_EC_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COR_EC_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AEC_EC_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_AECc_EC_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);
FCprofile_COH_EC_gamma = zeros(Nch*(Nch-1)/2,Ns,T/epoch);


for i=1:Ns
    for j=1:(T/epoch)
        % Eyes Open: EO
            % Delta band
        FCprofile_PLV_EO_delta(:,i,j) = FeatureVector(CONN_PLV_EO_delta(:,:,i,j),Nch);
        FCprofile_PLI_EO_delta(:,i,j) = FeatureVector(CONN_PLI_EO_delta(:,:,i,j),Nch);
        FCprofile_COR_EO_delta(:,i,j) = FeatureVector(CONN_COR_EO_delta(:,:,i,j),Nch);
        FCprofile_AEC_EO_delta(:,i,j) = FeatureVector(CONN_AEC_EO_delta(:,:,i,j),Nch);
        FCprofile_AECc_EO_delta(:,i,j) = FeatureVector(CONN_AECc_EO_delta(:,:,i,j),Nch);
        FCprofile_COH_EO_delta(:,i,j) = FeatureVector(CONN_COH_EO_delta(:,:,i,j),Nch);

            % Theta band
        FCprofile_PLV_EO_theta(:,i,j) = FeatureVector(CONN_PLV_EO_theta(:,:,i,j),Nch);
        FCprofile_PLI_EO_theta(:,i,j) = FeatureVector(CONN_PLI_EO_theta(:,:,i,j),Nch);
        FCprofile_COR_EO_theta(:,i,j) = FeatureVector(CONN_COR_EO_theta(:,:,i,j),Nch);
        FCprofile_AEC_EO_theta(:,i,j) = FeatureVector(CONN_AEC_EO_theta(:,:,i,j),Nch);
        FCprofile_AECc_EO_theta(:,i,j) = FeatureVector(CONN_AECc_EO_theta(:,:,i,j),Nch);
        FCprofile_COH_EO_theta(:,i,j) = FeatureVector(CONN_COH_EO_theta(:,:,i,j),Nch);
        
            % Alpha band
        FCprofile_PLV_EO_alpha(:,i,j) = FeatureVector(CONN_PLV_EO_alpha(:,:,i,j),Nch);
        FCprofile_PLI_EO_alpha(:,i,j) = FeatureVector(CONN_PLI_EO_alpha(:,:,i,j),Nch);
        FCprofile_COR_EO_alpha(:,i,j) = FeatureVector(CONN_COR_EO_alpha(:,:,i,j),Nch);
        FCprofile_AEC_EO_alpha(:,i,j) = FeatureVector(CONN_AEC_EO_alpha(:,:,i,j),Nch);
        FCprofile_AECc_EO_alpha(:,i,j) = FeatureVector(CONN_AECc_EO_alpha(:,:,i,j),Nch);
        FCprofile_COH_EO_alpha(:,i,j) = FeatureVector(CONN_COH_EO_alpha(:,:,i,j),Nch);
        
            % Beta band
        FCprofile_PLV_EO_beta(:,i,j) = FeatureVector(CONN_PLV_EO_beta(:,:,i,j),Nch);
        FCprofile_PLI_EO_beta(:,i,j) = FeatureVector(CONN_PLI_EO_beta(:,:,i,j),Nch);
        FCprofile_COR_EO_beta(:,i,j) = FeatureVector(CONN_COR_EO_beta(:,:,i,j),Nch);
        FCprofile_AEC_EO_beta(:,i,j) = FeatureVector(CONN_AEC_EO_beta(:,:,i,j),Nch);
        FCprofile_AECc_EO_beta(:,i,j) = FeatureVector(CONN_AECc_EO_beta(:,:,i,j),Nch);
        FCprofile_COH_EO_beta(:,i,j) = FeatureVector(CONN_COH_EO_beta(:,:,i,j),Nch);
        
            % Gamma band
        FCprofile_PLV_EO_gamma(:,i,j) = FeatureVector(CONN_PLV_EO_gamma(:,:,i,j),Nch);
        FCprofile_PLI_EO_gamma(:,i,j) = FeatureVector(CONN_PLI_EO_gamma(:,:,i,j),Nch);
        FCprofile_COR_EO_gamma(:,i,j) = FeatureVector(CONN_COR_EO_gamma(:,:,i,j),Nch);
        FCprofile_AEC_EO_gamma(:,i,j) = FeatureVector(CONN_AEC_EO_gamma(:,:,i,j),Nch);
        FCprofile_AECc_EO_gamma(:,i,j) = FeatureVector(CONN_AECc_EO_gamma(:,:,i,j),Nch);
        FCprofile_COH_EO_gamma(:,i,j) = FeatureVector(CONN_COH_EO_gamma(:,:,i,j),Nch);
        
        
        % Eyes Closed: EC
            % Delta band
        FCprofile_PLV_EC_delta(:,i,j) = FeatureVector(CONN_PLV_EC_delta(:,:,i,j),Nch);
        FCprofile_PLI_EC_delta(:,i,j) = FeatureVector(CONN_PLI_EC_delta(:,:,i,j),Nch);
        FCprofile_COR_EC_delta(:,i,j) = FeatureVector(CONN_COR_EC_delta(:,:,i,j),Nch);
        FCprofile_AEC_EC_delta(:,i,j) = FeatureVector(CONN_AEC_EC_delta(:,:,i,j),Nch);
        FCprofile_AECc_EC_delta(:,i,j) = FeatureVector(CONN_AECc_EC_delta(:,:,i,j),Nch);
        FCprofile_COH_EC_delta(:,i,j) = FeatureVector(CONN_COH_EC_delta(:,:,i,j),Nch);
        
            % Theta band
        FCprofile_PLV_EC_theta(:,i,j) = FeatureVector(CONN_PLV_EC_theta(:,:,i,j),Nch);
        FCprofile_PLI_EC_theta(:,i,j) = FeatureVector(CONN_PLI_EC_theta(:,:,i,j),Nch);
        FCprofile_COR_EC_theta(:,i,j) = FeatureVector(CONN_COR_EC_theta(:,:,i,j),Nch);
        FCprofile_AEC_EC_theta(:,i,j) = FeatureVector(CONN_AEC_EC_theta(:,:,i,j),Nch);
        FCprofile_AECc_EC_theta(:,i,j) = FeatureVector(CONN_AECc_EC_theta(:,:,i,j),Nch);
        FCprofile_COH_EC_theta(:,i,j) = FeatureVector(CONN_COH_EC_theta(:,:,i,j),Nch);
        
            % Alpha band
        FCprofile_PLV_EC_alpha(:,i,j) = FeatureVector(CONN_PLV_EC_alpha(:,:,i,j),Nch);
        FCprofile_PLI_EC_alpha(:,i,j) = FeatureVector(CONN_PLI_EC_alpha(:,:,i,j),Nch);
        FCprofile_COR_EC_alpha(:,i,j) = FeatureVector(CONN_COR_EC_alpha(:,:,i,j),Nch);
        FCprofile_AEC_EC_alpha(:,i,j) = FeatureVector(CONN_AEC_EC_alpha(:,:,i,j),Nch);
        FCprofile_AECc_EC_alpha(:,i,j) = FeatureVector(CONN_AECc_EC_alpha(:,:,i,j),Nch);
        FCprofile_COH_EC_alpha(:,i,j) = FeatureVector(CONN_COH_EC_alpha(:,:,i,j),Nch);
        
            % Beta band
        FCprofile_PLV_EC_beta(:,i,j) = FeatureVector(CONN_PLV_EC_beta(:,:,i,j),Nch);
        FCprofile_PLI_EC_beta(:,i,j) = FeatureVector(CONN_PLI_EC_beta(:,:,i,j),Nch);
        FCprofile_COR_EC_beta(:,i,j) = FeatureVector(CONN_COR_EC_beta(:,:,i,j),Nch);
        FCprofile_AEC_EC_beta(:,i,j) = FeatureVector(CONN_AEC_EC_beta(:,:,i,j),Nch);
        FCprofile_AECc_EC_beta(:,i,j) = FeatureVector(CONN_AECc_EC_beta(:,:,i,j),Nch);
        FCprofile_COH_EC_beta(:,i,j) = FeatureVector(CONN_COH_EC_beta(:,:,i,j),Nch);
        
            % Gamma band
        FCprofile_PLV_EC_gamma(:,i,j) = FeatureVector(CONN_PLV_EC_gamma(:,:,i,j),Nch);
        FCprofile_PLI_EC_gamma(:,i,j) = FeatureVector(CONN_PLI_EC_gamma(:,:,i,j),Nch);
        FCprofile_COR_EC_gamma(:,i,j) = FeatureVector(CONN_COR_EC_gamma(:,:,i,j),Nch);
        FCprofile_AEC_EC_gamma(:,i,j) = FeatureVector(CONN_AEC_EC_gamma(:,:,i,j),Nch);
        FCprofile_AECc_EC_gamma(:,i,j) = FeatureVector(CONN_AECc_EC_gamma(:,:,i,j),Nch);
        FCprofile_COH_EC_gamma(:,i,j) = FeatureVector(CONN_COH_EC_gamma(:,:,i,j),Nch); 
    end
end

%% Plot a sample feature vector.
if enable_plots
    figure();
    plot(FCprofile_PLV_EC_alpha(:,1,1),'LineWidth', 0.75);
    title('Feature Vector: PLV, Eyes Closed, alpha band');
    xlabel('Number of features');
    ylabel('PLV values');
    xlim([0 Nch*(Nch-1)/2]);
    ylim([0 1]); % For COR the range would be [-1, 1].
end

%% -- STEP 6: CALCULATE SCORE MATRIX (similarity matrix) --


%Delta band
ScoreMat_PLV_delta = CalcScoreMatrix(FCprofile_PLV_EO_delta,FCprofile_PLV_EC_delta,Ns,T,epoch);
ScoreMat_PLI_delta = CalcScoreMatrix(FCprofile_PLI_EO_delta,FCprofile_PLI_EC_delta,Ns,T,epoch);
ScoreMat_COR_delta = CalcScoreMatrix(FCprofile_COR_EO_delta,FCprofile_COR_EC_delta,Ns,T,epoch);
ScoreMat_AEC_delta = CalcScoreMatrix(FCprofile_AEC_EO_delta,FCprofile_AEC_EC_delta,Ns,T,epoch);
ScoreMat_AECc_delta = CalcScoreMatrix(FCprofile_AECc_EO_delta,FCprofile_AECc_EC_delta,Ns,T,epoch);
ScoreMat_COH_delta = CalcScoreMatrix(FCprofile_COH_EO_delta,FCprofile_COH_EC_delta,Ns,T,epoch);

% Theta band
ScoreMat_PLV_theta = CalcScoreMatrix(FCprofile_PLV_EO_theta,FCprofile_PLV_EC_theta,Ns,T,epoch);
ScoreMat_PLI_theta = CalcScoreMatrix(FCprofile_PLI_EO_theta,FCprofile_PLI_EC_theta,Ns,T,epoch);
ScoreMat_COR_theta = CalcScoreMatrix(FCprofile_COR_EO_theta,FCprofile_COR_EC_theta,Ns,T,epoch);
ScoreMat_AEC_theta = CalcScoreMatrix(FCprofile_AEC_EO_theta,FCprofile_AEC_EC_theta,Ns,T,epoch);
ScoreMat_AECc_theta = CalcScoreMatrix(FCprofile_AECc_EO_theta,FCprofile_AECc_EC_theta,Ns,T,epoch);
ScoreMat_COH_theta = CalcScoreMatrix(FCprofile_COH_EO_theta,FCprofile_COH_EC_theta,Ns,T,epoch);

% Alpha band
ScoreMat_PLV_alpha = CalcScoreMatrix(FCprofile_PLV_EO_alpha,FCprofile_PLV_EC_alpha,Ns,T,epoch);
ScoreMat_PLI_alpha = CalcScoreMatrix(FCprofile_PLI_EO_alpha,FCprofile_PLI_EC_alpha,Ns,T,epoch);
ScoreMat_COR_alpha = CalcScoreMatrix(FCprofile_COR_EO_alpha,FCprofile_COR_EC_alpha,Ns,T,epoch);
ScoreMat_AEC_alpha = CalcScoreMatrix(FCprofile_AEC_EO_alpha,FCprofile_AEC_EC_alpha,Ns,T,epoch);
ScoreMat_AECc_alpha = CalcScoreMatrix(FCprofile_AECc_EO_alpha,FCprofile_AECc_EC_alpha,Ns,T,epoch);
ScoreMat_COH_alpha = CalcScoreMatrix(FCprofile_COH_EO_alpha,FCprofile_COH_EC_alpha,Ns,T,epoch);

% Beta band
ScoreMat_PLV_beta = CalcScoreMatrix(FCprofile_PLV_EO_beta,FCprofile_PLV_EC_beta,Ns,T,epoch);
ScoreMat_PLI_beta = CalcScoreMatrix(FCprofile_PLI_EO_beta,FCprofile_PLI_EC_beta,Ns,T,epoch);
ScoreMat_COR_beta = CalcScoreMatrix(FCprofile_COR_EO_beta,FCprofile_COR_EC_beta,Ns,T,epoch);
ScoreMat_AEC_beta = CalcScoreMatrix(FCprofile_AEC_EO_beta,FCprofile_AEC_EC_beta,Ns,T,epoch);
ScoreMat_AECc_beta = CalcScoreMatrix(FCprofile_AECc_EO_beta,FCprofile_AECc_EC_beta,Ns,T,epoch);
ScoreMat_COH_beta = CalcScoreMatrix(FCprofile_COH_EO_beta,FCprofile_COH_EC_beta,Ns,T,epoch);

% Gamma band
ScoreMat_PLV_gamma = CalcScoreMatrix(FCprofile_PLV_EO_gamma,FCprofile_PLV_EC_gamma,Ns,T,epoch);
ScoreMat_PLI_gamma = CalcScoreMatrix(FCprofile_PLI_EO_gamma,FCprofile_PLI_EC_gamma,Ns,T,epoch);
ScoreMat_COR_gamma = CalcScoreMatrix(FCprofile_COR_EO_gamma,FCprofile_COR_EC_gamma,Ns,T,epoch);
ScoreMat_AEC_gamma = CalcScoreMatrix(FCprofile_AEC_EO_gamma,FCprofile_AEC_EC_gamma,Ns,T,epoch);
ScoreMat_AECc_gamma = CalcScoreMatrix(FCprofile_AECc_EO_gamma,FCprofile_AECc_EC_gamma,Ns,T,epoch);
ScoreMat_COH_gamma = CalcScoreMatrix(FCprofile_COH_EO_gamma,FCprofile_COH_EC_gamma,Ns,T,epoch);

%% Plot a sample score matrix.
if enable_plots
    figure();
    imagesc(ScoreMat_PLV_alpha);
    colorbar
    title('Score Matrix (PLV, Alpha band)');
end

%% Plot the genuine / impostor score distribution if the helper exists.
if enable_plots && enable_optional_distribution_plot
    if exist('PlotDistributionOfGenuineImpScores', 'file') == 2
        PlotDistributionOfGenuineImpScores(ScoreMat_PLV_alpha, T, epoch, Ns);
    else
        warning('main_program:MissingPlotHelper', ...
            ['PlotDistributionOfGenuineImpScores.m was not found. ' ...
             'Skipping the optional distribution plot.']);
    end
end

%% -- STEP 7: CALCULATE EER MATRIX --
% BT: Between-Tasks
% diastaseis:[2 x 2]

% Delta band
[EER_PLV_delta,FAR_PLV_EO_delta,FRR_PLV_EO_delta,FAR_PLV_EC_delta,FRR_PLV_EC_delta,FAR_PLV_BT_delta,FRR_PLV_BT_delta,AUC_PLV_delta] = EERMatrix(ScoreMat_PLV_delta,T,Ns,epoch);
[EER_PLI_delta,FAR_PLI_EO_delta,FRR_PLI_EO_delta,FAR_PLI_EC_delta,FRR_PLI_EC_delta,FAR_PLI_BT_delta,FRR_PLI_BT_delta,AUC_PLI_delta] = EERMatrix(ScoreMat_PLI_delta,T,Ns,epoch);
[EER_COR_delta,FAR_COR_EO_delta,FRR_COR_EO_delta,FAR_COR_EC_delta,FRR_COR_EC_delta,FAR_COR_BT_delta,FRR_COR_BT_delta,AUC_COR_delta] = EERMatrix(ScoreMat_COR_delta,T,Ns,epoch);
[EER_AEC_delta,FAR_AEC_EO_delta,FRR_AEC_EO_delta,FAR_AEC_EC_delta,FRR_AEC_EC_delta,FAR_AEC_BT_delta,FRR_AEC_BT_delta,AUC_AEC_delta] = EERMatrix(ScoreMat_AEC_delta,T,Ns,epoch);
[EER_AECc_delta,FAR_AECc_EO_delta,FRR_AECc_EO_delta,FAR_AECc_EC_delta,FRR_AECc_EC_delta,FAR_AECc_BT_delta,FRR_AECc_BT_delta,AUC_AECc_delta] = EERMatrix(ScoreMat_AECc_delta,T,Ns,epoch);
[EER_COH_delta,FAR_COH_EO_delta,FRR_COH_EO_delta,FAR_COH_EC_delta,FRR_COH_EC_delta,FAR_COH_BT_delta,FRR_COH_BT_delta,AUC_COH_delta] = EERMatrix(ScoreMat_COH_delta,T,Ns,epoch);

% Theta band
[EER_PLV_theta,FAR_PLV_EO_theta,FRR_PLV_EO_theta,FAR_PLV_EC_theta,FRR_PLV_EC_theta,FAR_PLV_BT_theta,FRR_PLV_BT_theta,AUC_PLV_theta] = EERMatrix(ScoreMat_PLV_theta,T,Ns,epoch);
[EER_PLI_theta,FAR_PLI_EO_theta,FRR_PLI_EO_theta,FAR_PLI_EC_theta,FRR_PLI_EC_theta,FAR_PLI_BT_theta,FRR_PLI_BT_theta,AUC_PLI_theta] = EERMatrix(ScoreMat_PLI_theta,T,Ns,epoch);
[EER_COR_theta,FAR_COR_EO_theta,FRR_COR_EO_theta,FAR_COR_EC_theta,FRR_COR_EC_theta,FAR_COR_BT_theta,FRR_COR_BT_theta,AUC_COR_theta] = EERMatrix(ScoreMat_COR_theta,T,Ns,epoch);
[EER_AEC_theta,FAR_AEC_EO_theta,FRR_AEC_EO_theta,FAR_AEC_EC_theta,FRR_AEC_EC_theta,FAR_AEC_BT_theta,FRR_AEC_BT_theta,AUC_AEC_theta] = EERMatrix(ScoreMat_AEC_theta,T,Ns,epoch);
[EER_AECc_theta,FAR_AECc_EO_theta,FRR_AECc_EO_theta,FAR_AECc_EC_theta,FRR_AECc_EC_theta,FAR_AECc_BT_theta,FRR_AECc_BT_theta,AUC_AECc_theta] = EERMatrix(ScoreMat_AECc_theta,T,Ns,epoch);
[EER_COH_theta,FAR_COH_EO_theta,FRR_COH_EO_theta,FAR_COH_EC_theta,FRR_COH_EC_theta,FAR_COH_BT_theta,FRR_COH_BT_theta,AUC_COH_theta] = EERMatrix(ScoreMat_COH_theta,T,Ns,epoch);

% Alpha band
[EER_PLV_alpha,FAR_PLV_EO_alpha,FRR_PLV_EO_alpha,FAR_PLV_EC_alpha,FRR_PLV_EC_alpha,FAR_PLV_BT_alpha,FRR_PLV_BT_alpha,AUC_PLV_alpha] = EERMatrix(ScoreMat_PLV_alpha,T,Ns,epoch);
[EER_PLI_alpha,FAR_PLI_EO_alpha,FRR_PLI_EO_alpha,FAR_PLI_EC_alpha,FRR_PLI_EC_alpha,FAR_PLI_BT_alpha,FRR_PLI_BT_alpha,AUC_PLI_alpha] = EERMatrix(ScoreMat_PLI_alpha,T,Ns,epoch);
[EER_COR_alpha,FAR_COR_EO_alpha,FRR_COR_EO_alpha,FAR_COR_EC_alpha,FRR_COR_EC_alpha,FAR_COR_BT_alpha,FRR_COR_BT_alpha,AUC_COR_alpha] = EERMatrix(ScoreMat_COR_alpha,T,Ns,epoch);
[EER_AEC_alpha,FAR_AEC_EO_alpha,FRR_AEC_EO_alpha,FAR_AEC_EC_alpha,FRR_AEC_EC_alpha,FAR_AEC_BT_alpha,FRR_AEC_BT_alpha,AUC_AEC_alpha] = EERMatrix(ScoreMat_AEC_alpha,T,Ns,epoch);
[EER_AECc_alpha,FAR_AECc_EO_alpha,FRR_AECc_EO_alpha,FAR_AECc_EC_alpha,FRR_AECc_EC_alpha,FAR_AECc_BT_alpha,FRR_AECc_BT_alpha,AUC_AECc_alpha] = EERMatrix(ScoreMat_AECc_alpha,T,Ns,epoch);
[EER_COH_alpha,FAR_COH_EO_alpha,FRR_COH_EO_alpha,FAR_COH_EC_alpha,FRR_COH_EC_alpha,FAR_COH_BT_alpha,FRR_COH_BT_alpha,AUC_COH_alpha] = EERMatrix(ScoreMat_COH_alpha,T,Ns,epoch);

% Beta band
[EER_PLV_beta,FAR_PLV_EO_beta,FRR_PLV_EO_beta,FAR_PLV_EC_beta,FRR_PLV_EC_beta,FAR_PLV_BT_beta,FRR_PLV_BT_beta,AUC_PLV_beta] = EERMatrix(ScoreMat_PLV_beta,T,Ns,epoch);
[EER_PLI_beta,FAR_PLI_EO_beta,FRR_PLI_EO_beta,FAR_PLI_EC_beta,FRR_PLI_EC_beta,FAR_PLI_BT_beta,FRR_PLI_BT_beta,AUC_PLI_beta] = EERMatrix(ScoreMat_PLI_beta,T,Ns,epoch);
[EER_COR_beta,FAR_COR_EO_beta,FRR_COR_EO_beta,FAR_COR_EC_beta,FRR_COR_EC_beta,FAR_COR_BT_beta,FRR_COR_BT_beta,AUC_COR_beta] = EERMatrix(ScoreMat_COR_beta,T,Ns,epoch);
[EER_AEC_beta,FAR_AEC_EO_beta,FRR_AEC_EO_beta,FAR_AEC_EC_beta,FRR_AEC_EC_beta,FAR_AEC_BT_beta,FRR_AEC_BT_beta,AUC_AEC_beta] = EERMatrix(ScoreMat_AEC_beta,T,Ns,epoch);
[EER_AECc_beta,FAR_AECc_EO_beta,FRR_AECc_EO_beta,FAR_AECc_EC_beta,FRR_AECc_EC_beta,FAR_AECc_BT_beta,FRR_AECc_BT_beta,AUC_AECc_beta] = EERMatrix(ScoreMat_AECc_beta,T,Ns,epoch);
[EER_COH_beta,FAR_COH_EO_beta,FRR_COH_EO_beta,FAR_COH_EC_beta,FRR_COH_EC_beta,FAR_COH_BT_beta,FRR_COH_BT_beta,AUC_COH_beta] = EERMatrix(ScoreMat_COH_beta,T,Ns,epoch);

% Gamma band
[EER_PLV_gamma,FAR_PLV_EO_gamma,FRR_PLV_EO_gamma,FAR_PLV_EC_gamma,FRR_PLV_EC_gamma,FAR_PLV_BT_gamma,FRR_PLV_BT_gamma,AUC_PLV_gamma] = EERMatrix(ScoreMat_PLV_gamma,T,Ns,epoch);
[EER_PLI_gamma,FAR_PLI_EO_gamma,FRR_PLI_EO_gamma,FAR_PLI_EC_gamma,FRR_PLI_EC_gamma,FAR_PLI_BT_gamma,FRR_PLI_BT_gamma,AUC_PLI_gamma] = EERMatrix(ScoreMat_PLI_gamma,T,Ns,epoch);
[EER_COR_gamma,FAR_COR_EO_gamma,FRR_COR_EO_gamma,FAR_COR_EC_gamma,FRR_COR_EC_gamma,FAR_COR_BT_gamma,FRR_COR_BT_gamma,AUC_COR_gamma] = EERMatrix(ScoreMat_COR_gamma,T,Ns,epoch);
[EER_AEC_gamma,FAR_AEC_EO_gamma,FRR_AEC_EO_gamma,FAR_AEC_EC_gamma,FRR_AEC_EC_gamma,FAR_AEC_BT_gamma,FRR_AEC_BT_gamma,AUC_AEC_gamma] = EERMatrix(ScoreMat_AEC_gamma,T,Ns,epoch);
[EER_AECc_gamma,FAR_AECc_EO_gamma,FRR_AECc_EO_gamma,FAR_AECc_EC_gamma,FRR_AECc_EC_gamma,FAR_AECc_BT_gamma,FRR_AECc_BT_gamma,AUC_AECc_gamma] = EERMatrix(ScoreMat_AECc_gamma,T,Ns,epoch);
[EER_COH_gamma,FAR_COH_EO_gamma,FRR_COH_EO_gamma,FAR_COH_EC_gamma,FRR_COH_EC_gamma,FAR_COH_BT_gamma,FRR_COH_BT_gamma,AUC_COH_gamma] = EERMatrix(ScoreMat_COH_gamma,T,Ns,epoch);

%% -- Plotting the final results. --
if enable_plots
    % PLV metric
    figure();
    plot(FAR_PLV_EO_beta,FRR_PLV_EO_beta)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Open (PLV, Beta band)');

    figure();
    plot(FAR_PLV_EC_alpha,FRR_PLV_EC_alpha)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Closed (PLV, Alpha band)');

    figure();
    imagesc(EER_PLV_alpha)
    colorbar;
    title('EER matrix (PLV, Alpha band)');

    % PLI metric
    figure();
    plot(FAR_PLI_EO_gamma,FRR_PLI_EO_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Open (PLI, Gamma band)');

    figure();
    plot(FAR_PLI_EC_gamma,FRR_PLI_EC_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Closed (PLI, Gamma band)');

    figure();
    imagesc(EER_PLI_gamma)
    title('EER matrix (PLI, Gamma band)');

    % COR metric
    figure();
    plot(FAR_COR_EO_gamma,FRR_COR_EO_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Open (COR, Gamma band)');

    figure();
    plot(FAR_COR_EC_gamma,FRR_COR_EC_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Closed (COR, Gamma band)');

    figure();
    imagesc(EER_COR_gamma)
    title('EER matrix (COR, Gamma band)');

    % AEC metric
    figure();
    plot(FAR_AEC_EO_gamma,FRR_AEC_EO_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Open (AEC, Gamma band)');

    figure();
    plot(FAR_AEC_EC_gamma,FRR_AEC_EC_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Closed (AEC, Gamma band)');

    figure();
    imagesc(EER_AEC_gamma)
    title('EER matrix (AEC, Gamma band)');

    % AECc metric
    figure();
    plot(FAR_AECc_EO_gamma,FRR_AECc_EO_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Open (AECc, Gamma band)');

    figure();
    plot(FAR_AECc_EC_gamma,FRR_AECc_EC_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Closed (AECc, Gamma band)');

    figure();
    imagesc(EER_AECc_gamma)
    title('EER matrix (AECc, Gamma band)');

    % COH metric
    figure();
    plot(FAR_COH_EO_gamma,FRR_COH_EO_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Open (COH, Gamma band)');

    figure();
    area(FAR_COH_EC_gamma,FRR_COH_EC_gamma)
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Closed (COH, Gamma band)');

    figure();
    imagesc(EER_COH_theta)
    title('EER matrix (COH, Theta band)');

    %% -- Extra plotting of results. --
    figure();
    plot(FAR_PLI_EC_delta,FRR_PLI_EC_delta);
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Closed (PLI)');
    hold on;
    plot(FAR_PLI_EC_theta,FRR_PLI_EC_theta);
    plot(FAR_PLI_EC_alpha,FRR_PLI_EC_alpha);
    plot(FAR_PLI_EC_beta,FRR_PLI_EC_beta);
    plot(FAR_PLI_EC_gamma,FRR_PLI_EC_gamma);
    legend('delta','theta','alpha','beta','gamma');

    figure();
    plot(FAR_PLI_EO_delta,FRR_PLI_EO_delta);
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Eyes Open (PLI)');
    hold on;
    plot(FAR_PLI_EO_theta,FRR_PLI_EO_theta);
    plot(FAR_PLI_EO_alpha,FRR_PLI_EO_alpha);
    plot(FAR_PLI_EO_beta,FRR_PLI_EO_beta);
    plot(FAR_PLI_EO_gamma,FRR_PLI_EO_gamma);
    legend('delta','theta','alpha','beta','gamma');

    figure();
    plot(FAR_AECc_BT_delta,FRR_AECc_BT_delta);
    xlabel('False acceptance rate');
    ylabel('False rejection rate');
    title('ROC curve - Between Tasks (AECc)');
    hold on;
    plot(FAR_AECc_BT_theta,FRR_AECc_BT_theta);
    plot(FAR_AECc_BT_alpha,FRR_AECc_BT_alpha);
    plot(FAR_AECc_BT_beta,FRR_AECc_BT_beta);
    plot(FAR_AECc_BT_gamma,FRR_AECc_BT_gamma);
    legend('delta','theta','alpha','beta','gamma');

    [GenuineScore1,GenuineScore2,GenuineScore3,ImpostorScore1,ImpostorScore2,ImpostorScore3] = Genuine_Impostor_Scores(ScoreMat_PLV_alpha,T,Ns,epoch);
    [FAR,FRR,thres] = Calculate_FAR_FRR(GenuineScore1,ImpostorScore1);

    figure(21);
    plot(thres,FAR);
    area(thres,FAR);
    xlabel('threshold')
    hold on;
    plot(thres,FRR);
    area(thres,FRR);
    legend('FAR','FRR');
    title('FAR - FRR');

    %% -- Plot all EER matrices together. --
    figure()

    % Delta band
    subplot(5,7,1);
    imagesc(EER_PLV_delta);
    subplot(5,7,2);
    imagesc(EER_PLI_delta);
    subplot(5,7,3);
    imagesc(EER_COR_delta);
    subplot(5,7,4);
    imagesc(EER_AEC_delta);
    subplot(5,7,5);
    imagesc(EER_AECc_delta);
    subplot(5,7,6);
    imagesc(EER_COH_delta);

    % Theta band
    subplot(5,7,8);
    imagesc(EER_PLV_theta);
    subplot(5,7,9);
    imagesc(EER_PLI_theta);
    subplot(5,7,10);
    imagesc(EER_COR_theta);
    subplot(5,7,11);
    imagesc(EER_AEC_theta);
    subplot(5,7,12);
    imagesc(EER_AECc_theta);
    subplot(5,7,13);
    imagesc(EER_COH_theta);

    % Alpha band
    subplot(5,7,15);
    imagesc(EER_PLV_alpha);
    subplot(5,7,16);
    imagesc(EER_PLI_alpha);
    subplot(5,7,17);
    imagesc(EER_COR_alpha);
    subplot(5,7,18);
    imagesc(EER_AEC_alpha);
    subplot(5,7,19);
    imagesc(EER_AECc_alpha);
    subplot(5,7,20);
    imagesc(EER_COH_alpha);

    % Beta band
    subplot(5,7,22);
    imagesc(EER_PLV_beta);
    subplot(5,7,23);
    imagesc(EER_PLI_beta);
    subplot(5,7,24);
    imagesc(EER_COR_beta);
    subplot(5,7,25);
    imagesc(EER_AEC_beta);
    subplot(5,7,26);
    imagesc(EER_AECc_beta);
    subplot(5,7,27);
    imagesc(EER_COH_beta);

    % Gamma band
    subplot(5,7,29);
    imagesc(EER_PLV_gamma);
    subplot(5,7,30);
    imagesc(EER_PLI_gamma);
    subplot(5,7,31);
    imagesc(EER_COR_gamma);
    subplot(5,7,32);
    imagesc(EER_AEC_gamma);
    subplot(5,7,33);
    imagesc(EER_AECc_gamma);
    subplot(5,7,34);
    imagesc(EER_COH_gamma);

    % Define colorbar.
    cbax = axes('visible', 'off');
    caxis(cbax, [0, 0.6]);
    colorbar(cbax, 'Location', 'eastoutside');
end
