function [data,MLConfig,TrialRecord,filename,varlist] = mlread(filename)
%MLREAD returns trial and configuration data from MonkeyLogic data files
%(*.bhv2; *.h5; *.mat).
%
%   [data,MLConfig,TrialRecord] = mlread(filename)
%   [data,MLConfig,TrialRecord,filename] = mlread
%
%   Mar 7, 2017         Written by Jaewon Hwang (jaewon.hwang@nih.gov, jaewon.hwang@hotmail.com)

MLConfig = [];
TrialRecord = [];

if ~exist('filename','var') || 2~=exist(filename,'file')
    [n,p] = uigetfile({'*.bhv2;*.h5;*.bhv','MonkeyLogic Datafile (*.bhv2;*.h5;*.bhv)';'*.mat','MonkeyLogic Datafile (*.mat)'});
    if isnumeric(n), error('File not selected'); end
    filename = [p n];
end
[~,~,e] = fileparts(filename);
switch lower(e)
    case '.bhv2', fid = mlbhv2(filename,'r');
    case '.h5', fid = mlhdf5(filename,'r');
    case '.mat', fid = mlmat(filename,'r');
    case '.bhv', data = bhv_read(filename); return;
    otherwise, error('Unknown file format');
end

data = fid.read_trial();
if 1<nargout
    MLConfig = fid.read('MLConfig');
    
    % convert the old config format for mlplayer. This is a copy of loadobj@mlconfig()
    obj = MLConfig;
    if ~isfield(obj.RewardFuncArgs,'JuiceLine'), obj.RewardFuncArgs.JuiceLine = 1; end
    if ~isstruct(obj.Touchscreen), a = struct('On',false,'NumTouch',1); a.On = obj.Touchscreen; obj.Touchscreen = a; end
    if ~isstruct(obj.USBJoystick), a = repmat(struct('ID',''),1,2); a(1).ID = obj.USBJoystick; obj.USBJoystick = a; end
    if ~isfield(obj.USBJoystick,'NumButton'), for m=1:length(obj.USBJoystick), obj.USBJoystick(m).NumButton = 0; end, end
    if ischar(obj.EyeTracerShape), obj.EyeTracerShape = {obj.EyeTracerShape, obj.EyeTracerShape}; end
    if 1==size(obj.EyeTracerColor,1), obj.EyeTracerColor = [obj.EyeTracerColor; 1 0 1]; end
    if isscalar(obj.EyeTracerSize), obj.EyeTracerSize = [obj.EyeTracerSize obj.EyeTracerSize]; end
    if isscalar(obj.EyeCalibration), obj.EyeCalibration = [obj.EyeCalibration obj.EyeCalibration]; end
    if 1==size(obj.EyeTransform,1), obj.EyeTransform = repmat(obj.EyeTransform,2,1); end
    if ischar(obj.JoystickCursorImage), obj.JoystickCursorImage = {obj.JoystickCursorImage, obj.JoystickCursorImage}; end
    if ischar(obj.JoystickCursorShape), obj.JoystickCursorShape = {obj.JoystickCursorShape, obj.JoystickCursorShape}; end
    if 1==size(obj.JoystickCursorColor,1), obj.JoystickCursorColor = [obj.JoystickCursorColor; 0 0.5 1]; end
    if isscalar(obj.JoystickCursorSize), obj.JoystickCursorSize = [obj.JoystickCursorSize obj.JoystickCursorSize]; end
    if isscalar(obj.JoystickCalibration), obj.JoystickCalibration = [obj.JoystickCalibration obj.JoystickCalibration]; end
    if 1==size(obj.JoystickTransform,1), obj.JoystickTransform = repmat(obj.JoystickTransform,2,1); end
    if ~isfield(obj.EyeTracker,'Ver')
        if isfield(obj.EyeTracker.ViewPoint,'Source')
            obj.EyeTracker.ViewPoint.Source(5:8,:) = obj.EyeTracker.ViewPoint.Source(3:6,:);
            obj.EyeTracker.ViewPoint.Source(3:4,:) = obj.EyeTracker.ViewPoint.Source(1:2,:);
            obj.EyeTracker.ViewPoint.Source(3:4,1) = 1-obj.EyeTracker.ViewPoint.Source(3:4,1);
            obj.EyeTracker.ViewPoint.Source(3:4,2) = 1;
        end
        if isfield(obj.EyeTracker.EyeLink,'Source')
            obj.EyeTracker.EyeLink.Source = [repmat(obj.EyeTracker.EyeLink.Source(1:2,:),2,1); obj.EyeTracker.EyeLink.Source(3:6,:)];
            obj.EyeTracker.EyeLink.Source(3:4,2) = 1;
        end
        obj.EyeTracker.Ver = 1;
    end
    MLConfig = obj;
end
if 2<nargout, TrialRecord = fid.read('TrialRecord'); end
if 4<nargout, varlist = who(fid); end
close(fid);

end
