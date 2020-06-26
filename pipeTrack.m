function needsFxn=pipeTrack(root,ext1,ext2)
%% creates cell array of files that have one filetype but not the other
% Intended for finding which files need to be run in a pipeCB function
% root should be the directory to look for these (e.g. 'Z:\AFdata\2p2019\Sut1');                    
% ext1 should be the previously created/baseline file extension (e.g. '.ephys')
% ext2 should be the file extension created by the function you intend to run (e.g. _nidaq.mat')

%example: determine which files for Sut1 need to have nidaq file written
% readSbxEphys function takes a .ephys file and writes a _nidaq.mat file
% for extension/pipeCB function interactions, see:
%%% https://docs.google.com/document/d/1kA-x2EFAlukr_mUJ7SEUFYzkZTMDO1LjIf8g-ok5f5U/edit?usp=sharing
% can use .sbx as generic ext1 for most of these
%% 
Dir1 = findFILE(root,ext1);
Dir2 = findFILE(root,ext2);

if  isempty(Dir2)==0 %prone to breaking... should make it either
    fileBase1=extractBefore(Dir1,ext1);
    fileBase2=extractBefore(Dir2,ext2);
    needsFxn =setdiff(fileBase1,fileBase2)
else 
    disp('all files needed')
    needsFxn=Dir1;
    return
end 
% need to be careful with what extension the function expects. can call
% this function directly from other fxns and append the correct extension?
% should probably incorporate varargin into functions
end 