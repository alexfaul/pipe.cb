function Stim=stimTimes(bhvPath)
%% Parse input path
[filepath,filename,~]=fileparts(char(bhvPath));
BHV=load(bhvPath);

%% Load the converted BHV file based on extension and same run #
try dsnidaq=load([filepath,'\',...
    ls(fullfile(filepath, ['*','dsNidaq.mat*']))]);                         %This is better way to do it than assuming same naming structure.. if it comes up!
catch
    sprintf('dsNidaq.mat not written/in different folder than BHV file!')
end
%% Find onsets and offsets
Stim.mouse=dsnidaq.mouse;
Stim.date=dsnidaq.date;

num_vstim=min(sum(diff(dsnidaq.visstim)>=1),sum(diff(dsnidaq.visstim)<=-1)) ;
Stim.numStim=num_vstim;
Stim.trialonsets=find(diff(dsnidaq.visstim)>=1)+1';   
Stim.trialoffsets=find(diff(dsnidaq.visstim)<=-1)+1';  %All of these are +1 bc of fencepost of diff

Stim.visstimOnsets=Stim.trialonsets;
Stim.visstimOffsets=Stim.trialoffsets;
Stim.shockOnsets=find(diff(dsnidaq.shock>0.5))+1;   
Stim.shockOffsets=find(diff(dsnidaq.shock<-0.5))+1;  
Stim.lickOnsets=find(diff(dsnidaq.licking>0.5))+1;   
Stim.ensureOnsets=find(diff(dsnidaq.ensure>0.5))+1; 
%% testing whether the nidaq supports the BHV file interpretation/is there stim?

if length(find(structfun(@isempty, Stim)))>=6
   sprintf('No BHV file or stim pulses found for %s %s %s', dsnidaq.mouse, dsnidaq.date, dsnidaq.run);   %6f
   sprintf('TREATING AS SPONTANEOUS RUN') ;
   Stim.spontaneous=1;
   Filename=[filepath,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_', num2str(dsnidaq.run),'_','stim'];
   save(Filename, '-struct', 'Stim');
    return
end 
%% Adjusting conditions/trials actually recorded by nidaq pulses
Stim.condition=[];
Stim.trial=[];
Stim.condition=BHV.ConditionNumber(1:num_vstim);              
Stim.trial=BHV.TrialNumber(1:num_vstim);                      
%% finding the orientation order
for ii=1:length(BHV.TaskObject)                                         % split by underscores to isolate the #'s indicating degree orientation
ori{ii,:}=strsplit(BHV.TaskObject{ii,1},'_');
end

for ii=1:length(ori)
    temp=ori{ii};
    if length(temp)==2;                                                 % blanks only have 1 underscore. this is prone to breaking.... may want to address
        oris{ii}='999';
    else 
        oris{ii}=temp{2};                                               % again, assumes same naming structure, falls apart w diff naming structure... regexp before???
    end
end

test=(regexp(oris,'\d*','Match'));
characterOri=cellfun(@str2double,test,'UniformOutput',0); % change this
%orientations=unique(Stim.condition);

for ii=1:length(Stim.condition)
Stim.oriTrace(ii)=characterOri{Stim.condition(ii)};
end
Stim.orientationsUsed=unique((Stim.oriTrace));
% Stim.stimTable=stimTable;
%% Saving struct
Filename=[filepath,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_', num2str(dsnidaq.run),'_','stim']
save(Filename, '-struct', 'Stim');
end 
