function [success]=writeVid(filePath,frameRate,ext)
%% I/O
    % filePath is path to .mat video
    % framerate is sampling rate of eyeVideo (either 1x or 2x 2p frame
    % rate, if after 11/2019, 15.63 or 30.25)
    % ext is type of file extension
%% Load the video path (eye is used throughout but can be used for any .mat video to turn to .avi)
% Need .avi for DLC and FM
%% 
try load(filePath);
    catch
    sprintf('No eye.mat file found, check path') %If it can't load, wrong filetype, DNE etc
    success=0;
    return
end

%% Get frame rate to write video from nidaq file if framerate not provided
% This will break if in updates don't write separate nidaq file
if nargin<2
ipath=join([file,'_nidaq'])
    try nidaq=load(ipath)
    catch
    sprintf('no _nidaq file found, run readSbxEphys or check path')
    success=0;
    return
    end
end
%% inputting extension
if nargin < 3;
    ext='.avi';
end
%% get correct path
if contains(filePath,'_eye')
    file=extractBefore(filePath,'_eye');
else
    file=filePath;
end 
%% Check for file presence to avoid overwriting
eyesave=join([file,'_eye',ext]);
if isfile(eyesave) %If file exists.
     success=1 %do not rewrite
     return   
end
%% Write .avi 
v = VideoWriter(eyesave);
v.FrameRate=nidaq.eyeframerate
open(v);
try writeVideo(v,data)
    catch
    success=0;
    sprintf('Unspecified issue writing video, check if file is corrupted')
    return
end;
close(v);
success=1;
end