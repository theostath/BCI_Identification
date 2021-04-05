function [FeatVec] = FeatureVector(ConMat,Nch)

% Feature vector extracted from the upper triangular connectivity matrix.
% Input: ConMat = connectivity matrix
%        Nch = Number of channels

FeatVec = zeros(1,Nch*(Nch-1)/2);

s = 0;
for i=1:Nch
    for j=1:Nch
        if (i>j)
            s = s+1;
            FeatVec(s) = ConMat(i,j);
        end
    end
end