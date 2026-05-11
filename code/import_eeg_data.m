function [raw_dataEO,raw_dataEC] = import_eeg_data(Ns,Nch,Fs,T,dataDir)

% Read EDF baseline data and store it in Eyes Open (EO) and Eyes Closed
% (EC) matrices.
%
% Input:
%   Ns = number of subjects
%   Nch = number of EEG channels to keep
%   Fs = sampling frequency (Hz)
%   T = signal duration (sec)
%   dataDir = directory that contains the EDF files (optional)

scriptDir = fileparts(mfilename('fullpath'));
if nargin < 5 || isempty(dataDir)
    dataDir = scriptDir;
elseif ~isfolder(dataDir)
    candidateDir = fullfile(scriptDir, dataDir);
    if isfolder(candidateDir)
        dataDir = candidateDir;
    else
        error('import_eeg_data:InvalidDataDir', ...
            'The data directory "%s" does not exist. Checked "%s" and "%s".', ...
            dataDir, dataDir, candidateDir);
    end
end

expectedSamples = Fs * T;

raw_dataEO = zeros(Nch, expectedSamples, Ns);
raw_dataEC = zeros(Nch, expectedSamples, Ns);

for i = 1:Ns
    subjectId = sprintf('S%03d', i);

    fileEO = fullfile(dataDir, [subjectId, 'R01.edf']);
    raw_dataEO(:,:,i) = read_single_record(fileEO, Nch, expectedSamples);

    fileEC = fullfile(dataDir, [subjectId, 'R02.edf']);
    raw_dataEC(:,:,i) = read_single_record(fileEC, Nch, expectedSamples);
end

end

function trimmedRecord = read_single_record(filePath, Nch, expectedSamples)

if exist(filePath, 'file') ~= 2
    error('import_eeg_data:MissingFile', ...
        ['Missing EDF file: %s\n' ...
         'Place the baseline EDF files in the configured data directory ' ...
         'or update data_dir in main_program.m.'], filePath);
end

[~, record] = edfread(filePath);

if size(record, 1) < Nch
    error('import_eeg_data:UnexpectedChannelCount', ...
        'File "%s" contains %d channels, but %d channels are required.', ...
        filePath, size(record, 1), Nch);
end

if size(record, 2) < expectedSamples
    error('import_eeg_data:UnexpectedSampleCount', ...
        'File "%s" contains %d samples, but %d samples are required.', ...
        filePath, size(record, 2), expectedSamples);
end

trimmedRecord = record(1:Nch, 1:expectedSamples);

end
