function success = writeTiff(array, tifPath, typestr, ijroot)
%WRITETIFF Writes array as TIFF file
% % orig: write_tiff
%   Uses ImageJ code to do write
%   typestr is a matlab type name, supplied to the cast function
%
%   array should be size [nRows,nCols,nFrames,nPlanes] where nPlanes is 1
%   (indexed color) or 3 (RGB color)
%   Edited 180731 by Arthur Sugden
%% Change this default (do not push this change to git) or pass your correct path as 4th input
%% 

    % Correct the image type
    if nargin < 3, typestr = class(array); end
    if nargin < 4, ijroot= '/sw/med/centos7/fiji'; end
        %'/nfs/turbo/umms-crburge/Code/AF/newPipeline/pipe.cb/greatlakes/Fiji/Fiji.app'; end
        %%Lex's ComputerE:\2Photon\pipe-master\minimal_ImageJ'; 
        %%Alvins Computer: 'C:\Fiji.app' ; end
        

    if ~strcmp(class(array), typestr), array = cast(array, typestr); end

    
    [pathstr] = fileparts(tifPath);
    if ~isempty(pathstr) && exist(pathstr) ~= 7, mkdir(pathstr); end
    if isempty(strfind(tifPath, '.tif')), tifPath = [tifPath '.tif']; end
    [~,stackName]=fileparts(tifPath);
    imp = arrayToImagej(array, typestr, ijroot, stackName); %check tifPath
    fs = ij.io.FileSaver(imp);
    if imp.getImageStackSize == 1
        success = fs.saveAsTiff(tifPath);
    else
        success = fs.saveAsTiffStack(tifPath);
    end    
    
    if ~success
        error('write fail: does directory exist?');
    end
end