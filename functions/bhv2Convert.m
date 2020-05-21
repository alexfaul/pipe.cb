function [ bhv_struct ] = bhv2Convert(dataFile,configFile)
%% I/O
% datafile:      path to .bhv2 file
% config file:   path of config Monkeylogic file (accessible to pipe, not original path from ML). Optional bc it will parse the info within .bhv2, 
%                but if there are duplicate files w/ same names + diff info, could pull in
%                wrong information

% bhv_struct:    structure w info about conditions and stim order/times
%                Saves as .mat file so can loop through and write for
%                multiple files
% MAKE SURE YOUR .BHV2 FILE HAS RUN # (e.g. 001) listed so it can be
% matched to correct nidaq file.
%% Checking whether bhv2 file is a bhv file..... Do we need this?
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
[filepath,bhv2Filename,ext]=fileparts(dataFile)

[data, MLConfig, TrialRecord, ~] = mlconcatenate(dataFile);                  %not returning fieldname, duplicate of datafile
bhv2_struct=mlread(dataFile); 
%% Put path of any .bhv file (to use as template) here:
BHV=bhv_read('Z:\AFdata\ML_output_BHV\Experiment-AS20-07-12-2016-run2.bhv'); %Template to get .bhv2 in same format, any .bhv file will do
% Hack 
%% Creating empty structure w fieldnames from BHV template
bhvFields=fieldnames(BHV);
bhv_struct=cell2struct(cell(numel(bhvFields),1),bhvFields);
%% getting name of config file + finding path
[~, cName, ~] = fileparts(MLConfig.MLPath.ConditionsFile);                  %Name of conditions file from filepath of conditions file on ML computer
if nargin<2,
    configFile=fullfile(which([cName,'.txt']));                             % Find configfile local path, based on config filename in bhv2 file
end                                                                         % this is going to look in directory close to data first

 [~, cFile, ~] = fileparts(configFile);                                     % getting name of config file (if nargin<2, this will be the same, but important check
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
 %Should debug and figure out what info we actually need instead of
 %everything, (but need to not hardcode?
 % auto update? UI?)
%% Inputting fields from MLConfig
fieldNAMES=fieldnames(MLConfig);                                            %This won't work on anything nested below first level
fieldsML=intersect(bhvFields,fieldNAMES);
for ii=1:length(fieldsML)                                                           % Looping through all produced structures to grab overlapping fieldnames from workspace
bhv_struct.(fieldsML{ii})=MLConfig.(fieldsML{ii});                                     % and put into bhv_struct
end      
%% Inputting fields from data
fieldNAMES=fieldnames(data);                                             %so manually will manually find those stragglers
fieldsD=intersect(bhvFields,fieldNAMES);

for ii=1:length(fieldsD)  
bhv_struct.(fieldsD{ii})=data.(fieldsD{ii});
end 
%% Inputting fields from TrialRecord
fieldNAMES=fieldnames(TrialRecord);
fieldsTR=intersect(bhvFields,fieldNAMES);

for ii=1:length(fieldsTR)
 bhv_struct.(fieldsTR{ii})=TrialRecord.(fieldsTR{ii});
end 
% clean up workspace
clearvars -except BHV bhv_struct bhv2_struct configFile dataFile MLConfig MLDATA TrialRecord data ext
%% Saving variables that are named differently than .bhv
bhv_struct.configPath=configFile;

bhv_struct.TrialNumber = [bhv2_struct.Trial]';
bhv_struct.BlockNumber = [bhv2_struct.Block]';
bhv_struct.TrialWithinBlock = [bhv2_struct.TrialWithinBlock];
bhv_struct.ConditionNumber = [bhv2_struct.Condition]';
bhv_struct.AbsoluteTrialStartTime = [data.TrialDateTime];
% bhv_struct.AbsoluteTrialStartTime=reshape(bhv_struct.AbsoluteTrialStartTime, 6,[])';
bhv_struct.TimeElapsed = [data.AbsoluteTrialStartTime];

bhv_struct.TrialError = [bhv2_struct.TrialError]';
bhv_struct.CodeTimes = cellfun(@(x) x.CodeTimes, ...
    {bhv2_struct.BehavioralCodes}, 'UniformOutput', false);
bhv_struct.CodeNumbers = cellfun(@(x) x.CodeNumbers, ...
    {bhv2_struct.BehavioralCodes}, 'UniformOutput', false);
temp = [bhv2_struct.AnalogData];
[temp.EyeSignal] = temp.Eye;
bhv_struct.AnalogData = rmfield(temp, 'Eye');
bhv_struct.ReactionTime = [bhv2_struct.ReactionTime];
bhv_struct.ObjectStatusRecord = [bhv2_struct.ObjectStatusRecord];
temp = [bhv2_struct.RewardRecord];
[temp.RewardOnTime] = temp.StartTimes;
[temp.RewardOffTime] = temp.EndTimes;
temp = rmfield(temp, 'StartTimes');
bhv_struct.RewardRecord = rmfield(temp, 'EndTimes');
bhv_struct.UserVars = [bhv2_struct.UserVars];
bhv_struct.ConditionsFile = [MLConfig.MLPath.ConditionsFile];

bhv_struct.FinishTime=datetime((bhv_struct.AbsoluteTrialStartTime(end,:)),'InputFormat','dd-MMM-yyyy HH:mm:ss');
bhv_struct.StartTime=datetime([bhv_struct.AbsoluteTrialStartTime(1,:)],'InputFormat','dd-MMM-yyyy HH:mm:ss');
bhv_struct.StartTime=datestr(bhv_struct.StartTime);
bhv_struct.FinishTime=datestr(bhv_struct.FinishTime);
%cycle rate is def wrong??
%% manually putting in fields w/ slightly diff names
bhv_struct.ScreenBackgroundColor=MLConfig.SubjectScreenBackground;
bhv_struct.Stimuli=TrialRecord.TaskInfo.Stimuli; %not the same structure
bhv_struct.ScreenXresolution=str2num(extractBefore(MLConfig.Resolution,'x'));
bhv_struct.VideoRefreshRate=extractAfter(MLConfig.Resolution,12);
bhv_struct.ScreenYresolution=str2double(extractBetween(MLConfig.Resolution,7,12));
bhv_struct.AnalogInputFrequency=MLConfig.AISampleRate;
bhv_struct.JoyTransform=MLConfig.JoystickTransform;

%% 
[filepath,name,ext] = fileparts(bhv_struct.ConditionsFile);                           %%getting filenames of ALL timing condition files (not just ones used)
TimingFileByCond=bhv_struct.TimingFileByCond;
for k = 1:length(TimingFileByCond)                                              % should find a better way to automate this
  endfile=(TimingFileByCond(k));
  fullFileName(k) = fullfile(filepath, endfile);
end
bhv_struct.TimingFiles=unique(fullFileName);            %Take out unique if want duplicates. Doesn't look like duplicates are a thing in original. 
%% 
% [~,name,ext] = fileparts(bhv_struct.ConditionsFile);                           %%getting filenames of ALL timing condition files (not just ones used)
% [filepath,~,~] = fileparts(bhv_struct.FullDataFile);                           %%getting filenames of ALL timing condition files (not just ones used)
% con_file=fullfile(filepath,[name ext]); % presumably be working out of this file directory
%configfile='Z:\AFdata\2p2019\Eight_orientations_AF.txt'
%conditions_path=importdata(configfile);
%% pulling in info from config file

%%% NEEDS A DEEP CLEAN!!
try conditions_path=importdata(configFile); %% MAKE SURE NO SPACES AFTER LAST TASK OBJECT IN .txt FILE OR THIS WILL ERROR
    catch     sprintf('CANNOT FIND CONFIGURATION FILE') %6f
        return
end
expression = '\t';
splitStr = regexp(conditions_path,expression,'split');
for i=1:length(splitStr);
     temp_cell=splitStr{i,1};
     idx1=find(~cellfun(@isempty,temp_cell));
     output(i,(1:length(idx1)))=(temp_cell(idx1));
     clear idx1
end 
output = regexprep(output, ' ', '_');
output = regexprep(output, '#', '_');
output2=cell2table(output(2:end,:), 'VariableNames',output(1,:));
bhv_struct.FullConditions=output2;
output3=table2array(output2(:,5:end));
output3=(output2(:,5:end));
bhv_struct.TaskObject=output3;

%% save as struct
filepath=fileparts(dataFile);
FileName=[filepath,'\',bhv_struct.DataFileName,'_','bhv'];
save(FileName, '-struct', 'bhv_struct');
success=1;
end

