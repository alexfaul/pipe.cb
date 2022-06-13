function [success]=writeVid(filePath,frameRate,ext)
%% I/O
    % filePath is path to .mat video
    % framerate is sampling rate of eyeVideo (either 1x or 2x 2p frame
    % rate, if after 11/2019, 15.63 or 30.25)
    % ext is type of file extension in character format ('.avi')
%% Load the video path (eye is used throughout but can be used for any .mat video to turn to .avi)
% Need .avi for DLC and FM
%% add 'eye' to search for eye files specifically (will have to change this if wanting other file types)
if contains(filePath,'.sbx')==1;            % Account for different potential inputs 
    root=extractBefore(filePath, '.sbx');   % So this can accept either paths without extension, with .sbx or _nidaq.mat at end
    vidPath = [root 'eye.mat'] ;
end %do we really need to plan on a .sbx extension? Maybe just below will suffice

if contains(filePath,'_eye.mat')
    vidPath = filePath;
    root    = extractBefore(filePath, '_eye.mat');
    ipath   = [root '_nidaq.mat'];
else
    vidPath =[filePath '_eye.mat'];
    root    = filePath;
    ipath   =[filePath '_nidaq.mat'];
end 
%% try opening video
try load(vidPath);
    catch
    sprintf('No eye.mat file found, check path') %If it can't load, wrong filetype, DNE etc
    success=0;
    return
end

%% Get frame rate to write video from nidaq file if framerate not provided
% This will break if in updates don't write separate nidaq file
if nargin<2
try nidaq=load(ipath)
  catch
    sprintf('no _nidaq file found, run readSbxEphys or check path')
    success=0;
  return
end
frameRate=nidaq.eyeframerate;
end
%% inputting extension
if nargin < 3;
    ext='.avi';
end
%% Check for file presence to avoid overwriting
eyesave=join([root '_eye' ext]);
if isfile(eyesave) %If file exists.
     success=1 %do not rewrite
     return   
end
%% Write .avi 
v = VideoWriter(eyesave);
v.FrameRate=frameRate
open(v);
try writeVideo(v,data)
    catch
    success=0;
    sprintf('Unspecified issue writing video, check if file is corrupted')
    close (v)
    return
end;
fclose('all');
success=1;
end