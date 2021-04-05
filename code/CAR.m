function [CAR_EO,CAR_EC] = CAR(rawEO,rawEC)

% Computes Common Average Reference data, from raw EEG data.
% Remove mean value of all electrodes, from all electrodes, for each
% sample.
%
% Inputs: rawEO, rawEC = raw eeg data eyes open and eyes closed

% Initialize
CAR_EO = zeros(size(rawEO,1),size(rawEO,2),size(rawEO,3)) ;
CAR_EC = zeros(size(rawEC,1),size(rawEC,2),size(rawEC,3)) ;

for k=1:size(rawEO,3)
    for j=1:size(rawEO,2)
    
        % Calculate common activity for all channels for each time point.
        sum_channel_EO = sum(rawEO(:,j,k));
        sum_channel_EC = sum(rawEC(:,j,k));
    
        common_average_EO = sum_channel_EO / size(rawEO,1) ;
        common_average_EC = sum_channel_EC / size(rawEC,1) ;
    
        % Substract common activity from each channel.
        CAR_EO(:,j,k) = rawEO(:,j,k) - common_average_EO;
        CAR_EC(:,j,k) = rawEC(:,j,k) - common_average_EC;

    end
end