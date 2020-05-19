function info = readSbxInfo(ipath, infpath, date) 
% ipath = path to .mat file
% infpath = path to .sbx file - need this for the additional parameters
% info should be outputting. Both as character strings
%% Load the .mat info file
load(ipath);

if(isfield(info,'sz'))
      sz = [796 512]; %this might be backwards... but i really think the height is 512 and width is 796
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

% switch info.nchan
%     case 1
%           info.nchan = 2;      % both PMT0 & 1
%           factor = 1;
%     case 2
%           info.nchan = 1;      % PMT 0
%           factor = 2;
% %     case 3
% %          info.nchan = 1;      % PMT 1
% %          factor = 2;
% end
 %% Adding info read in from the .sbx files (frames)
    info.fid = fopen(infpath);
    d = dir(infpath);
    info.nsamples = (info.sz(2)*info.recordsPerBuffer*2*info.nchan);

    if(info.scanmode == 0)
      % If bidirectional scanning, double the records per buffer
      info.recordsPerBuffer = info.recordsPerBuffer*2;
    end
    
    if isfield(info, 'scanbox_version') && info.scanbox_version >= 2
            info.max_idx = d.bytes/info.recordsPerBuffer/info.sz(2)*factor/4 - 1;
            info.nsamples = (info.sz(2)*info.recordsPerBuffer*2*info.nchan);   % bytes per record 
    else
            info.max_idx =  d.bytes/info.bytesPerBuffer*factor - 1;
    end
        
% Appended useful information
    info.nframes = info.max_idx + 1;
    info.optotune_used = false;
    info.otlevels = 1;
    if isfield(info, 'volscan') && info.volscan > 0, info.optotune_used = true; end
    if ~isfield(info, 'volscan') && ~isempty(info.otwave), info.optotune_used = true; end
    if info.optotune_used, info.otlevels = length(info.otwave); end
    if info.scanmode == 0 && date>=191108, info.framerate = 30.98;
        elseif info.scanmode == 0 && date <= 191107, info.framerate = 31.25; 
        elseif info.scanmode == 1 && date <=191107, info.framerate = 15.49; 
        elseif info.scanmode == 1 && date>=191108, info.framerate = 15.63; end
        
    info.height = info.sz(2);
    info.width = info.recordsPerBuffer;
        
end        
 
