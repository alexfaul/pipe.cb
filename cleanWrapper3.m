%% Pipe wrapper3
% Change root to whatever mouse you want to run
% Check for registration issues before running these and proceeding w
% analysis
% Must have output from Suite2p to run all below functions
%% %% get dFF calculations - RUN AFTER SUITE2P + CELL CLICKING!
    root    ='Z:\AFdata\2p2019\Sut3';                    %% as character 
    ext = 'Fall.mat';
    stimdir = findFILE(root,ext);

    stimDirs=stimdir(:);
    time_window=30;
    percentile=10;
for ii=1:length(stimDirs)
dffCalc(stimDirs{ii},percentile,time_window); 
end 
%% Generate plots
    ext = 'dff.mat';
    stimdir = findFILE(root,ext);
    stimDirs=stimdir(:);

for ii=1:length(stimDirs)
generateCellPlots(stimDirs{ii},5); %change to be just stim path
end 

%which orientation was rewarded**
%plot line at first lick on trial by trial basis
%average licking and running rate per orientation - on graph in behavior plots? 
%% find drivenness - below functions do not save output, workspace output only
ext = 'stim.mat';
stimdir = findFilePathAF(root,ext);
stimDirs=stimdir(4);

for ii=1:length(stimDirs)
    [dffTrials,baselineTrials, statsT, statsW]=separateByTrials(stimDirs(ii))
end

bias200226=biasDet(dffTrials200226,baselineTrials2002226,statsW200226) 
