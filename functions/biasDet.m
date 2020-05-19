function bias=biasDet(dffTrials,baselineTrials,stats, strLabel) 
if nargin<4
    strLabel=['']
end 
%can use any stats determination for visually driven here
trialTypeIDX=fieldnames(baselineTrials) % use baseline bc dffTrials has mouse info as fields
%% Making row index of ROIs responsive to any stimulus

for ii=1:length(trialTypeIDX)
visDrivenIDX(:,ii)=(stats.h.(trialTypeIDX{ii})==1) %finding positions of visuallly responsive neurons
end 
temp=sum(visDrivenIDX,2); % add together all columns (each column corresponding to each ori stat significance diff from baseline
temp(temp>=1)=1;          % make all values above 1 equal 1 (if vis driven to any stim, count as visDriven)
drivenIDX=find(temp==1) ; %index position of 

%% New structure with only visually responsive neurons

for ii=1:length(trialTypeIDX) %made index to isolate the responsive cells and make new structures w only responsive cells
responsiveROIs.(trialTypeIDX{ii})=dffTrials.(trialTypeIDX{ii})(drivenIDX,:);
responsiveBaseline.(trialTypeIDX{ii})=baselineTrials.(trialTypeIDX{ii})(drivenIDX,:);
end


%% subtract baseline from mean response
for ii=1:length(trialTypeIDX)
    adjdFF.(trialTypeIDX{ii})=responsiveROIs.(trialTypeIDX{ii})-responsiveBaseline.(trialTypeIDX{ii}); %this should be element wise
end %DEBUG AND VERIFY
%% Making total dff response across all oris for vis responsive neurons

for ii=1:length(trialTypeIDX)
    dffByOri(:,ii)=mean(adjdFF.(trialTypeIDX{ii}),2);
end 
dffByOri(dffByOri<0)=0; %this makes a bunch of the totals zero.... 
% 
% for ii=1:length(trialTypeIDX) %should this happen after taking the average?
% adjdFF.(trialTypeIDX{ii})(adjdFF.(trialTypeIDX{ii})<0) = 0;
% end
dffTotal=sum(dffByOri,2);

%% 
for ii=1:length(trialTypeIDX)
    for kk=1:length(dffTotal)
    bias.(trialTypeIDX{ii})(kk)=dffByOri(kk,ii)/dffTotal(kk);
    end
end
bias.visDrivenIDX=visDrivenIDX;
%% bias for plotting

for ii=1:length(trialTypeIDX)
   temp=find(bias.(trialTypeIDX{ii})>=0.5);
    biasPerc(ii)=(length(temp))/(length(bias.(trialTypeIDX{ii})))*100;
end 


X = categorical(trialTypeIDX);

figure
bar(X,biasPerc)
ylim([0 25])
ylabel('Percentage of cells responsive to cue')
xlabel('Orientations')
title([dffTrials.mouse,' ',dffTrials.runDate,' ',dffTrials.run, ' Bias Percentage for each Ori ',strLabel]);
% text(1:length(biasPerc),biasPerc,num2str(biasPerc'),'vert','top','horiz','center'); 

end 