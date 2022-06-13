%% Pipe wrapper3
% Change root to whatever mouse you want to run
% Check for registration issues before running these and proceeding w
% analysis
% Must have output from Suite2p to run all below functions
%% %% get dFF calculations - RUN AFTER SUITE2P + CELL CLICKING!
    root    ='Z:\AFdata\2p2019\Experiments\I03';                    %% as character 
    ext = 'Fall.mat';
    stimdir = findFILE(root,ext);

    stimDirs=stimdir(17:end);
    time_window=20;
    percentile=30;
for ii=1:length(stimDirs)
dffCalc(stimDirs{ii},percentile,time_window); %%%%%%%%%%%%%dsNidaq saving 5000 fewer pulses??????????????????
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






sum(suite2pData.statsT.h.Trials0)
sum(suite2pData.statsT.h.Trials90)
sum(suite2pData.statsT.h.Trials225)








root    ='Z:\AFdata\2p2019\B02';                    %% as character 
ext = 'eye_area.mat';
stimdir = findFILE(root,ext);
eyeDirs=stimdir(:);
[allDataB02,B02,eyeDataB02,motSVDB02,x1,x2]=crossDayBehavior(eyeDirs)

% figure
% plot(allData.B02_210315_001_dsNidaq.licking)
% 
% nansum(B02.B02_210315_001_dsNidaq.licking,2)

daysidx=fieldnames(B02)
for ii= 1:length(daysidx)
    totalLicks(ii)=nansum(allDataB02.(daysidx{ii}).licking)
    totalRunning(ii)=nansum(allDataB02.(daysidx{ii}).runVel)
    for kk=1:length(B02.(daysidx{ii}).orisUsed)
        tempTrialidx=B02.(daysidx{ii}).trialIdx(kk,:)'
        tempTrialidx = tempTrialidx(~isnan(tempTrialidx))
        
%        test(1:length(tempTrialidx),:)= W10.(daysidx{ii}).licking(tempTrialidx,:)
       B02.(daysidx{ii}).runningByTrial(kk,1:length(tempTrialidx))=nansum(B02.(daysidx{ii}).running(tempTrialidx,:),2)
       B02.(daysidx{ii}).runningbyTrialpostStim(kk,1:length(tempTrialidx))=nansum(B02.(daysidx{ii}).running(tempTrialidx,x1:end),2)
       B02.(daysidx{ii}).lickingbyTrial(kk,1:length(tempTrialidx))=nansum(B02.(daysidx{ii}).licking(tempTrialidx,:),2)
       B02.(daysidx{ii}).lickingbyTrialpostStim(kk,1:length(tempTrialidx))=nansum(B02.(daysidx{ii}).licking(tempTrialidx,x1:end),2)

    end
end 



runningbyOri=[]
lickingbyOri=[]
for ii=1:7
  temp=sum(B02.(daysidx{ii}).runningByTrial,2)'
  offsetRun=sum(B02.(daysidx{ii}).runningbyTrialpostStim,2)'
  temp=[temp offsetRun]
  runningbyOri=[runningbyOri;temp]
  
 
  temp2=nansum(B02.(daysidx{ii}).lickingbyTrial,2)'
  offsetRunL=nansum(B02.(daysidx{ii}).lickingbyTrialpostStim,2)'
  temp2=[temp2 offsetRunL]
  lickingbyOri=[lickingbyOri;temp2];
  
  clear temp offsetRun offsetRunL temp2
end

allRun=sum(runningbyOri,2)'
restofRunning=totalRunning-(allRun)
runningbyOri=[runningbyOri restofRunning']

allLick=sum(lickingbyOri,2)'
restofLick=totalLicks-(allLick)
lickingbyOri=[lickingbyOri restofLick']

% figure
% bar(runningbyOri)
% 
% bar(runningbyOri,'stacked')
totalbiasR=NaN(7,7)
totalbiasL=NaN(7,7)

totalbiasR=sum(runningbyOri(1:3,:))
 totalbiasL=sum(lickingbyOri(1:3,:))
% 
% totalbiasR(isnan(totalbiasR=[]))
% totalbiasR = totalbiasR(~isnan(totalbiasR))


for ii=1:length(daysidx)
for kk=1:3
    runningBias(kk,ii)=runningbyOri(kk,ii)/totalLicks(ii)
    lickingBias(kk,ii)=lickingbyOri(kk,ii)/totalRunning(ii)

end
end 


figure
bar(lickingBias')
title('B02 lick response by stimulus')
xt = get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', {'Day 1 App' 'Day 2 App'  'Day 3 app'  'Day 4 App' 'Day 1 Av' 'Day 2 Av' 'Day3 Av' })
xtickangle(-45)
label = {'App Visstim (0deg)' 'Aversive Visstim (90deg)' 'Neutral Visstim (225deg)'};

legend(label,'FontSize',7,'Location','bestoutside')


figure
bar(


% runningBias=char(runningBias)
% 
% A(strcmp(A, 'None')) = {NaN};
% cell2mat(A)
% ... and credits to Stephen Cobeldick for providing the general solution (for any string):
% A(~cellfun(@isnumeric,A)) = {NaN}

figure
sgtitle('Running and Licking Response during all Trial Types - B02')
subplot(2,1,1)
b=bar(runningbyOri)
b(1).FaceColor = [0 0 1];
b(2).FaceColor = [1 0 0];
b(3).FaceColor = [0 1 0];
b(4).FaceColor = [0 .2 .80];
b(5).FaceColor = [.80 .2 0];
b(6).FaceColor = [.1 .8 .1];
 b(7).FaceColor = [.5 .5 .5];

title('total running during trial times')
xt = get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', {'Day 1 App' 'Day 2 App'  'Day 3 app'  'Day 4 App' 'Day 1 Av' 'Day 2 Av' 'Day3 Av' })
xtickangle(-45)
label = {'App Visstim (0deg)' 'Aversive Visstim (90deg)' 'Neutral Visstim (225deg)' 'App Visstim PostTrial(0deg)' 'Aversive Visstim PostTrial(90deg)' 'Neutral VisstimPostTrial (225deg)' 'Baseline/all other total response'};

legend(label,'FontSize',7,'Location','bestoutside')

subplot(2,1,2)
b2=bar(lickingbyOri)
b2(1).FaceColor = [0 0 1];
b2(2).FaceColor = [1 0 0];
b2(3).FaceColor = [0 1 0];
b2(4).FaceColor = [0 .2 .80];
b2(5).FaceColor = [.80 .2 0];
b2(6).FaceColor = [.1 .8 .1];
b2(7).FaceColor = [.5 .5 .5];title('total licking during trial times')
xt = get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', {'Day 1 App' 'Day 2 App' 'Day 3 app' 'Day 4 App' 'Day 1 Av' 'Day 2 Av' 'Day3 Av' })
xtickangle(-45)
label = {'App Visstim (0deg)' 'Aversive Visstim (90deg)' 'Neutral Visstim (225deg)' 'App Visstim PostTrial(0deg)' 'Aversive Visstim PostTrial(90deg)' 'Neutral VisstimPostTrial (225deg)' 'Baseline/all other total response'};
legend(label,'FontSize',7,'Location','bestoutside')

figure


slope of last 10 frames before onset

text(1:length(runningBias),runningBias,num2str(runningBias'),'vert','bottom','horiz','center'); 
box off


subplot(3,1,3)
axis off

yd = get(hBar, 'YData');














D = randi(10, 5, 3);
figure(1)
hBar = bar(D, 'stacked');
xt = get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', {'Machine 1' 'Machine 2' 'Machine 3' 'Machine 4' 'Machine 5'})
yd = get(hBar, 'YData');
yjob = {'Job A' 'Job B' 'Job C'};
barbase = cumsum([zeros(size(D,1),1) D(:,1:end-1)],2);
joblblpos = D/2 + barbase;
for k1 = 1:size(D,1)
    text(xt(k1)*ones(1,size(D,2)), joblblpos(k1,:), yjob, 'HorizontalAlignment','center')
end

