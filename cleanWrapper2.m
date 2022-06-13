%% Wrapper 2

% Before running, make sure you have:
%   1. bhv2 file from the ML computer AND
%   2. Outputs from Facemap/DLC (pupil and motSVD)
% If using FM, convert outputs with jupyter notebook 
%   (Open anaconda prompt, type jupyter notebook, adjust filepath in facemap processing, run - comment out pupil if only doing motSVD)
%% Get BHV paths to find stimuli/response onsets/offsets
    root    ='Z:\AFdata\2p2019\Experiments\W10';                    %% as character 
    ext = '.bhv2';
    bhvdirs = findFILE(root,ext);
    bhvPath = bhvdirs(:);
    bhvPath = cellDirs(5:end);

for ii=1:length(bhvPath);   
   [~]= bhv2Convert(bhvPath{ii},'Z:\AFdata\2p2019');      %% MAKE SURE THERE IS A RUN # in THE .bhv2 FILE NAME (A 001 or 002 etc) IN THERE
end                                                                                                     % config file (.txt with MonkeyLogic Conditions) should be in the 2p data folder
% configfile=fullfile(which([cname,'.txt']));'Z:\AFdata\2p2019\FC_baselinerand_200211.txt'
%% find stim times from nidaq output pulses
%     ext1 = 'bhv.mat';
%     bhvdirs = findFILE(root,ext1);
%     bhvPath=bhvdirs(:);
%     
%     bhvPath=bhvdirs;
% for ii=1:length(bhvPath);
    Stim=stimTimes(bhvPath{ii});
% end 
%% plots of behavior (pupil, running, etc) during trials w/ stim
    ext = '_stim';
    stimdirs = findFILE(root,ext);
    stimDirs=stimdirs(9);
    time_window=90;

for ii=1:length(stimDirs) %should this go back to looking for dsnidaq? If there is no stim... skip behavior plots?
   behaviorPlots(stimDirs{ii},time_window,'FC App Day 3')           % last is custom label (useful for labeling behavioral day ex: FC) 
end %still needs some cleaning/optimization (such as adding graphing fxn?)


%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialLength=min(Stim.trialoffsets-Stim.trialonsets);
n=trialLength;

pos1Idx=Stim.trialonsets(Stim.condition==1)
pos2Idx=Stim.trialonsets(Stim.condition==2)
pos3Idx=Stim.trialonsets(Stim.condition==3)
pos4Idx=Stim.trialonsets(Stim.condition==4)
pos5Idx=Stim.trialonsets(Stim.condition==5)
pos6Idx=Stim.trialonsets(Stim.condition==6)

