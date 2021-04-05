function [EER,FAR_11,FRR_11,FAR_22,FRR_22,FAR_12,FRR_12,AUC] = EERMatrix(ScoreMat,T,Ns,epoch)

% Calculates EER matrix: EER = FRR (False Reject Rate) == FAR (False Accept
% Rate)
% FAR = FP/(FP + TN)
% FRR = FN/(FN + TP)
% 
% FP: False Positive, FN: False Negative
% TP: True Positive, TN: True Negative
%
% Input: ScoreMat = Score Matrix for each metric and each frequency band
%        T = Duration of signal (sec)
%        Ns = Number of subjects
%        epoch = Duration of non-overlapping epoch (sec)

% Case1: Task1 vs Task1
% Case2: Task1 vs Task2  == Task2 vs Task1
% Case3: Task2 vs Task2

% Task1 = Resting with Eyes Open (REO)   --   Task2 = Resting with Eyes
% Closed (REC)

% -- STEP 1: Calculate all impostor and genuine scores from Score Matrix. -- 
[GenuineScore1,GenuineScore2,GenuineScore3,ImpostorScore1,ImpostorScore2,ImpostorScore3] = Genuine_Impostor_Scores(ScoreMat,T,Ns,epoch) ;

% -- STEP 2: Calculate FAR, FRR between each task. --
[FAR_11,FRR_11,~] = Calculate_FAR_FRR(GenuineScore1,ImpostorScore1); %  Task1 vs Task1
[FAR_12,FRR_12,~] = Calculate_FAR_FRR(GenuineScore2,ImpostorScore2); %  Task1 vs Task2 == Task2 vs Task1
[FAR_22,FRR_22,~] = Calculate_FAR_FRR(GenuineScore3,ImpostorScore3); %  Task2 vs Task2

% -- STEP 3: Compute EER (Equal Error Rate) and AUC (Area Under the Curve). --
%Initialize matrices.
AUC = zeros(2,2);
EER = zeros(2,2);

% Extra metrikh gia thn apodosh tou systhmatos.
AUC(1,1) = abs(trapz(FAR_11,FRR_11)); 
AUC(1,2) = abs(trapz(FAR_12,FRR_12)); 
AUC(2,1) = AUC(1,2);
AUC(2,2) = abs(trapz(FAR_22,FRR_22)); 


% Ypologizw apolyth diafora FAR kai FRR, wste na vrw to shmeio EER.
min_val_11=abs(FAR_11-FRR_11); %  Task1 vs Task1
min_val_12=abs(FAR_12-FRR_12); %  Task1 vs Task2 == Task2 vs Task1
min_val_22=abs(FAR_22-FRR_22); %  Task2 vs Task2

% Epeidh h ROC curve (FAR,FRR) den einai synexhs kampylh, alla exei
% diakritopoiithei, mporei na mhn yparxei shmeio tetoio wste FAR == FRR.
% Opote epilegw ws shmeio EER, afto me thn elaxisth diafora metaksy FAR kai
% FRR.
%%  Task1 vs Task1

EER_FAR=FAR_11(find(min_val_11==min(min_val_11))); % to FAR ekei poy h apolyth diafora einai elaxisth
EER_FRR=FRR_11(find(min_val_11==min(min_val_11))); % to FRR ekei poy h apolyth diafora einai elaxisth

EER_calc = (EER_FAR+EER_FRR)/2; % mean value
if length(EER_calc)>1
    EER_calc = EER_calc(1);
end
EER(1,1) = EER_calc ;

%%  Task1 vs Task2 == Task2 vs Task1

EER_FAR=FAR_12(find(min_val_12==min(min_val_12))); 
EER_FRR=FRR_12(find(min_val_12==min(min_val_12))); 

EER_calc = (EER_FAR+EER_FRR)/2;
if length(EER_calc)>1
    EER_calc = EER_calc(1);
end
EER(1,2) = EER_calc ;

EER(2,1) = EER(1,2); % symmetric matrix

%%  Task2 vs Task2

EER_FAR=FAR_22(find(min_val_22==min(min_val_22))); 
EER_FRR=FRR_22(find(min_val_22==min(min_val_22)));

EER_calc = (EER_FAR+EER_FRR)/2;
if length(EER_calc)>1
    EER_calc = EER_calc(1);
end
EER(2,2) = EER_calc ;