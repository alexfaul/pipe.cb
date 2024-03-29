%% Example code using findFILE to isolate files that need to be run through pipeline:
%% 
    root    ='Z:\AFdata\2p2019\Sut1';                    %% as character 
    ext='.ephys'
    ephysDir = findFILE(root,ext);

    ext='_nidaq.mat'
    nidaqDir = findFILE(root,ext);

%% 
    ext = '.avi';
    aviDir = findFILE(root,ext);

    ext = 'eye.mat';
    eyeDir = findFILE(root,ext);
        
fileBaseAVI=extractBefore(aviDir,'.avi')
fileBaseMAT=extractBefore(eyeDir,'.mat')

needsAvi =setdiff(fileBaseMAT,fileBaseAVI) 
%% for finding things run through suite2p and cell clicked
    root    ='Z:\AFdata\2p2019\Sut2';                    %% as character 
    ext = 'stat.npy';
    suite2pDir = findFILE(root,ext);

     ext = 'Fall.mat';
    clickedDir = findFILE(root,ext);
    