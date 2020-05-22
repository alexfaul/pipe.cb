function [goodEyeFile]=writeVidAF(eyeFile,frameRate)
%% Load the video path (eye is used throughout but can be used for any .mat video to turn to .avi)
% Need .avi for DLC and FM
try load(eyeFile);
    catch
    sprintf('No eye.mat file found, check path')
    goodEyeFile=0;
    return
end
%% get path correctly
if contains(eyeFile,'_eye')
    file=extractBefore(eyeFile,'_eye');
else
    file=eyeFile
end 
%% Check for file presence to avoid overwriting
a='_eye.avi';
eyesave=join([file,a]);
if isfile(eyesave) %If file exists.
     goodEyeFile=1 %do not rewrite
     return   
end

%% Get frame rate to write video from nidaq file if framerate not provided
% This will break if in updates don't write separate nidaq file
if nargin<2
ipath=join([file,'_nidaq'])
    try nidaq=load(ipath)
    catch
    sprintf('no _nidaq file found, run readSbxEphys or check path')
    goodEyeFile=0;
    return
    end
end
%% Write .avi 
v = VideoWriter(eyesave);
v.FrameRate=nidaq.eyeframerate
open(v);
try writeVideo(v,data)
    catch
    goodEyeFile=0;
    sprintf('Unspecified issue writing video, check if file is corrupted')
    return
end;
close(v);
goodEyeFile=1;
end