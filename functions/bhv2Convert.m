function [ bhv_struct ] = bhv2Convert(dataFile,configFile)
%% I/O
% datafile:      path to .bhv2 file (character, with extension)
% config file:   path of config Monkeylogic file (accessible to pipe, not original path from ML). Optional bc it will parse the info within .bhv2, 
%                but if there are duplicate files w/ same names + diff info, could pull in
%                wrong information

% bhv_struct:    structure w info about conditions and stim order/times
%                Saves as .mat file so can loop through and write for
%                multiple files

% MAKE SURE YOUR .BHV2 FILE HAS RUN # (e.g. 001) listed so it can be
% matched to correct nidaq file.
%% Put path of any .bhv file (to use as template) here:
BHV=bhv_read('Z:\AFdata\ML_output_BHV\Experiment-AS20-07-12-2016-run2.bhv'); %Template to get .bhv2 in same format, any .bhv file will do
% Hacky^ 
%% Checking whether bhv2 file is a bhv file....

fidbhv = fopen(dataFile, 'r');
    if fidbhv == -1,
        error(sprintf('*** Unable to open data file: %s', dataFile));
    end
    bhv_struct.MagicNumber = fread(fidbhv, 1, 'uint32');
    if bhv_struct.MagicNumber ~= 13,
        error('*** %s is not recognized as a "BHV2" file ***', dataFile);
    end
%% get filepath and load in .bhv2
dataFile=char(dataFile);
[filepath,bhv2Filename,ext]=fileparts(dataFile);

[data, MLConfig, TrialRecord, ~] = mlconcatenate(dataFile);                  %not returning fieldname, duplicate of datafile
bhv2_struct=mlread(dataFile); 
%% Creating empty structure w fieldnames from BHV template
bhvFields=fieldnames(BHV);
bhv_struct=cell2struct(cell(numel(bhvFields),1),bhvFields);
%% getting name of config file + finding path (Checking input NAME matches structure. Allows for 2 paths)

[~, cName, ~] = fileparts(MLConfig.MLPath.ConditionsFile);                  %Name of conditions file from filepath of conditions file on ML computer
if nargin<2,                                                                % Must have location of ML scripts on Matlab path (could use findFILE here?)
    configFile=fullfile(which([cName,'.txt']));                             % Find configfile local path, based on config filename in bhv2 file
end                                                                         % this is going to look in directory close to data first

[~, cFile, ~] = fileparts(configFile);                                      % getting name of config file (if nargin<2, this will be the same, but important check
                                                                            % checking that any manually entered config file matches name in the .bhv2 file
if  strcmp(cName,cFile)==0                                                  % as seen in this if statement
        sprintf('Please check config file! Filename not found/doesnt match conditions file listed in original BHV: %s ', cName) %6f
        return
end 
%% Save file info to new struct
bhv_struct.DataFileName = bhv2Filename;
bhv_struct.FullDataFile = dataFile;
bhv_struct.TimingFileByCond=TrialRecord.TaskInfo.TimingFileByCond;

%% Finding fields present in both .bhv and the files associated w new .bhv2
 % Bhv2 separates info diff than .bhv. 
 % Should debug and figure out what info we actually need instead of
 % everything, (but need to not hardcode?
 % auto update? UI?)

 %% Inputting fields from MLConfig
fieldNAMES=fieldnames(MLConfig);                                            % This won't work on anything nested below first level
fieldsML=intersect(bhvFields,fieldNAMES);
for ii=1:length(fieldsML)                                                   % Looping through all produced structures to grab overlapping fieldnames from workspace
bhv_struct.(fieldsML{ii})=MLConfig.(fieldsML{ii});                          % and put into bhv_struct
end
bhv_struct.ScreenXresolution    = str2num(extractBefore(MLConfig.Resolution,'x'));
bhv_struct.VideoRefreshRate     = extractAfter(MLConfig.Resolution,12);
bhv_struct.ScreenYresolution    = str2double(extractBetween(MLConfig.Resolution,7,12));
bhv_struct.AnalogInputFrequency = MLConfig.AISampleRate;
bhv_struct.JoyTransform         = MLConfig.JoystickTransform;
bhv_struct.ScreenBackgroundColor= MLConfig.SubjectScreenBackground;
bhv_struct.ConditionsFile       = [MLConfig.MLPath.ConditionsFile];
clear fieldNAMES fieldsML
%% Inputting fields from data
fieldNAMES=fieldnames(data);                                                % Have to manually find stragglers if named/formatted differently
fieldsD=intersect(bhvFields,fieldNAMES);

for ii=1:length(fieldsD)  
bhv_struct.(fieldsD{ii})=data.(fieldsD{ii});
end
bhv_struct.AbsoluteTrialStartTime = [data.TrialDateTime];                   % manually adding fields w/ diff names
bhv_struct.TimeElapsed            = [data.AbsoluteTrialStartTime];
clear fieldNAMES fieldsD
%% Inputting fields from TrialRecord
fieldNAMES=fieldnames(TrialRecord);
fieldsTR=intersect(bhvFields,fieldNAMES);

for ii=1:length(fieldsTR)
 bhv_struct.(fieldsTR{ii})=TrialRecord.(fieldsTR{ii});
end
bhv_struct.Stimuli=TrialRecord.TaskInfo.Stimuli; %not the same structure

%% clean up workspace
clearvars -except BHV bhv_struct bhv2_struct configFile dataFile MLConfig MLDATA TrialRecord data ext
%% Saving variables that are named/formatted differently than .bhv
bhv_struct.configPath         = configFile;
bhv_struct.TrialNumber        = [bhv2_struct.Trial]';
bhv_struct.BlockNumber        = [bhv2_struct.Block]';
bhv_struct.TrialWithinBlock   = [bhv2_struct.TrialWithinBlock]';
bhv_struct.ConditionNumber    = [bhv2_struct.Condition]';
bhv_struct.ObjectStatusRecord = [bhv2_struct.ObjectStatusRecord];
bhv_struct.UserVars           = [bhv2_struct.UserVars];

bhv_struct.CodeTimes = cellfun(@(x) x.CodeTimes, ...
    {bhv2_struct.BehavioralCodes}, 'UniformOutput', false);
bhv_struct.CodeNumbers = cellfun(@(x) x.CodeNumbers, ...
    {bhv2_struct.BehavioralCodes}, 'UniformOutput', false);

% Probably don't need analog signal? Original BHV doesnt have much info in
% analog...

bhv_struct.FinishTime=datetime((bhv_struct.AbsoluteTrialStartTime(end,:)),'InputFormat','dd-MMM-yyyy HH:mm:ss');
bhv_struct.StartTime=datetime([bhv_struct.AbsoluteTrialStartTime(1,:)],'InputFormat','dd-MMM-yyyy HH:mm:ss');
bhv_struct.StartTime=datestr(bhv_struct.StartTime);
bhv_struct.FinishTime=datestr(bhv_struct.FinishTime);
%cycle rate - check
%% get filepaths of Timing Files (to parse for TaskObject)
[filepath,name,ext] = fileparts(bhv_struct.ConditionsFile);                % getting filenames of ALL timing condition files (not just ones used)
for k = 1:length(bhv_struct.TimingFileByCond)                              % better way?
  endfile=(bhv_struct.TimingFileByCond(k));
  fullFileName(k) = fullfile(filepath, endfile);
end
bhv_struct.TimingFiles=unique(fullFileName);                               % Take out unique if want duplicates. Doesn't look like duplicates are a thing in original. 
%% pulling in info from config file to make TaskObject

try conditionsFile=importdata(configFile);                                 %% MAKE SURE NO SPACES AFTER LAST TASK OBJECT IN .txt FILE OR THIS WILL ERROR
    catch     sprintf('CANNOT FIND CONFIGURATION FILE') %6f
        return
end
expression = '\t';
splitStr = regexp(conditionsFile,expression,'split');
for i=1:length(splitStr);                                                  % There may be better way to write this, 
     temp_cell=splitStr{i,1};                                              % but this is v robust to diff inputs/ edge cases
     idx1=find(~cellfun(@isempty,temp_cell));
     parsedConditions(i,(1:length(idx1)))=(temp_cell(idx1));
     clear idx1
end 
parsedConditions = regexprep(parsedConditions, '#', '_');
bhv_struct.FullConditions=parsedConditions(2:end,:)

taskObject=(bhv_struct.FullConditions(:,5:end));
bhv_struct.TaskObject=taskObject;
%% save as struct
filepath=fileparts(dataFile);
FileName=[filepath,'\',bhv_struct.DataFileName,'_','bhv'];
save(FileName, '-struct', 'bhv_struct');
success=1;
end

