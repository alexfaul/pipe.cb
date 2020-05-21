%% Get BHV paths to find stimuli/response onsets/offsets
root='Z:\DATA TEMP\New folder';
ext = 'bhv2';
bhvdirs = findFILE(root,ext);
bhvPath = bhvdirs(1);
%% Path to file with conditions listed

for ii=1:length(bhvPath);   
    bhv_struct= bhv2Convert(bhvPath{ii});                               %% MAKE SURE THERE IS A RUN # in THE .bhv2 FILE NAME (A 001 or 002 etc) IN THERE
end                                                                     % config file (.txt with MonkeyLogic Conditions) should be in the 2p data folder
% configfile=fullfile(which([cname,'.txt']));
%% find stim times from nidaq output pulses
ext = 'dsNidaq';
nidaqdirs = findFILE(root,ext);
nidaqDirs=nidaqdirs(:);
for ii=1:length(nidaqDirs);
Stim=stimTimes(nidaqDirs{ii});
end 
%% make generate cell plots and generate behavior plots 2 separate functions
 %Run
ext = '_stim';
stimdirs = findFILE(root,ext);
stimDirs=stimdirs(3);
time_window=90;
for ii=1:length(stimDirs)
behaviorPlots2(stimDirs{ii},time_window,['FC Day 3 - Expression']) %add XY offset
end 
