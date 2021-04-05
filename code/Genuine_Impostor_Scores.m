function [genuine_scores1,genuine_scores2,genuine_scores3,impostor_scores1,impostor_scores2,impostor_scores3]=Genuine_Impostor_Scores(ScoreMat,T,Ns,epoch)

% Creates matrices for genuine and impostor scores between each task, with the help of Score
% matrix.
% Task1 = Eyes Open
% Task2 = Eyes Closed
%
% Input: ScoreMat = Score matrix for each FC metric and each frequency band
%        T = Duration of signal (sec)
%        Ns = Number of subjects
%        epoch = Duration of non-overlapping epoch (sec) 

dim = size(ScoreMat,1) ;

% Within task (symmetric matrices) --> case1 + case 3
num_gen1 = (T/epoch)*(T/epoch-1)*Ns/2 ; % number of genuine scores
num_imp1 = (dim/2)*((dim/2)-1)/2 - num_gen1 ; % number of impostor scores

% Between task (mh symmetric matrices) --> case 2
num_gen2 = (T/epoch) * (T/epoch) * Ns ; % number of genuine scores
num_imp2 = (dim/2) * (dim/2) - num_gen2 ; % number of impostor scores

%Initialize vectors.
% Case1: Task1 vs Task1
genuine_scores1 = zeros(1,num_gen1) ;
impostor_scores1 = zeros(1,num_imp1) ;

% Case2: Task1 vs Task2  == Task2 vs Task1
genuine_scores2 = zeros(1,num_gen2) ;
impostor_scores2 = zeros(1,num_imp2) ;

% Case3: Task2 vs Task2
genuine_scores3 = zeros(1,num_gen1) ;
impostor_scores3 = zeros(1,num_imp1) ;

%Score index.
index1 = 1;
index2 = 1;
index3 = 1;
index4 = 1;
index5 = 1;
index6 = 1;


for i=1:size(ScoreMat,1)
    for j=1:size(ScoreMat,2)

        % Case1: Task1 vs Task1
        if ((i<=dim/2) && (j<=dim/2) && (i<j))
            if fix(i/(T/epoch)) == fix((j-1)/(T/epoch)) && mod(i,(T/epoch))~=0
                genuine_scores1(index1) = ScoreMat(i,j) ;
                index1 = index1 + 1;
            else
                impostor_scores1(index2) = ScoreMat(i,j) ;
                index2 = index2 + 1;
            end
            
        % Case2: Task1 vs Task2 AND case3: Task2 vs Task1    
        elseif ((i<=dim/2) && (j>dim/2))

            if fix((i-1)/(T/epoch)) == fix((j-dim/2-1)/(T/epoch))
                genuine_scores2(index3) = ScoreMat(i,j) ;
                index3 = index3 + 1;
            else
                impostor_scores2(index4) = ScoreMat(i,j) ;
                index4 = index4 + 1;
            end                   
            
        % Case3: Task2 vs Task2    
        elseif ((i>dim/2) && (j>dim/2) && (i<j)) 
             if fix(i/(T/epoch)) == fix((j-1)/(T/epoch)) && mod(i,(T/epoch))~=0
                genuine_scores3(index5) = ScoreMat(i,j) ;
                index5 = index5 + 1;
            else
                impostor_scores3(index6) = ScoreMat(i,j) ;
                index6 = index6 + 1;
            end           

        end
    end
end