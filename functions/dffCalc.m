function dffCalc(root,percentile,time_window,runNums,dffTreatment)
% 
 
% clearvars -except f0_115 f0_233 dff233 dff115 suite2pData tempdFF cellsort_batched_f f0_vector
%%
if nargin<3, time_window=30; end
if nargin<4, runNums=[]; end                    % optional, will default to assuming 1:1 nidaq to registered suite2p data unless frame # mismatch
if nargin<5, dffTreatment=2;end
% if nargin<6, skipDFF=0;end
%% prep for matching to nidaq files
% runNums=arrayfun(@(x) sprintf('%03d', mod(x,100)), runNums, 'UniformOutput', false);  
%% load in dff data
suite2pData = load(char(root)); % make it so the path is by the clicked cells
%% construct + load nidaq path
[fullRoot,~,~] = fileparts(root);
idcs   = strfind(fullRoot,filesep);
newdir = fullRoot(1:idcs(end-1)-1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement (ex: update of Suite2p that changes file locations)
    
    % should figure out how to make more robust w/out strict folder scheme from Suite2p (or auto generate names)
ext     = '_dsNidaq.mat';
nidaqDirs = findFILE(newdir,ext);

if isempty(nidaqDirs) %if previous directory is empty, go up one level
    nidaqDirs = findFILE(fullRoot(1:idcs(end-2)-1),ext);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement
end
if isempty(nidaqDirs)
    nidaqDirs = findFILE(fullRoot(1:idcs(end-3)-1),ext);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement
end

if isempty(nidaqDirs)
    sprintf('dsNidaq file not in expected location. Proceeding, but will abort if cant concatenate. Please move to folder above unregisteredTIFFs')
  return
    elseif ~isempty(nidaqDirs)
    dsnidaq = load(char(nidaqDirs{1}));
end
[newdir,~]=fileparts(nidaqDirs{1});
Filename=[newdir,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_',dsnidaq.run,'_','Suite2p_dff.mat'];
% 
% if isfile(Filename) 
%     load(Filename)
%     suite2pData.config=dsnidaq.config;
%     clearvars -except Filename suite2pData
%     save(Filename, '-struct', 'suite2pData');
% disp('File exists, appending missing fields')
% else ~isfile(Filename)
%% find number of frames in the run
nFrames=length(dsnidaq.frames2p);
suite2pData.config=dsnidaq.config;

%% Add check for multiple runs together, add correction - port to own function? TESTED EDGE CASES
% Clunky but reliable
if length(suite2pData.F)~=nFrames                                                   % If the length of traces doesn't equal the total # of frames in nidaq
    if isempty(runNums)                                                             % and user hasn't inputted custom runs to concat together... then,
    runConcat2(nidaqDirs,root,dffTreatment); %should be full path with Fall.mat extension
    runDirs=sort(runsConcatenate);                                          % dialog box to enter runs to cat together if not specified when called
    elseif ~isempty(runNums)  
    runDirs=nidaqDirs(find(contains(nidaqDirs,runNums)));
    end
   
   for ii=1:length(runDirs)
        [~,fname,~]=fileparts(runDirs{ii});                                     % runDirs has 
        dsNidaq.(fname)=load(runDirs{ii});   
        if isfield(dsNidaq.(fname), 'frames2p')
        % load each nidaqfile that matches user-input runs in a loop
        nFrames(ii)=length(dsNidaq.(fname).frames2p);   
        elseif isfield(dsNidaq.(fname), 'dsnidaq')
        datacell = struct2cell(dsNidaq.(fname).dsnidaq);
        dsNidaq.(fname) = cell2struct(datacell, fieldnames(dsNidaq.(fname).dsnidaq))
        nFrames(ii)=length(dsNidaq.(fname).frames2p);   
      
   end % get number of frames for each respective run so we can do neuropil on run-by run basis                                                                    % can be anything, just arbitrarily chose EEG
%         A = regexp(fname,'(?<=_).+?(?=_dsNidaq)','match')
%         temp=cellfun(@(x) x{1},A(cellfun('length',A)>0),'uniformoutput',0)

        temp=regexp(fname,'\d{3,3}','Match');
        runNums{ii}=char(temp(end));
   end

   
   for ii=1:length(runDirs)
        [~,fname,~]=fileparts(runDirs{ii});                                     % runDirs has 
        if ~isfield(dsNidaq.(fname), 'trialonsets')
        dsNidaq.(fname).trialonsets = find(diff(dsNidaq.(fname).visstim)>=1)+1';   %%% temp offset variable bc if trial is rewarded, the offset is wrong bc monkeylogic hates me
        dsNidaq.(fname).trialoffsetsTemp= find(diff(dsNidaq.(fname).visstim)<=-1)+1';  %All of these are +1 bc of fencepost of diff
        dsNidaq.(fname).ensureOnsets=find(diff(dsNidaq.(fname).ensure)>=1)+1';
        if ~isfield(dsNidaq.(fname),'ManualVisstimFix')
            dsNidaq.(fname).ManualVisstimFix=[];
            dsNidaq.(fname).ManualStartTime=[];
        end
        end 
   end 
   fields = fieldnames(dsnidaq);            %# Get the field names from the 1st loaded nidaq file
   runIdx = fieldnames(dsNidaq);            %# Get the run names of all runs relevant to the suite2p data registered together

   for ii=1:length(fields);
        concatenateddata.(fields{ii})=[];        % create empty structure to append all nidaq data to for desired runs
   end   
 %%%%%%%%%%%%%%%%%%%%  
   %Isolate a run, loop through all fields, 
   %skip the fields with duplicates (date, mousename etc) 
   %UNLESS it's shock or frames 2p 
   %(since processing can make arrays the same if no shock etc)
   for ii=1:length(runIdx)
        for kk = 1:length(fields);
        fname = fields{kk};    %%%%%%%%%%%%%%SKIP FIELDS THAT ARE IDENTIFICAL BETWEEN DSNIDAQS BEING CONCATENATED (mouse, date, etc) UNLESS THEYRE frames2p,shock,onset,and offsets (raw signals or conditions that may be the same still need to be appended so processing for each run independently can still happen
              if  ~isequal(dsNidaq.(runIdx{ii}).(fname),concatenateddata.(fname)) | strcmp(fname,'frames2p')==1 | strcmp(fname,'shock')| strcmp(fname,'onsetOffBy1')| strcmp(fname,'offsetOffBy1');                                   %if the info is the same, then skip. If it contains different info, then proceed with concatenation
            concatenateddata.(fname) = ...                                  
            horzcat(concatenateddata.(fname),dsNidaq.(runIdx{ii}).(fname));
              end 
        end
   end

   % adjusting timestamps - must have timestamps in column form for this to
   % work
   for ii=2:length(runDirs) 
      concatenateddata.timeStamps2p(:,ii)=concatenateddata.timeStamps2p(:,ii)+...
      (concatenateddata.timeStamps2p(end,ii-1));
   end
    % replace corrected timestamps
    concatenateddata.timeStamps2p=...
    reshape(concatenateddata.timeStamps2p,[1,sum(nFrames)]);
    dsnidaq=concatenateddata; 

 clearvars concatenateddata runsConcatenate idcs ii kk fname rundirs
end

%% Check length of nidaq + registered frames again
if sum(nFrames)~=length(suite2pData.F)
    if (abs(length(suite2pData.F)-sum(nFrames)))<3
        suite2pData.F=suite2pData.F(:,1:sum(nFrames))
        suite2pData.Fneu=suite2pData.Fneu(:,1:sum(nFrames))
        suite2pData.spks=suite2pData.spks(:,1:sum(nFrames))
    elseif (abs(length(suite2pData.F)-sum(nFrames)))>3
    error('Length mismatch between  registered frames and nidaq files, please check runs that were registered against nidaq files');
    end 
end
%% Calculating signal-to-noise ratio
Fs=suite2pData.ops.fs;
%SHOULD PROB JUST USE TIMESTAMPS FOR BELOW??
% time = 0:1/Fs:(length(suite2pData.F)/Fs); %making time vector for plotting
% tVec = time(1:end-1); %timepoint at which each ecg point corresponds, same length as signal

% n          = time_window/(1/Fs); %
% fac        = divisors(length(suite2pData.F)); %find even divisors to do rolling dff
% dist       = abs(fac - n);
% minDist    = min(dist);
% numSamples = fac(find(dist == minDist)); %number of samples can evenly divide

dffTemp = suite2pData.F-suite2pData.Fneu;
cellidx = find(suite2pData.iscell(:,1)==1);
dff     = dffTemp(cellidx,:);
neuropil= suite2pData.Fneu(cellidx,:);

suite2pData.Fneu=suite2pData.Fneu(cellidx,:);  %% only save the raw fluorescence and neuropil from cells that are cells
suite2pData.F=suite2pData.F(cellidx,:);
suite2pData.stat=suite2pData.stat{cellidx,:};

%check this

for ii=1:length(cellidx)
    suite2pData.snr(ii)=snr(suite2pData.F(cellidx(ii),:),...
    suite2pData.Fneu(cellidx(ii),:));
end 
clear dffTemp
%%  
if isempty(runNums)
    runNums={dsnidaq.run};
end
    endIdx    = cumsum(nFrames);                                    % Adjust - Find start and end idx of frame # corresponding to nidaq signal
    startIdx  = ([0,endIdx]+1);
    startIdx  = startIdx(1:length(endIdx));

 suite2pData.startIdx    = startIdx ;
 suite2pData.endIdx      = endIdx ;

 for ii=1:length(runNums)
npilmean(:,ii)= mean(neuropil(:,startIdx(ii):endIdx(ii)),2); % loop through by nFrames
end

%looping through to add respective neuropil between diff runs
for kk=1:size(npilmean,2)
for ii=1:size(npilmean,1)
tempdff= dff(:,startIdx(kk):endIdx(kk));                                    % isolating window of dff trace
dFFTemp(ii,startIdx(kk):endIdx(kk))=tempdff(ii,:)+npilmean(ii,kk);          % to add respective neuropil (based on run)
end 
end

clear fac dist minDist time n dff dffTemp ii
%% Rolling dFF
if length(runNums)>1
for ii=2:length(runNums)
 if ~isequal(length(dffTreatment),length(runNums)) %Unless otherwise specified, assume all treated same way
        dffTreatment(ii)=dffTreatment(ii-1)
 end 
end
end

for ii=1:length(runNums)
if dffTreatment(ii)==2
cellsort_batched_f=dFFTemp(:,startIdx(ii):endIdx(ii));
fr_number = size(cellsort_batched_f,2);
nROIs = size(cellsort_batched_f,1);

% Calculate f0 for each timecourse using a moving window of time window
% prior to each frame
f0_vector = zeros(nROIs,fr_number);
time_window_frame = round(time_window*dsnidaq.framerate(1));

for mm = 1:fr_number
    if mm <= time_window_frame
        frames = cellsort_batched_f(:,1:time_window_frame);
        f0 = prctile(frames,percentile,2);
    else
        frames = cellsort_batched_f(:,mm - time_window_frame:mm-1);
        f0 = prctile(frames,percentile,2);
    end
    f0_vector(:,mm) = f0;
end 

suite2pData.dFF(:,startIdx(ii):endIdx(ii)) = (cellsort_batched_f-f0_vector)./ f0_vector;


%percentile
elseif dffTreatment(ii)==1;
    df=dFFTemp(:,startIdx(ii):endIdx(ii));
  f0 = prctile(df,percentile,2);
  suite2pData.dFF(:,startIdx(ii):endIdx(ii)) = (df-f0)./f0; %start and end idx of whole run (trials not considered here)
end
end 
suite2pData.cellIdx=cellidx;
%% attach mean Image
fname=[path '\' temp]
for kk=0:(endIdx(ii)-1)
image=sbxread(fname,ii,1);
meanImg(ii+1)=mean(image(:));
clear image
end
%% calculate AUC
for ii=1:length(startIdx)
   temp= suite2pData.dFF(:,startIdx(ii):endIdx(ii));
suite2pData.AUC(:,ii)=trapz(temp,2); % not normalized by length SO IF COMPARING BETWEEN DIFF DAYS, MAKE SURE TO NORMALIZE BY LENGTH!
end 
suite2pData.percentiledFF=percentile;
suite2pData.nidaqAligned=dsnidaq;
suite2pData.nidaqAligned.startIdx=suite2pData.startIdx;
suite2pData.nidaqAligned.endIdx=suite2pData.endIdx;
%% generate graphs

    aucTEMP=suite2pData.AUC;
    
    figure('Units','normalized','Position',[0 0 1 1])
    titleTEMP=['AUC-',char(dsnidaq.mouse), '_', num2str(dsnidaq.date), '_', char(dsnidaq.run)];
    [B,~] = sort(aucTEMP,'descend') ;
    subplot(1,3,1);
    plot(aucTEMP)
    title('AUC, unsorted')
    subplot(1,3,2)
    plot(B)
    title('AUC, sorted')
    subplot(1,3,3)
    histogram(aucTEMP,30)
    title('AUC, histogram')
    sgtitle(titleTEMP, 'Interpreter', 'none')  
 
idcs   = strfind(newdir,filesep);
savePath = newdir(1:idcs(end)-1); 
ft=[savePath,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_',dsnidaq.run,'_AUC','.jpeg'];
saveas(gcf,(ft))
 %% DBSCAN %% 
 %%%%%%%%%%%%%%%%%%%%%%%%
 
X=std(suite2pData.dFF,0,2);

idx = dbscan(X,1,10); % The default distance metric is Euclidean distance
[B, I]=sort(X,'descend');

suite2pData.possibleOutlier_stdev=I(B>1.5);
suite2pData.possibleOutlier_dbscan=find(idx==-1);

figure
for ii=1:length(suite2pData.possibleOutlier_stdev)
    plot(suite2pData.dFF(suite2pData.possibleOutlier_stdev(ii),:)+(ii*2))
    hold on
end
hold off

%figure
%gscatter(suite2pData.dFF,idx);
%title('DBSCAN Using Euclidean Distance Metric');
%% run stimTimes to append to nidaq data
% suite2pData.nidaqAligned.visstim(startIdx(1):endIdx(1))=1
[Stim,suite2pData.nidaqAligned]=alignStim(suite2pData.nidaqAligned,runNums, newdir); %%% check alignStim adjustment
suite2pData.Stim=Stim
Stim.nidaqAligned=suite2pData.nidaqAligned;
% figure
% plot(dsnidaq.visstim(startIdx(2):endIdx(2)))
%% Separate by trials and find bias


[suite2pData.dffTrials,suite2pData.baselineTrials, suite2pData.statsT]=...
    separateByTrialsDff(suite2pData,savePath,time_window);
suite2pData.bias=biasDet(suite2pData.dffTrials,suite2pData.baselineTrials,savePath,suite2pData.statsT) ;
%% Save struct
Filename=[newdir,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_',dsnidaq.run,'_','Suite2p_dff.mat'];
save(Filename, 'suite2pData','-v7.3','-nocompression');
% filename=[newdir,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_',dsnidaq.run,'_','Stim.mat']; 
% save (filename, 'Stim', '-v7.3','-nocompression')
%end
end 
 