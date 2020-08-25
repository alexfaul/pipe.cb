function behaviorPlots(path,timeWin,altTitle)
%% I/O 
% path is full path of _stim (can also use .sbx) file
% timeWin is integer of seconds to isolate before and after stim
% altTitle='FC app Day 1';

% Outputs new folder with graphs generated here
%% Allow for alternate title in graphs (optional)
if nargin<3, altTitle=[]; end 
%% creating directory and additional extensions for necessary files

[fullRoot,filename,~] = fileparts(path);
folder                = [fullRoot,'\','behaviorPlots']; % create directory if it doesn't exist
if ~exist(folder, 'dir');
        mkdir(folder);
end

if   contains(path,'_stim')==1;
        root=extractBefore(path, '_stim');
else contains(path,'_stim')==0;
        root=path;
end 
dsNidaqPath     = [root '_dsnidaq.mat'];              % adding extension of native scanbox outputs
stimPath        = [root '_stim.mat']  ;
eyePath         = [root '_eye_area.mat'] ;
motSVDPath      = [root '_motSVD.mat'] ;

ext = 'dff.mat';
dffDir = findFILE(fullRoot,ext); %should come after running dff calculation so that you have the index positions of each run and the ops.xoff and ops.yoff
                                    % alternatively, 
%% Try loading all necessary variables

try  dsNidaq=load(dsNidaqPath);                  
        catch
        sprintf('Problem opening nidaq file %s %s %s, Please ensure downsampled nidaq has been created', mouse, date, run) %6f
        success = 0;
        return
end  

try  Stim=load(stimPath);
        catch
        sprintf('Problem opening Stim information %s %s %s, Please ensure _stim.mat file has been created', mouse, date, run) %6f
        success = 0;
        return
end
if isfield(Stim, 'spontaneous')
    return
    sprintf('No trials to trigger behavior plots on, this is a spontaneous run')
end


%% Creating behavior structure - loading non-critical data 
% (currently pupil area and motSVD)

%%% IMPORTANT %%%
%   You have to process videos in Facemap and then run 
%   Facemap processing.ipynb to get these data below

if isfile(eyePath)
    Beh=load(eyePath);
elseif ~isfile(eyePath);
    sprintf('No eye area from Facemap detected')
end 
if isfile(motSVDPath);
    load(motSVDPath);
    Beh.motsvd=motsvd;
    elseif ~isfile(motSVDPath);
    sprintf('No motionSVD from Facemap detected')
end
Beh.EMG=dsNidaq.EMG;                                                        %shit, what do we do about EMG?
if isfield(dsNidaq, 'runVel');
    Beh.runVel=dsNidaq.runVel;
end

if isempty(dffDir)==0 
    try dff=load(dffDir{:});
        Beh.xOff=dff.suite2pData.ops.xoff
        Beh.yOff=dff.suite2pData.ops.yoff
    catch
        sprintf('no dff file detected. No XY offsets will be computed. If imaging run, run dff calculation before running this script')
    end
end

behIdx=fieldnames(Beh); % fieldnames to loop through graph generation
clearvars -except Beh behIdx dsNidaq filename folder fullRoot motsvd Stim stimTime timeWin altTitle
%% finding visstim length
if length(Stim.visstimOnsets)>length(Stim.visstimOffsets);                 % Only taking through the vis stims that have onset+offset to avoid partial trials 
    Stim.visstimOnsets=Stim.visstimOnsets(1:length(Stim.visstimOffsets));
elseif length(Stim.visstimOnsets)<length(Stim.visstimOffsets);             % Some files may have "offset" when first starting visstim when screen is blank 
        Stim.visstimOffsets=Stim.visstimOffsets(2:length(Stim.visstimOffsets)); %So ignore 1st "offset"
end 

for kk=1:length(Stim.visstimOnsets);                                        % finding length of all trials 
    stimTime(kk)=Stim.visstimOffsets(kk)-Stim.visstimOnsets(kk);            % if trial lengths differ, you'll get indexing errors when isolating those timepoints into structures
end 
stimLength=round(mean(stimTime));                                           % find average stim tim
                                                                            % Doing this means that SOME trials off point may be +/-1, important for if we want to do t-test?
%% Making structure for behavior around Visstim time
for ii=1:length(Stim.orientationsUsed)  
        k=Stim.orientationsUsed(ii)
        field = strcat('Trials_',num2str(k));      %making struct to store all trials isolated by standardized time
        responseVis.(field)=[];                  %each replication starting points stored in structure
end
oriIdx=fieldnames(responseVis);

for k=1:length(Stim.orientationsUsed)
temp=Stim.orientationsUsed(k);
trialIdx.(oriIdx{k})=find(Stim.oriTrace==temp);
end 
%% inputting behavioral responses to Visstim into structure
for bb=1:length(behIdx)                                                     % loop through behaviors
    for k=1:length(oriIdx)                                                  % loop through all oris
    idxt=trialIdx.(oriIdx{k});                                              % do all trials for a particular ori (trial # varies)
    for ii=1:length(idxt)                                                   
        if (Stim.visstimOnsets(idxt(ii))+timeWin+stimLength)<length(Beh.EMG) % To adjust for end trials not having full length of stim Window
        if (Stim.visstimOnsets(idxt(ii))-timeWin>0)                          % to adjust for beginning trials not having enough before time for Stim Window
            responseVis.(oriIdx{k}).(behIdx{bb})(ii,:) = ...                 % grab correct onset times corresponding to the trial
            Beh.(behIdx{bb})(Stim.visstimOnsets(idxt(ii))-timeWin:Stim.visstimOnsets(idxt(ii))+stimLength+timeWin);
        end 
        end 
    end
    end 
end 
%% Allow custom titles (such as Day1 habituation etc)
if nargin==3
    ft=[folder,'\',Stim.mouse,'_',altTitle]
    figTitle=[dsNidaq.mouse,' ',altTitle,' ']
else
    ft=[folder,'\',Stim.mouse,'_',num2str(Stim.date),'_', num2str(dsNidaq.run)]
    figTitle=[dsNidaq.mouse,' ',num2str(dsNidaq.date),' ', num2str(dsNidaq.run),' ',]
end 
%% Great Idea:
% make graphing function that allows you to specify levels so you can look at graphs any number of ways
% would save so much re-coding.

% e.g. (behIdx,ori) would give oris nested w/in behaviors. (ori,behIdx) would give you behavior nested w/in oris
% Wouldn't be too difficult... 
% would massively improve below b/c it is clunky. Thoroughly debugged but
% clunky.
%% Making heatmaps for all present behaviors
for ii=1:length(behIdx)
    errBottom.(behIdx{ii})=prctile(Beh.(behIdx{ii}),5); %generating the error bars (bottom)
    errTop.(behIdx{ii})=prctile(Beh.(behIdx{ii}),95);
end 

for jj=1:length(behIdx)
figure
for kk=1:length(oriIdx)
colormap('hot')
subplot(length(oriIdx),1,kk)
imagesc(responseVis.(oriIdx{kk}).(behIdx{jj}))
temp=(oriIdx{kk});
xlabel(temp, 'Interpreter', 'none');
hold on
plot([timeWin timeWin],ylim,'Color','g');
plot([timeWin+stimLength timeWin+stimLength],ylim,'Color','g');
ylabel('Trials');
hold off
caxis manual
caxis([errBottom.(behIdx{jj}) errTop.(behIdx{jj})]);
colorbar
figName=[ft,'',(behIdx{jj}),'_oriHeatmap','.jpeg'];
end 
sgtitle([figTitle,(behIdx{jj}),' oriHeatmap','- Trial Response by Ori']);
saveas(gcf,(figName))
end
%% Making structure with behavioral responses to shock + associated heatmap
if ~isempty(Stim.shockOnsets)==1
    for bb=1:length(behIdx)
    for ii=1:length(Stim.shockOnsets);
        if (Stim.shockOnsets(ii)+timeWin)<length(dsNidaq.visstim)           %any signal length that will be consistently present will do here.
        responseShock.(behIdx{bb})(ii,:)=...
        Beh.(behIdx{bb})(Stim.shockOnsets(ii)-timeWin:Stim.shockOnsets(ii)+timeWin);
        end
    end     
    end
end

if ~isempty(Stim.shockOnsets)==1
figure
for kk=1:length(behIdx);
colormap('hot')
subplot(length(behIdx),1,kk)
imagesc(responseShock.(behIdx{kk}))
temp=behIdx{kk};
xlabel(temp);    
ylabel('Trials');
sgtitle([figTitle,' Behavioral Response after Shock'])
hold on
plot([timeWin timeWin],ylim,'Color','g')
plot([timeWin+2 timeWin+2],ylim,'Color','g')
colorbar
end
figName=[ft,'',' SHOCK','_behHeatmap','.jpeg']
saveas(gcf,(figName))
%%
timeVec=0:(timeWin+timeWin); %make time vector

%%%% ShErrBar for shock
figure
for mm=1:length(behIdx) %loop through all behaviors to be plotted
subplot(length(behIdx),1,mm)
shadedErrorBar(timeVec,...
    responseShock.(behIdx{mm}),{@mean,@(x) std(x)/sqrt(size(x,1))});
temp=behIdx{mm};
xlabel(temp,'Interpreter', 'none')
hold on
plot([timeWin timeWin],ylim); %
plot([timeWin+2 timeWin+2],ylim);
hold off
sgtitle([upper([behIdx{mm}]),' ',figTitle, ' shErrBar(sem) - Shock Behavior Response']);
figName=[ft,'','_shErrBarShock','.jpeg'];
saveas(gcf,(figName))
end
end 
%% Shaded Error Bars - behaviors by ori and behavior after shock
timeVec=0:(timeWin+stimLength+timeWin); %make time vector

for mm=1:length(behIdx) %loop through all behaviors to be plotted
figure
for kk=1:length(oriIdx) %loop through all oris presented
subplot(length(oriIdx),1,kk)
shadedErrorBar(timeVec,...
    responseVis.(oriIdx{kk}).(behIdx{mm}),{@mean,@(x) std(x)/sqrt(size(x,1))});
temp=oriIdx{kk};
xlabel(temp,'Interpreter', 'none')
hold on
plot([timeWin timeWin],ylim); %
plot([timeWin+stimLength timeWin+stimLength],ylim);
hold off
sgtitle([upper([behIdx{mm}]),' ',figTitle, ' shErrBar(sem) - Behavior Response by Ori']);
end
figName=[ft,'',(behIdx{mm}),'_shErrBar','.jpeg'];
saveas(gcf,(figName))
end


end 