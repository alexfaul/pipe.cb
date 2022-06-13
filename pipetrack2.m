
root    ='Z:\AFdata\2p2019\Experiments\Sut1';                    %% as character 

ext1='.sbx'
ext2='_nidaq.mat' % make sure to have full ext... eek unideal....

ext1='.sbx'
ext2='_dsNidaq.mat' % make sure to have full ext... eek unideal....
ext1='.bhv2'
ext2='_bhv.mat'

cellDirs=pipeTrack(root,ext1,ext2) 



intersect(A,B) %%% see which files need both eye.avi AND proc_eye.mat. 

suite2pNeed=suite2pTrack(root,ext1, ext2);


%to check if _eye file written
ext1='_eye.mat'
ext2='_eye.avi'

%to check if FM done
ext1='_eye.avi'
ext1='.sbx'
ext2='_eye_proc.npy'

%to check cell clicked
ext1='iscell.npy'
ext2='Fall.mat'

ext1='.sbx'  %%doesn't work for concatenated runs, look for presence of suite2p to satisfy suite2p 
                %%requirement for all .sbx files within the folder... hmm
                %%how
ext2='iscell.npy'

%
ext1='.bhv2'

ext1 = '.sbx';
ext2 = '\behaviorPlots'

ext1='_eye_proc.npy'
ext2='\behaviorPlots'
eyeDirs=cellDirs

ext='Fall.mat'

ext2='Suite2p_dff.mat'
root    ='Z:\AFdata\2p2019\Experiments\Sut4'

 Fall2pDir=findFILE(root, ext)
suite2pDir=findFILE(root, ext2)

figure
plot(visstim)

[fullRoot,~] = cellfun(@fileparts,Fall2pDir,'UniformOutput',0);
fullRoot=fullRoot(1:19)
idcs     = strfind(fullRoot,filesep);
for ii=1:length(fullRoot)
nameRoot{ii,1} = fullRoot{ii}(idcs{ii}(end-3)+1:idcs{ii}(end-2)-1);
end


eyeDirs=cellDirs(:)
time_window=20;
percentile=30;
for ii=1:length(sbxDirs)                     % will output a _nidaq.mat file
[nidaq,success] = alignNidaq(sbxDirs{ii}); % this took kinda awhile to run... hmm
goodfiles(ii)   = success;                   % use this to get index position in case it fails but doesn't have matlab error message
end

for ii=1:length(sbxDirs)
dffCalc(sbxDirs{ii},percentile,time_window); 
end 

for ii=1:length(sbxDirs)                     % will output a _nidaq.mat file
[nidaq,success] = alignNidaq(sbxDirs{ii}); % this took kinda awhile to run... hmm
goodfiles(ii)   = success;                   % use this to get index position in case it fails but doesn't have matlab error message
end
