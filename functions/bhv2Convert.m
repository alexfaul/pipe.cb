function [ bhv_struct ] = bhv2Convert(dataFile,configRoot,configFile)
%% I/O
% datafile:      path to .bhv2 file (character, with extension)
% config file:   path of config Monkeylogic file (accessible to pipe, not original path from ML). Optional bc it will parse the info within .bhv2, 
%                but if there are duplicate files w/ same names + diff info, could pull in
%                wrong information

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
if nargin<3,                                                                % Must have location of ML scripts on Matlab path (could use findFILE here?)
    configFile=findFILE(configRoot,[cName,'.txt']);
    configFile=char(configFile);                                                       % Find configfile local path, based on config filename in bhv2 file
end                                                                         % this is going to look in directory close to data first

                                                                            % checking that any manually entered config file matches name in the .bhv2 file
if  isempty(configFile)==1                                                  % as seen in this if statement
        sprintf('Please check config file! Filename not found/doesnt match conditions file listed in original BHV: %s ', cName) %6f
        %%add something here to find based on name of file not the one
        %%listed in MLConfig??
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

%% Assign unique colors to be used for consistent ori 

A = regexp(taskObject,'(?<=_).+?(?=deg)','match');
B=cellfun(@(x) x{1},A(cellfun('length',A)>0),'uniformoutput',0);

characterOri=cellfun(@str2double,B,'UniformOutput',0); % change this
bhv_struct.orientationsOrderedbyCond=characterOri;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bhv_struct.colors=distinguishable_colors(length(characterOri)) 
%%make vector of maximally distinct for all ori
% bhv_struct.colors=zeros(length(colors),3)           % 3 columns bc RBG is a TRIPLET, make matrix of all zeroes to protect against edge effects (if Csp and CSm arent 1st/3rd, would miss correct final size by 1)
% for ii=1:length(characterOri)                       %%manually set any that have CSp (CS plus) or CSm (CS minus)in timing files to green + red respectively
% if ii==find(contains(bhv_struct.TimingFileByCond,'CSp'))
%     bhv_struct.colors(ii,:)=[0,1,0] %green
% elseif ii==find(contains(bhv_struct.TimingFileByCond,'CSm'))
%      bhv_struct.colors(ii,:)=[1,0,0] %red
% elseif ii==find(contains(bhv_struct.TimingFileByCond,'Csnrand'))
%      bhv_struct.colors(ii,:)=[0,0,1] %blue
% 
% end
% end
% 
% colorDiff = setdiff(colors,bhv_struct.colors,'rows')  %find which colors from full set of max distinct colors was already used (if CSp or CSm present)
% unassigned=find(all(bhv_struct.colors == 0,2));       %find where the rows havent been assigned a color in bhv struct
% 
% for ii=1:size(colorDiff,1) %by number of rows found in unrepresented color triplet
% bhv_struct.colors(unassigned(ii),:)=colorDiff(ii,:);  %sub the rows still empty for color assignment w remaining colors (red + green spoken for if CSp/CSm used)
% end
%% save as struct
filepath=fileparts(dataFile);
FileName=[filepath,'\',bhv_struct.DataFileName,'_','bhv'];
save(FileName, '-struct', 'bhv_struct');
success=1;
fclose('all');
end

