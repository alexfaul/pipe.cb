function [dffTrials,baselineTrials, statsT,statsW]=separateByTrialsDff(suite2pData,savePath,timeWin)
% [path,fileName]=fileparts(char(stimPath))
% ext = 'dff.mat';
% dffPath = findFilePathAF(char(path),ext);
% if isempty(dffPath)
%     sprintf('Cannot locate dFF file, make sure cell clicked and dFF fcn run')
%     return
% end 
% load(char(dffPath));
% load(char(stimPath));
Fs=suite2pData.nidaqAligned.framerate;
%% if timewindow isn't specified, go by trial length
if nargin<3                             %
    startPt=suite2pData.Stim.trialonsets;
    endPt=suite2pData.Stim.trialoffsets;    
    winLength=round(Fs);
elseif nargin==3
    winLength=round(Fs*timeWin);
    startPt=Stim.trialonsets;
    endPt=startPt+(round(Fs*winLength));
end
%% Isolate which orientations are actually used
orientationsUsed=suite2pData.Stim.orientationsUsed(unique(suite2pData.Stim.condition));
%% Create array with all stim
for kk=1:length(orientationsUsed);
    oris = strcat('Trials',num2str(orientationsUsed(kk)));
    dffTrials.(oris) = [];
    baselineTrials.(oris)=[]
    idx.(oris)=find(suite2pData.Stim.oriTrace==orientationsUsed(kk));
end
trialTypeIDX=fieldnames(dffTrials)

for kk=1:length(trialTypeIDX) %loop through each trial type (Trials0, Trials90 etc)                                                                      
    oriTrialIDX=idx.(trialTypeIDX{kk});                                                      %temporary variable name for the Trial # index separated by Ori
    for ii=1:length(oriTrialIDX)                                                                %go through the index of trial number within each trial type (ii=3 corresponds to Trial 9 for example)
        dataTemp=suite2pData.dFF(:,startPt(oriTrialIDX(ii)):endPt(oriTrialIDX(ii))); %ROI by time across that trial matrix
        baselineTemp=suite2pData.dFF(:,(startPt(oriTrialIDX(ii)))-winLength:(startPt(oriTrialIDX(ii))-1)); %ROI by time across that trial matrix

        dffTrials.(trialTypeIDX{kk})(:,ii)=mean(dataTemp,2);                                    %gives average values across entire trial, separated by trial type
        baselineTrials.(trialTypeIDX{kk})(:,ii)=mean(baselineTemp,2);                                    %gives average values across entire trial, separated by trial type

    end
end 


    for kk=1:length(trialTypeIDX) % visually driven w simple t-test
        for ii=1:length(dffTrials.(trialTypeIDX{kk}))        
        [statsT.h.(trialTypeIDX{kk})(ii),statsT.p.(trialTypeIDX{kk})(ii)] = ...
            ttest(dffTrials.(trialTypeIDX{kk})(ii,:),baselineTrials.(trialTypeIDX{kk})(ii,:))
        end 
    end 
    
    for kk=1:length(trialTypeIDX) % visually driven w simple t-test
        for ii=1:length(dffTrials.(trialTypeIDX{kk}))        
        [statsW.p.(trialTypeIDX{kk})(ii),statsW.h.(trialTypeIDX{kk})(ii)] = ...
            signrank(dffTrials.(trialTypeIDX{kk})(ii,:),baselineTrials.(trialTypeIDX{kk})(ii,:))
        end 
    end
    %% make graphs of number of visually driven cells

for kk=1:length(trialTypeIDX)
    bC=0.05/length(statsW.h.(trialTypeIDX{kk}));
    percTemp(kk)=((sum(statsW.h.(trialTypeIDX{kk})==1))/length(statsW.h.(trialTypeIDX{kk})) *100);
    percTemp2(kk)=((sum(statsT.h.(trialTypeIDX{kk})==1))/length(statsT.h.(trialTypeIDX{kk})) * 100);

end
runDate=num2str(suite2pData.nidaqAligned.date);
figure
bar(percTemp)
set(gca,'xticklabel',trialTypeIDX);
text(1:length(percTemp),percTemp,num2str(percTemp'),'vert','bottom','horiz','center'); 
ylim([0 100])
ylabel('Number of Responsive cells - % of total')    
title([suite2pData.nidaqAligned.mouse,' ',runDate,' ',suite2pData.nidaqAligned.run, 'Percentage of Responsive Cells - Sign Rank']);
ft=[savePath,'\',suite2pData.nidaqAligned.mouse,' ',runDate,' ',suite2pData.nidaqAligned.run,'_biasW','.jpeg'];


figure
bar(percTemp2)
set(gca,'xticklabel',trialTypeIDX);
text(1:length(percTemp2),percTemp2,num2str(percTemp2'),'vert','bottom','horiz','center'); 
ylim([0 100])
ylabel('Number of Responsive cells - % of total')    
title([suite2pData.nidaqAligned.mouse,' ',runDate,' ',suite2pData.nidaqAligned.run, 'Percentage of Responsive Cells - T-test']);

ft=[savePath,'\',suite2pData.nidaqAligned.mouse,' ',runDate,' ',suite2pData.nidaqAligned.run,'_biasT','.jpeg'];
saveas(gcf,(ft))
%% 
dffTrials.runDate=runDate;
dffTrials.mouse=suite2pData.nidaqAligned.mouse;
dffTrials.run=suite2pData.nidaqAligned.run;
    %% using baseline SD to determine drivenness
% % 
% % for kk=1:length(trialTypeIDX) %loop through each trial type (Trials0, Trials90 etc)                                                                      
% %     oriTrialIDX=idx.(trialTypeIDX{kk});                                                      %temporary variable name for the Trial # index separated by Ori
% %     for ii=1:length(oriTrialIDX)                                                                %go through the index of trial number within each trial type (ii=3 corresponds to Trial 9 for example)
% %         baselineTemp=suite2pData.dFF(:,(startPt(oriTrialIDX(ii)))-(winLength*2):(startPt(oriTrialIDX(ii))-1)); %ROI by time across that trial matrix
% %         baselineTrialsSD.(trialTypeIDX{kk})(:,ii)=std(baselineTemp,2);                                    %gives average values across entire trial, separated by trial type
% %     end
% % end
% % 
% % for ii=1:length(
% %    
% %     statsSD(ii)=

end 

