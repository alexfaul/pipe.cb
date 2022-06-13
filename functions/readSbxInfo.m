function info = readSbxInfo(infpath,ipath) 
% ipath = path to .mat file
% infpath = path to .sbx file - need this for the additional parameters
% info should be outputting. Both as character strings
% AF 05/2020

%%% based on read_sbxinfo from Arthur Sugden
%% Construct .mat info file - assumes stored in same folder 
[tempPath,file,~]=fileparts(infpath);
base = [tempPath '\' file];

if nargin<2 && contains(infpath, '.sbx')==1 %if only given the sbx path, create .mat info path
    ipath = [base '.mat'];
end

%% Need date to automatically interpret scanbox info correctly - extracting from filename
parsedFile=strsplit(file,'_')                                          %split filename by '_' & find the date by uniq characteristics 
for ii=1:length(parsedFile)                             
 [number,status]=str2num(parsedFile{ii})                               % (length - run is 3numeric, mousename usually 3-4alphanumeric + ONLY containing numbers) 
    if  status==1 && length(parsedFile{ii})>4 ;                        % if scanbox changes so that length of runs are longer than 4, or if you don't input expexted date format this will error
         date=str2num(parsedFile{ii})
     end
end
clear number status parsedFile
%% load .mat info 
load(ipath);
%% Setting info parameters 
if ~isfield(info,'sz')
      sz = [512 796];                           %is this backwards?... height is 512 and width is 796??
end
 
if ~isfield(info, 'nchan') && date>=191108
    info.nchan= info.chan.nchan;
end 

if ~isfield(info, 'nchan') && date<191108  %%what's going on here, may need further debug
    info.nchan=1;
end

if info.nchan == 2;
    factor = 1;
elseif info.nchan == 1;
    factor = 2;
end 
 %% Adding info read in from the .sbx files (frames)
    info.fid = fopen(infpath);
    d = dir(infpath);
    info.nsamples = (info.sz(2)*info.recordsPerBuffer*2*info.nchan); %changed index here to 1

    if(info.scanmode == 0)
      % If bidirectional scanning, double the records per buffer
      info.recordsPerBuffer = info.recordsPerBuffer*2;
    end
    
    if isfield(info, 'scanbox_version') && info.scanbox_version >= 2
            info.max_idx = d.bytes/info.recordsPerBuffer/info.sz(2)*factor/4 - 1; %changed these to index 1 instead of 2... think AS switched height and width? idk
            info.nsamples = (info.sz(2)*info.recordsPerBuffer*2*info.nchan);   % bytes per record 
    else
            info.max_idx =  d.bytes/info.bytesPerBuffer*factor - 1;
    end      
%% Append useful information
    info.nframes = info.max_idx + 1;
    info.optotune_used = false;
    info.otlevels = 1;
    if isfield(info, 'volscan') && info.volscan > 0, info.optotune_used = true; end
    if ~isfield(info, 'volscan') && ~isempty(info.otwave), info.optotune_used = true; end
%     if info.optotune_used, info.otlevels = length(info.otwave); end %%
%     figure out how optotune and Z stack interact and come back to this
    if info.scanmode == 0 && date>=191108, info.framerate = 30.98;
        elseif info.scanmode == 0 && date <= 191107, info.framerate = 31.25; 
        elseif info.scanmode == 1 && date <=191107, info.framerate = 15.49; 
        elseif info.scanmode == 1 && date>=191108, info.framerate = 15.63; end    %%%% change sampling rate here
        
    info.height = info.sz(1);
    info.width = info.recordsPerBuffer;    
end        
 
