%% Pipeline Wrapper %%

% The only changes necessary should be within root and selecting which
% files to run in second line of indexing after findFilePathAF
%% Find Files of Interest
%root='E:\2Photon\Data'
    root    ='Z:\AFdata\2p2019\Sut1';                    %% as character 
    ext ='.sbx';                                   %% Can find any character (text) matching ext. Also faster than the File Explorer
    sbxdirs = findFILE(root,ext);                  %% Will return cell array of all files under root containing extList
    sbxDirs = sbxdirs(1:60);                      %% Sub-select files you want to continue in pipeline with by indexing 
%% Write TIFFs - OPTIONAL! CAN RUN .Sbx DIRECTLY IN SUITE2P on YB-2
stimTimes=[300, 900, 1200];
n=100;

for ii=1:length(sbxDirs);
tiffLoop(sbxDirs{ii},n,0,stimTimes);        %% write TIFFs for all sbx files found above to run suite2p
end                                         %% skip this if TIFFs already exist/don't need TIFFs

%% Read in Nidaq + Save as _nidaq.mat
for ii=1:length(sbxDirs)                     % will output a _nidaq.mat file
[nidaq,success] = readSbxEphys(sbxDirs{ii}); % this took kinda awhile to run... hmm
goodfiles(ii)   = success;
end

%% get downsampled nidaq + save as dsNidaq.mat
for ii=1:length(sbxDirs);                    % will output a _dsnidaq.mat file
[dsnidaq,success]=alignNidaq(sbxDirs{ii}); 
end
%% Eye vids - find and write them to .avi
    root   = 'Z:\AFdata\2p2019\W05'
    eyedirs = findFILE(root,ext);
    eyeDirs = eyedirs()
    
for ii=1:length(eyeDirs)
[temp]=writeVid(eyeDirs{ii}); % change this so that it will find the eye.mat files from the sbx directories
goodEyeFile(ii)=temp;
end 