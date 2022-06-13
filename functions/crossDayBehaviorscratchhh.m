function crossDayBehaviorscratchhh(eyeDirs)
%% 
%% Terrible way to write this...
% try again... so much repitetion.    
for ii=1:length(eyeDirs)
    [fullRoot,filename,~] = fileparts(eyeDirs{ii});
%     idcs   = strfind(fullRoot,filesep);

    ext     = 'Suite2p_dff.mat';
    stimDirs{ii} = findFILE(fullRoot,ext);
    
    ext     = '_motSVD.mat';
    motSVDdir{ii} = findFILE(fullRoot,ext);

    if isempty(stimDirs{ii})
        stimDirs{ii}=[]
        sprintf('suite2p file not in expected location, please make sure cell clicked + dff run')
    end 
    if isempty(motSVDdir{ii})
        motSVDdir=[]
        sprintf('motion file not in expected location, please convert')
    end 
end 
    %% 

idx=find(~cellfun(@isempty,stimDirs))   

stimDirs=cellfun(@char,stimDirs,'UniformOutput',false)
motSVDdir=cellfun(@char,motSVDdir,'UniformOutput',false)
    
stimDir=stimDirs(idx) %AWFUL, cmon
eyeDir=eyeDirs(idx)
motSVDdirs=motSVDdir(idx)
%% 

[~,filenames]=cellfun(@fileparts,stimDir,'UniformOutput',false)
for ii=1:length(stimDir)
      W10Data.(filenames{ii})=[]
       W10Data.(filenames{ii}) =load(stimDir{ii})
end 
    
% [~,filenames]=cellfun(@fileparts,motSVDdirs,'UniformOutput',false)
for ii=1:length(motSVDdirs)
       W10motSVD. (filenames{ii})=[]
       W10motSVD.(filenames{ii}) =load(motSVDdirs{ii})
end
    
% [~,filenames2]=cellfun(@fileparts,eyeDir,'UniformOutput',false)
for ii=1:length(eyeDir)
       W10eye. (filenames{ii})=[]
       W10eye.(filenames{ii}) =load(eyeDir{ii})
end
%% 

%yeah all of this is garbage coding lol. works but on a hair pin

[~,filenames1]=cellfun(@fileparts,stimDir,'UniformOutput',false)




%% 
for ii=1:length(filenames)
% for kk=1:length(W10Data.(filenames{ii}).suite2pData.Stim.visstimOnsets);                                        % finding length of all trials 
 
stimTime=W10Data.(filenames{ii}).suite2pData.Stim.visstimOffsets-W10Data.(filenames{ii}).suite2pData.Stim.visstimOnsets;            % if trial lengths differ, you'll get indexing errors when isolating those timepoints into structures
stimLength(ii)=round(max(stimTime));
 clear stimTime
% end 
numTrials(ii)=length(W10Data.(filenames{ii}).suite2pData.Stim.trialonsets)
end 

 for ii=1:length(filenames)
     oris{ii}=W10Data.(filenames{ii}).suite2pData.Stim.orientationsUsed';
 end
for ii=1:length(filenames)
W10.(filenames{ii}).eyeTrials=NaN(numTrials(ii),stimLength(ii)+1)
W10.(filenames{ii}).eyeTrialsext=NaN(numTrials(ii),stimLength(ii)+61)
W10.(filenames{ii}).motSVDTrials=NaN(numTrials(ii),stimLength(ii)+1)
W10.(filenames{ii}).motSVDTrialsext=NaN(numTrials(ii),stimLength(ii)+61)
W10.(filenames{ii}).orisUsed(:,1)=oris{ii}
end 

for ii=1:length(filenames)
    for kk=1:(numTrials(ii))
win=length(W10eye.(filenames{ii}).parea(W10Data.(filenames{ii}).suite2pData.Stim.visstimOnsets(kk):W10Data.(filenames{ii}).suite2pData.Stim.visstimOffsets(kk)))
winExt=win+60;
W10.(filenames{ii}).eyeTrials(kk,1:win)=W10eye.(filenames{ii}).parea(W10Data.(filenames{ii}).suite2pData.Stim.visstimOnsets(kk):W10Data.(filenames{ii}).suite2pData.Stim.visstimOffsets(kk))
W10.(filenames{ii}).eyeTrialsext(kk,1:winExt)=W10eye.(filenames{ii}).parea(W10Data.(filenames{ii}).suite2pData.Stim.visstimOnsets(kk)-30:W10Data.(filenames{ii}).suite2pData.Stim.visstimOffsets(kk)+30)


W10.(filenames{ii}).motSVDTrials(kk,1:win)=W10motSVD.(filenames{ii}).motsvd(W10Data.(filenames{ii}).suite2pData.Stim.visstimOnsets(kk):W10Data.(filenames{ii}).suite2pData.Stim.visstimOffsets(kk))
W10.(filenames{ii}).motSVDTrialsext(kk,1:winExt)=W10motSVD.(filenames{ii}).motsvd(W10Data.(filenames{ii}).suite2pData.Stim.visstimOnsets(kk)-30:W10Data.(filenames{ii}).suite2pData.Stim.visstimOffsets(kk)+30)
   
    
    end
end 

 
 
for ii=1:length(filenames)
    for kk=1:length(oris{ii})
        temp=find(W10Data.(filenames{ii}).suite2pData.Stim.oriTrace==W10.(filenames{ii}).orisUsed(kk))
      W10.(filenames{ii}).trialIdx(kk,1:length(temp))=temp;
    end 
   clear temp
end %orientation(rows) x trial # (columns)

%% 

[baseRoot,~,~] = fileparts(fullRoot);
folder                = [baseRoot,'\','crossDayBehavior\']; % create directory if it doesn't exist
if ~exist(folder, 'dir');
        mkdir(folder);
end
foldereye                = [baseRoot,'\','crossDayBehavior\','eye']; % create directory if it doesn't exist
if ~exist(foldereye, 'dir');
        mkdir(foldereye);
end

foldermot                = [baseRoot,'\','crossDayBehavior\','motSVD']; % create directory if it doesn't exist
if ~exist(foldermot, 'dir');
        mkdir(foldermot);
end

%% by trial types
% ugh=unique(oris{:})
% uniqueOris=cellfun(@unique(x{:}),oris,'UniformOutput',false)
% uniqueOris = cellfun(@(x) unique(x(:)), oris, 'UniformOutput',false)
% B = cellfun(@(v)sort(char(v)),oris,'uni',0);
% uniqueOris = cellfun(@double,unique(B),'uni',0);
% 
% Fc=uniqueOris{1,2}
% 
% 
% for ii=1:length(filenames)
%     for kk=1:length(Fc)
%         oriDay(ii,:)=find(W10Data.(filenames{ii}).suite2pData.Stim.oriTrace==Fc(kk))
% 
%     end 
% end 
%% 

for ii=1:length(filenames)
    W10.(filenames{ii}).trialIdx(W10.(filenames{ii}).trialIdx==0)=NaN

end 


for ii=1:length(filenames)
    for kk=1:length(W10.(filenames{ii}).orisUsed)
        tempIdx = W10.(filenames{ii}).trialIdx(kk,:)
        tempidx=tempIdx(~isnan(tempIdx))
        temp=NaN(length(W10.(filenames{ii}).trialIdx(kk,:)),stimLength(ii)+1)
        temp=W10.(filenames{ii}).eyeTrials(tempidx,:)
eyePupil(ii)=nanmean(temp) %gives mean over timecourse

SEM(ii) = std(temp,2)./sqrt(size(temp,2));
        end
    end
end

        
        
        end 
end 
figure
bar(temp)

end 
%% 
errhigh = [2.1 4.4 0.4 3.3 2.5 0.4 1.6 0.8 0.6 0.8 2.2 0.9 1.5];
errlow  = [4.4 2.4 2.3 0.5 1.6 1.5 4.5 1.5 0.4 1.2 1.3 0.8 1.9];
bar(x,data)                

hold on

er = errorbar(x,data,errlow,errhigh);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  

hold off




figure
for kk=1:length(conds_used)
% subplot(num_cond,1,kk)
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
legend
sgtitle([Stim.mouse,' ',num2str(Stim.date),' ',num2str(ss),' cell#',num2str(cell_num),' Avg Trial Response by Ori']);
end
end %%%take this one out
end
ft=[folder,'\','meanTimecourse','\',Stim.mouse,'_',num2str(Stim.date),'_00',num2str(ss),'_','cell',num2str(cell_num),'_trialResponse','.jpeg'];
saveas(gcf,(ft))
end 
end

