%% Pipeline Wrapper %%

% The only changes necessary should be within root and selecting which
% files to run in second line of indexing after findFilePathAF
%% Find Files of Interest
%root='E:\2Photon\Data'
root    ='Z:\DATA TEMP\New folder';            %% as character 
ext ='.sbx';                                %% as long as in character format, can find any text matching this. Most useful for extensions for pipelinin'. Faster than the File Explorer search also (suck it Windows)
sbxdirs = findFILE(root,ext);         %% Will return cell array of all files under root containing extList

sbxDirs = sbxdirs(1);                      %% Sub-select files you want to continue in pipeline with by indexing 
%% Write TIFFs - OPTIONAL! CAN RUN .Sbx DIRECTLY IN SUITE2P on YB-2
for ii=1:length(sbxDirs);
tiffloopAF(sbxDirs{ii},1000,0);   %% write TIFFs for all sbx files found above to run suite2p
end                                         %% skip this if TIFFs already exist/don't need TIFFs

%% Read in Nidaq + Save as _nidaq.mat
for ii=1:length(sbxDirs) %will output a _nidaq.mat file
[nidaq,success] = readSbxEphys(sbxDirs{ii});
goodfiles(ii)   = success;
end

%% get downsampled nidaq + save as dsNidaq.mat
for ii=1:length(sbxDirs); %will output a _dsnidaq.mat file
[dsnidaq,success]=alignNidaq(sbxDirs{ii}); 
end
%% Eye vids - find and write them to .avi
root   = 'Z:\AFdata\2p2019\W05';
ext    = 'eye.mat';
eyedirs= findFILE(root,ext);
eyeDirs= eyedirs(16:end);

for ii=1:length(eyeDirs)
[temp]=writeVidAF(eyeDirs{ii}); % change this so that it will find the eye.mat files from the sbx directories
goodEyeFile(ii)=temp;
end 