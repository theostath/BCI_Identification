function [FAR,FRR,thres] = Calculate_FAR_FRR(GenuineScore,ImpostorScore)

% Calculates False Acceptance Rate (FAR) and False Rejection Rate (FRR),
% through genuine and impostor scores, with the help of a reference
% threshold.
%
% Input: GenuineScore = genuine scores from score matrix
%        ImpostorScore = impostor scores from score matrix

min1 = min(ImpostorScore);
min2 = min(GenuineScore);

max1 = max(ImpostorScore);
max2 = max(GenuineScore);

final_min = min(min1,min2);
final_max = max(max1,max2);

NumThres = length(GenuineScore)+length(ImpostorScore) ;  % Number of thresholds.

step = (final_max-final_min)/NumThres; % Step between each threshold and the next one.
step = step*10; % Veltiwnei 5 fores ton kwdika (apo apopsh xronou) kai xanei elaxista se akriveia)!
thres = final_min:step:(final_max-step); % Vector of thresholds.

% Score > threshold --> accept
% Score <= threshold --> reject

%Initialize vectors.
FRR = zeros(1,length(thres));
FAR = zeros(1,length(thres));

for k=1:length(thres)
    
    genuine_user = 0;
    impostor_user = 0;
    
    for i=1:length(GenuineScore)
        if GenuineScore(i)<=thres(k)
            genuine_user = genuine_user+1; % false negative
        end
    end
    for j=1:length(ImpostorScore)
        if ImpostorScore(j)>thres(k)
            impostor_user = impostor_user+1; % false positive
        end
    end
    FRR(k) = (genuine_user/length(GenuineScore));
    FAR(k) = (impostor_user/length(ImpostorScore));
end