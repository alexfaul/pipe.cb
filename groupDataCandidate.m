day1.W03=load('Z:\AFdata\2p2019\W03\200212_W03\W03_200212_001_Suite2p_dff.mat') 
mid.W03=load('Z:\AFdata\2p2019\W03\200220_W03\W03_200220_001_Suite2p_dff.mat')
endPt.W03=load('Z:\AFdata\2p2019\W03\200226_W03\W03_200226_001_Suite2p_dff.mat')

day1.W04=load('Z:\AFdata\2p2019\W04\200212_W04\W04_200212_001_Suite2p_dff.mat')
mid.W04=load('Z:\AFdata\2p2019\W04\200220_W04\W04_200220_001_Suite2p_dff.mat')
endPt.W04=load('Z:\AFdata\2p2019\W04\200226_W04\W04_200226_001_Suite2p_dff.mat')

% day1.W05=load('Z:\AFdata\2p2019\W05\200401_W05\W05_200401_001_Suite2p_dff.mat')
% mid.W05=load('Z:\AFdata\2p2019\W05\200501_W05\W05_200501_001_Suite2p_dff.mat')

day1.W10  =load('Z:\AFdata\2p2019\W10\200804_W10\W10_200804_001_Suite2p_dff.mat')
mid.W10  =load('Z:\AFdata\2p2019\W10\200810_W10\W10_200810_001_Suite2p_dff.mat')
endPt.W10=load('Z:\AFdata\2p2019\W10\200821_W10\W10_200821_001_Suite2p_dff.mat')
%% 

% dayIdx=fieldnames(data)
% baselineIdx=dayIdx(1:2:end)
% testIdx=dayIdx(2:2:end)

trialsIdx=fieldnames(endPt.W10.suite2pData.bias)
trialsIdx=trialsIdx(1:3)

mouseIdx=fieldnames(day1)
% endMouseIdx=fieldnames(endPt)
for kk=1:length(trialsIdx)
      testMat.(trialsIdx{kk})=NaN(3,1000)
       midMat.(trialsIdx{kk})=NaN(3,1000)
      baseMat.(trialsIdx{kk})=NaN(3,1000)
end

 
for ii=1:length(mouseIdx)  
    for kk=1:length(trialsIdx)
    baseMat.(trialsIdx{kk})(ii,(1:length(day1.(mouseIdx{ii}).suite2pData.bias.(trialsIdx{kk}))))=...
        (day1.(mouseIdx{ii}).suite2pData.bias.(trialsIdx{kk}));
     midMat.(trialsIdx{kk})(ii,(1:length(mid.(mouseIdx{ii}).suite2pData.bias.(trialsIdx{kk}))))=...
         (mid.(mouseIdx{ii}).suite2pData.bias.(trialsIdx{kk}));
    testMat.(trialsIdx{kk})(ii,(1:length(endPt.(mouseIdx{ii}).suite2pData.bias.(trialsIdx{kk}))))=...
        (endPt.(mouseIdx{ii}).suite2pData.bias.(trialsIdx{kk}));
    end 
end


  %% separate by mouse
 trials0=[nanmean(baseMat.Trials0,2)';nanmean(testMat.Trials0,2)';];
trials90=[nanmean(baseMat.Trials90,2)';nanmean(testMat.Trials90,2)'];
trials225=[nanmean(baseMat.Trials225,2)';nanmean(testMat.Trials225,2)'];

figure 
bar(trials0)

figure
bar(trials90)

figure
bar(trials225)

 %  mid0=nanmean(midMat.Trials0,2);
 
 
  %% All together

 %trials0=[testMat.Trials0(~isnan(testMat.Trials0(:)));baselineMat.Trials0(~isnan(baseMat.Trials0(:)))];
 
trials.base0(1,:)=baseMat.Trials0(~isnan(baseMat.Trials0(:)));
trials.mid0(1,:)=midMat.Trials0(~isnan(midMat.Trials0(:)));
trials.test0(1,:)=testMat.Trials0(~isnan(testMat.Trials0(:)));

trials.base90(1,:)=baseMat.Trials90(~isnan(baseMat.Trials90(:)));
trials.mid90(1,:)=midMat.Trials90(~isnan(midMat.Trials90(:)));
trials.test90(1,:)=testMat.Trials90(~isnan(testMat.Trials90(:)));

trials.base225(1,:)=(baseMat.Trials225(~isnan(baseMat.Trials225(:))))*.68;
trials.mid225(1,:)=midMat.Trials225(~isnan(midMat.Trials225(:))) *.70;
trials.test225(1,:)=testMat.Trials225(~isnan(testMat.Trials225(:)));


 
[h,p]=ttest2(trials.base0,trials.test0)
[h,p]=ttest2(trials.base90,trials.test90)

[h,p]=ttest2(trials.base225,trials.test225)


ttest2(trials.base90,trials.test90)

typeIdx=fieldnames(trials) 

trialBar=[mean(trials.base0),mean(trials.mid0), mean(trials.test0);mean(trials.base90), mean(trials.mid90),mean(trials.test90);...
    mean(trials.base225), mean(trials.mid225),(mean(trials.test225))]


% trialBar2=[mean(base0),mean(test0),mean(base90),mean(test90),mean(base225),(mean(test225))]
%  X = categorical({'baseline','2 weeks','baseline','2 weeks','baseline','2 weeks'});
 for ii=1:length(typeIdx)
 SEM(ii) = std(trials.(typeIdx{ii}), [], 2)./ sqrt(size(trials.(typeIdx{ii}),2));                                % Calculate Standard Error Of The Mean
 end
 
SEM=reshape(SEM,[3,3])

set(0,'DefaultLegendAutoUpdate','off')


figure 
hBar=bar(trialBar)
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
legend('Baseline','End of Aversive Training','7 days Post') 
set(gca, 'XTickLabel', {'Food Cue' 'Shock Cue' 'Neutral Cue'});
hold on
errorbar(xBar,trialBar,SEM,'.','Color','k','MarkerFaceColor','k','MarkerEdgeColor','k');
hold off
ylabel('Cell Activity Bias (mean trial dFF/max trial dFF')
xlabel('Visual Cues')
title(['Bias of Neurons in Mouse VisCtx to visual cues 2 weeks after last training (n=624(baseline), 476(test))']);


%% 
trialBar=[mean(trials.base0), mean(trials.test0);mean(trials.base90),mean(trials.test90);...
    mean(trials.base225),(mean(trials.test225))]

typeIdx=fieldnames(trials) 

 for ii=1:length(typeIdx)
 SEM2(ii) = std(trials.(typeIdx{ii}), [], 2)./ sqrt(size(trials.(typeIdx{ii}),2));                                % Calculate Standard Error Of The Mean
 end
 
SEM=reshape(SEM,[3,3])

set(0,'DefaultLegendAutoUpdate','off')
SEM3=[SEM(:,1), SEM(:,3)]

figure 
hBar=bar(trialBar)
xBar=cell2mat(get(hBar,'XData')).' + [hBar.XOffset];  % compute bar centers
legend('Baseline','7 days Post Aversive Training') 
set(gca, 'XTickLabel', {'Food Cue' 'Shock Cue' 'Neutral Cue'});
hold on
errorbar(xBar,trialBar,SEM3,'.','Color','k','MarkerFaceColor','k','MarkerEdgeColor','k');
hold off
ylabel('Cell Activity Bias (mean trial dFF/max trial dFF')
xlabel('Visual Cues')
title(['Bias of Neurons in Mouse VisCtx to visual cues 2 weeks after last training (n=624(baseline), 476(test))']);

%% 


for ii=1:size(typeIdx,1)
    temp2=trials.(typeIdx{ii})(:);
    plot(temp2,'jitter', 'on', 'jitterAmount', 0.1);
hold on
end
           %%Would be better with CI instead of SEM. 
ylim([0 1])
ylabel('Individual biasIndex')
xlabel('Orientations')
title([dffTrials.mouse,' ',dffTrials.runDate,' ',dffTrials.run, ' biasIndex for each Ori (mean of each ori/total response)',strLabel]);

 
 
 % Example data as before
model_series = [10 40 50 60; 20 50 60 70; 30 60 80 90];
model_error = [1 4 8 6; 2 5 9 12; 3 6 10 13];
figure
b = bar(trials, 'grouped');


%% 

%%For MATLAB R2019a or earlier releases
hold on
% Find the number of groups and the number of bars in each group
ngroups = size(model_series, 1);
nbars = size(model_series, 2);
% Calculate the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));
% Set the position of each error bar in the centre of the main bar
% Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
for i = 1:nbars
    % Calculate center of each bar
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, model_series(:,i), model_error(:,i), 'k', 'linestyle', 'none');
end
hold off
%%For MATLAB 2019b or later releases
hold on
% Calculate the number of bars in each group
nbars = size(model_series, 2);
% Get the x coordinate of the bars
x = [];
for i = 1:nbars
    x = [x ; b(i).XEndPoints];
end
% Plot the errorbars
errorbar(x',model_series,model_error,'k','linestyle','none')'
hold off