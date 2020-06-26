function tiffLoop(path, n, pmt, customStart,ijroot,varargin)
%% put path to YOUR imagej here
if nargin<5, ijroot= 'E:\2Photon\pipe-master\minimal_ImageJ'; end 
%should add mkdir optional. Will always make a folder named
%'unregisteredTIFFs' where .sbx file is found and put all Tiffs in that folder
%% I/O
% path is full path to sbx file you want to write tif's for (ex: Z:\AFdata\2p2019\W03\200220_W04\W04_200220_001.sbx)
    % This should always be correct if using the find file function above it in
    % pipeWrapper and includes .sbx extension

% n = number of frames to write in a single tif, usually maxes out ~2000,
    % writing smaller is usually slightly faster overall but more clutter w/ #
    % of files

% pmt = which pmt used from scope, default is 0 (green)

% customStart is for writing specific frames sliced out of whole session.
    % Useful for writing tiffs for times when a visual
    % stim/reward/shock/etc happens. An index where each value
    % is the START POINT in frame number you want to write, and 'n' is adjusted 
    % to length of stimuli to be isolated. (Ex: Visstim is on at
    % frame# 45, 125, 190, 250. Stim length is 25. Then in FUNCTION CALL, n=25 (if variable length, go
    % with minimum length), and customFrames input should be [45,125,190,250].
    % Could also use for random sampling/first-last500

%Outputs are tifs only, written in same folder as .sbx files

%Based on AS firstLast500%
%% additional inputs/vargin

    p = inputParser;
    addOptional(p, 'server', []);  % Server name
    addOptional(p, 'startframe', 1, @isnumeric);
    addOptional(p, 'optolevel', []);
    parse(p, varargin{:});
    p = p.Results;
    
    if nargin < 2, n = 1000; end
    if nargin < 3, pmt = 1; end 
    if nargin < 4, customStart = []; end 

    info = readSbxInfo(path);
    %% make new directory
    [fullRoot,fileName,~] = fileparts(path);
folder                = [fullRoot,'\','unregisteredTIFFs\']; % create directory if it doesn't exist
if ~exist(folder, 'dir');
        mkdir(folder);
end
 %% Create vector of image index to write tiffs in succession
    %%This whole loop assumes that if you're inputting custom frames and associated n, 
    % you're not going to have more frames to write than length of movie
    %loop will break below if you have frames specified to be written that
    %exceed index
    if isempty(customStart)  %If not inputting custom start frames, and n less than total frames, divide full movie by n number of frames for each tiff 
        if n<=info.nframes
            tiff_start_vector=1:n:info.nframes;
        else                    % If whole .sbx file is fewer than n #frames, default to writing as 1 tiff
            tiff_start_vector=1;
            n=info.nframes;
        end
    else
        tiff_start_vector=customStart;     %ignore dividing whole movie evenly by n if inputting custom start points
    end                                     %This will write each instance in custom as separate tiff 
    
    if ((tiff_start_vector(end)+(n-1))<info.nframes)
        disp('Pick # of frames to write that is a factor of full movie length, e.g. n=1000 in 25000 frames')
    end 

 %% writing Tiffs
        for i=1:length(tiff_start_vector);
        spath = [folder sprintf('%s_-%i.tif',fileName, i)]; %changed to new fullRoot here
        tempTiff = imRead(path, tiff_start_vector(i), n, pmt, p.optolevel);
        writeTiff(tempTiff, spath, class(tempTiff), ijroot);
        end    
end