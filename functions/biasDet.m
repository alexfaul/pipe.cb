function [bias,biasIndex]=biasDet(dffTrials,baselineTrials,savePath,stats,biasCutoff, strLabel) 
if nargin<5,
    biasCutoff=0.4;
end 
if nargin<6
    strLabel=['']
end 
%can use any stats determination for visually driven here
trialTypeIDX=fieldnames(baselineTrials) % use baseline bc dffTrials has mouse info as fields
%% Making row index of ROIs responsive to any stimulus

for ii=1:length(trialTypeIDX)
visDrivenIDX(:,ii)=(stats.h.(trialTypeIDX{ii})==1); %finding positions of visuallly responsive neurons
end 
drivenTotal=sum(visDrivenIDX,2); % add together all columns (each column corresponding to each ori stat significance diff from baseline
drivenTotal(drivenTotal>=1)=1;          % make all values above 1 equal 1 (if vis driven to any stim, count as visDriven)
drivenIDX=find(drivenTotal==1) ; %index position of 

%% New structure with only visually responsive neurons

for ii=1:length(trialTypeIDX) %made index to isolate the responsive cells and make new structures w only responsive cells
responsiveROIs.(trialTypeIDX{ii})=dffTrials.(trialTypeIDX{ii})(drivenIDX,:);
responsiveBaseline.(trialTypeIDX{ii})=baselineTrials.(trialTypeIDX{ii})(drivenIDX,:);
allROIs.(trialTypeIDX{ii})=dffTrials.(trialTypeIDX{ii});
allBaseline.(trialTypeIDX{ii})=baselineTrials.(trialTypeIDX{ii});

end


%% subtract baseline from mean response
for ii=1:length(trialTypeIDX)
    adjdFF.(trialTypeIDX{ii})=responsiveROIs.(trialTypeIDX{ii})-responsiveBaseline.(trialTypeIDX{ii}); %this should be element wise
    adjdFFAll.(trialTypeIDX{ii})=allROIs.(trialTypeIDX{ii})-allBaseline.(trialTypeIDX{ii}); %this should be element wise
end %DEBUG AND VERIFY
%% Making total dff response across all oris for vis responsive neurons
% for ii=1:length(trialTypeIDX)
% maxTrial.(trialTypeIDX{ii})=[];
% end 

for ii=1:length(trialTypeIDX)
    ugh(:,ii)=max(adjdFF.(trialTypeIDX{ii}),[],2);
    dffByOri(:,ii)=mean(adjdFF.(trialTypeIDX{ii}),2);
    ughAll(:,ii)=max(adjdFFAll.(trialTypeIDX{ii}),[],2);
    dffByOriAll(:,ii)=mean(adjdFFAll.(trialTypeIDX{ii}),2);
end
maxTrial=max(ugh,[],2);
maxTrialAvg=max(dffByOri,[],2);
maxTrialAll=max(ughAll,[],2);
maxTrialAvgAll=max(dffByOriAll,[],2);

 %max response in any trial


dffByOri(dffByOri<0)=0;
maxTrial(maxTrial<0)=0;
dffByOriAll(dffByOriAll<0)=0;
maxTrialAll(maxTrialAll<0)=0;

%this makes a bunch of the totals zero if their means are negative.... 
% 
% for ii=1:length(trialTypeIDX) %should this happen after taking the average?
% adjdFF.(trialTypeIDX{ii})(adjdFF.(trialTypeIDX{ii})<0) = 0;
% end

%% find bias Index
dffTotal=sum(dffByOri,2);
for ii=1:length(trialTypeIDX)
    for kk=1:length(dffTotal)
    bias.(trialTypeIDX{ii})(kk)     =dffByOri(kk,ii)/maxTrial(kk); %avg trial dFF by ori/max of all individual trials(per neuron)
    biasIndex.(trialTypeIDX{ii})(kk)=dffByOri(kk,ii)/dffTotal(kk); %mean of all trials for each orientation( per neuron)/total mean dFF from all oris
    biasMaxTrialAvg.(trialTypeIDX{ii})(kk)=dffByOri(kk,ii)/maxTrialAvg(kk);
    end
end

dffTotalAll=sum(dffByOriAll,2);
for ii=1:length(trialTypeIDX)
    for kk=1:length(dffTotalAll)
    biasAll.(trialTypeIDX{ii})(kk)     =dffByOriAll(kk,ii)/maxTrialAll(kk); %avg trial dFF by ori/max of all individual trials(per neuron)
    biasIndexAll.(trialTypeIDX{ii})(kk)=dffByOriAll(kk,ii)/dffTotalAll(kk); %mean of all trials for each orientation( per neuron)/total mean dFF from all oris
    biasMaxTrialAvgAll.(trialTypeIDX{ii})(kk)=dffByOriAll(kk,ii)/maxTrialAvgAll(kk);
    end
end
bias.visDrivenIDX=visDrivenIDX;
%% biasIndex for plotting

for ii=1:length(trialTypeIDX)
   tempBias=find(biasIndex.(trialTypeIDX{ii})>=biasCutoff);
   biasIndexPerc(ii)=(length(tempBias))/(length(biasIndex.(trialTypeIDX{ii})))*100;
end 

biasIndex.biasIndexPerc=biasIndexPerc
X = categorical(trialTypeIDX);

figure
bar(X,biasIndexPerc)
ylim([0 (max(biasIndexPerc)+5)])
ylabel('Percentage of visually-driven cells responsive cue')
xlabel('Orientations')
title([dffTrials.mouse,' ',dffTrials.runDate,' ',dffTrials.run, ' biasIndex Percentage for each Ori ',num2str(biasCutoff),strLabel]);

ft=[savePath,'\','bias','\',dffTrials.mouse,' ',dffTrials.runDate,' ',dffTrials.run,'_biasIndexPercOri','.jpeg'];
saveas(gcf,(ft))
%% Find preference

for ii=1:length(trialTypeIDX)
    for kk=1:length(biasIndex.(trialTypeIDX{ii}))
    biasMat(kk,ii)=(bias.(trialTypeIDX{ii})(kk)); %divided by max response in all trials
    biasIndexMat(kk,ii)=(biasIndex.(trialTypeIDX{ii})(kk)); %divided by mean response across all oris
    end
end

[r,c]=find(biasIndexMat == max(biasIndexMat))
for ii=1:length(r)
     tempidx=r(ii);
    biasIndex.cellPref{ii}=trialTypeIDX{c};;
end


for ii=1:length(trialTypeIDX)
    for kk=1:length(biasIndex.(trialTypeIDX{ii}))
    biasMatAll(kk,ii)=(biasAll.(trialTypeIDX{ii})(kk)); %divided by max response in all trials
    biasIndexMatAll(kk,ii)=(biasIndexAll.(trialTypeIDX{ii})(kk)); %divided by mean response across all oris
    end
end

[r,c]=find(biasIndexMatAll == max(biasIndexMatAll))
for ii=1:length(r)
     tempidx=r(ii);
    biasIndexAll.cellPref{ii}=trialTypeIDX{c};;
end
%% 

SEM= std(biasIndexMat, [], 1)./ sqrt(size(biasIndexMat,2));                                % Calculate Standard Error Of The Mean

figure
for ii=1:size(biasIndexMat,1)
    temp2=biasIndexMat(ii,:);
    scatter(X, temp2,'jitter', 'on', 'jitterAmount', 0.1);
hold on
end
hold on
errorbar(mean(biasIndexMat,1),SEM,'o',...
    'MarkerEdgeColor','k','MarkerFaceColor','k');           %%Would be better with CI instead of SEM. 
ylim([0 1])
ylabel('Individual biasIndex')
xlabel('Orientations')
title([dffTrials.mouse,' ',dffTrials.runDate,' ',dffTrials.run, ' biasIndex for each Ori (mean of each ori/total response)',strLabel]);

ft=[savePath,'\','bias','\',dffTrials.mouse,' ',dffTrials.runDate,' ',dffTrials.run,'_biasIndexScatter','.jpeg'];
saveas(gcf,(ft))
%% bias graph

SEM= std(biasMat, [], 1)./ sqrt(size(biasMat,2));                                % Calculate Standard Error Of The Mean

figure
for ii=1:size(biasMat,1)
    temp3=biasMat(ii,:);
    scatter(X, temp3,'jitter', 'on', 'jitterAmount', 0.1);
hold on
end
hold on
errorbar((mean(biasMat,1)),SEM,'o',...
    'MarkerEdgeColor','k','MarkerFaceColor','k');           %%Would be better with CI instead of SEM. 
ylim([0 (max(max(biasMat))+.1)])
ylabel('Individual biasIndex')
xlabel('Orientations')
title([dffTrials.mouse,' ',dffTrials.runDate,' ',dffTrials.run, ' bias for each Ori (mean of each ori/max response)',strLabel]);

ft=[savePath,'\','bias','\',dffTrials.mouse,' ',dffTrials.runDate,' ',dffTrials.run,'_biasScatter','.jpeg'];
saveas(gcf,(ft))
%% 
bias.biasCutoff  = biasCutoff;
bias.biasMat     = biasMat;
bias.biasIndexMat= biasIndexMat;
bias.visDrivenIDX= visDrivenIDX;
bias.biasIndex=biasIndex;                   %mean of all trials for each orientation( per neuron)/total mean dFF from all oris
bias.biasMaxTrialAvg=biasMaxTrialAvg;

bias.biasMatAll     = biasMatAll;
bias.biasIndexMatAll= biasIndexMatAll;
bias.biasIndexAll=biasIndexAll;                   %mean of all trials for each orientation( per neuron)/total mean dFF from all oris
bias.biasMaxTrialAvgAll=biasMaxTrialAvgAll;
end 