function [raw_dataEO,raw_dataEC] = import_eeg_data(Ns,Nch,Fs,T)

% This function reads European Data Format data (.edf) with function edfread.
% It stores data in one matrix for each task. (Eyes Open: EO, Eyes Closed: EC)

% Input: Ns = Number of subjects
%        Nch = Number of channels
%        Fs = Sampling frequency (Hz)
%        T = Signal duration (sec)

% Kratame ta prwta 64 kanalia, den mas endiaferei to annotation channel.

% Episis kratame 9600 samples, afou exw katagrafes tou 1 min me syxnothta
% deigmatolhpsias 160 Hz, ara 160 samples/sec * 60 sec = 9600 samples.

%% Code

%Initialize matrices.
raw_dataEO = zeros(Nch,Fs*T,Ns);
raw_dataEC = zeros(Nch,Fs*T,Ns);

for i=1:Ns
    monades = mod(i,10) ;
    dekades = fix(i/10) ;
    ekatontades = fix(i/100) ;
    
    if (ekatontades == 1)
        dekades = fix((i-100)/10);    
    end
    
    % TASK 1: Baseline, eyes open (EO)

    s1 = ['S',num2str(ekatontades),num2str(dekades),num2str(monades),'R01.edf']; %num2str = number to string
    [~,record] = edfread(s1);
    raw_dataEO(:,:,i) = record(1:64,1:9600) ;

    
    % TASK 2: Baseline, eyes closed (EC)

    s2 = ['S',num2str(ekatontades),num2str(dekades),num2str(monades),'R02.edf'];
    [~,record] = edfread(s2);
    raw_dataEC(:,:,i) = record(1:64,1:9600) ;
end