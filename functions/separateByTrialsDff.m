function [dffTrials,baselineTrials, statsT,statsW]=separateByTrialsDff(suite2pData,savePath,timeWin)

%% NEEDS WORK/ORGANIZATION
% 3 diff measures of driven, 
% t-test all, 1st half, 2nd half
%
%%
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
  startPt=suite2pData.Stim.trialonsets;
 endPt=suite2pData.Stim.trialoffsets;  
 if nargin<3                             %  
    winLength=round(diffTrialTimes); 
 else
     winLength=round(timeWin*Fs)
 end
 

% elseif nargin==3
%     winLength=round(Fs*timeWin);
%     startPt=Stim.trialonsets;
%     endPt=startPt+(round(Fs*winLength));
% end

%% Isolate which orientations are actually used
orientationsUsed=suite2pData.Stim.orientationsUsed(unique(suite2pData.Stim.condition));
%% if the first trial is shorter than the window.... CUT IT
% for ii=1:length(suite2pData.nidaqAligned.startIdx)
    
if startPt(1)<(winLength+10);
    startPt=startPt(2:end);
    endPt=endPt(2:end);
    suite2pData.Stim.oriTrace=suite2pData.Stim.oriTrace(2:end);
    suite2pData.Stim.stimTreatment='Skipping first trial because onset is too close to beginning for a comparable baseline';
end


% end
%% Create array with all stim
for kk=1:length(orientationsUsed);
    oris = strcat('Trials',num2str(round(orientationsUsed(kk)))); %can't have .5 in there, will just have to remember... ughhh
    dffTrials.(oris) = [];
    baselineTrials.(oris)=[]
    idx.(oris)=find(suite2pData.Stim.oriTrace==orientationsUsed(kk));
end
trialTypeIDX=fieldnames(dffTrials)
halfWin=winLength/2;

figure
plot(suite2pData.nidaqAligned.visstim)
for kk=1:length(trialTypeIDX) %loop through each trial type (Trials0, Trials90 etc)                                                                      
    oriTrialIDX=idx.(trialTypeIDX{kk});                                                      %temporary variable name for the Trial # index separated by Ori
    for ii=1:length(oriTrialIDX)
        if oriTrialIDX(ii)==length(startPt)
            continue
        else
        %go through the index of trial number within each trial type (ii=3 corresponds to Trial 9 for example)
%         if startPt(oriTrialIDX(1))<winLength
%             oriTrialIDX=oriTrialIDX(2:end)
%             oriTrialIDX=oriTrialIDX-1;
%             startPt=startPt(2:end);
%             endPt=endPt(2:end);
%            idx.(trialTypeIDX{kk})= idx.(trialTypeIDX{kk})(2:end)
%         end
        dataTemp=suite2pData.dFF(:,startPt(oriTrialIDX(ii)):endPt(oriTrialIDX(ii))); %ROI by time across that trial matrix
        baselineTemp=suite2pData.dFF(:,(startPt(oriTrialIDX(ii)))-winLength:(startPt(oriTrialIDX(ii))-1)); %ROI by time across that trial matrix

        dataTempfirstHalf=suite2pData.dFF(:,startPt(oriTrialIDX(ii)):endPt(oriTrialIDX(ii))-halfWin); %ROI by time across that trial matrix

        dataTempsecondHalf=suite2pData.dFF(:,startPt(oriTrialIDX(ii)):startPt(oriTrialIDX(ii))+halfWin); %ROI by time across that trial matrix
        
        
        dffFirstHalf.(trialTypeIDX{kk})(:,ii)=mean(dataTempfirstHalf,2);
        dffSecondHalf.(trialTypeIDX{kk})(:,ii)=mean(dataTempsecondHalf,2);        
        dffTrials.(trialTypeIDX{kk})(:,ii)=mean(dataTemp,2);                                    %gives average values across entire trial, separated by trial type
        baselineTrials.(trialTypeIDX{kk})(:,ii)=mean(baselineTemp,2);                                    %gives average values across entire trial, separated by trial type
        end
    end
end 

%%normal distribution??? Homogeneity of variance?? Welch's t-test.
    for kk=1:length(trialTypeIDX) % visually driven w simple t-test
%             oriTrialIDX=idx.(trialTypeIDX{kk});                                                      %temporary variable name for the Trial # index separated by Or
        for ii=1:length(dffTrials.(trialTypeIDX{kk}))        
        [statsT.h.(trialTypeIDX{kk})(ii),statsT.p.(trialTypeIDX{kk})(ii)] = ...
            ttest(dffTrials.(trialTypeIDX{kk})(ii,:),baselineTrials.(trialTypeIDX{kk})(ii,:),'Tail','right')
        
       [statsT.firsthalf.(trialTypeIDX{kk})(ii),~] = ...
            ttest(dffFirstHalf.(trialTypeIDX{kk})(ii,:),baselineTrials.(trialTypeIDX{kk})(ii,:),'Tail','right')
       
       [statsT.endhalf.(trialTypeIDX{kk}),~] = ...
            ttest(dffSecondHalf.(trialTypeIDX{kk})(ii,:),baselineTrials.(trialTypeIDX{kk})(ii,:),'Tail','right')
         
        
        %[statsT.h.(trialTypeIDX{kk}).endhalf(ii),statsT.p.(trialTypeIDX{kk}).endhalf(ii)] = ...
         %   ttest(dffTrials.(trialTypeIDX{kk})(ii,halfWin:end),baselineTrials.(trialTypeIDX{kk})(ii,halfWin:end),'Tail','right')
        end 
    end
    
for kk=1:length(trialTypeIDX) % visually driven w simple t-test
   for ii=1:length(dffTrials.(trialTypeIDX{kk}))        
         [statsW.p.(trialTypeIDX{kk})(ii),statsW.h.(trialTypeIDX{kk})(ii)] = ...
             signrank(dffTrials.(trialTypeIDX{kk})(ii,:),baselineTrials.(trialTypeIDX{kk})(ii,:),'tail','right')
   end 
end   
  

%% 

% % 
% % for kk=1:length(trialTypeIDX) % visually driven w simple t-test
% %    for ii=1:length(dffTrials.(trialTypeIDX{kk}))
% %        baselineTemp=baselineTrials.(trialTypeIDX{kk})(ii,:)
% %        meandFF= dffTrials.(trialTypeIDX{kk})(ii,:)
% %          [statsW.p.(trialTypeIDX{kk}).SD(ii)] = ...
% %              signrank(dffTrials.(trialTypeIDX{kk})(ii,:),baselineTrials.(trialTypeIDX{kk})(ii,:),'tail','right')
% %    end 
% % end   
%% 
    
    for kk=1:length((trialTypeIDX))
        statsT.(trialTypeIDX{kk}).drivenMatrixKey={'T-test all','T-test 1st half','T-test 2nd half','signrank all'}  
        statsT.(trialTypeIDX{kk}).drivenMatrix(1,:)=statsT.h.(trialTypeIDX{kk})(:)
        statsT.(trialTypeIDX{kk}).drivenMatrix(2,:)=statsT.firsthalf.(trialTypeIDX{kk})(:)
        statsT.(trialTypeIDX{kk}).drivenMatrix(3,:)=statsT.endhalf.(trialTypeIDX{kk})(:)
        statsT.(trialTypeIDX{kk}).drivenMatrix(4,:)=statsW.h.(trialTypeIDX{kk})(:)
    end 
    
    %     
    %% Test for homogeniety of variance and normal distribution
%   for kk=1:length(trialTypeIDX) %do I need to have a mean or loop through the rows?
%     h(kk) =vartest2(mean(dffTrials.(trialTypeIDX{kk}),2),mean(baselineTrials.(trialTypeIDX{kk}),2));
%   figure
%   histogram(dffTrials(trialTypeIDX{kk}))
%   hold on
%   histogram(baselineTrials(trialTypeIDX{kk}))
%   end 
%     
    %% make graphs of number of visually driven cells

for kk=1:length(trialTypeIDX)
    bC=0.05/length(statsT.h.(trialTypeIDX{kk}));
%     percTemp(kk)=((sum(statsW.h.(trialTypeIDX{kk})==1))/length(statsW.h.(trialTypeIDX{kk})) *100);
    percTemp2(kk)=((sum(statsT.h.(trialTypeIDX{kk})==1))/length(statsT.h.(trialTypeIDX{kk})) * 100);

end
runDate=num2str(suite2pData.nidaqAligned.date);
% figure
% bar(percTemp)
% set(gca,'xticklabel',trialTypeIDX);
% text(1:length(percTemp),percTemp,num2str(percTemp'),'vert','bottom','horiz','center'); 
% ylim([0 100])
% ylabel('Number of Responsive cells - % of total cells')    
% title([suite2pData.nidaqAligned.mouse,' ',runDate,' ',suite2pData.nidaqAligned.run, 'Percentage of Responsive Cells - Sign Rank']);
% ft=[savePath,'\',suite2pData.nidaqAligned.mouse,' ',runDate,' ',suite2pData.nidaqAligned.run,'_biasW','.jpeg'];
% 

figure
bar(percTemp2)
set(gca,'xticklabel',trialTypeIDX);
text(1:length(percTemp2),percTemp2,num2str(percTemp2'),'vert','bottom','horiz','center'); 
ylim([0 100])
ylabel('Number of Responsive cells - % of total cells')    
title([suite2pData.nidaqAligned.mouse,' ',runDate,' ',suite2pData.nidaqAligned.run, 'Percentage of Responsive Cells - T-test']);

folder                = [savePath,'\','bias\',]; % create directory if it doesn't exist
if ~exist(folder, 'dir');
        mkdir(folder);
end

ft=[savePath,'\','bias','\',suite2pData.nidaqAligned.mouse,' ',runDate,' ',suite2pData.nidaqAligned.run,'_biasT','.jpeg'];
saveas(gcf,(ft))
%% 
dffTrials.runDate=runDate;
dffTrials.mouse=suite2pData.nidaqAligned.mouse;
dffTrials.run=suite2pData.nidaqAligned.run;
dffTrials.trialOnsets=startPt;
dffTrials.trialOffsets=endPt;
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

