%% Wrapper 2

% Before running, make sure you have:
%   1. bhv2 file from the ML computer AND
%   2. Outputs from Facemap/DLC (pupil and motSVD)
% If using FM, convert outputs with jupyter notebook 
%   (Open anaconda prompt, type jupyter notebook, adjust filepath in facemap processing, run - comment out pupil if only doing motSVD)
%% Get BHV paths to find stimuli/response onsets/offsets
    root='Z:\DATA_TEMP\New folder';
    ext = 'bhv2';
    bhvdirs = findFILE(root,ext);
    bhvPath = bhvdirs(1);

for ii=1:length(bhvPath);   
   [~]= bhv2Convert(bhvPath{ii});                               %% MAKE SURE THERE IS A RUN # in THE .bhv2 FILE NAME (A 001 or 002 etc) IN THERE
end                                                              % config file (.txt with MonkeyLogic Conditions) should be in the 2p data folder
% configfile=fullfile(which([cname,'.txt']));
%% find stim times from nidaq output pulses
    ext = 'bhv.mat';
    bhvdirs = findFILE(root,ext);
    bhvPath=bhvdirs(1);

for ii=1:length(bhvPath);
   Stim=stimTimes(bhvPath{ii});
end 
%% plots of behavior (pupil, running, etc) during trials w/ stim
    ext = '_stim';
    stimdirs = findFILE(root,ext);
    stimDirs=stimdirs(1);
    time_window=90;

for ii=1:length(stimDirs) %should this go back to looking for dsnidaq? If there is no stim... skip behavior plots?
   behaviorPlots(stimDirs{ii},time_window,'FC Day 3 - Expression')           % last is custom label (useful for labeling behavioral day ex: FC) 
end 
