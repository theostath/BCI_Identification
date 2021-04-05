function [ConMat] = ConnectivityMatrix(data_epoch,metric,Nch,Fs,epoch)

% Create/compute connectivity matrix for each subject, each epoch and each functional connectivity metric.
%
% Input: data_epoch = eeg data (64 channels, 1920 samples, specific
% subject, specific epoc)
%        metric = 'PLV' / 'PLI' / 'COR' / 'AEC' / 'AECc' / 'COH'
%        Nch = Number of channels
%        Fs = sampling frequency
%        epoch = duration of epochs in sec (non overlapping)

% Note-1: hilbert(Xr) function computes the discrete-time analytic signal X = Xr + i*Xi, such that Xi is the 
%         Hilbert transform of Xr
% Note-2: angle(x) = arctan[imaginary(x)/real(x)]  --> inst. phase(x) =
%         angle(hilbert(x))

EpSam = Fs*epoch; % epoch length ( in samples )

% Initialize matrix.
ConMat = zeros(Nch,Nch);

% Useful computations.
phase = angle(hilbert(data_epoch));

%% PLV (Phase Locking Value)
% range [0,1]

check = strcmp(metric,'PLV'); % compare strings

if (check == 1)
    for i=1:Nch        
        for j=1:Nch
            if (i<j)                
                ConMat(i,j) = abs(mean(exp(1i*(phase(i,:)-phase(j,:))))) ; 
                ConMat(j,i) = ConMat(i,j) ; % symmetric FC matrix
            end
        end
    end
end

%% PLI (Phase Lag Index)
% range [0,1]

check = strcmp(metric,'PLI'); % compare strings

if (check == 1)
    for i=1:Nch        
        for j=1:Nch
            if (i<j) 
                ConMat(i,j) = abs(mean(sign(sin(phase(i,:)-phase(j,:)))));
                ConMat(j,i) = ConMat(i,j); % symmetric FC matrix
            end
        end
    end
end

%% COR (Pearson's correlation coefficient)
% range [-1,1]

check = strcmp(metric,'COR'); % compare strings

if (check == 1)
    for i=1:Nch
        
        x = data_epoch(i,:) ; % Channel i, all samples.
        
        % mean value
        sum_x = sum(x) ;
        mean_x = sum_x/EpSam ;
        
        % standard deviation (typikh apoklish)
        s_x = std(x) ;
        
        for j=1:Nch
            
            if (i<j)
                y = data_epoch(j,:) ; % Channel i, all samples.
                
                % mean value 
                sum_y = sum(y);
                mean_y = sum_y/EpSam ;
            
                % standard deviation (typikh apoklish)
                s_y = std(y) ;
            
                % calculate Pearson's correlation coeff.
                ConMat(i,j) = 1/EpSam * sum(((x-mean_x)/s_x).*((y-mean_y)/s_y)) ;
                ConMat(j,i) = ConMat(i,j) ; % symmetric FC matrix
            end            
        end
    end
end

%% AEC (Amplitude Envelope Correltion)
% range [-1,1]

check = strcmp(metric,'AEC'); % compare strings

if (check == 1)
    for i=1:Nch
        
        x = abs(hilbert(data_epoch(i,:))) ; % Absolute of analytic signal (amplitude) of: channel i, all samples.
        
        % mean value
        sum_x = sum(x) ;
        mean_x = sum_x/EpSam ;
        
        % standard deviation (typikh apoklish)
        s_x = std(x) ;
        
        for j=1:Nch
            
            if (i<j)
                
                y = abs(hilbert(data_epoch(j,:))) ; % Absolute of analytic signal (amplitude) of: channel j, all samples.
                
                % mean value 
                sum_y = sum(y);
                mean_y = sum_y/EpSam ;
            
                % standard deviation (typikh apoklish)
                s_y = std(y) ;
            
                % calculate Pearson's correlation coeff.
                ConMat(i,j) = 1/EpSam * sum(((x-mean_x)/s_x).*((y-mean_y)/s_y)) ;
                ConMat(j,i) = ConMat(i,j) ; % symmetric FC matrix
            end            
        end
    end
end

%% AECc (Amplitude Envelope Correltion corrected version)
% range [-1,1]

check = strcmp(metric,'AECc'); % compare strings

if (check == 1)
    for i=1:Nch
        
        x = data_epoch(i,:) ; % Channel i, all samples.
        
        x_amp = abs(hilbert(data_epoch(i,:))) ; % Absolute of analytic signal (amplitude) of: channel i, all samples.

        % mean value
        x_sum = sum(x_amp) ;
        x_mean = x_sum/EpSam ;

        % standard deviation (typikh apoklish)
        x_s = std(x_amp) ;

        for j=1:Nch

            if (i<j)

                y = data_epoch(j,:) ; % Channel j, all samples.
                
                y_amp = abs(hilbert(data_epoch(j,:))) ; % Absolute of analytic signal (amplitude) of: channel j, all samples.

                % mean value 
                y_sum = sum(y_amp);
                y_mean = y_sum/EpSam ;

                % standard deviation (typikh apoklish)
                y_s = std(y_amp) ;

            % Orthgonalization procedure: channel i - channel j:
                
            % - STEP 1 -
                % Calculate orthogonalized signal X to Y.
                x_orthog = orthogonalization(x,y) ;

                % Compute amplitude of orthogonalized signal.
                x_orthog_amp = abs(x_orthog);

                % mean value 
                x_orthog_sum = sum(x_orthog_amp) ;
                x_orthog_mean = x_orthog_sum/EpSam ;

                % standard deviation
                x_orthog_s = std(x_orthog_amp);

                % Compute AEC of orthogonalized signal and channel i EEG data.
                AEC1 = 1/EpSam * sum(((x_amp-x_mean)/x_s).*((x_orthog_amp-x_orthog_mean)/x_orthog_s)) ;

            % - STEP 2 -
                % Calculate orthogonalized signal Y to X.
                y_orthog = orthogonalization(y,x) ;

                % compute amplitude of orthogonalized signal.
                y_orthog_amp = abs(y_orthog);

                % mean value 
                y_orthog_sum = sum(y_orthog_amp) ;
                y_orthog_mean = y_orthog_sum/EpSam ;

                % standard deviation
                y_orthog_s = std(y_orthog_amp);

                % Compute AEC of orthogonalized signal and channel j EEG
                % data.
                AEC2 = 1/EpSam * sum(((y_orthog_amp-y_orthog_mean)/y_orthog_s).*((y_amp-y_mean)/y_s)) ;
            
            % - FINAL STEP -
                % AECc = mean value of AEC1 + AEC2
                AEC_mean = (AEC1+AEC2)/2;

                ConMat(i,j)=AEC_mean;          
                ConMat(j,i)=ConMat(i,j); % symmetric FC matrix

            end            
        end
    end
end 

%% COH (Coherence)
% range [0,1]

check = strcmp(metric,'COH'); % compare strings

if (check == 1)
    for i=1:Nch
        
        x = data_epoch(i,:) ; % Channel i, all samples.
        
        for j=1:Nch
            
            if (i<j)
                y = data_epoch(j,:) ; % Channel j, all samples.

                ConMat(i,j) = mean(mscohere(x,y)); % Mean value of all frequencies.
                ConMat(j,i) = ConMat(i,j) ; % symmetric FC matrix
            end            
        end
    end
end