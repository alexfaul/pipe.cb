%% SUTTON GROUP DATA
%% 
clearvars -except messedUpNeurons
%% Initialize with manually known index positions
% MAKE A TIME POINT INDEX BY ~ALL~ DATES THAT CORRESPOND TO THAT TIMEPOINT IN EXPERIMENT

Idx=...
{{'190924_001';'210202_001';'191117_001'};...     %0.5 - Baseline
 {'210202_005'; '190924_005'; '191117_005'};...     %6B
 {'210202_009'; '190924_009'; '191117_009'};...     %12B
 {'210203_001'; '190925_001';'191118_001'};...      %24B
 {'190926_001';'191119_001';'210204_001'};...       %48B
 {'210205_001'; '190927_001'; '191120_001'};...     %72B
 {'210206_001'; '190928_001'; '191121_001'};...     %96
    %%% SUT3 and SUT4 now off by 2 days after resuture needed on Sut4
 {'210209_001';'191001_001';'Sut3_191122_001';'Sut4_191124_001'};...   %0.5 - Sutured
 {'210209_005';'191001_005';'Sut3_191122_005';'Sut3_191122_005'};...    %6S
 {'210209_009';'191001_009';'Sut3_191122_009';'Sut4_191124_009'};...    %12S
 {'210210_001';'191002_001';'Sut3_191123_001';'Sut4_191125_001'};...    %24S
 {'210211_001';'191003_001';'Sut3_191124_001';'Sut4_191126_001'};...    %48S
 {'210212_001';'191004_001';'Sut3_191125_001';'Sut4_191127_001'};...    %72S
 {'210213_001';'191005_001';'Sut3_191126_001'; 'Sut4_191128_001'};...   %96S
%  {'210214_001'};...                                                     %120S (Only T01-T03)
%  {'210215_001'}...                                                      %144S (Only T01-T03)      
%  %%%% ONLY SUT1-4 HAVE UNSUTURE DATA
 {'191005_005';'Sut3_191126_005';'Sut4_191129_001'};...                %0.5 - Unsutured
 {'191006_001';'Sut3_191127_001';'Sut4_191130_001'};...                 %24U 
 {'191007_001';'Sut3_191128_001';'Sut4_191201_001'};...                 %48U
 {'191008_001';'Sut3_191129_001';'Sut4_191202_001'};...                 %72U
 {'191009_001';'Sut3_191130_001';'Sut4_191203_001'}}                    %96U
 
 %%% Skipped timepoints between 0.5 and 24U, N=2, Sut3 and Sut4%%%
    %%% SO SKIPPING THOSE TIME POINTS %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
XLabelsTime={'0.5B','6B','12B','24B','48B','72B','96B',...
'0.5S','6S','12S','24S','48S','72S','96S', ...
'0.5U','24U','48U','72U','96U'};
XLabelsTime=XLabelsTime';
%% Load Data
%%%%%%%%%%%%%%%%
%%% Get
%% DECONVOLVED PEAKS, ALTERNATE TO SAMPLE ENTROPY (WHICH TAKES FOREVER)
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
MICE={'Sut1','Sut2','Sut3','Sut4','T01','T02','T03'};
for MM=1:length(MICE)
% mm=4;             %mouse number [ 1= Sut1 ... 7=T03 ]
mouse=MICE{MM};

ext = 'Suite2p_dff.mat';
root    =['Z:\AFdata\2p2019\Experiments\' mouse];                    %% as character 
stimdir = findFILE(root,ext);
Idx2=vertcat(Idx{:});
% test=setdiff(stimdir,setdiff(stimdir,Idx2))

r=[];
[r,~] = find(contains(stimdir,Idx2)) ;% single line engine
% for bb=1:length(stimdir)
% % substrfind = @(x,y) ~cellfun(@isempty,strfind(stimdir,Idx2));
% 
% end
suite2pdir=stimdir(r)

%%%%%%%%%%%%%%%%%%%%%%
ext='_nidaq.mat'; %%uses this to find correct date
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% FIND DECONVOLVED PEAKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii=1:length(suite2pdir)
   spksSpontTemp=[];
   dffTemp=[];
%    ii=4
   load(suite2pdir{ii});
   cellIdx=find(suite2pData.iscell(:,1)==1);
   cellCount.(mouse)(ii)=length(cellIdx);

   spksSpontTemp  =suite2pData.spks(cellIdx,suite2pData.startIdx(1):suite2pData.endIdx(1));
   dffTemp        =suite2pData.dFF(:,suite2pData.startIdx(1):suite2pData.endIdx(1));
   dFFSpont.(mouse){ii}=dffTemp;
   output = smoothdata(dffTemp,2,'gaussian',50);
   aucSpont.(mouse){ii}    =trapz(output,2);
   rmsSpont.(mouse){ii}    =rms(output,2);
   stdevSpont.(mouse){ii}  =std(output,0,2);
   visDrivenIdx.(mouse){ii}=find(sum(suite2pData.bias.visDrivenIDX,2)>=1)
   numActiveNeurBias.(mouse)(ii)=length(visDrivenIdx.(mouse){ii})
%    groupMean=mean(mean(output,2));
%    groupStdev=mean(std(output,0,2));
   convert2Seconds=(size(spksSpontTemp,2)/suite2pData.nidaqAligned.framerate);
   for nn=1:length(cellIdx)
       %%%take top 20% of active neurons in signal to noise 
        SNR.(mouse){ii}(nn)=snr(output(nn,:))
        spontSpikeRate.(mouse){ii}(nn)=length(find(spksSpontTemp(nn,:)))/convert2Seconds;
        cellMean=mean(output(nn,:));
        cellStdev=std(output(nn,:),0,2);
        pk=[];
        lc=[];
        [pk,lc]=findpeaks(output(nn,:),'MinPeakHeight',cellMean+2*cellStdev, 'MinPeakDistance',30, 'MinPeakProminence',0.15);

   if length(pk)>5
        spontActiveNeuron.(mouse){ii}(nn)=1;
   else
        spontActiveNeuron.(mouse){ii}(nn)=0; 
   end
   end
   
spontActiveIDXbyPeak.(mouse){ii}=find(spontActiveNeuron.(mouse){ii});
[fullRoot,tmpFILENAME] = fileparts(suite2pdir{ii});
tempDir = findFILE(fullRoot,ext);
[~,tempDir]=fileparts(tempDir{1});
FILENAMEsuite2p.(mouse){ii} =extractBefore(tempDir,'_nidaq')
registeredFILENAMEsuite2p.(mouse){ii} =tmpFILENAME;
end
end
%%
idx = dbscan(spontSpikeRate.Sut1{1,1}(:),1,5); % The default distance metric is Euclidean distance
figure
gscatter(spontSpikeRate.Sut1{1},idx);
title('DBSCAN Using Euclidean Distance Metric');