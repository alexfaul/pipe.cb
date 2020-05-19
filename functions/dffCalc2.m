function dffCalc(root,percentile,time_window,runNums,dffTreatment)
if nargin<3, time_window=60; end
if nargin<4, runNums=[]; end                    % optional, will default to assuming 1:1 nidaq to registered suite2p data
if nargin<5, dffTreatment=1;end
% runNums=(1:2) 


suite2pData = load(char(root)); % make it so the path is by the clicked cells
% if it is a 1:1 run to suite2p ratio, enter nothing here. Or do, just pointless           
[fullRoot,filename,~] = fileparts(root);
%move up four divisions
% extractBefore();
% idcs   = strfind(root,filesep);
% newdir = root(1:idcs(end-3)-1); %expects to be in 


% ext     = '_stim.mat'
% stimDirs = findFilePathAF(newdir,ext);
% Stim = load(char(stimDirs{1}));
clear ext
ext2     = '_dsNidaq.mat';
nidaqDirs = findFilePathAF(fullRoot,ext2);
dsnidaq = load(char(nidaqDirs{1}));
%% get dsnidaq data loaded
% % if   contains(root,'_stim')==1;
% %         root=extractBefore(root, '_stim');
% % else contains(root,'_stim')==0;
% %         root=root;
% % end 
% % dsNidaqPath = [root '_dsnidaq.mat'];   
% % dsnidaq     = load(dsNidaqPath);
% % clear ext
%% find number of frames in the run
nFrames=length(dsnidaq.frames2p);

%% Add check for multiple runs together, add correction - port to own function?
if length(suite2pData.F)~=nFrames  
    if isempty(runNums)
    runConcat(nidaqDirs,fullRoot); runsConcatenate=sort(runsConcatenate);           % dialog box to enter runs to cat together if not specified when called
    runNums=runsConcatenate;
    else
    runNums=arrayfun(@(x) sprintf('%03d', mod(x,100)), runNums, 'UniformOutput', false);  
    end
   
 % Find full path of all dsNidaq files in the directory the cell clicked imaging data comes from  
                                                
  ext2='_dsNidaq.mat';
  rundirs=findFilePathAF(fullRoot,ext2);   
  runDirs=rundirs(find(contains(rundirs,runNums)));   % isolate nidaq files matching the runs manually specified
    
  if length(runNums)~=length(runDirs)
        sprintf('Cannot find nidaq files for all runs associated with Fall.mat file')
        return
  end
  
for ii=1:length(runDirs)
    [~,fname,~]=fileparts(runDirs{ii});                             % runDirs has 
    dsNidaq.(fname)=load(runDirs{ii});                              % load each nidaqfile that matches user-input runs in a loop
    nFrames(ii)=length(dsNidaq.(fname).frames2p);                        % get number of frames for each respective run so we can do neuropil on run-by run basis
                                                                    % can be anything, just arbitrarily chose EEG
end

fields = fieldnames(dsnidaq);            %# Get the field names from the 1st loaded nidaq file
runIdx = fieldnames(dsNidaq);            %# Get the run names of all runs relevant to the suite2p data registered together

for ii=1:length(fields);
concatenateddata.(fields{ii})=[];        % create empty structure to append all nidaq data to for desired runs
end

for ii=1:length(runIdx)
   for kk = 1:length(fields);
   fname = fields{kk};
   if isequal(dsNidaq.(runIdx{ii}).(fname),concatenateddata.(fname))~=1 | strcmp(fname,'frames2p')==1 ; %if the info is the same, then skip. If it contains different info, then proceed with concatenation
   concatenateddata.(fname) = ...
       horzcat(concatenateddata.(fname),dsNidaq.(runIdx{ii}).(fname));
   end 
   end
end 
for ii=2:length(runDirs) % adjusting timestamps
concatenateddata.timeStamps2p(:,ii)=concatenateddata.timeStamps2p(:,ii)+...
    (concatenateddata.timeStamps2p(end,ii-1));
end 
concatenateddata.timeStamps2p=...
    reshape(concatenateddata.timeStamps2p,[1,sum(nFrames)]);
dsnidaq=concatenateddata; % replace
clearvars concatenateddata dsNidaq runsConcatenate idcs ii kk fname rundirs
end 
if sum(nFrames)~=length(suite2pData.F)
    answer=warndlg('Length mismatch between  registered frames and nidaq files, please check runs that were registered against nidaq files',...
     'Error with Suite2p and nidaq file alignment');
    return
end

%% 

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
%check this

% rawratio = dff ./ abs(neuropil);

for ii=1:length(cellidx)
suite2pData.snr(ii)=snr(suite2pData.F(:,cellidx(ii)),...
    suite2pData.Fneu(:,cellidx(ii)));
end 
% suite2pData.snr=db2mag(suite2pData.snr)
clear dffTemp
%% 
if isempty(runNums)
    runNums=1;
end 
    endIdx    = cumsum(nFrames);
    startIdx= ([0,endIdx]+1);
    startIdx=startIdx(1:length(endIdx))
    
suite2pData.endIdx=endIdx;
suite2pData.startIdx=startIdx;
for ii=1:length(runNums)
npilmean(:,ii)= mean(neuropil(:,startIdx(ii):endIdx(ii)),2); % loop through by nFrames
end
% kk=1
%looping through to add respective neuropil between diff runs
for kk=1:size(npilmean,2)
for ii=1:size(npilmean,1)
tempdff= dff(:,startIdx(kk):endIdx(kk));
dFFTemp(ii,startIdx(kk):endIdx(kk))=tempdff(ii,:)+npilmean(ii,kk); 
end 
end

clear fac dist minDist time n dff dffTemp ii
%% Rolling dFF
%  ii=2
for ii=1:length(dffTreatment)
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
else dffTreatment(ii)==1;
    df=dFFTemp(:,startIdx(ii):endIdx(ii));
  f0 = prctile(df,percentile,2);
  suite2pData.dFF(:,startIdx(ii):endIdx(ii)) = (df-f0)./f0;
end
end 
suite2pData.cellIdx=cellidx;

%% calculate signal to noise and AUC

suite2pData.AUC=trapz(suite2pData.dFF,2); % not normalized by length SO IF COMPARING BETWEEN DIFF DAYS, MAKE SURE TO NORMALIZE BY LENGTH!
suite2pData.nidaqAligned=dsnidaq;
%as trial only basis dffTreatment(ii)==3; 
%save the concat nidaq? how will you get accurate stim times for the cell
%plots otherwise?

Filename=[fullRoot,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_',dsnidaq.run,'_','Suite2p_dff.mat'];
save(Filename, 'suite2pData');
end 
 