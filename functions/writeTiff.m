function success = writeTiff(array, filename, typestr)
%WRITETIFF Writes array as TIFF file
% % orig: write_tiff
%   Uses ImageJ code to do write
%   typestr is a matlab type name, supplied to the cast function
%
%   array should be size [nRows,nCols,nFrames,nPlanes] where nPlanes is 1
%   (indexed color) or 3 (RGB color)
%
%   See also: readtiff
%
%$Id: writetiff.m 305 2008-07-18 20:55:10Z vincent $
%   Edited 180731 by Arthur Sugden

    % Correct the image type
    if nargin < 3, typestr = class(array); end
    if ~strcmp(class(array), typestr), array = cast(array, typestr); end

    imp = arrayToImagej(array, typestr);
    
    [pathstr] = fileparts(filename);
    if ~isempty(pathstr) && exist(pathstr) ~= 7, mkdir(pathstr); end
    if isempty(strfind(filename, '.tif')), filename = [filename '.tif']; end

    fs = ij.io.FileSaver(imp);
    if imp.getImageStackSize == 1
        success = fs.saveAsTiff(filename);
    else
        success = fs.saveAsTiffStack(filename);
    end    
    
    if ~success
        error('write fail: does directory exist?');
    end
end