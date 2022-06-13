%% neuron count
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%
MICE={'Sut1','Sut2','Sut3','Sut4','T01','T02','T03'};
mm=1             %mouse number [ 1= Sut1 ... 7=T03 ]
mouse=MICE{mm}
ext = 'Fall.mat';
root    =['Z:\AFdata\2p2019\Experiments\' mouse];                    %% as character 
stimdir = findFILE(root,ext);
 stimDirs=stimdir(1:19)  %Sut1
% stimDirs=stimdir(:)    %Sut2
% stimDirs=stimdir([1:16 18:29]) %Sut3
% stimDirs=stimdir(1:23) %Sut4
% stimDirs = stimdir(:); %T01,T03
ii=2
%%%%%%%%%%%%%%%%%%%%%%
ext='_nidaq.mat' %%uses this extension to find correct date to align w timepointIDX
for ii=1:length(stimDirs)
  load(stimDirs{ii});
  cellCount.mouse(ii)=length(find(iscell(:,1)))
        [fullRoot,~] = fileparts(stimDirs{ii});
        idcs     = strfind(fullRoot,filesep);
        tempRoot = fullRoot(1:idcs(end-2)-1);
        tempDir = findFILE(tempRoot,ext);
        [~,tempDir]=fileparts(tempDir{1});
        FILENAME.(mouse){ii} =extractBefore(tempDir,'_nidaq')
end
%% SAMPLE ENTROPY 
MICE={'Sut1','Sut2','Sut3','Sut4','T01','T02','T03'};
for MM=1
mm=MM             %mouse number [ 1= Sut1 ... 7=T03 ]
mouse=MICE{MM}

ext = 'Suite2p_dff.mat';
root    =['Z:\AFdata\2p2019\Experiments\' mouse];                    %% as character 
stimdir = findFILE(root,ext);

suite2pdir=stimdir(:)
%%%%%%%%%%%%%%%%%%%%%%
ext='_nidaq.mat' %%uses this to find correct date
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% WITH SAMPLE ENTROPY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii=1:length(suite2pdir)
   ii=4
   spksSpontTemp=[];
   dffTemp=[];
   load(suite2pdir{ii});
   cellIdx=find(suite2pData.iscell(:,1)==1)
   cellCount.(mouse)(ii)=length(cellIdx)

   spksSpontTemp  =suite2pData.spks(cellIdx,suite2pData.startIdx(1):suite2pData.endIdx(1));
   dffTemp        =suite2pData.dFF(:,suite2pData.startIdx(1):suite2pData.endIdx(1));
   output = smoothdata(dffTemp,2,'gaussian',50);

   aucSpont.(mouse){ii}    =trapz(output,2);
   rmsSpont.(mouse){ii}    =rms(output,2);
   stdevSpont.(mouse){ii}  =std(output,0,2);
   visDrivenIdx.(mouse){ii}=find(sum(suite2pData.bias.visDrivenIDX,2)>=1)
   numActiveNeurBias.(mouse)(ii)=length(visDrivenIdx.(mouse){ii})
for nn=1:length(cellIdx)
  SampEnSpont.(mouse){ii}(nn)=sampen(dffTemp(nn,:),2,0.2*std(dffTemp(nn,:)),'mahalanobis')
%   spikesSpont.(mouse){ii}(nn)=findpeaks(spksSpontTemp(nn,:))
end 
[fullRoot,~] = fileparts(suite2pdir{ii});
tempDir = findFILE(fullRoot,ext);
[~,tempDir]=fileparts(tempDir{1});
FILENAMEsuite2p.(mouse){ii} =extractBefore(tempDir,'_nidaq')
end
end
sum(spontActiveNeuron.Sut1)
%%
%%%%%%
%% DECONVOLVED PEAKS, ALTERNATE TO SAMPLE ENTROPY (WHICH TAKES FOREVER)
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
MICE={'Sut1','Sut2','Sut3','Sut4','T01','T02','T03'};
for MM=1:length(MICE)
mm=MM             %mouse number [ 1= Sut1 ... 7=T03 ]
mouse=MICE{MM}

ext = 'Suite2p_dff.mat';
root    =['Z:\AFdata\2p2019\Experiments\' mouse];                    %% as character 
stimdir = findFILE(root,ext);

suite2pdir=stimdir(:)
%%%%%%%%%%%%%%%%%%%%%%
ext='_nidaq.mat' %%uses this to find correct date
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

        [pk,lc]=findpeaks(output(nn,:),'MinPeakHeight',cellMean+2*cellStdev, 'MinPeakDistance',30, 'MinPeakProminence',0.15);

   if length(pk)>5
        spontActiveNeuron.(mouse){ii}(nn)=1;
   else
        spontActiveNeuron.(mouse){ii}(nn)=0; end
        pk=[];
        lc=[];
   end
%    spontActiveIDXtemp=[]
   spontActiveIDXbyPeak.(mouse){ii}=find(spontActiveNeuron.(mouse){ii});
%    spontActiveIDXtemp=spontActiveIDXbyPeak.(mouse){ii};
   
%    aucSpontACTIVEbyPeak.(mouse){ii}=aucSpont.(mouse){ii}(spontActiveIDXtemp,:);
[fullRoot,tmpFILENAME] = fileparts(suite2pdir{ii});
tempDir = findFILE(fullRoot,ext);
[~,tempDir]=fileparts(tempDir{1});
FILENAMEsuite2p.(mouse){ii} =extractBefore(tempDir,'_nidaq')
registeredFILENAMEsuite2p.(mouse){ii} =tmpFILENAME;

end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
    aucTEMP(233,:)=[]
for MM=1:length(MICE)
for ii=1:length(spontActiveNeuron.(MICE{MM}))
spontActiveSUM.(MICE{MM})(ii)=sum(spontActiveNeuron.(MICE{MM}){ii})
end
end% nn=150
% groupMean=mean(mean(output,2))
% groupStdev=mean(std(output,0,2))
% [pk,lc]=findpeaks(output(nn,:),'MinPeakHeight',groupMean+2*groupStdev, 'MinPeakDistance',30, 'MinPeakProminence',0.15)
% 
% figure
% plot(output(12,:))
% hold on
% plot(dffTemp(1,:))
%% MAKE A TIME POINT INDEX BY ~ALL~ DATES THAT CORRESPOND TO THAT TIMEPOINT IN EXPERIMENT

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
'0.5U','24U','48U','72U','96U'}
XLabelsTime=XLabelsTime';

%% Normalizing treatment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% zscore within animal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% get row index then pull to align runs across 

for ii=1:7
  tempFileMatch=FILENAMEsuite2p.(MICE{ii})
  for mm=1:length(tempFileMatch)
    tempFilename=tempFileMatch{mm}     
  for nn=1:length(Idx)
    tempIdx=Idx{nn}
    ROWS=find(contains(tempFilename,tempIdx))
    if ~isempty(ROWS)
        timePtidx.(MICE{ii})(mm)=nn;
    end
  end 
  end
end

for MM=1:length(MICE)
mm=MM             %mouse number [ 1= Sut1 ... 7=T03 ]
mouse=MICE{MM}
for ii=1:length(aucSpont.(mouse))
    aucSpont.(mouse){ii}(messedUpNeurons.(mouse){ii})=[]
    dFFSpont.(mouse){ii}(messedUpNeurons.(mouse){ii},:)=[]
    stdevSpont.(mouse){ii}(messedUpNeurons.(mouse){ii})=[]
end
end 

for ii=1:7  %% take out elements that are zero
    k=[]
    k=find(timePtidx.(MICE{ii}))
    aucSpont.(MICE{ii})=aucSpont.(MICE{ii})(k)
    dFFSpont.(MICE{ii})=dFFSpont.(MICE{ii})(k);
    timePtIDX.(MICE{ii})=timePtidx.(MICE{ii})(k);
    FILENAMEsuite2p_ALIGNED.(MICE{ii})=FILENAMEsuite2p.(MICE{ii})(k);
%    messedUpNeurons.(MICE{ii})=messedUpNeurons.(MICE{ii}){k}
%     dFFSpont.(MICE{ii})=dFFSpont.(MICE{ii})(k)
%     aucSpont.(MICE{ii})=aucSpont.(MICE{ii})(k)
%     cellCount.(MICE{ii})=cellCount.(MICE{ii})(k)
end

    



for mm=1:length(MICE)
 timePtLABELS.(MICE{mm})=XLabelsTime(timePtIDX.(MICE{mm}))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%
%%%% AUC PLOTTING
%%%% HISTOGRAM
%%%%%%%%%%%%%%
mm=2
ii=10

 for mm=1:length(MICE)
    mouse=MICE{mm}
 for ii=1:length(timePtIDX.(mouse))
    
%     plot(aucTEMP(233,:))
    aucTEMP=[]
    
    figure('Units','normalized','Position',[0 0 1 1])
    titleTEMP=['AUC-' XLabelsTime{timePtIDX.(mouse)(ii)} '   ' char(FILENAMEsuite2p_ALIGNED.(mouse){ii})];
    aucTEMP=aucSpont.(mouse){ii}
    [B,I] = sort(aucTEMP,'descend') 
    subplot(1,3,1);
    plot(aucTEMP)
    title('AUC, unsorted')
    subplot(1,3,2)
    plot(B)
    ylim([-500 8000])
    title('AUC, sorted')
    subplot(1,3,3)
    histogram(aucTEMP,30)
    xlim([-500 8000])
    title('AUC, histogram')
    sgtitle(titleTEMP, 'Interpreter', 'none')  
 ft=['Z:\AFdata\2p2019\Experiments\SUTgraphs_AUC\sutAUC_JPEG-FIXED','\',(FILENAMEsuite2p.(mouse){ii}),'_','AUC_',XLabelsTime{timePtIDX.(mouse)(ii)},'.jpeg'];
     saveas(gcf,(ft)) 
 close all
    end
 end


 for mm=1:length(MICE)
    mouse=MICE{mm}
 for ii=1:length(timePtIDX.(mouse))
    
%     plot(aucTEMP(233,:))
    stdevTEMP=[]
    
    figure('Units','normalized','Position',[0 0 1 1])
    titleTEMP=['AUC-' XLabelsTime{timePtIDX.(mouse)(ii)} '   ' char(FILENAMEsuite2p_ALIGNED.(mouse){ii})];
    stdevTEMP=stdevSpont.(mouse){ii}
    [B,I] = sort(stdevTEMP,'descend') 
    subplot(1,3,1);
    plot(stdevTEMP)
    title('STdev, unsorted')
    subplot(1,3,2)
    plot(B)
    ylim([-0.1 0.8])
    title('STdev, sorted')
    subplot(1,3,3)
    histogram(stdevTEMP,30)
    xlim([-0.1 0.8])
    title('STdev, histogram')
    sgtitle(titleTEMP, 'Interpreter', 'none')  
 ft=['Z:\AFdata\2p2019\Experiments\SUTgraphs_STdev\',(FILENAMEsuite2p.(mouse){ii}),'_','AUC_',XLabelsTime{timePtIDX.(mouse)(ii)},'.jpeg'];
     saveas(gcf,(ft)) 
 close all
    end
 end
 
%% 
 ii=1
for ii=1:length(MICE)
k=find(timePtIDX.(MICE{ii})< 7)
avgBaseline=mean(cellCount.(MICE{ii})(k))
temp=cellCount.(MICE{ii})-avgBaseline
m=find(timePtIDX.(MICE{ii})> 7)
cellDifffromBaseline.(MICE{ii})=temp(m)
cellDiffPerc.(MICE{ii})(1:length(m))=temp(m)./cellCount.(MICE{ii})(m)
timePtIDXfromB.(MICE{ii})=m
clear temp
end

for ii=1:length(MICE)
cellCountZ.(MICE{ii})=zscore(cellCount.(MICE{ii}))
end
for ii=1:length(MICE)
cellCountdiff.(MICE{ii})=diff(cellCount.(MICE{ii}))
end 
for ii=1:length(MICE)
timePtIDXdiff.(MICE{ii})=timePtIDX.(MICE{ii})+1
timePtIDXdiff.(MICE{ii})=timePtIDXdiff.(MICE{ii})(1:end-1)
end
XLabelsTimeDIFF=XLabelsTime(2:end)
%% 

figure 
for ii=1:length(MICE)
plot(1:length(cellDifffromBaseline.(MICE{ii})),cellDifffromBaseline.(MICE{ii}),'DisplayName',MICE{ii},'LineWidth',2)
hold on
end
hold off
title('Difference in Neurons Detected (suite2p- raw #) from Average Baseline Count')

xticks([1:12])
xticklabels(XLabelsTime(8:end))
legend('Location','southeast')



spontSpikeRate
aucSpont.(mouse){ii}   
rmsSpont.(mouse){ii}   
stdevSpont.(mouse){ii}  
visDrivenIdx.(mouse){ii}

cellCount
numActiveNeurBias
 
for ii=1:length(MICE)
k=find(timePtIDX.(MICE{ii})< 7)
for mm=1:length(k)
avgBaseline(mm)=mean(spontSpikeRate.(MICE{ii}){k(mm)})
end
avgBaseline(ii)=mean(avgBaseline)
end

figure
for ii=5:7
    x=[]
    tempMean=[]
    tempErr=[]
%     for mm=1:length(timePtIDX.(MICE{ii}))
     adjIDX=find(timePtIDX.(MICE{ii})>=7)
    for mm= 1:length(adjIDX)
       tempMean(mm)=((nanmean(spontSpikeRate.(MICE{ii}){adjIDX(mm)}))-avgBaseline(ii))/avgBaseline(ii)
       x(mm)=timePtIDX.(MICE{ii})(adjIDX(mm))
    end 
        tempErr(1:length(tempMean))=nanstd(tempMean)/length(tempMean)
        errorbar(x,tempMean,tempErr,'DisplayName',MICE{ii},'LineWidth',2)
        hold on
end
hold off
title('Spike Rate across Monocular Deprivation, Spontaneous, Transgenic Mice')
legend('Location','southeast')
xticks([8:length(XLabelsTime)])
xticklabels(XLabelsTime(8:end))
%%%%%%%%%%%%%%%%%%
%%%% visdrivenIDX

for ii=1:length(MICE)
k=find(timePtIDX.(MICE{ii})< 7)
for mm=1:length(k)
avgBaseline(mm)=mean(spontSpikeRate.(MICE{ii}){k(mm)})
end
avgBaseline(ii)=mean(avgBaseline)
end
figure
for ii=5:7
    x=[]
    tempMean=[]
    tempErr=[]
    visDrivenTemp=[]
%     for mm=1:length(timePtIDX.(MICE{ii}))
     adjIDX=find(timePtIDX.(MICE{ii})>=7)
    for mm= 1:length(adjIDX)
        TEMPspontSpikeRate=[]
        visDrivenTemp=visDrivenIdx.(MICE{ii}){adjIDX(mm)}
        TEMPspontSpikeRate=aucSpont.(MICE{ii}){adjIDX(mm)}
       tempMean(mm)=(nanmean(TEMPspontSpikeRate))
       x(mm)=timePtIDX.(MICE{ii})(adjIDX(mm))
       tempErr(mm)=nanstd(TEMPspontSpikeRate)/sqrt(length(TEMPspontSpikeRate))

    end 
%         tempErr(1:length(tempMean))=nanstd(tempMean)/length(tempMean)
        errorbar(x,tempMean,tempErr,'DisplayName',MICE{ii},'LineWidth',2)
        hold on
end
hold off
title('AUC across Monocular Deprivation-Visually Driven Neurons, Spontaneous, Transgenic Mice')
legend('Location','southeast')
xticks([8:length(XLabelsTime)])
xticklabels(XLabelsTime(8:end))

ii=7
figure
plot(aucSpont.(MICE{ii}){7}(visDrivenTemp))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure 
for ii=1:4
    x=[]
    tempMean=[]
    tempErr=[]
%     for mm=1:length(timePtIDX.(MICE{ii}))
     adjIDX=find(timePtIDX.(MICE{ii})> 7)
    for mm= 1:length(adjIDX)
       tempMean(mm)=((nanmean(aucSpont.(MICE{ii}){adjIDX(mm)}))-avgBaseline(ii))/avgBaseline(ii)
       tempErr(mm)=nanstd(aucSpont.(MICE{ii}){adjIDX(mm)})/length(aucSpont.(MICE{ii}){adjIDX(mm)})
       x(mm)=timePtIDX.(MICE{ii}){adjIDX(mm)}
    end 
        errorbar(x,tempMean,tempErr,'DisplayName',MICE{ii},'LineWidth',2)
        hold on
end
%% 

temp=aucSpont.(MICE{ii}(k(mm)))-avgBaseline
m=find(timePtIDX.(MICE{ii})> 7)
aucDifffromBaseline.(MICE{ii})=temp(m)
cellDiffPerc.(MICE{ii})(1:length(m))=temp(m)./aucSpont.(MICE{ii})(m)
timePtIDXfromB.(MICE{ii})=m
clear temp
% end
end
%% cell change percentage from baseline, split by group

figure 
for ii=1:4
plot(1:length(cellDiffPerc.(MICE{ii})),cellDifffromBaseline.(MICE{ii})*100,'DisplayName',MICE{ii},'LineWidth',2)
hold on
end
hold off
title('Percentage Diff in Neurons Detected (raw #), Average Baseline, Injection')
yline(0)
xticks([1:12])
xticklabels(XLabelsTime(8:end))
legend('Location','southeast')


figure 
for ii=5:7
plot(1:length(cellDiffPerc.(MICE{ii})),cellDifffromBaseline.(MICE{ii})*100,'DisplayName',MICE{ii},'LineWidth',2)
hold on
end
hold off
title('Percentage Diff in Neurons Detected (raw #), Average Baseline, Transgenic')
yline(0)
xticks([1:12])
xticklabels(XLabelsTime(8:end))
legend('Location','southeast')
%% 

figure
for ii=1:length(MICE)
scatter(timePtIDX.(MICE{ii}),cellCount.(MICE{ii}),'DisplayName',MICE{ii})
hold on
end
hold off
title('Active Detected Neurons during Ocular Deprivation')
xticks([1:length(XLabelsTime)])
xticklabels(XLabelsTime)
legend

figure
for ii=1:length(MICE)
plot(timePtIDX.(MICE{ii}),cellCountZ.(MICE{ii}),'DisplayName',MICE{ii})
hold on
end
hold off
title('Active Detected Neurons during Ocular Deprivation - Z scored')
xticks([1:length(XLabelsTime)])
xticklabels(XLabelsTime)
legend


figure
for ii=1:length(MICE)
scatter(timePtIDXdiff.(MICE{ii}),cellCountdiff.(MICE{ii}),'DisplayName',MICE{ii})
hold on
end
hold off
title('Active Detected Neurons during Ocular Deprivation - DIFF')
xticks([0:length(XLabelsTime)])
xticklabels([ XLabelsTime])
legend

for ii=1:length(MICE)
   Variance(ii)= var(cellCount.(MICE{ii}))
end 
 val=1/length(XLabelsTime)

for ii=1:length(XLabelsTime)
    colors(ii,1)=val*ii   
    colors(ii,2)=val*ii
    colors(ii,3)=val*ii  
end

figure
histogram(cellCount.Sut1)


n = [4,2,2,2,2,2,2,3,2,6,4,2,2,3];
h = histogram(n);
b = bar(2:6,h.Values);
b.FaceColor = 'flat';
b.CData(2,:) = [.5 0 .5];