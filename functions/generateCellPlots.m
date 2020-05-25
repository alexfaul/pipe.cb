function generateCellPlots(root,time_window)
%% 
load(root)
[path]=fileparts(root)

%% load in all Stim info? Should I do all runs separate, 

extList='stim.mat'
StimDirs=findFilePathAF(path,extList);
%% 
folder=[path,'\','cellPlots'];
if ~exist(folder, 'dir');
    mkdir(folder);
end
% ss=1
for ss=1:length(StimDirs)
Stim=load(StimDirs{ss})
if ~isfield(Stim,'spontaneous')
%% Limit trial length to shortest trial length to standardize
for ii=1:length(Stim.condition)
    trial_length(ii)=Stim.trialoffsets(ii)-Stim.trialonsets(ii);
end
num_timepts=min(trial_length);
%% make extracted time points for each ori
Fs=suite2pData.ops.fs;
for ii=1:length(Stim.orientationsUsed)
    field = strcat('idx',num2str(Stim.orientationsUsed(ii)));      %making struct to store all replications
    idx.(field)=[];  
end
oriIdx=fieldnames(idx);

for ii=1:length(Stim.orientationsUsed)
    field = strcat('resp_',num2str(Stim.orientationsUsed(ii)));      %making struct to store all replications
    response.(field)=[];
    trial_response.(field)=[];
end
responseIdx=fieldnames(response);
num_cond=length(Stim.orientationsUsed);
conds_used=Stim.orientationsUsed;

for k=1:length(conds_used)
temp=conds_used(k)
idx.(oriIdx{k})=find(Stim.oriTrace==temp);
end 
%% 
% make it 2s before vis onset %%%%%%%%%%%%%%%\

tim=round(time_window*Fs)
for kk=1:size(suite2pData.dFF,1) %should this be changed
cell_num=kk;
exTrace=suite2pData.dFF(cell_num,suite2pData.startIdx(ss):suite2pData.endIdx(ss)); %isolating by run
for k=1:length(oriIdx)
    idxt=idx.(oriIdx{k});
    if Stim.trialoffsets(idxt(end))+tim > length(exTrace), 
        idxT=idxt(1:end-1)
    else idxT=idxt;
    end 
for ii=1:length(idxT)
    start=Stim.trialonsets(idxT(ii));
    tend=Stim.trialoffsets(idxT(ii));
    resp=exTrace(1,start:tend);
    resp2=resp(1:num_timepts);
    trial_response.(responseIdx{k})(ii,:)=resp2;
    before=exTrace(start-tim:start-1);
    after=exTrace(tend+1:tend+tim);
    response.(responseIdx{k})(ii,:)=[before,resp2,after];
    %add t-test here
    %add the orientation here
end 
end   

len=length(resp2)+length(before)+length(after);
frames=1:len;

%getting index positions of isolated responses to account for 1s around
%stim
ttestTim=length(before)-(round(Fs));
trialBefore=ttestTim:length(before);
trialDuring=length(before)+1:(length(before)+(round(Fs))+1);


for kk=1:length(conds_used)
subplot(num_cond,1,kk)
shadedErrorBar(frames,response.(responseIdx{kk}),{@mean,@(x) std(x)/sqrt(size(x,1))});
% [h,p] = ttest(x,y)
% avgBefore=mean(response.(responseIdx{kk})(:,trialBefore),2);
% avgDuring=mean(response.(responseIdx{kk})(:,trialDuring),2);
% [~,p]=ttest(avgBefore,avgDuring);
temp=num2str(conds_used(kk));
% temp2=[temp,' p=',num2str(p)];
hold on
% xlabel(temp2);
plot([tim tim],ylim,'Color','g');
plot([(tim+num_timepts) (tim+num_timepts)],ylim,'Color','g');
sgtitle([Stim.mouse,' ',num2str(Stim.date),' ',num2str(ss),' cell#',num2str(cell_num),' Avg Trial Response by Ori']);
end
ft=[folder,'\',Stim.mouse,'_',num2str(Stim.date),'_00',num2str(ss),'_','cell',num2str(cell_num),'_trialResponse','.jpeg'];
saveas(gcf,(ft))
figure
for kk=1:length(conds_used)
colormap('hot')
subplot(num_cond,1,kk)
imagesc(response.(responseIdx{kk}))
% avgBefore=mean(response.(responseIdx{kk})(:,trialBefore),2); %have to run separate t-tests bc it iterates through each condition separately
% avgDuring=mean(response.(responseIdx{kk})(:,trialDuring),2);
% [~,p]=ttest(avgBefore,avgDuring);
temp=num2str(conds_used(kk));
% temp2=[temp,' p=',num2str(p)];
% xlabel(temp2)
ylabel('Trials')
sgtitle([Stim.mouse,' ',num2str(Stim.date),' 00',num2str(ss),' cell#',num2str(cell_num),' Avg Trial Response by Ori']);
colorbar
end 
ft=[folder,'\',Stim.mouse,'_',num2str(Stim.date),'_00',num2str(ss),'_','cell',num2str(cell_num),'_heatmap','.jpeg'];
saveas(gcf,(ft))
close all
end
end 

end 
