
root    ='Z:\AFdata\2p2019\W05';                    %% as character 
   
ext1='.sbx'
ext2='_nidaq.mat' % make sure to have full ext... eek unideal....

ext1='_nidaq.mat'
ext2='_dsNidaq.mat' % make sure to have full ext... eek unideal....

%to check if _eye file written
ext1='_eye.mat'
ext2='_eye.avi'

%to check if FM done
ext1='_eye.avi'
ext2='_eye_proc.npy'

%to check cell clicked
ext1='iscell.npy'
ext2='Fall.mat'

cellDirs=pipeTrack(root,ext1,ext2) 
%
ext1='.bhv2'

ext1 = '.sbx';
ext2 = '\behaviorPlots'

ext1='_eye_proc.npy'
ext2='\behaviorPlots'
eyeDirs=cellDirs


for ii=1:length(sbxDirs)                     % will output a _nidaq.mat file
[nidaq,success] = readSbxEphys(sbxDirs{ii}); % this took kinda awhile to run... hmm
goodfiles(ii)   = success;                   % use this to get index position in case it fails but doesn't have matlab error message
end