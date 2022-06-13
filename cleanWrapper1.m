%% Pipeline Wrapper %%

% The only changes necessary should be within root and selecting which
% files to run in second line of indexing after findFilePathAF
%% Find Files of Interest
%root='E:\2Photon\Data'
    root    ='Z:\AFdata\2p2019\Experiments\T07';             %% as character 
    ext ='.sbx';                                 %% Can find any character (text) matching ext. Also faster than the File Explorer
    sbxdirs = findFILE(root,ext);                %% Will return cell array of all files under root containing extList
    sbxDirs = sbxdirs(:);                        %% Sub-select files you want to continue in pipeline with by indexing 
%% Write TIFFs - OPTIONAL! NOW CAN RUN SBX DIRECTLY, all files to run together should be in same folder
stimTimes=[];
n=200;
%n=trialLength-1
customStart=[1:1000:50000];
customStart=[];
for ii=1:length(sbxDirs);
tiffLoop(sbxDirs{ii},n,0,customStart,'C:\Fiji.app');                    %% write TIFFs for all sbx files found above to run suite2p
end                                         %% skip this if TIFFs already exist/don't need TIFFs

T03_210204_001=load(...
    'Z:\AFdata\2p2019\Experiments\T03\\210204_T03\\T03_210204_001_dsNidaq.mat')
T03_210204_002=load(...
    'Z:\AFdata\2p2019\Experiments\T03\210204_T03\\T03_210204_002_dsNidaq.mat')
T03_210204_003=load(...
    'Z:\AFdata\2p2019\Experiments\T03\210204_T03\T03_210204_003_dsNidaq.mat')
T03_210204_004=load(...
    'Z:\AFdata\2p2019\Experiments\T03\210204_T03\T03_210204_004_dsNidaq.mat')

T03_210204_002visstim=T03_210204_002.visstim
%% Read in Nidaq + Save as _nidaq.mat
% for ii=1:length(sbxDirs)                     % will output a _nidaq.mat file
% [nidaq,success] = readSbxEphys(sbxDirs{end}); % this took kinda awhile to run... hmm
% goodfiles(ii)   = success;                   % use this to get index position in case it fails but doesn't have matlab error message
% end
sbxDirs=cellDirs2(14:end)
for ii=1:length(sbxDirs)
    customLabels(ii)={['Training Day',num2str(ii)]}
end
for ii=1:length(sbxDirs)
readSbxEphysCheck(sbxDirs{ii});
end

%% get downsampled nidaq + save as dsNidaq.mat
% for ii=1:length(sbxDirs);                    % will output a _dsnidaq.mat file
% [dsnidaq,success]=alignNidaq(sbxDirs{ii}); 
% goodfiles(ii)   = success;
% end
%% Eye vids - find and write them to .avi
    root   = 'Z:\AFdata\2p2019\I05'
    ext='_eye.mat';
    eyedirs = findFILE(root,ext);
    eyeDirs = cellDirs2(:);
    
for ii=1:length(eyeDirs)
[temp]=writeVid(eyeDirs{ii});               % change this so that it will find the eye.mat files from the sbx directories
goodEyeFile(ii)=temp;
end 
