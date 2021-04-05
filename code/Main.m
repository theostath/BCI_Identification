% Thesis: Biometric system using EEG data
% Name: Theodoros - Panagiotis Stathakopoulos
% AM: 1047043
% University of Patras, Department of Electrical and Computer Engineering
% 17/04/2020 (start date)
% 20/05/2020 (current date)


%% STEP 1: READ THE DATA
% 64 Channels, 160 Hz, 1 minute duration, 109 subjects, 2 baseline ...
... recordings (eyes open/closed)
% plot eeg data with function eegplot(eeg_data)

Nch = 64; % Number of channels
Fs = 160 ; % Sampling rate
T = 60 ; % time duration (sec)
Ns = 109; % Number of subjects

[raw_dataEO,raw_dataEC] = import_eeg_data(Ns,Nch,Fs,T); % EO = Eyes Open, EC = Eyes Closed

%% STEP 2a (PREPROCESSING): CAR (Common Average Referncing)

[CAR_EO,CAR_EC] = CAR(raw_dataEO,raw_dataEC);

%% STEP 2b (PREPROCESSING): ICA (DEN TO KANW PROS TO PARON) + BANDPASS FILTERING
% Delta band: 1-4 Hz
% Theta band: 4-8 Hz
% Alpha band: 8-13 Hz
% Beta band: 13-30 Hz
% Gamma band: 30-45 Hz

% NA KANW COMMON AVERAGE REFERENCING PRIN XWRISW SE EPOXES ?
flag = 0; % flag = 0 => With CAR        flag = 1 => Without CAR
% initialize
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
% WITH CAR
    if (flag == 0)
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
 
% WITHOUT CAR
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

%% STEP 3 EPOCHS: XWRIZW SE 5 MH EPIKALYPTOMENES EPOXES TWN 12 SEC 
% 12 sec = 160 * 12 = 1920 samples

epoch = 12; % epoch length ( sec )
EpSam = Fs*epoch; % epoch length ( samples )

% initialize
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

%% STEP 4a: COMPUTE CONNECTIVITY MATRIX FOR EACH SUBJECT, EACH EPOCH AND EACH FREQUENCY BAND

% POSA DIAFORETIKA FUNCTIONAL CONNECTIVITY METRICS THA EXW ? 

% initialize
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

Theta band
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

Alpha band
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
  
%% STEP 4b: PLOT CONNECTIVITY MATRIX FOR EACH METRIC

%imagesc(CONN_PLV_EO_delta(:,:,1,1));
%colorbar

%% STEP 5: FUNCTIONAL CONNECTIVITY PROFILES (feature vectors)

% Ftiaxnw dianysma xaraktiristikwn apo anw trigwniko pinaka tou
% prohgoumenou vhmatos.

% Initialize
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

%% STEP 6: CALCULATE SCORE MATRIX

% Metrikes: PLV, PLI, COR, AEC

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

%%
figure(1);
imagesc(ScoreMat_PLV_beta);
colorbar
title('Score Matrix (PLV, Beta band)');

%% STEP 7: CALCULATE EER MATRIX - diastaseis:[2 x 2]

% Delta band
[EER_PLV_delta,FAR_PLV_EO_delta,FRR_PLV_EO_delta,FAR_PLV_EC_delta,FRR_PLV_EC_delta,thres_PLV_delta] = EERMatrix_vol2(ScoreMat_PLV_delta,T,Ns,epoch);
[EER_PLI_delta,FAR_PLI_EO_delta,FRR_PLI_EO_delta,FAR_PLI_EC_delta,FRR_PLI_EC_delta,thres_PLI_delta] = EERMatrix_vol2(ScoreMat_PLI_delta,T,Ns,epoch);
[EER_COR_delta,FAR_COR_EO_delta,FRR_COR_EO_delta,FAR_COR_EC_delta,FRR_COR_EC_delta,thres_COR_delta] = EERMatrix_vol2(ScoreMat_COR_delta,T,Ns,epoch);
[EER_AEC_delta,FAR_AEC_EO_delta,FRR_AEC_EO_delta,FAR_AEC_EC_delta,FRR_AEC_EC_delta,thres_AEC_delta] = EERMatrix_vol2(ScoreMat_AEC_delta,T,Ns,epoch);
[EER_AECc_delta,FAR_AECc_EO_delta,FRR_AECc_EO_delta,FAR_AECc_EC_delta,FRR_AECc_EC_delta,thres_AECc_delta] = EERMatrix_vol2(ScoreMat_AECc_delta,T,Ns,epoch);
[EER_COH_delta,FAR_COH_EO_delta,FRR_COH_EO_delta,FAR_COH_EC_delta,FRR_COH_EC_delta,thres_COH_delta] = EERMatrix_vol2(ScoreMat_COH_delta,T,Ns,epoch);

% Theta band
[EER_PLV_theta,FAR_PLV_EO_theta,FRR_PLV_EO_theta,FAR_PLV_EC_theta,FRR_PLV_EC_theta,thres_PLV_theta] = EERMatrix_vol2(ScoreMat_PLV_theta,T,Ns,epoch);
[EER_PLI_theta,FAR_PLI_EO_theta,FRR_PLI_EO_theta,FAR_PLI_EC_theta,FRR_PLI_EC_theta,thres_PLI_theta] = EERMatrix_vol2(ScoreMat_PLI_theta,T,Ns,epoch);
[EER_COR_theta,FAR_COR_EO_theta,FRR_COR_EO_theta,FAR_COR_EC_theta,FRR_COR_EC_theta,thres_COR_theta] = EERMatrix_vol2(ScoreMat_COR_theta,T,Ns,epoch);
[EER_AEC_theta,FAR_AEC_EO_theta,FRR_AEC_EO_theta,FAR_AEC_EC_theta,FRR_AEC_EC_theta,thres_AEC_theta] = EERMatrix_vol2(ScoreMat_AEC_theta,T,Ns,epoch);
[EER_AECc_theta,FAR_AECc_EO_theta,FRR_AECc_EO_theta,FAR_AECc_EC_theta,FRR_AECc_EC_theta,thres_AECc_theta] = EERMatrix_vol2(ScoreMat_AECc_theta,T,Ns,epoch);
[EER_COH_theta,FAR_COH_EO_theta,FRR_COH_EO_theta,FAR_COH_EC_theta,FRR_COH_EC_theta,thres_COH_theta] = EERMatrix_vol2(ScoreMat_COH_theta,T,Ns,epoch);

% Alpha band
[EER_PLV_alpha,FAR_PLV_EO_alpha,FRR_PLV_EO_alpha,FAR_PLV_EC_alpha,FRR_PLV_EC_alpha,thres_PLV_alpha] = EERMatrix_vol2(ScoreMat_PLV_alpha,T,Ns,epoch);
[EER_PLI_alpha,FAR_PLI_EO_alpha,FRR_PLI_EO_alpha,FAR_PLI_EC_alpha,FRR_PLI_EC_alpha,thres_PLI_alpha] = EERMatrix_vol2(ScoreMat_PLI_alpha,T,Ns,epoch);
[EER_COR_alpha,FAR_COR_EO_alpha,FRR_COR_EO_alpha,FAR_COR_EC_alpha,FRR_COR_EC_alpha,thres_COR_alpha] = EERMatrix_vol2(ScoreMat_COR_alpha,T,Ns,epoch);
[EER_AEC_alpha,FAR_AEC_EO_alpha,FRR_AEC_EO_alpha,FAR_AEC_EC_alpha,FRR_AEC_EC_alpha,thres_AEC_alpha] = EERMatrix_vol2(ScoreMat_AEC_alpha,T,Ns,epoch);
[EER_AECc_alpha,FAR_AECc_EO_alpha,FRR_AECc_EO_alpha,FAR_AECc_EC_alpha,FRR_AECc_EC_alpha,thres_AECc_alpha] = EERMatrix_vol2(ScoreMat_AECc_alpha,T,Ns,epoch);
[EER_COH_alpha,FAR_COH_EO_alpha,FRR_COH_EO_alpha,FAR_COH_EC_alpha,FRR_COH_EC_alpha,thres_COH_alpha] = EERMatrix_vol2(ScoreMat_COH_alpha,T,Ns,epoch);

% Beta band
[EER_PLV_beta,FAR_PLV_EO_beta,FRR_PLV_EO_beta,FAR_PLV_EC_beta,FRR_PLV_EC_beta,thres_PLV_beta] = EERMatrix_vol2(ScoreMat_PLV_beta,T,Ns,epoch);
[EER_PLI_beta,FAR_PLI_EO_beta,FRR_PLI_EO_beta,FAR_PLI_EC_beta,FRR_PLI_EC_beta,thres_PLI_beta] = EERMatrix_vol2(ScoreMat_PLI_beta,T,Ns,epoch);
[EER_COR_beta,FAR_COR_EO_beta,FRR_COR_EO_beta,FAR_COR_EC_beta,FRR_COR_EC_beta,thres_COR_beta] = EERMatrix_vol2(ScoreMat_COR_beta,T,Ns,epoch);
[EER_AEC_beta,FAR_AEC_EO_beta,FRR_AEC_EO_beta,FAR_AEC_EC_beta,FRR_AEC_EC_beta,thres_AEC_beta] = EERMatrix_vol2(ScoreMat_AEC_beta,T,Ns,epoch);
[EER_AECc_beta,FAR_AECc_EO_beta,FRR_AECc_EO_beta,FAR_AECc_EC_beta,FRR_AECc_EC_beta,thres_AECc_beta] = EERMatrix_vol2(ScoreMat_AECc_beta,T,Ns,epoch);
[EER_COH_beta,FAR_COH_EO_beta,FRR_COH_EO_beta,FAR_COH_EC_beta,FRR_COH_EC_beta,thres_COH_beta] = EERMatrix_vol2(ScoreMat_COH_beta,T,Ns,epoch);

% Gamma band
[EER_PLV_gamma,FAR_PLV_EO_gamma,FRR_PLV_EO_gamma,FAR_PLV_EC_gamma,FRR_PLV_EC_gamma,thres_PLV_gamma] = EERMatrix_vol2(ScoreMat_PLV_gamma,T,Ns,epoch);
[EER_PLI_gamma,FAR_PLI_EO_gamma,FRR_PLI_EO_gamma,FAR_PLI_EC_gamma,FRR_PLI_EC_gamma,thres_PLI_gamma] = EERMatrix_vol2(ScoreMat_PLI_gamma,T,Ns,epoch);
[EER_COR_gamma,FAR_COR_EO_gamma,FRR_COR_EO_gamma,FAR_COR_EC_gamma,FRR_COR_EC_gamma,thres_COR_gamma] = EERMatrix_vol2(ScoreMat_COR_gamma,T,Ns,epoch);
[EER_AEC_gamma,FAR_AEC_EO_gamma,FRR_AEC_EO_gamma,FAR_AEC_EC_gamma,FRR_AEC_EC_gamma,thres_AEC_gamma] = EERMatrix_vol2(ScoreMat_AEC_gamma,T,Ns,epoch);
[EER_AECc_gamma,FAR_AECc_EO_gamma,FRR_AECc_EO_gamma,FAR_AECc_EC_gamma,FRR_AECc_EC_gamma,thres_AECc_gamma] = EERMatrix_vol2(ScoreMat_AECc_gamma,T,Ns,epoch);
[EER_COH_gamma,FAR_COH_EO_gamma,FRR_COH_EO_gamma,FAR_COH_EC_gamma,FRR_COH_EC_gamma,thres_COH_gamma] = EERMatrix_vol2(ScoreMat_COH_gamma,T,Ns,epoch);

%% STEP 8: Impostor and Genuine Score Histogramms

% Prepei gia kathe metrikh kai mpanta na ektelestei ksexwrista gia na
% ginoun swsta ta plot.

% Delta band
MakeHist(ScoreMat_PLV_delta,T,Ns,epoch,'PLV','Delta');
MakeHist(ScoreMat_PLI_delta,T,Ns,epoch,'PLI','Delta');
MakeHist(ScoreMat_COR_delta,T,Ns,epoch,'COR','Delta');
MakeHist(ScoreMat_AEC_delta,T,Ns,epoch,'AEC','Delta');
MakeHist(ScoreMat_AECc_delta,T,Ns,epoch,'AECc','Delta');
MakeHist(ScoreMat_COH_delta,T,Ns,epoch,'COH','Delta');

% Theta band
MakeHist(ScoreMat_PLV_theta,T,Ns,epoch,'PLV','Theta');
MakeHist(ScoreMat_PLI_theta,T,Ns,epoch,'PLI','Theta');
MakeHist(ScoreMat_COR_theta,T,Ns,epoch,'COR','Theta');
MakeHist(ScoreMat_AEC_theta,T,Ns,epoch,'AEC','Theta');
MakeHist(ScoreMat_AECc_theta,T,Ns,epoch,'AECc','Theta');
MakeHist(ScoreMat_COH_theta,T,Ns,epoch,'COH','Theta');

% Alpha band
MakeHist(ScoreMat_PLV_alpha,T,Ns,epoch,'PLV','Alpha');
MakeHist(ScoreMat_PLI_alpha,T,Ns,epoch,'PLI','Alpha');
MakeHist(ScoreMat_COR_alpha,T,Ns,epoch,'COR','Alpha');
MakeHist(ScoreMat_AEC_alpha,T,Ns,epoch,'AEC','Alpha');
MakeHist(ScoreMat_AECc_alpha,T,Ns,epoch,'AECc','Alpha');
MakeHist(ScoreMat_COH_alpha,T,Ns,epoch,'COH','Alpha');

% Beta band
MakeHist(ScoreMat_PLV_beta,T,Ns,epoch,'PLV','Beta');
MakeHist(ScoreMat_PLI_beta,T,Ns,epoch,'PLI','Beta');
MakeHist(ScoreMat_COR_beta,T,Ns,epoch,'COR','Beta');
MakeHist(ScoreMat_AEC_beta,T,Ns,epoch,'AEC','Beta');
MakeHist(ScoreMat_AECc_beta,T,Ns,epoch,'AECc','Beta');
MakeHist(ScoreMat_COH_beta,T,Ns,epoch,'COH','Beta');

% Gamma band
MakeHist(ScoreMat_PLV_gamma,T,Ns,epoch,'PLV','Gamma');
MakeHist(ScoreMat_PLI_gamma,T,Ns,epoch,'PLI','Gamma');
MakeHist(ScoreMat_COR_gamma,T,Ns,epoch,'COR','Gamma');
MakeHist(ScoreMat_AEC_gamma,T,Ns,epoch,'AEC','Gamma');
MakeHist(ScoreMat_AECc_gamma,T,Ns,epoch,'AECc','Gamma');
MakeHist(ScoreMat_COH_gamma,T,Ns,epoch,'COH','Gamma');

%% STEP 9: Find PDFs (and Mean Square Error: pdf vs histogram)

% Delta band
MSE_PLV_delta = CalcPDF(ScoreMat_PLV_delta,T,Ns,epoch,'PLV','Delta');
MSE_PLI_delta = CalcPDF(ScoreMat_PLI_delta,T,Ns,epoch,'PLI','Delta');
MSE_COR_delta = CalcPDF(ScoreMat_COR_delta,T,Ns,epoch,'COR','Delta');
MSE_AEC_delta = CalcPDF(ScoreMat_AEC_delta,T,Ns,epoch,'AEC','Delta');
MSE_AECc_delta = CalcPDF(ScoreMat_AECc_delta,T,Ns,epoch,'AECc','Delta');
MSE_COH_delta = CalcPDF(ScoreMat_COH_delta,T,Ns,epoch,'COH','Delta');

% Theta band
MSE_PLV_theta = CalcPDF(ScoreMat_PLV_theta,T,Ns,epoch,'PLV','Theta');
MSE_PLI_theta = CalcPDF(ScoreMat_PLI_theta,T,Ns,epoch,'PLI','Theta');
MSE_COR_theta = CalcPDF(ScoreMat_COR_theta,T,Ns,epoch,'COR','Theta');
MSE_AEC_theta = CalcPDF(ScoreMat_AEC_theta,T,Ns,epoch,'AEC','Theta');
MSE_AECc_theta = CalcPDF(ScoreMat_AECc_theta,T,Ns,epoch,'AECc','Theta');
MSE_COH_theta = CalcPDF(ScoreMat_COH_theta,T,Ns,epoch,'COH','Theta');

% Alpha band
MSE_PLV_alpha = CalcPDF(ScoreMat_PLV_alpha,T,Ns,epoch,'PLV','Alpha');
MSE_PLI_alpha = CalcPDF(ScoreMat_PLI_alpha,T,Ns,epoch,'PLI','Alpha');
MSE_COR_alpha = CalcPDF(ScoreMat_COR_alpha,T,Ns,epoch,'COR','Alpha');
MSE_AEC_alpha = CalcPDF(ScoreMat_AEC_alpha,T,Ns,epoch,'AEC','Alpha');
MSE_AECc_alpha = CalcPDF(ScoreMat_AECc_alpha,T,Ns,epoch,'AECc','Alpha');
MSE_COH_alpha = CalcPDF(ScoreMat_COH_alpha,T,Ns,epoch,'COH','Alpha');

% Beta band
MSE_PLV_beta = CalcPDF(ScoreMat_PLV_beta,T,Ns,epoch,'PLV','Beta');
MSE_PLI_beta = CalcPDF(ScoreMat_PLI_beta,T,Ns,epoch,'PLI','Beta');
MSE_COR_beta = CalcPDF(ScoreMat_COR_beta,T,Ns,epoch,'COR','Beta');
MSE_AEC_beta = CalcPDF(ScoreMat_AEC_beta,T,Ns,epoch,'AEC','Beta');
MSE_AECc_beta = CalcPDF(ScoreMat_AECc_beta,T,Ns,epoch,'AECc','Beta');
MSE_COH_beta = CalcPDF(ScoreMat_COH_beta,T,Ns,epoch,'COH','Beta');

% Gamma band
MSE_PLV_gamma = CalcPDF(ScoreMat_PLV_gamma,T,Ns,epoch,'PLV','Gamma');
MSE_PLI_gamma = CalcPDF(ScoreMat_PLI_gamma,T,Ns,epoch,'PLI','Gamma');
MSE_COR_gamma = CalcPDF(ScoreMat_COR_gamma,T,Ns,epoch,'COR','Gamma');
MSE_AEC_gamma = CalcPDF(ScoreMat_AEC_gamma,T,Ns,epoch,'AEC','Gamma');
MSE_AECc_gamma = CalcPDF(ScoreMat_AECc_gamma,T,Ns,epoch,'AECc','Gamma');
MSE_COH_gamma = CalcPDF(ScoreMat_COH_gamma,T,Ns,epoch,'COH','Gamma');


%% Step 10: CALCULATE FAR, FRR THROUGH NEYMAN-PEARSON ESTIMATOR

[EER_PLV_delta2,FAR_PLV_EO_delta2,FRR_PLV_EO_delta2,FAR_PLV_EC_delta2,FRR_PLV_EC_delta2] = NP_Estimator(ScoreMat_PLV_delta,T,Ns,epoch);

%% TEEEEEEESTING

[GenuineScore1,GenuineScore2,GenuineScore3,ImpostorScore1,ImpostorScore2,ImpostorScore3] = Genuine_Impostor_Scores(ScoreMat_PLV_delta,T,Ns,epoch) ;

m11 = mean(ImpostorScore1) ; % mean valuse
sigma11 = std(ImpostorScore1) ; % standard deviation

m12 = mean(ImpostorScore2) ; % mean valuse
sigma12 = std(ImpostorScore2) ; % standard deviation

m13 = mean(ImpostorScore3) ; % mean valuse
sigma13 = std(ImpostorScore3) ; % standard deviation


step = 0.001 ;
a = step:step:(1-step);    % false negative


% Step 3b: Find threshold (g tonos)
num = qfuncinv(a) ;
thres1 = (sigma11*num-m11) ;      % Task1 vs Task1
thres2 = (sigma12*num-m12) ;      % Task1 vs Task2%  Task1 vs Task2 == Task2 vs Task1
thres3 = (sigma13*num-m13) ;      % Task2 vs Task2

% initialize
FAR_11 = zeros(1,length(a)) ;
FRR_11 = zeros(1,length(a)) ;

FAR_12 = zeros(1,length(a)) ;
FRR_12 = zeros(1,length(a)) ;

FAR_22 = zeros(1,length(a)) ;
FRR_22 = zeros(1,length(a)) ;
%%
plot(thres1) ;
title('Threshold values - PLV (Delta band, Task1 vs Task1)') ;
xlabel('Number of thresholds');
ylabel('Threshold values');

%%
Pes = a ;

% find gamma (threshold)
g1 = exp(thres1)*std(GenuineScore1)/(sigma11*sqrt(pi)) ;
g2 = exp(thres2)*std(GenuineScore2)/(sigma12*sqrt(pi)) ;
g3 = exp(thres3)*std(GenuineScore3)/(sigma13*sqrt(pi)) ;

% Find Poa with g'
% % Poa1 = 1-1/2*exp(sqrt(2)*(thres1-mean(GenuineScore1))/std(GenuineScore1)) ; 
% % Poa2 = 1-1/2*exp(sqrt(2)*(thres2-mean(GenuineScore2))/std(GenuineScore2)) ; 
% % Poa3 = 1-1/2*exp(sqrt(2)*(thres3-mean(GenuineScore3))/std(GenuineScore3)) ; 

% Find Poa with g
Poa1 = 1-1/2*exp(sqrt(2)*(g1-mean(GenuineScore1))/std(GenuineScore1)) ; 
Poa2 = 1-1/2*exp(sqrt(2)*(g2-mean(GenuineScore2))/std(GenuineScore2)) ; 
Poa3 = 1-1/2*exp(sqrt(2)*(g3-mean(GenuineScore3))/std(GenuineScore3)) ;

figure(1);
plot(Pes,1-Poa1) ; 
title('ROC Curve') ;
xlabel('FAR (Pes)') ;
ylabel('FRR (1-Poa)') ;
%%
figure(2);
plot(Pes,Poa2) ; 
title('ROC Curve') ;
xlabel('False alarm probability (Pes)') ;
ylabel('Detection probability (Poa)') ;

figure(3);
plot(Pes,Poa3) ; 
title('ROC Curve') ;
xlabel('False alarm probability (Pes)') ;
ylabel('Detection probability (Poa)') ;
%%
genuine_user = zeros(1,length(a)) ;

decision2 = -1/(2*sigma11^2)*(GenuineScore1-m11).^2 + sqrt(2)*(mean(GenuineScore1)-GenuineScore1)/std(GenuineScore1) ;

%%
figure(5);
plot(thres1,decision2(1:length(thres1)))

%%
for j = 1:length(a)
    for i=1:length(GenuineScore1)
        if decision2(i)<=-thres1(j)
            genuine_user(j)=genuine_user(j)+1; % false negative
        end
    end
end

%%
% Step 3c: Find FAR, FRR
for i = 1:length(a)
    [FAR_11(i),FRR_11(i)] = FAR_FRR_NP_Estimator(GenuineScore1,ImpostorScore1,-thres1(i),a(i)) ; %  Task1 vs Task1
    [FAR_12(i),FRR_12(i)] = FAR_FRR_NP_Estimator(GenuineScore2,ImpostorScore2,-thres2(i),a(i)) ; %  Task1 vs Task2 == Task2 vs Task1
    [FAR_22(i),FRR_22(i)] = FAR_FRR_NP_Estimator(GenuineScore3,ImpostorScore3,-thres3(i),a(i)) ; %  Task2 vs Task2
end


%%  PLOT TEST
figure(5);
plot(FAR_11,FRR_11)
xlabel('False acceptance rate'); 
ylabel('False rejection rate');
title('ROC curve (PLV, Delta band)');

%% Step 11: Stochastic Classifier (FAR, FRR, Optimal Threshold)

% Define parameter lamda.
lamda = 0.5 ;    % minimize the sum: lamda*FAR + (1-lamda)FRR     lamda takes values in [0,1]

% Delta band
[FAR_PLV_delta,FRR_PLV_delta,opt_thres_PLV_delta] = StochClass(ScoreMat_PLV_delta,T,Ns,epoch,lamda);
[FAR_PLI_delta,FRR_PLI_delta,opt_thres_PLI_delta] = StochClass(ScoreMat_PLI_delta,T,Ns,epoch,lamda);
[FAR_COR_delta,FRR_COR_delta,opt_thres_COR_delta] = StochClass(ScoreMat_COR_delta,T,Ns,epoch,lamda);
[FAR_AEC_delta,FRR_AEC_delta,opt_thres_AEC_delta] = StochClass(ScoreMat_AEC_delta,T,Ns,epoch,lamda);
[FAR_AECc_delta,FRR_AECc_delta,opt_thres_AECc_delta] = StochClass(ScoreMat_AECc_delta,T,Ns,epoch,lamda);
[FAR_COH_delta,FRR_COH_delta,opt_thres_COH_delta] = StochClass(ScoreMat_COH_delta,T,Ns,epoch,lamda);

% Theta band
[FAR_PLV_theta,FRR_PLV_theta,opt_thres_PLV_theta] = StochClass(ScoreMat_PLV_theta,T,Ns,epoch,lamda);
[FAR_PLI_theta,FRR_PLI_theta,opt_thres_PLI_theta] = StochClass(ScoreMat_PLI_theta,T,Ns,epoch,lamda);
[FAR_COR_theta,FRR_COR_theta,opt_thres_COR_theta] = StochClass(ScoreMat_COR_theta,T,Ns,epoch,lamda);
[FAR_AEC_theta,FRR_AEC_theta,opt_thres_AEC_theta] = StochClass(ScoreMat_AEC_theta,T,Ns,epoch,lamda);
[FAR_AECc_theta,FRR_AECc_theta,opt_thres_AECc_theta] = StochClass(ScoreMat_AECc_theta,T,Ns,epoch,lamda);
[FAR_COH_theta,FRR_COH_theta,opt_thres_COH_theta] = StochClass(ScoreMat_COH_theta,T,Ns,epoch,lamda);

% Aplha band
[FAR_PLV_alpha,FRR_PLV_alpha,opt_thres_PLV_alpha] = StochClass(ScoreMat_PLV_alpha,T,Ns,epoch,lamda);
[FAR_PLI_alpha,FRR_PLI_alpha,opt_thres_PLI_alpha] = StochClass(ScoreMat_PLI_alpha,T,Ns,epoch,lamda);
[FAR_COR_alpha,FRR_COR_alpha,opt_thres_COR_alpha] = StochClass(ScoreMat_COR_alpha,T,Ns,epoch,lamda);
[FAR_AEC_alpha,FRR_AEC_alpha,opt_thres_AEC_alpha] = StochClass(ScoreMat_AEC_alpha,T,Ns,epoch,lamda);
[FAR_AECc_alpha,FRR_AECc_alpha,opt_thres_AECc_alpha] = StochClass(ScoreMat_AECc_alpha,T,Ns,epoch,lamda);
[FAR_COH_alpha,FRR_COH_alpha,opt_thres_COH_alpha] = StochClass(ScoreMat_COH_alpha,T,Ns,epoch,lamda);

% Beta band
[FAR_PLV_beta,FRR_PLV_beta,opt_thres_PLV_beta] = StochClass(ScoreMat_PLV_beta,T,Ns,epoch,lamda);
[FAR_PLI_beta,FRR_PLI_beta,opt_thres_PLI_beta] = StochClass(ScoreMat_PLI_beta,T,Ns,epoch,lamda);
[FAR_COR_beta,FRR_COR_beta,opt_thres_COR_beta] = StochClass(ScoreMat_COR_beta,T,Ns,epoch,lamda);
[FAR_AEC_beta,FRR_AEC_beta,opt_thres_AEC_beta] = StochClass(ScoreMat_AEC_beta,T,Ns,epoch,lamda);
[FAR_AECc_beta,FRR_AECc_beta,opt_thres_AECc_beta] = StochClass(ScoreMat_AECc_beta,T,Ns,epoch,lamda);
[FAR_COH_beta,FRR_COH_beta,opt_thres_COH_beta] = StochClass(ScoreMat_COH_beta,T,Ns,epoch,lamda);

% Gamma band
[FAR_PLV_gamma,FRR_PLV_gamma,opt_thres_PLV_gamma] = StochClass(ScoreMat_PLV_gamma,T,Ns,epoch,lamda);
[FAR_PLI_gamma,FRR_PLI_gamma,opt_thres_PLI_gamma] = StochClass(ScoreMat_PLI_gamma,T,Ns,epoch,lamda);
[FAR_COR_gamma,FRR_COR_gamma,opt_thres_COR_gamma] = StochClass(ScoreMat_COR_gamma,T,Ns,epoch,lamda);
[FAR_AEC_gamma,FRR_AEC_gamma,opt_thres_AEC_gamma] = StochClass(ScoreMat_AEC_gamma,T,Ns,epoch,lamda);
[FAR_AECc_gamma,FRR_AECc_gamma,opt_thres_AECc_gamma] = StochClass(ScoreMat_AECc_gamma,T,Ns,epoch,lamda);
[FAR_COH_gamma,FRR_COH_gamma,opt_thres_COH_gamma] = StochClass(ScoreMat_COH_gamma,T,Ns,epoch,lamda);


%% print ROC curve  (Eyes Open, delta, PLV)
figure(1);
plot(FAR_PLV_EO_delta,FRR_PLV_EO_delta)
xlabel('False acceptance rate'); 
ylabel('False rejection rate');
title('ROC curve - Eyes Open (PLV, Delta band)');
hold on;
plot(FAR_PLV_delta(1,1),FRR_PLV_delta(1,1),'r*');
plot(EER_PLV_delta(1,1),EER_PLV_delta(1,1),'g*');
%plot(FAR_PLV_delta2(1,1),FRR_PLV_delta2(1,1),'k*');
%plot(FAR_PLV_delta3(1,1),FRR_PLV_delta3(1,1),'m*');
legend('ROC curve','Optimal threshold (stochastic classifier) (lamda=0.5)','EER') %,'Optimal threshold (stochastic classifier) (lamda=0.5)','Optimal threshold (stochastic classifier) (lamda=0.25)');
%% (Eyes Closed, delta, PLV)
figure(2);
plot(FAR_PLV_EC_delta,FRR_PLV_EC_delta)
xlabel('False acceptance rate'); 
ylabel('False rejection rate');
title('ROC curve - Eyes Closed (PLV, Delta band)');
hold on;
plot(FAR_PLV_delta(2,2),FRR_PLV_delta(2,2),'r*');
plot(EER_PLV_delta(2,2),EER_PLV_delta(2,2),'g*');
legend('ROC curve','Optimal threshold (stochastic classifier) (lamda=0.5)','EER');


%% (Eyes Open, gamma, PLV)
figure(3);
plot(FAR_PLV_EO_gamma,FRR_PLV_EO_gamma)
xlabel('False acceptance rate'); 
ylabel('False rejection rate');
title('ROC curve - Eyes Open (PLV, Gamma band)');
hold on;
plot(FAR_PLV_gamma(1,1),FRR_PLV_gamma(1,1),'r*');
plot(EER_PLV_gamma(1,1),EER_PLV_gamma(1,1),'g*');
legend('ROC curve','Optimal threshold (stochastic classifier) (lamda=0.5)','EER')

%% (Eyes Closed, gamma, PLV)
figure(4);
plot(FAR_PLV_EC_gamma,FRR_PLV_EC_gamma)
xlabel('False acceptance rate'); 
ylabel('False rejection rate');
title('ROC curve - Eyes Closed (PLV, Gamma band)');
hold on;
plot(FAR_PLV_gamma(2,2),FRR_PLV_gamma(2,2),'r*');
plot(EER_PLV_gamma(2,2),EER_PLV_gamma(2,2),'g*');
legend('ROC curve','Optimal threshold (stochastic classifier) (lamda=0.5)','EER');

%% CommonPlot
figure(5);
plot(FAR_PLV_EO_delta,FRR_PLV_EO_delta)
xlabel('False acceptance rate'); 
ylabel('False rejection rate');
title('ROC curve (PLV, Delta and Gamma band)');
hold on;
plot(FAR_PLV_delta(1,1),FRR_PLV_delta(1,1),'r*');
plot(EER_PLV_delta(1,1),EER_PLV_delta(1,1),'g*');

plot(FAR_PLV_EC_delta,FRR_PLV_EC_delta)
plot(FAR_PLV_delta(2,2),FRR_PLV_delta(2,2),'m*');
plot(EER_PLV_delta(2,2),EER_PLV_delta(2,2),'k*');

% gamma
plot(FAR_PLV_EO_gamma,FRR_PLV_EO_gamma)
plot(FAR_PLV_gamma(1,1),FRR_PLV_gamma(1,1),'y*');
plot(EER_PLV_gamma(1,1),EER_PLV_gamma(1,1),'c*');

plot(FAR_PLV_EC_gamma,FRR_PLV_EC_gamma)
plot(FAR_PLV_gamma(2,2),FRR_PLV_gamma(2,2),'g*');
plot(EER_PLV_gamma(2,2),EER_PLV_gamma(2,2),'b*');







legend('ROC curve (Eyes Open - Delta)','Optimal threshold (stochastic classifier) (lamda=0.5) (EO)','EER (EO)', 'ROC curve (Eyes Closed - Delta)','Optimal threshold (stochastic classifier) (lamda=0.5) (EC)','EER (EC)', 'ROC curve (Eyes Open - Gamma)','Optimal threshold (stochastic classifier) (lamda=0.5) (EO)','EER (EO)', 'ROC curve (Eyes Closed - Gamma)','Optimal threshold (stochastic classifier) (lamda=0.5) (EC)','EER (EC)');







