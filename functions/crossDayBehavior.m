function [allData,W10,eyeData,motSVD,x1,x2]=crossDayBehavior(eyeDirs,EXT)
%%% 
% eyeDirs = cell array with facemap processed + converted eyeData (from fM
% then jupyter notebook)
% this will work fine if missing motSVD but not pupil
% numFrames is how many 

if nargin<2, EXT=30; end


%%% 
%% Terrible way to write this...
for ii=1:length(eyeDirs)
%     ii=2
    [fullRoot,filename,~] = fileparts(eyeDirs{ii});
%     idcs   = strfind(fullRoot,filesep);

%     ext     = 'Suite2p_dff.mat';
%     stimDirs{ii} = findFILE(fullRoot,ext);
    ext     = '_dsNidaq.mat';
    nidaqDirs{ii} = findFILE(fullRoot,ext);
   
    ext     = '_motSVD.mat';
    motSVDdir{ii} = findFILE(fullRoot,ext);

%     if isempty(stimDirs{ii})
%         %stimDirs{ii}=[]
%         sprintf('suite2p file not in expected location, please make sure cell clicked + dff run if looking at *neural* data, using dsNidaq instead')
%         ext     = '_dsNidaq.mat';
%         nidaqDirs{ii} = findFILE(fullRoot,ext);
% 
%     end 
    if isempty(motSVDdir{ii})
        motSVDdir=[]
        sprintf('motion file not in expected location, please convert')
    end 
end 
    %% 
% for ii=1:length(eyeDirs)

idx=find(~cellfun(@isempty,nidaqDirs))

% stimDirs=cellfun(@char,stimDirs,'UniformOutput',false)
nidaqDirs=cellfun(@char,nidaqDirs,'UniformOutput',false)

motSVDdir=cellfun(@char,motSVDdir,'UniformOutput',false)
    
stimDir=nidaqDirs(idx) %AWFUL, cmon
eyeDir=eyeDirs(idx)
motSVDdirs=motSVDdir(idx)
%% 

[~,filenames]=cellfun(@fileparts,stimDir,'UniformOutput',false)
for ii=1:length(stimDir)
      [~,dsNidaq]=alignStim(stimDir{ii})
      allData.(filenames{ii})=dsNidaq; 
      clear dsNidaq
%       allData.(filenames{ii}) =load(stimDir{ii})
end 
    
% [~,filenames]=cellfun(@fileparts,motSVDdirs,'UniformOutput',false)
for ii=1:length(motSVDdirs)
       motSVD.(filenames{ii})=[]
       motSVD.(filenames{ii}) =load(motSVDdirs{ii})
end
    
[~,filenames2]=cellfun(@fileparts,eyeDir,'UniformOutput',false)
for ii=1:length(eyeDir)
       eyeData. (filenames{ii})=[]
       eyeData.(filenames{ii}) =load(eyeDir{ii})
end
%% 
[~,filenames1]=cellfun(@fileparts,stimDir,'UniformOutput',false)
%% 
for ii=1:length(filenames) 
    stimTime=allData.(filenames{ii}).Stim.visstimOffsets-allData.(filenames{ii}).Stim.visstimOnsets;            % if trial lengths differ, you'll get indexing errors when isolating those timepoints into structures
    stimLength(ii)=round(max(stimTime));
    numTrials(ii)=length(allData.(filenames{ii}).Stim.trialonsets)-1;
end 
 clear stimTime

for ii=1:length(filenames)
     oris{ii}=allData.(filenames{ii}).Stim.orientationsUsed';
end

for ii=1:length(filenames)
W10.(filenames{ii}).eyeTrials=NaN(numTrials(ii),stimLength(ii)+1)
W10.(filenames{ii}).motSVDTrials=NaN(numTrials(ii),stimLength(ii)+1)
W10.(filenames{ii}).eyeTrialsNorm=NaN(numTrials(ii),stimLength(ii)+1)
W10.(filenames{ii}).motSVDTrialsNorm=NaN(numTrials(ii),stimLength(ii)+1)

W10.(filenames{ii}).running=NaN(numTrials(ii),stimLength(ii)+1)
W10.(filenames{ii}).licking=NaN(numTrials(ii),stimLength(ii)+1)

W10.(filenames{ii}).eyeTrialsext=NaN(numTrials(ii),stimLength(ii)+1+2*EXT)
W10.(filenames{ii}).motSVDTrialsext=NaN(numTrials(ii),stimLength(ii)+1+2*EXT)
W10.(filenames{ii}).eyeTrialsextNorm=NaN(numTrials(ii),stimLength(ii)+1+2*EXT)
W10.(filenames{ii}).motSVDTrialsextNorm=NaN(numTrials(ii),stimLength(ii)+1+2*EXT)

W10.(filenames{ii}).runningExt=NaN(numTrials(ii),stimLength(ii)+1+2*EXT)
W10.(filenames{ii}).lickingExt=NaN(numTrials(ii),stimLength(ii)+1+2*EXT)

W10.(filenames{ii}).orisUsed(:,1)=oris{ii}
end 
% % 
% allData.B04_210321_001_dsNidaq.Stim.visstimOffsets=allData.B04_210321_001_dsNidaq.Stim.visstimOffsets(2:end);
% allData.B04_210321_001_dsNidaq.Stim.trialoffsets=allData.B04_210321_001_dsNidaq.Stim.trialoffsets(2:end);
% allData.B04_210321_001_dsNidaq.Stim.oriTrace=allData.B04_210321_001_dsNidaq.Stim.oriTrace(2:end);
% allData.B04_210321_001_dsNidaq.Stim.trial=allData.B04_210321_001_dsNidaq.Stim.trial(2:end)
% allData.B04_210321_001_dsNidaq.Stim.condition=allData.B04_210321_001_dsNidaq.Stim.condition(2:end)
% 
% allData.B04_210321_001_dsNidaq.Stim.visstimOnsets=allData.B04_210321_001_dsNidaq.Stim.visstimOnsets(1:end-1)
% allData.B04_210321_001_dsNidaq.Stim.trialonsets=allData.B04_210321_001_dsNidaq.Stim.trialonsets(1:end-1)
% % 
% 
% 
% allData.W10_200811_001_dsNidaq.Stim.visstimOffsets=allData.W10_200811_001_dsNidaq.Stim.visstimOffsets(2:end);
% allData.W10_200811_001_dsNidaq.Stim.trialoffsets=allData.W10_200811_001_dsNidaq.Stim.trialoffsets(2:end);
% allData.W10_200811_001_dsNidaq.Stim.oriTrace=allData.W10_200811_001_dsNidaq.Stim.oriTrace(2:end);
% allData.W10_200811_001_dsNidaq.Stim.trial=allData.W10_200811_001_dsNidaq.Stim.trial(2:end)
% allData.W10_200811_001_dsNidaq.Stim.condition=allData.W10_200811_001_dsNidaq.Stim.condition(2:end)
% 
% allData.W10_200811_001_dsNidaq.Stim.visstimOnsets=allData.W10_200811_001_dsNidaq.Stim.visstimOnsets(1:end-1)
% allData.W10_200811_001_dsNidaq.Stim.trialonsets=allData.W10_200811_001_dsNidaq.Stim.trialonsets(1:end-1)

for ii=1:length(filenames) 
    stimTime=allData.(filenames{ii}).Stim.visstimOffsets-allData.(filenames{ii}).Stim.visstimOnsets;            % if trial lengths differ, you'll get indexing errors when isolating those timepoints into structures
    stimLength(ii)=round(max(stimTime));
    numTrials(ii)=length(allData.(filenames{ii}).Stim.trialonsets)-1;
end 
for ii=1:length(filenames) %if it says index exceeds number of array elements (0) in this section, prob the FM conversion wasnt run/error-free
    if allData.(filenames{ii}).Stim.visstimOffsets(end-1)<length(eyeData.(filenames{ii}).parea)
     W10.(filenames{ii}).normalizedEye     =zscore(eyeData.(filenames{ii}).parea);
     W10.(filenames{ii}).normalizedmotSVD     =zscore(motSVD.(filenames{ii}).motsvd);

    for kk=1:(numTrials(ii))-1 %took out -1... hmmmmm. lose last trial... going to cause off by 1 error elsewhere? idk
win=length(eyeData.(filenames{ii}).parea(allData.(filenames{ii}).Stim.visstimOnsets(kk):allData.(filenames{ii}).Stim.visstimOffsets(kk)))
winExt=win+60;
    
W10.(filenames{ii}).eyeTrials(kk,1:win)         =eyeData.(filenames{ii}).parea(allData.(filenames{ii}).Stim.visstimOnsets(kk):allData.(filenames{ii}).Stim.visstimOffsets(kk));
W10.(filenames{ii}).motSVDTrials(kk,1:win)      =motSVD.(filenames{ii}).motsvd(allData.(filenames{ii}).Stim.visstimOnsets(kk):allData.(filenames{ii}).Stim.visstimOffsets(kk));
W10.(filenames{ii}).eyeTrialsNorm(kk,1:win)         =W10.(filenames{ii}).normalizedEye(allData.(filenames{ii}).Stim.visstimOnsets(kk):allData.(filenames{ii}).Stim.visstimOffsets(kk));
W10.(filenames{ii}).motSVDTrialsNorm(kk,1:win)      =W10.(filenames{ii}).normalizedmotSVD(allData.(filenames{ii}).Stim.visstimOnsets(kk):allData.(filenames{ii}).Stim.visstimOffsets(kk));

W10.(filenames{ii}).running(kk,1:win)           =allData.(filenames{ii}).runVel(allData.(filenames{ii}).Stim.visstimOnsets(kk):allData.(filenames{ii}).Stim.visstimOffsets(kk));
W10.(filenames{ii}).licking(kk,1:win)           =allData.(filenames{ii}).licking(allData.(filenames{ii}).Stim.visstimOnsets(kk):allData.(filenames{ii}).Stim.visstimOffsets(kk));
%     catch

W10.(filenames{ii}).motSVDTrialsext(kk,1:winExt)=motSVD.(filenames{ii}).motsvd(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOffsets(kk)+30);
W10.(filenames{ii}).eyeTrialsext(kk,1:winExt)   =eyeData.(filenames{ii}).parea(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOffsets(kk)+30);
W10.(filenames{ii}).motSVDTrialsextNorm(kk,1:winExt)=W10.(filenames{ii}).normalizedmotSVD(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOffsets(kk)+30);
W10.(filenames{ii}).eyeTrialsextNorm(kk,1:winExt)   =W10.(filenames{ii}).normalizedEye(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOffsets(kk)+30);


W10.(filenames{ii}).runningExt(kk,1:winExt)     =allData.(filenames{ii}).runVel(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOffsets(kk)+30);
W10.(filenames{ii}).lickingExt(kk,1:winExt)     =allData.(filenames{ii}).licking(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOffsets(kk)+30); 

    end 
    else
       continue 
    end
end 

 
 
for ii=1:length(filenames)
    for kk=1:length(oris{ii})
        temp=find(allData.(filenames{ii}).Stim.oriTrace==W10.(filenames{ii}).orisUsed(kk));
        temp(temp > numTrials(ii)) = NaN;

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

folderrun                = [baseRoot,'\','crossDayBehavior\','running']; % create directory if it doesn't exist
if ~exist(folderrun, 'dir');
        mkdir(folderrun);
end

folderlick               = [baseRoot,'\','crossDayBehavior\','licking']; % create directory if it doesn't exist
if ~exist(folderlick, 'dir');
        mkdir(folderlick);
end


%% by trial types
% ugh=unique(oris{:})
% uniqueOris=cellfun(@unique(x{:}),oris,'UniformOutput',false)
uniqueOris = cellfun(@(x) unique(x(:)), oris, 'UniformOutput',false)
B = cellfun(@(v)sort(char(v)),oris,'uni',0);
uniqueOris = cellfun(@double,unique(B),'uni',0);

allOris=[];
for ii=1:size(uniqueOris,2)
    kk=length(allOris)+1:length(allOris)+(length(uniqueOris{ii}))
    allOris(kk)=uniqueOris{ii}
end
allOris=unique(allOris);

for ii=1:length(uniqueOris{1,1})
label=strcat('Trials',num2str(allOris(ii)));
byOri.(label)=[];
 end
% % % % 
% % % % for ii=1:length(allOris)
% % % %    (=find(W10 
% % % % end
%% different length stim trials... should sort before plotting bc... otherwise its gonna be wayyy off

%so segregate stimLength by trial type??
% % % 
% % % for ii=1:length(uniqueOris{1,1})
% % % label=strcat('Trials',num2str(round(uniqueOris{1,1}(ii))));
% % % byOri.(label)=[];
% % % end
% % % 
% % % for ii=1:length(filenames)
% % %     for kk=1:length(oris)
% % %         
% % % byOri.(filenames{ii}).    
% % % 
% % %     end



%% 

for ii=1:length(filenames)
    W10.(filenames{ii}).trialIdx(W10.(filenames{ii}).trialIdx==0)=NaN

end 


colors=[0,1,0;1,0,0;0,0,1]

 
 %green
% elseif ii==find(contains(bhv_struct.TimingFileByCond,'CSm'))
%      bhv_struct.colors(ii,:)=[1,0,0] %red
% elseif ii==find(contains(bhv_struct.TimingFileByCond,'Csnrand'))
%      bhv_struct.colors(ii,:)=[0,0,1] %blue

for ii=1:length(filenames)  %eyeArea
figure 
    for kk=1:length(W10.(filenames{ii}).orisUsed) %kk=3
        if contains(baseRoot,["W03"])  %%old version of facemap(no pims) for W03 read in shuffled blocks, issue w conversion script 
            mm=length(W10.(filenames{ii}).orisUsed)+1-kk;
        else 
            mm=kk;
        end 
        tempIdx = W10.(filenames{ii}).trialIdx(mm,:);
        tempidx=tempIdx(~isnan(tempIdx));
        temp=NaN(length(W10.(filenames{ii}).trialIdx(mm,:)),stimLength(ii)+61);
        temp=W10.(filenames{ii}).eyeTrialsext(tempidx,:);
        
        label = strcat('Trials',num2str(round(W10.(filenames{ii}).orisUsed)));
        
shadedErrorBar(1:size(temp,2),temp,{@nanmean,@(x) nanstd(x)/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});

        hold on
    title([filenames{ii},'_eyeArea'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('PupilArea - pixels')
        x1=size(temp,2)-30;
        x2=30;
    end
      xlim([-30 winExt+30])
      ylimit=get(gca, 'YLim');
    xlimit=get(gcf,'XLim');
    ylim=[ylimit(1)*0.85 ylimit(2)] 
    xline(x1,'-','DisplayName','Trial Onset')
    xline(x2,'-','DisplayName','Trial Offset')
    legend(label,'FontSize',7,'Location','northwest','AutoUpdate','off')   
   
     x_points = [-30, -30, x2, x2];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 0, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.06;
    
    
    x_points = [x2, x2, x1, x1];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 1, 0.5];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.05;
      
    x_points = [x1, x1, winExt+30, winExt+30];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, .5, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.08;
    
    txt = {'Pre-Stimulus';' (baseline)'};
    text(-20,ylimit(1)*1.08+2,txt)
    txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x2+5,ylimit(2)*.95,txt2)
    txt3 = {'    Outcome ' ;'(unconditioned'; '  response)'};
    text(x1+3,ylimit(1)*1.08+2,txt3)
   hold off

    ft=[foldereye,'\',[filenames{ii},'_eyeArea'],'.png'];
    saveas(gcf,(ft))
end


for ii=1:length(filenames) %%motSVD
   figure
    for kk=1:length(W10.(filenames{ii}).orisUsed)
        tempIdx = W10.(filenames{ii}).trialIdx(kk,:);
        tempidx=tempIdx(~isnan(tempIdx));
        temp=NaN(length(W10.(filenames{ii}).trialIdx(kk,:)),stimLength(ii)+1);
        temp=W10.(filenames{ii}).motSVDTrialsext(tempidx,:);
        
        label = strcat('Trials',num2str(round(W10.(filenames{ii}).orisUsed)));
        
shadedErrorBar(1:size(temp,2),temp,{@nanmean,@(x) std(x,'omitnan')/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});
x1=size(temp,2)-30;
        x2=30;
        hold on
       
        clear temp

    end
 
    title([filenames{ii},'_motSVD'],'Interpreter', 'none')
     xlabel('Frames')
     ylabel('motSVD')
     xlim([-30 winExt+30])
      ylimit=get(gca, 'YLim');
    xlimit=get(gcf,'XLim');
    ylim=[ylimit(1)*0.85 ylimit(2)] 
    xline(x1,'-','DisplayName','Trial Onset')
    xline(x2,'-','DisplayName','Trial Offset')
    legend(label,'FontSize',7,'Location','northwest','AutoUpdate','off')   
   
     x_points = [-30, -30, x2, x2];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 0, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.06;
    
    
    x_points = [x2, x2, x1, x1];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 1, 0.5];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.05;
      
    x_points = [x1, x1, winExt+30, winExt+30];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, .5, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.08;
    
    txt = {'Pre-Stimulus';' (baseline)'};
    text(-20,ylimit(1)*0.90+2,txt)
    txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x2+5,ylimit(1)*.9,txt2)
    txt3 = {'    Outcome ' ;'(unconditioned'; '  response)'};
    text(x1+3,ylimit(1)*.85+2,txt3)
   hold off
   
     ft=[foldermot,'\',[filenames{ii},'_motSVD'],'.png'];
    saveas(gcf,(ft))
end


for ii=1:length(filenames) %%running
   figure

    for kk=1:length(W10.(filenames{ii}).orisUsed)
        tempIdx = W10.(filenames{ii}).trialIdx(kk,:);
        tempidx=tempIdx(~isnan(tempIdx));
        temp=NaN(length(W10.(filenames{ii}).trialIdx(kk,:)),stimLength(ii)+1);
        temp=W10.(filenames{ii}).runningExt(tempidx,:);
        
        label = strcat('Trials',num2str(round(W10.(filenames{ii}).orisUsed)));
        
shadedErrorBar(1:size(temp,2),temp,{@nanmean,@(x) std(x,'omitnan')/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});
x1=size(temp,2)-30;
        x2=30;       
hold on
        title([filenames{ii},'_running'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('Running Velocity')
        clear temp

    end
    xline(x1,'-','DisplayName','Trial Onset')
    xline(x2,'-','DisplayName','Trial Offset')
    
     xlim([-30 winExt+30])
      ylimit=get(gca, 'YLim');
    xlimit=get(gcf,'XLim');
    ylimit=[ylimit(1)-ylimit(2)*.05 ylimit(2)] 
    ylimit=get(gca, 'YLim');

    xline(x1,'-','DisplayName','Trial Onset')
    xline(x2,'-','DisplayName','Trial Offset')
    legend(label,'FontSize',7,'Location','northwest','AutoUpdate','off')   
   
     x_points = [-30, -30, x2, x2];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 0, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.06;
    
    
    x_points = [x2, x2, x1, x1];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 1, 0.5];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.05;
      
    x_points = [x1, x1, winExt+30, winExt+30];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, .5, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.08;
    
    txt = {'Pre-Stimulus';' (baseline)'};
    text(-20,ylimit(1)*.9+abs(ylimit(2)*.01),txt)
    txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x2+5,ylimit(2)*.9,txt2)
    txt3 = {'    Outcome ' ;'(unconditioned'; '  response)'};
    text(x1+3,ylimit(1)*.9+abs(ylimit(2)*.01),txt3)
   hold off
    ft=[folderrun,'\',[filenames{ii},'_running'],'.png'];
    saveas(gcf,(ft))
end


for ii=1:length(filenames) %%licking
   figure
%     if isfield(allData.(filenames{ii}).Stim,'colors')
%        colors=allData.(filenames{ii}).Stim.colors;
%    else
%     colors=distinguishable_colors(length(W10.(filenames{ii}).orisUsed))
%    end 
    for kk=1:length(W10.(filenames{ii}).orisUsed)
        tempIdx = W10.(filenames{ii}).trialIdx(kk,:);
        tempidx=tempIdx(~isnan(tempIdx));
        temp=NaN(length(W10.(filenames{ii}).trialIdx(kk,:)),stimLength(ii)+1);
        temp=W10.(filenames{ii}).lickingExt(tempidx,:);
        
        label = strcat('Trials',num2str(round(W10.(filenames{ii}).orisUsed)));
        
shadedErrorBar(1:size(temp,2),temp,{@nanmean,@(x) std(x,'omitnan')/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});
        hold on
        title([filenames{ii},'_lick'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('Licks')
        clear temp

    end
legend(label,'FontSize',7)
    xline(x1,'-','DisplayName','Trial Onset')
    xline(x2,'-','DisplayName','Trial Offset')
    ft=[folderlick,'\',[filenames{ii},'_lick'],'.png'];
    saveas(gcf,(ft))
end
%% 
%% 
%% 
%% 
%% 
%% 
%% 
%% 
%% 
%%


for ii=1:length(filenames) 
    stimTime=allData.(filenames{ii}).Stim.visstimOffsets-allData.(filenames{ii}).Stim.visstimOnsets;            % if trial lengths differ, you'll get indexing errors when isolating those timepoints into structures
    stimLength(ii)=round(max(stimTime));
    numTrials(ii)=length(allData.(filenames{ii}).Stim.trialonsets)-1;
end 
for ii=1:length(filenames) %if it says index exceeds number of array elements (0) in this section, prob the FM conversion wasnt run/error-free
    if allData.(filenames{ii}).Stim.visstimOffsets(end-1)<length(eyeData.(filenames{ii}).parea)
     W10.(filenames{ii}).normalizedEye     =zscore(eyeData.(filenames{ii}).parea);
     W10.(filenames{ii}).normalizedmotSVD     =zscore(motSVD.(filenames{ii}).motsvd);

    for kk=1:(numTrials(ii)) %took out -1... hmmmmm. lose last trial... going to cause off by 1 error elsewhere? idk
% win=length(eyeData.(filenames{ii}).parea(allData.(filenames{ii}).Stim.visstimOnsets(kk):allData.(filenames{ii}).Stim.visstimOffsets(kk)))
% winExt=win+60;
win=91;
    
W10.(filenames{ii}).eyeTrialsStart(kk,1:win)         =eyeData.(filenames{ii}).parea(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOnsets(kk)+60);
W10.(filenames{ii}).motSVDTrialsStart(kk,1:win)      =motSVD.(filenames{ii}).motsvd(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOnsets(kk)+60);
W10.(filenames{ii}).eyeTrialsNormStart(kk,1:win)         =W10.(filenames{ii}).normalizedEye(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOnsets(kk)+60);
W10.(filenames{ii}).motSVDTrialsNormStart(kk,1:win)      =W10.(filenames{ii}).normalizedmotSVD(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOnsets(kk)+60);

W10.(filenames{ii}).runningStart(kk,1:win)           =allData.(filenames{ii}).runVel(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOnsets(kk)+60);
W10.(filenames{ii}).lickingStart(kk,1:win)           =allData.(filenames{ii}).licking(allData.(filenames{ii}).Stim.visstimOnsets(kk)-30:allData.(filenames{ii}).Stim.visstimOnsets(kk)+60);
%     catch

W10.(filenames{ii}).motSVDTrialsEnd(kk,1:win)=motSVD.(filenames{ii}).motsvd(allData.(filenames{ii}).Stim.visstimOffsets(kk)-45:allData.(filenames{ii}).Stim.visstimOffsets(kk)+45);
W10.(filenames{ii}).eyeTrialsEnd(kk,1:win)   =eyeData.(filenames{ii}).parea(allData.(filenames{ii}).Stim.visstimOffsets(kk)-45:allData.(filenames{ii}).Stim.visstimOffsets(kk)+45);
W10.(filenames{ii}).motSVDTrialsextNormEnd(kk,1:win)=W10.(filenames{ii}).normalizedmotSVD(allData.(filenames{ii}).Stim.visstimOffsets(kk)-45:allData.(filenames{ii}).Stim.visstimOffsets(kk)+45);
W10.(filenames{ii}).eyeTrialsextNormEnd(kk,1:win)   =W10.(filenames{ii}).normalizedEye(allData.(filenames{ii}).Stim.visstimOffsets(kk)-45:allData.(filenames{ii}).Stim.visstimOffsets(kk)+45);

W10.(filenames{ii}).runningEnd(kk,1:win)     =allData.(filenames{ii}).runVel(allData.(filenames{ii}).Stim.visstimOffsets(kk)-45:allData.(filenames{ii}).Stim.visstimOffsets(kk)+45);
W10.(filenames{ii}).lickingEnd(kk,1:win)     =allData.(filenames{ii}).licking(allData.(filenames{ii}).Stim.visstimOffsets(kk)-45:allData.(filenames{ii}).Stim.visstimOffsets(kk)+45); 

    end 
    else
       continue 
    end
end 
%% 
%% 
%% 
%% 
for ii=1:length(filenames)
    W10.(filenames{ii}).trialIdx(W10.(filenames{ii}).trialIdx==0)=NaN

end 
colors=[0,1,0;1,0,0;0,0,1]

for ii=1:length(filenames)  %eyeArea
 figure
    for kk=1:length(W10.(filenames{ii}).orisUsed) %kk=3
        if contains(baseRoot,["W03"])  %%old version of facemap(no pims) for W03 read in shuffled blocks, issue w conversion script 
            mm=length(W10.(filenames{ii}).orisUsed)+1-kk;
        else 
            mm=kk;
        end 
        tempIdx = W10.(filenames{ii}).trialIdx(mm,:);
        tempidx=tempIdx(~isnan(tempIdx));
        tempStart=NaN(length(W10.(filenames{ii}).trialIdx(mm,:)),win);
        tempStart=W10.(filenames{ii}).eyeTrialsStart(tempidx,:);
        
        label = strcat('Trials',num2str(round(W10.(filenames{ii}).orisUsed)));
subplot(2,1,1)  
shadedErrorBar(1:size(tempStart,2),tempStart,{@nanmean,@(x) nanstd(x)/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});

        hold on
%         xline(x1,'-','DisplayName','Trial Onset')
title([filenames{ii},'_eyeArea Trial Onset'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('PupilArea - pixels')
        x3=45;
        x2=30;
    legend(label,'FontSize',7,'Location','northwest','AutoUpdate','off')   
%      xline(x2,'-','DisplayName','Trial Offset')
%     xlimit=get(gcf,'XLim');
   
    end  
    %%%%%%%%%%%%%%%%%%%  
    ylimit=get(gca, 'YLim');
    ylimit=[round(ylimit(1)*0.95), round(ylimit(2)*1.05)]
    ylimit=get(gca, 'YLim');
    xlim([0 92])
    x_points = [0, 0, x2, x2];  

    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 0, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.06;
    hold off

    x_points = [x2, x2, win, win];  
    color = [0, 1, 0.5];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.05;
    
    txt = {'Pre-Stimulus';' (baseline)'};
    text(x2-20,ylimit(1)*1.2+2,txt,'FontSize', 8)
    
    txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x2+10,ylimit(2)*.95,txt2,'FontSize', 8)
    hold off
    
     for kk=1:length(W10.(filenames{ii}).orisUsed) %kk=3
        if contains(baseRoot,["W03"])  %%old version of facemap(no pims) for W03 read in shuffled blocks, issue w conversion script 
            mm=length(W10.(filenames{ii}).orisUsed)+1-kk;
        else 
            mm=kk;
        end 
        tempIdx = W10.(filenames{ii}).trialIdx(mm,:);
        tempidx=tempIdx(~isnan(tempIdx));
        tempEnd=NaN(length(W10.(filenames{ii}).trialIdx(mm,:)),win);
        tempEnd=W10.(filenames{ii}).eyeTrialsEnd(tempidx,:);
   subplot(2,1,2)  
   shadedErrorBar(1:size(tempEnd,2),tempEnd,{@nanmean,@(x) nanstd(x)/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});

      hold on
        xline(x3,'-','DisplayName','Trial Offset')
title([filenames{ii},'_eyeArea Trial Offset'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('PupilArea - pixels')
        x3=45;
        x2=30;      
    xlim([0 92])
      
    end
           ylimit=get(gca, 'YLim');
  y2=[round(ylimit(1)*0.95), round(ylimit(2)*1.05)];
  ylimit=get(gca, 'YLim');
        txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x3-40,ylimit(2)*.95,txt2,'FontSize', 8)
    txt3 = {'        Outcome   ' ;'(unconditioned  response)'};
    text(x3+15,ylimit(1)*1.2+2,txt3,'FontSize', 8)
     x_points = [x3, x3, win, win];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, .5, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.08;
  clear ylimit ylim y_points
   hold off

    ft=[foldereye,'\',['OnsetOffset',filenames{ii},'_eyeArea'],'.png'];
    saveas(gcf,(ft))
end




clear  y2 

for ii=1:length(filenames)  %motSVD
 figure
    for kk=1:length(W10.(filenames{ii}).orisUsed) %kk=3
%         if contains(baseRoot,["W03"])  %%old version of facemap(no pims) for W03 read in shuffled blocks, issue w conversion script 
%             mm=length(W10.(filenames{ii}).orisUsed)+1-kk;
%         else 
            mm=kk;
%         end 
        tempIdx = W10.(filenames{ii}).trialIdx(mm,:);
        tempidx=tempIdx(~isnan(tempIdx));
        tempStart=NaN(length(W10.(filenames{ii}).trialIdx(mm,:)),win);
        tempStart=W10.(filenames{ii}).motSVDTrialsStart(tempidx,:);
        
        label = strcat('Trials',num2str(round(W10.(filenames{ii}).orisUsed)));
subplot(2,1,1)  
shadedErrorBar(1:size(tempStart,2),tempStart,{@nanmean,@(x) nanstd(x)/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});

        hold on
%         xline(x1,'-','DisplayName','Trial Onset')
title([filenames{ii},'_motSVD Trial Onset'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('motSVD PC0')
        x3=45;
        x2=30;
    legend(label,'FontSize',7,'Location','northwest','AutoUpdate','off')   
%      xline(x2,'-','DisplayName','Trial Offset')
%     xlimit=get(gcf,'XLim');
   
    end  
    %%%%%%%%%%%%%%%%%%%  
        ylimit=get(gca, 'YLim');
        ylimit=[round(ylimit(1)*0.95) round(ylimit(2)*1.05)]
    x_points = [0, 0, x2, x2];  
    ylimit=get(gca, 'YLim');
    xlim([0 92])

    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 0, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.06;
    hold off

    x_points = [x2, x2, win, win];  
    color = [0, 1, 0.5];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.05;
    
    txt = {'Pre-Stimulus';' (baseline)'};
    text(x2-20,ylimit(1)*1.2+2,txt,'FontSize', 8)
    
    txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x2+10,ylimit(2)*.95,txt2,'FontSize', 8)
    hold off
    
     for kk=1:length(W10.(filenames{ii}).orisUsed) %kk=3
%         if contains(baseRoot,["W03"])  %%old version of facemap(no pims) for W03 read in shuffled blocks, issue w conversion script 
%             mm=length(W10.(filenames{ii}).orisUsed)+1-kk;
%         else 
            mm=kk;
%         end 
        tempIdx = W10.(filenames{ii}).trialIdx(mm,:);
        tempidx=tempIdx(~isnan(tempIdx));
        tempEnd=NaN(length(W10.(filenames{ii}).trialIdx(mm,:)),win);
        tempEnd=W10.(filenames{ii}).motSVDTrialsEnd(tempidx,:);
   subplot(2,1,2)  
   shadedErrorBar(1:size(tempEnd,2),tempEnd,{@nanmean,@(x) nanstd(x)/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});

      hold on
       xline(x3,'-','DisplayName','Trial Offset')
    title([filenames{ii},'_motSVD'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('motSVD PC0')
        x3=45;
        x2=30;      
    xlim([0 92])
      
    end
           ylimit=get(gca, 'YLim');
  y2=[round(ylimit(1)*0.95) round(ylimit(2)*1.05)];
       ylimit=get(gca, 'YLim');
        txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x3-40,ylimit(2)*.95,txt2,'FontSize', 8)
    txt3 = {'        Outcome   ' ;'(unconditioned  response)'};
    text(x3+15,ylimit(1)*1.2+2,txt3,'FontSize', 8)
     x_points = [x3, x3, win, win];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, .5, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.08;
  clear ylimit ylim y_points
   hold off

    ft=[foldermot,'\',['OnsetOffset',filenames{ii},'_motSVD'],'.png'];
    saveas(gcf,(ft))
end


clear ylim y2
for ii=1:length(filenames)  %running
 figure
    for kk=1:length(W10.(filenames{ii}).orisUsed) %kk=3
%         if contains(baseRoot,["W03"])  %%old version of facemap(no pims) for W03 read in shuffled blocks, issue w conversion script 
%             mm=length(W10.(filenames{ii}).orisUsed)+1-kk;
%         else 
            mm=kk;
%         end 
        tempIdx = W10.(filenames{ii}).trialIdx(mm,:);
        tempidx=tempIdx(~isnan(tempIdx));
        tempStart=NaN(length(W10.(filenames{ii}).trialIdx(mm,:)),win);
        tempStart=W10.(filenames{ii}).runningStart(tempidx,:);
        
        label = strcat('Trials',num2str(round(W10.(filenames{ii}).orisUsed)));
subplot(2,1,1)  
shadedErrorBar(1:size(tempStart,2),tempStart,{@nanmean,@(x) nanstd(x)/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});

        hold on
%         xline(x1,'-','DisplayName','Trial Onset')
title([filenames{ii},'_Running Trial Onset'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('running velocity')
        x3=45;
        x2=30;
    legend(label,'FontSize',7,'Location','northwest','AutoUpdate','off')   
%      xline(x2,'-','DisplayName','Trial Offset')
%     xlimit=get(gcf,'XLim');
   
    end  
    %%%%%%%%%%%%%%%%%%%  
        ylimit=get(gca, 'YLim');
    x_points = [0, 0, x2, x2];  
    ylimit=get(gca, 'YLim');
    xlim([0 92])

    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 0, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.06;
    hold off

    x_points = [x2, x2, win, win];  
    color = [0, 1, 0.5];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.05;
    
    txt = {'Pre-Stimulus';' (baseline)'};
    text(x2-20,ylimit(1)*1.2+2,txt,'FontSize', 8)
    
    txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x2+10,ylimit(2)*.95,txt2,'FontSize', 8)
    hold off
    
     for kk=1:length(W10.(filenames{ii}).orisUsed) %kk=3
%         if contains(baseRoot,["W03"])  %%old version of facemap(no pims) for W03 read in shuffled blocks, issue w conversion script 
%             mm=length(W10.(filenames{ii}).orisUsed)+1-kk;
%         else 
            mm=kk;
%         end 
        tempIdx = W10.(filenames{ii}).trialIdx(mm,:);
        tempidx=tempIdx(~isnan(tempIdx));
        tempEnd=NaN(length(W10.(filenames{ii}).trialIdx(mm,:)),win);
        tempEnd=W10.(filenames{ii}).runningEnd(tempidx,:);
   subplot(2,1,2)  
   shadedErrorBar(1:size(tempEnd,2),tempEnd,{@nanmean,@(x) nanstd(x)/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});

      hold on
       xline(x3,'-','DisplayName','Trial Offset')
    title([filenames{ii},'_running'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('running velocity')
        x3=45;
        x2=30;      
    xlim([0 92])
      
    end
           ylimit=get(gca, 'YLim');
        ylimit=get(gca, 'YLim');
        txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x3-40,ylimit(2)*.95,txt2,'FontSize', 8)
    txt3 = {'        Outcome   ' ;'(unconditioned  response)'};
    text(x3+15,ylimit(1)*1.2+2,txt3,'FontSize', 8)
     x_points = [x3, x3, win, win];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, .5, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.08;
  clear ylimit ylim y_points
   hold off

    ft=[folderrun,'\',['OnsetOffset',filenames{ii},'_running'],'.png'];
    saveas(gcf,(ft))
end



for ii=1:length(filenames)  %licking
 figure
    for kk=1:length(W10.(filenames{ii}).orisUsed) %kk=3
        
            mm=kk;
         
        tempIdx = W10.(filenames{ii}).trialIdx(mm,:);
        tempidx=tempIdx(~isnan(tempIdx));
        tempStart=NaN(length(W10.(filenames{ii}).trialIdx(mm,:)),win);
        tempStart=W10.(filenames{ii}).lickingStart(tempidx,:);
        
        label = strcat('Trials',num2str(round(W10.(filenames{ii}).orisUsed)));
subplot(2,1,1)  
shadedErrorBar(1:size(tempStart,2),tempStart,{@nanmean,@(x) nanstd(x)/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});

        hold on
%         xline(x1,'-','DisplayName','Trial Onset')
title([filenames{ii},'_Running Trial Onset'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('Licks')
        x3=45;
        x2=30;
    legend(label,'FontSize',7,'Location','northwest','AutoUpdate','off')   
%      xline(x2,'-','DisplayName','Trial Offset')
%     xlimit=get(gcf,'XLim');
   
    end  
    %%%%%%%%%%%%%%%%%%%  
        ylimit=get(gca, 'YLim');
    x_points = [0, 0, x2, x2];  
    ylimit=get(gca, 'YLim');
    xlim([0 92])

    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, 0, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.06;
    hold off

    x_points = [x2, x2, win, win];  
    color = [0, 1, 0.5];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.05;
    
    txt = {'Pre-Stimulus';' (baseline)'};
    text(x2-20,ylimit(1)*1.2+2,txt,'FontSize', 8)
    
    txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x2+10,ylimit(2)*.95,txt2,'FontSize', 8)
    hold off
    
     for kk=1:length(W10.(filenames{ii}).orisUsed) %kk=3
        
            mm=kk;
        tempIdx = W10.(filenames{ii}).trialIdx(mm,:);
        tempidx=tempIdx(~isnan(tempIdx));
        tempEnd=NaN(length(W10.(filenames{ii}).trialIdx(mm,:)),win);
        tempEnd=W10.(filenames{ii}).lickingEnd(tempidx,:);
   subplot(2,1,2)  
   shadedErrorBar(1:size(tempEnd,2),tempEnd,{@nanmean,@(x) nanstd(x)/sqrt(size(x,1))},'lineprops', {'color', colors(kk,:)});

      hold on
       xline(x3,'-','DisplayName','Trial Offset')
    title([filenames{ii},'_licking'],'Interpreter', 'none')
        xlabel('Frames')
        ylabel('Licks')
        x3=45;
        x2=30;      
    xlim([0 92])
      
    end
           ylimit=get(gca, 'YLim');
        ylimit=get(gca, 'YLim');
        txt2 = {'Visual Stimulus ON (predictive cue)'};
    text(x3-40,ylimit(2)*.95,txt2,'FontSize', 8)
    txt3 = {'        Outcome   ' ;'(unconditioned  response)'};
    text(x3+15,ylimit(1)*1.2+2,txt3,'FontSize', 8)
     x_points = [x3, x3, win, win];  
    y_points = [ylimit(1), ylimit(2), ylimit(2), ylimit(1)];
    color = [0, .5, 1];
    hold on;
    a = fill(x_points, y_points, color);
    a.FaceAlpha = 0.08;
  clear ylimit ylim y_points
   hold off

    ft=[folderlick,'\',['OnsetOffset',filenames{ii},'_licking'],'.png'];
    saveas(gcf,(ft))
end



%% create reference images, save as tiff 

% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % sz=[size(AllWarpFields{1}{1})]
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % edges= [20, 20, 10, 10];
% % % % % % % % % % % % % % % % AWFbackup=AWF;
% % % % % % % % % % % % % % % % for ii=1:length(AllWarpFields)    
% % % % % % % % % % % % % % % % %                 Buffer = zeros(512,796);
% % % % % % % % % % % % % % % %         cols_remove_l = edges(1);
% % % % % % % % % % % % % % % %         cols_remove_r = edges(2);
% % % % % % % % % % % % % % % %         rows_remove_top = edges(3);
% % % % % % % % % % % % % % % %         rows_remove_bottom = edges(4);
% % % % % % % % % % % % % % % %         col_buffer_r = zeros(492,cols_remove_r,2);  
% % % % % % % % % % % % % % % %         col_buffer_l = zeros(492,cols_remove_r,2);  
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % %         % now buffer back in both dimensions
% % % % % % % % % % % % % % % %         WarpField = [col_buffer_l AllWarpFields{1,ii}{1,ii} col_buffer_r];
% % % % % % % % % % % % % % % %         row_buffer_top = zeros(rows_remove_top, size(WarpField,2), ...
% % % % % % % % % % % % % % % %                            size(WarpField,3));
% % % % % % % % % % % % % % % %         row_buffer_bottom = zeros(rows_remove_bottom, size(WarpField,2), ...
% % % % % % % % % % % % % % % %                            size(WarpField,3));
% % % % % % % % % % % % % % % %         WarpField = [row_buffer_top; WarpField; row_buffer_bottom];
% % % % % % % % % % % % % % % %         AllWarpFields{1,ii}{1,ii}=WarpField
% % % % % % % % % % % % % % % % end 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % sz=[size(AllWarpFields{1}{1})]
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % Get all masks for all days
% % % % % % % % % % % % % % % % % masks_original = zeros(sz(1), sz(2), length(AllWarpFields)); %changed from final_dates
% % % % % % % % % % % % % % % % % for i = 1:length(obj.final_dates)
% % % % % % % % % % % % % % % % %     date = obj.final_dates(i);
% % % % % % % % % % % % % % % % %     run = obj.final_runs{i}(end);
% % % % % % % % % % % % % % % % %     simp = pipe.load(obj.mouse, date, run, 'simpcell', ...
% % % % % % % % % % % % % % % % %                obj.pars.server);
% % % % % % % % % % % % % % % % %     masks_original(:,:,i) = (simp.masks');
% % % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % for mm=1:length()
% % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % for mm=1:length(obj.dffDirs)
% % % % % % % % % % % % % % % % testData=load(char(obj.dffDirs{mm}))
% % % % % % % % % % % % % % % % cellIdx=find(testData.suite2pData.iscell(:,1)==1)
% % % % % % % % % % % % % % % % for ii=1:length(cellIdx)
% % % % % % % % % % % % % % % %     emptyMat=zeros(size(testData.suite2pData.ops.meanImg,1),size(testData.suite2pData.ops.meanImg,2));
% % % % % % % % % % % % % % % %         emptyMat2=zeros(size(testData.suite2pData.ops.meanImg,1),size(testData.suite2pData.ops.meanImg,2));
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % %    for kk=1:length(testData.suite2pData.stat{1,cellIdx(ii)}.xpix)
% % % % % % % % % % % % % % % %    
% % % % % % % % % % % % % % % %    emptyMat(testData.suite2pData.stat{1,cellIdx(ii)}.ypix(kk),testData.suite2pData.stat{1,cellIdx(ii)}.xpix(kk))=testData.suite2pData.stat{1,cellIdx(ii)}.lam(kk);
% % % % % % % % % % % % % % % %    emptyMat2(testData.suite2pData.stat{1,cellIdx(ii)}.ypix(kk),testData.suite2pData.stat{1,cellIdx(ii)}.xpix(kk))=ii;
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % %    end 
% % % % % % % % % % % % % % % %    ROIs(:,:,ii)=emptyMat;
% % % % % % % % % % % % % % % %    ROIs2(:,:,ii)=emptyMat2;
% % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % masks_original{mm}(:,:,:)= ROIs;
% % % % % % % % % % % % % % % % masks_original2(:,:,mm)=sum(ROIs,3);
% % % % % % % % % % % % % % % % masks_original3(:,:,mm)=sum(ROIs2,3);
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % clear ROIs ROIs2 emptyMat cellIdx emptyMat2 
% % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % masks_original2=round(masks_original2)
% % % % % % % % % % % % % % % % test2=sum(ROIs2,3);
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % figure
% % % % % % % % % % % % % % % % imshow(emptyMat2,[])
% % % % % % % % % % % % % % % % unique(nonzeros(test2))
% % % % % % % % % % % % % % % % % Unpack all masks into filtermask tensors and 
% % % % % % % % % % % % % % % % % flattened warped masks
% % % % % % % % % % % % % % % %     best_day=1
% % % % % % % % % % % % % % % %     obj.warpfields = AllWarpFields{best_day};
% % % % % % % % % % % % % % % % %changed from 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % filtermasks = {};
% % % % % % % % % % % % % % % % masks_warped = zeros(sz(1), sz(2), length(obj.dffDirs)); 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % figure
% % % % % % % % % % % % % % % % imshow(warp_mask,[])
% % % % % % % % % % % % % % % % test=AllWarpFields{4}{5};
% % % % % % % % % % % % % % % % figure
% % % % % % % % % % % % % % % % imshow(test(:,:,1),[])
% % % % % % % % % % % % % % % % for i = 1:length(AllWarpFields) %% originally final_dates
% % % % % % % % % % % % % % % %     masks = masks_original3(:,:,i);
% % % % % % % % % % % % % % % %     top_ind = round(max(masks(:)));
% % % % % % % % % % % % % % % %     masks_tensor = zeros(top_ind, sz(1), sz(2));
% % % % % % % % % % % % % % % %     for k = 1:top_ind
% % % % % % % % % % % % % % % %         bin_mask = masks == k;
% % % % % % % % % % % % % % % %         warp_mask = imwarp(bin_mask, obj.warpfields{i});
% % % % % % % % % % % % % % % %         warp_mask = warp_mask > 0;
% % % % % % % % % % % % % % % %         % Add a fabricated pixel to the top row of the image
% % % % % % % % % % % % % % % %         % if there is no mask. Ziv cannot handle empties
% % % % % % % % % % % % % % % %         if sum(warp_mask(:)) == 0
% % % % % % % % % % % % % % % % %             disp(['Empty mask in day ' ...
% % % % % % % % % % % % % % % % %                   num2str(obj.dffDirs{i}) ...
% % % % % % % % % % % % % % % % %                   ', ROI index ' num2str(k) ...
% % % % % % % % % % % % % % % % %                   ', adding fake pixel...']);
% % % % % % % % % % % % % % % %             fake_pixel_ind = randi([1 sz(2)], 1, 1);
% % % % % % % % % % % % % % % %             warp_mask(1, fake_pixel_ind) = 1;
% % % % % % % % % % % % % % % %         end
% % % % % % % % % % % % % % % %         masks_tensor(k,:,:) = warp_mask;
% % % % % % % % % % % % % % % %         masks_warped(:,:,i) = masks_warped(:,:,i).*(warp_mask == 0);
% % % % % % % % % % % % % % % %         masks_warped(:,:,i) = masks_warped(:,:,i) + (warp_mask.*k);
% % % % % % % % % % % % % % % %     end
% % % % % % % % % % % % % % % %     filtermasks{i} = masks_tensor; 
% % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % populate properties
% % % % % % % % % % % % % % % % obj.masks_original = masks_original3;
% % % % % % % % % % % % % % % % obj.masks_warped = masks_warped;
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % %% 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % %% Across Days Graphs
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % for ii=1:length(uniqueOris{1,1})
% % % % % % % % % % % % % % % % label=strcat('Trials',num2str(round(uniqueOris{1,1}(ii))))
% % % % % % % % % % % % % % % % byOri.(label)=[]
% % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % oriidxName=fieldnames(byOri)
% % % % % % % % % % % % % % % % for ii=1:length(oriidxName)
% % % % % % % % % % % % % % % %     for kk=1:length(filenames)
% % % % % % % % % % % % % % % %         t=strcat('Day',num2str(kk));
% % % % % % % % % % % % % % % %         
% % % % % % % % % % % % % % % %     byOri.(oriidxName{ii}).eye.(t)=[];
% % % % % % % % % % % % % % % %     byOri.(oriidxName{ii}).mot.(t)=[];
% % % % % % % % % % % % % % % %     byOri.(oriidxName{ii}).lick.(t)=[];
% % % % % % % % % % % % % % % %     byOri.(oriidxName{ii}).run.(t)=[];
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % %     end 
% % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % %% 
% % % % % % % % % % % % % % % % for kk=1:length(oris)
% % % % % % % % % % % % % % % %     oriIDX(kk,:)=find(oris{:}==(oris{kk}))
% % % % % % % % % % % % % % % % end 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % for ii=1:length(oris)
% % % % % % % % % % % % % % % % for kk=1:length(oris{ii})
% % % % % % % % % % % % % % % % days = cellfun(@(x)isequal(x,oris{1,1}(kk)),oris);
% % % % % % % % % % % % % % % % dayOriIdx(ii,kk) = find(days)
% % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % %  for kk=1:length(W10.(filenames{ii}).orisUsed)
% % % % % % % % % % % % % % % %         tempIdx = W10.(filenames{ii}).trialIdx(kk,:);
% % % % % % % % % % % % % % % %         tempidx=tempIdx(~isnan(tempIdx));
% % % % % % % % % % % % % % % %         temp=NaN(length(W10.(filenames{ii}).trialIdx(kk,:)),stimLength(ii)+1);
% % % % % % % % % % % % % % % %         temp=W10.(filenames{ii}).eyeTrialsext(tempidx,:);
% % % % % % % % % % % % % % % %         
% % % % % % % % % % % % % % % % for kk=1:length(oris{ii})
% % % % % % % % % % % % % % % %         temp=find(allData.(filenames{ii}).suite2pData.Stim.oriTrace==W10.(filenames{ii}).orisUsed(kk))
% % % % % % % % % % % % % % % %       W10.(filenames{ii}).trialIdx(kk,1:length(temp))=temp;
% % % % % % % % % % % % % % % %     end 
% % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % 







%% 

%        options,'color_area' 
%         
%         eyePupil(ii)=nanmean(temp) %gives mean over timecourse
% 
% SEM(ii) = std(temp,2)./sqrt(size(temp,2));        
%         end 
% end 
% figure
% bar(temp)
% 
% end 
% %% 
% errhigh = [2.1 4.4 0.4 3.3 2.5 0.4 1.6 0.8 0.6 0.8 2.2 0.9 1.5];
% errlow  = [4.4 2.4 2.3 0.5 1.6 1.5 4.5 1.5 0.4 1.2 1.3 0.8 1.9];
% bar(x,data)                
% 
% hold on
% 
% er = errorbar(x,data,errlow,errhigh);    
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';  
% 
% hold off
% 
% 
% 
% 
% figure
% for kk=1:length(conds_used)
% % subplot(num_cond,1,kk)
% shadedErrorBar(frames,response.(responseIdx{kk}),{@mean,@(x) std(x)/sqrt(size(x,1))});
% % [h,p] = ttest(x,y)
% % avgBefore=mean(response.(responseIdx{kk})(:,trialBefore),2);
% % avgDuring=mean(response.(responseIdx{kk})(:,trialDuring),2);
% % [~,p]=ttest(avgBefore,avgDuring);
% temp=num2str(conds_used(kk));
% % temp2=[temp,' p=',num2str(p)];
% hold on
% % xlabel(temp2);
% plot([tim tim],ylim,'Color','g');
% plot([(tim+num_timepts) (tim+num_timepts)],ylim,'Color','g');
% legend
% sgtitle([Stim.mouse,' ',num2str(Stim.date),' ',num2str(ss),' cell#',num2str(cell_num),' Avg Trial Response by Ori']);
% end
% end %%%take this one out
% end
% ft=[folder,'\','meanTimecourse','\',Stim.mouse,'_',num2str(Stim.date),'_00',num2str(ss),'_','cell',num2str(cell_num),'_trialResponse','.jpeg'];
% saveas(gcf,(ft))



% for ii=1:length(filenames)
% for kk=1:length(oris{ii});
%     temp=strcat('Trials',num2str(round(oris{ii}(kk))))
%     W10.(filenames{ii}).(temp) = []
% end
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% for ii=1:7
% W10.(filenames1{ii}).eyeTrials=NaN(100,400)
% W10.(filenames1{ii}).eyeTria
% for ii=1:length(filenames)
% for kk=1:length(oris{ii});
%     W10.(filenames{ii}).oris = strcat('Trials',num2str(round(W10.(filenames{ii}).orientationsUsed(kk)))); %can't have .5 in there, will just have to remember... ughhh
% end
% endlsext=NaN(100,400)
% W10.(filenames1{ii}).motSVDTrials=NaN(100,400)
% W10.(filenames1{ii}).motSVDTrialsext=NaN(100,400)
% end 
% 
% 
% 
% figure
% bar(zeroTrials)
% title('pupilDiameter neutral cue')
% figure
% bar(twentyfivetrials)
% title('pupilDiameter Food Cue')
% 
% figure
% plot(twtwentyfivetrials)
% for ii=1:length(filenames)
% W10.(filenames{ii}).orientationsUsed(ii)=[]
% W10.(filenames{ii}).orientationsUsed(ii,:)=W10Data.(filenames{ii}).suite2pData.Stim.orientationsUsed(unique(W10Data.(filenames{ii}).suite2pData.Stim.oriTrace));
% %W10.(filenames{ii}).orientationsUsed=unique(W10Data.(filenames{ii}).suite2pData.Stim.oriTrace);
% end
% 
% for ii=1:length(filenames) 
% if length(W10.(filenames{ii}).Stim.visstimOnsets)>length(W10.(filenames{ii}).Stim.visstimOffsets);                 % Only taking through the vis stims that have onset+offset to avoid partial trials 
%     Stim.visstimOnsets= W10.(filenames{ii}).Stim.visstimOnsets(1:length( W10.(filenames{ii}).Stim.visstimOffsets));
% elseif length(W10.(filenames{ii}).Stim.visstimOnsets)<length(W10.(filenames{ii}).Stim.visstimOffsets);             % Some files may have "offset" when first starting visstim when screen is blank 
%         Stim.visstimOffsets=W10.(filenames{ii}).Stim.visstimOffsets(2:length(W10.(filenames{ii}).Stim.visstimOffsets)); %So ignore 1st "offset"
% end 
% for kk=1:length(Stim.visstimOnsets);                                        % finding length of all trials 
%     stimTime(kk)=Stim.visstimOffsets(kk)-Stim.visstimOnsets(kk);            % if trial lengths differ, you'll get indexing errors when isolating those timepoints into structures
% end 
% stimLength(ii)=round(mean(stimTime));
%  clear Stim
% end 
% 
% for ii=1:length(filenames)
% for kk=1:length(oris{ii});
%     W10.(filenames{ii}).oris = strcat('Trials',num2str(round(W10.(filenames{ii}).orientationsUsed(kk)))); %can't have .5 in there, will just have to remember... ughhh
%      W10.(filenames{ii}).trials.(oris) = [];
%      W10.(filenames{ii}).extendedtrials.(oris)=[]
%      W10.(filenames{ii}).idx.(oris)=find(W10.(filenames{ii}).suite2pData.Stim.oriTrace==W10.(filenames{ii}).orientationsUsed(kk));
% end
% end 
% 
% for ii=1:length(filenames)
% W10.(filenames{ii}).winLength=NaN(stimLength(ii),length( W10.(filenames{ii}).oris))
% end 
% 
% 
% % for ii=1:length(filenames)
% %     for kk=1:length(W10Data.(filenames{ii}).Stim.visstimOnsets)
% %    W10.(filenames{ii}).TrialsEye(kk,:)=...
% %        W10eye.(filenames{ii}). parea(W10Data.(filenames{ii}).Stim.visstimOnsets(kk):W10Data.(filenames{ii}).Stim.visstimOffsets(kk))
% %     end
% % end 

    
end