%% Pipe wrapper3
% Change root to whatever mouse
%% %% get dFF calculations - RUN AFTER SUITE2P + CELL CLICKING!
root='Z:\DATA TEMP\New folder';
ext = 'Fall.mat';
stimdir = findFilePathAF(root,ext);
%dffDirs=clickeddir(ismember(stimdir,clickeddir));

stimDirs=stimdir(1);
time_window=30;
percentile=10;
for ii=1:length(stimDirs)
dffCalc2(stimDirs{ii},percentile,time_window); %debugged, AUC and SNR added. SNR is in dB, may or maynot be best measure but give a try...
end 
%% Generate plots
set(gcf,'visible','off')
ext = 'dff.mat';
stimdir = findFilePathAF(root,ext);
stimDirs=stimdir(:);

for ii=1:length(stimDirs)
generateCellPlots(stimDirs{ii},5); %change to be just stim path
end 

%which orientation was rewarded**
%monocoluar vs binocular
%plot line at first lick on trial by trial basis
%average licking and running rate per orientation - on graph in behavior plots? 

%  add stats to graph
%% find drivenness
ext = 'stim.mat';
stimdir = findFilePathAF(root,ext);
stimDirs=stimdir(4);

for ii=1:length(stimDirs)
    [dffTrials,baselineTrials, statsT, statsW]=separateByTrials(stimDirs(ii))
end

%will not save anything, so have to just load what you want. 
bias200226=biasDet(dffTrials200226,baselineTrials2002226,statsW200226) 
