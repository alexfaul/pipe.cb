%% Pipeline Wrapper %%

% The only changes necessary should be within root and selecting which
% files to run in second line of indexing after findFilePathAF
    root    ='Z:\AFdata\2p2019\Experiments\MR4';             %% as character 
    ext ='.sbx';                                 %% Can find any character (text) matching ext. Also faster than the File Explorer
%     ext='dsNidaq.mat'
    sbxdirs = findFILE(root,ext);                %% Will return cell array of all files under root containing extList
    sbxDirs = sbxdirs(:) %% change here   

%     sbxDirs=cellDirs2(14:end)
% for ii=1:length(sbxDirs)
%     customLabels={['Training Day Baseline 1']}   %%optional, will label graphs within readSbxEphysCheck
% end
% sbxDirs=cellDirs
%     customLabels=['Appetetive day 1']   %%optional, will label graphs within readSbxEphysCheck

for ii=1:length(sbxDirs)
readSbxEphysCheck(sbxDirs{ii});
end
%% WRITE TIFFS
stimTimes=[];
n=500;
%n=trialLength-1
%customStart=[1:1000:25000];
 customStart=[];
for ii=1:length(sbxDirs);
tiffLoop(sbxDirs{ii},n,0,customStart,'Z:\Fiji.app');                    %% write TIFFs for all sbx files found above to run suite2p
end     
% % % 
% 
javaaddpath 'C:\Program Files\MATLAB\R2022a\java\mij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2022a\java\ij.jar'

%% Eye vids - find and write them to .avi

    root    ='Z:\AFdata\2p2019\Experiments\T07';             %% as character 
    ext = 'eye.mat';
    eyedirs = findFILE(root,ext);
    eyeDirs = eyedirs(:)


for ii=1:length(eyeDirs)
[temp]=writeVid(eyeDirs{ii});               % change this so that it will find the eye.mat files from the sbx directories
goodEyeFile(ii)=temp;  %%%%%% put this into 
end 

%% Convert BHV files - from MonkeyLogic
    root    ='Z:\AFdata\2p2019\Experiments\T07';      %% as character

    ext = '.bhv2';
    bhvdirs = findFILE(root,ext);
    bhvPath = bhvdirs(:)
    %bhvPath = cellDirs(:);

for ii=1:length(bhvPath);   
   [~]= bhv2Convert(bhvPath{ii},'Z:\AFdata\2p2019\Experiments\AF_allBehavior_LTLearning Scripts');      %% MAKE SURE THERE IS A RUN # in THE .bhv2 FILE NAME (A 001 or 002 etc) IN THERE
end         
% %     
% % for ii=1:length(bhvPath);   
% %    [~]= bhv2Convert(bhvPath{ii},'Z:\AFdata\2p2019', 'Z:\AFdata\2p2019\Eight_orientations_AF.txt');      
% %    %% MAKE SURE THERE IS A RUN # in THE .bhv2 FILE NAME (A 001 or 002 etc) IN THERE
% % end
%for sut mice need to specify the ori
%% Run Facemap and conversion script before running:
 ext = '_stim';
    stimdirs = findFILE(root,ext);
    stimDirs=stimdirs(9);
    time_window=90;
%%%%%%%%%%%%%%% behaviorPlots
for ii=1:length(stimDirs) %should this go back to looking for dsnidaq? If there is no stim... skip behavior plots?
   behaviorPlots(stimDirs{ii},time_window,'FC App Day 3')           % last is custom label (useful for labeling behavioral day ex: FC) 
end %still needs some cleaning/optimization (such as adding graphing fxn?)
%% RUN SUITE2P + CELL CLICKING!
%%%%%%%% once finished cell clicking write to Fall.mat within suite2p GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% %% get dFF calculations 
    root    ='Z:\AFdata\2p2019\Experiments\T03';                    %% as character 
    ext = 'Fall.mat';
%     ext = 'Suite2p_dff.mat';

    stimdir = findFILE(root,ext);
    stimDirs=stimdir(11) %%210210 and 210209 are fucky. FUN! just make it so it skips the last trial, its too much of a fucking hassle.
%     stimDirs=stimdir(:)
    time_window=10;
    percentile=20;
%     runNums={['001'],['002']}  %%manual for the flipped files, no good way around this bc the tiffs arent named

%%%%%%%%%%%%%%%%%%%%%%%
%%%% if file exists, won't overwrite
%%% still need to fix alignStim
tic
for ii=1:length(stimDirs)
close all
dffCalc(stimDirs{ii},percentile,time_window); 
end 
toc

    root    ='Z:\AFdata\2p2019\Experiments\W05';                    %% as character 
    ext = 'dff.mat';
    ext = 'Suite2p_dff.mat';

    stimdir = findFILE(root,ext);

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
ii=1

for ii=1:length(stimDirs)
load(stimDirs{ii})
Sut1cells(ii)=length(find(iscell(:,1)))
[fullRoot,filename,~] = fileparts(stimDirs{ii});
idcs   = strfind(fullRoot,filesep);
FILENAMESut1(ii) = fullRoot(idcs(end-4)+1:idcs(end-3)-1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement (ex: update of Suite2p that changes file locations)
end

=fileparts(stimDirs{ii})
fileName = regexprep(stimDirs,'.*\', '');                 %%filename of cell list

clear all

    root    ='Z:\AFdata\2p2019\Experiments\Sut3';                    %% as character 
%%% Generate plots
    ext = 'dff.mat';
    stimdir = findFILE(root,ext);
    stimDirs=stimdir(9:end);

for ii=1:length(stimDirs)
generateCellPlots(stimDirs{ii},5); %change to be just stim path
end 
