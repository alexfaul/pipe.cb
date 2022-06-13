%%%%% TOP SECTION IS ONLY FOR WHEN SWITCHING MICE!!!
%%%%%%%%%%%%%
%% IMPORTANT: RUN THIS TOP SECTION(UNTIL LINE ~55) FOR A NEW MOUSE
%%%% THEN ONLY RUN BELOW LINE ~55 when doing different files within SAME
%%%% MOUSE
root    ='Z:\AFdata\2p2019\Experiments\T02';                    %% USER INPUT change mouse here 
%%%%%%%%%%%%%%%%%%%%%%%%%%% finding which dsnidaqs were overwritten eeeek
%%%%%%%%%%%%%%%%%%%%%%%%%%% USING FILE SIZE BRILLIANT
% % % % % % % %     ext='dsNidaq.mat'
% % % % % % % %     sbxdirs = findFILE(root,ext);  
% % % % % % % % for ii=1:length(sbxdirs)    
% % % % % % % % s = dir(sbxdirs{ii});         
% % % % % % % % filesize(ii) = s.bytes
% % % % % % % % end
% % % % % % % % 
% % % % % % % % dsredo=find(filesize<1000)
% % % % % % % % dsRedoPaths=sbxdirs(dsredo)
% % % % % % % % sbxDirs=dsRedoPaths(1:12)
%% Find matching directories
    ext = '_nidaq.mat';
    nidaqDirs = findFILE(root,ext);
    ext = 'bhv.mat';
    bhvDirs = findFILE(root,ext);
    ext='meanImg.mat'
    imgDirs=findFILE(root,ext)
    ext = 'dsNidaq.mat';  %save file
    dsnidaqDirs = findFILE(root,ext);
%% 
for ii=1:length(imgDirs)                    %%% finding name of imgDir to match to nidaq
[~,filename,~] = fileparts(imgDirs{ii});
fileName(ii)={extractBefore(filename,'meanImg')}; %%'meanImg'
end

nidaqName = regexprep(nidaqDirs,'.*\', '');    %%filename of cell list
for ii=1:length(imgDirs)
idx=find(contains(nidaqName,fileName{ii}))
nidaqMatchList(ii)=nidaqDirs(idx)
end

dsnidaqName = regexprep(dsnidaqDirs,'.*\', '');                 %%filename of cell list
dsnidaqName = extractBefore(dsnidaqName,'_dsNidaq.mat');
for ii=1:length(fileName)
idx=find(contains(dsnidaqName,fileName{ii}))
dsnidaqMatchList(ii,1)=dsnidaqDirs(idx)
end
%%
% customMouseIDX=([1:26 28:length(fileName)]); %%%%%%%% if theres a missing bhv file
% %% Index so they all align
% nidaqMatchList  = nidaqMatchList(customMouseIDX)';  %% missing 1 bhv file T03 
% imgDirs         = imgDirs(customMouseIDX);
% dsnidaqMatchList= dsnidaqMatchList([customMouseIDX]);  %% missing 1 bhv file T03 
% fileName        = fileName(customMouseIDX)
% bhvMatchList    = bhvDirs;  
% 
customMouseIDX=([2:length(bhvDirs)]); %%%%%%%% if theres a missing bhv file
nidaqMatchList  = nidaqMatchList';  %% extra 1 bhv file T02 and T01(??)
imgDirs         = imgDirs;
dsnidaqMatchList= dsnidaqMatchList;  %% missing 1 bhv file T03 
fileName        = fileName';
bhvMatchList    = bhvDirs(customMouseIDX); 
%%%%%%%%%%match with nidaq
% % % % % % 
close all
clearvars -except bhvMatchList fileName nidaqMatchList dsnidaqMatchList imgDirs root
% % % % % % % % % % % % % % % % % % % 
%% RUN THE SECTION BELOW ONLY WHEN SWITCHING FILES
%%%%% TOP SECTION IS ONLY FOR WHEN SWITCHING MICE!!!
%% Load matching files, create new visstim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%% T02 START WITH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  210205 AND BEYOND
mm=18;                          %%%%%%%%%USER INPUT HERE (WHICH FILE # - on google sheet!! )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%  If missing visstim, run this section
startTime=162;                  %%%%%%%%%USER INPUT - Pull from Cell Clicking Google Sheet
%%%%%%%%%%%%%%%
fileName{mm}
[~,bhv]=fileparts(bhvMatchList{mm})
[~,nidaq]=fileparts(nidaqMatchList{mm})
[~,dsnidaq]=fileparts(dsnidaqMatchList{mm})
[~,img]=fileparts(imgDirs{mm})

nidaqMatchList{mm}
clearvars -except mm root imgDirs fileName ii data startTime AbsoluteTrialStartTime nidaqMatchList bhvMatchList dsnidaqMatchList meanImg
%% 
load(nidaqMatchList{mm});
load(bhvMatchList{mm});
load(imgDirs{mm});
load(dsnidaqMatchList{mm});
%%
clearvars -except mm dsnidaq root imgDirs fileName ii data startTime AbsoluteTrialStartTime nidaqMatchList bhvMatchList dsnidaqMatchList meanImg
%% Create alternate visstim trace reconstructed from BHV files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % AbsoluteTrialStartTime(:,4)=AbsoluteTrialStartTime(:,4)+2
% % % AbsoluteTrialStartTime(1,4)=1 FIX FOR MIDNIGHT RUNS
% % % AbsoluteTrialStartTime(2,4)=1

New_signal_ds = makenewvisstimsignal(data, AbsoluteTrialStartTime);
%%%%%%
temp=zeros(1,startTime-3)  %change estimated start time here 3 frames before spike
temp2=[temp New_signal_ds(43:end) temp] %%% 43 is base blank made in visstim fix, 
AdjustNew_signal_ds=temp2(1:length(meanImg))
New_signal_dsPlot=(AdjustNew_signal_ds*100)+(mean(meanImg)*0.95)

figure
plot(meanImg(1:3000))
hold on
plot(New_signal_dsPlot(1:3000))
%%%%%%%
%% find vissstim on and off
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%
visStim=AdjustNew_signal_ds;
trialOnsets = find(diff(visStim)==5);  %5 for generated visstim
trialOnsets=trialOnsets+1;
trialOffsets = find(diff(visStim)==-5);
trialOffsets=trialOffsets+1;

%%% mean trace of pulse with onset
trialOnsets=trialOnsets(1:length(trialOffsets))
trialLength=trialOffsets-trialOnsets
visstimResponses=zeros(length(trialOnsets),max(trialLength)+30)
for ii=1:length(trialOnsets)-1
temp=meanImg(trialOnsets(ii)-15:trialOnsets(ii)+max(trialLength)+14); %%%Am I off by 1 here?
visstimResponses(ii,:)=temp;
clear temp
end 



errr=std(visstimResponses,0,1);
figure
shadedErrorBar(1:size(visstimResponses,2),visstimResponses,{@mean,@(x) std(x)/sqrt(size(x,1))})
hold on
xline(15)
%%%%%%%%%%%%%%%%%%%%%%%%%
%% STOP RUNNING HERE UNTIL VERIFYING - ignore this warning if pulling from google sheet
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%
% IF IT LOOKS ALIGNED,PROCEED TO SAVE IT
%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save new visstim
% clearvars -except dsnidaqMatchList startTime visStim mm
% load(dsnidaqMatchList{mm})
dsnidaq=load(dsnidaqMatchList{mm});
visStim=visStim+1;
visStim(visStim>5)=5;   
dsnidaq.ManualVisstimFix=1;
dsnidaq.ManualStartTime=startTime;
dsnidaq.visstim=visStim;

save(dsnidaqMatchList{mm},'-struct','dsnidaq')