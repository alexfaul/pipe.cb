function Stim=stimTimes(bhvPath, dsNidaqPath)
%% Parse input path
[filepath,filename,~]=fileparts(char(bhvPath));
BHV=load(bhvPath);
if nargin==2, dsnidaq=load(dsNidaqPath); end 
%% Load the converted BHV file based on extension and same run #
if nargin<2

fileSplit=strsplit(extractBefore(filename,'_bhv'),'_');
for ii=1:length(fileSplit);
    temp=fileSplit{ii};
    [num, status] = str2num(temp);
    if status==1 ;
        if num>999
          date=str2num(temp);
        else
            run=temp;
        end 
    elseif contains(temp,'run')==1;
        run=temp;
    elseif status==0
        if length(regexp(temp,'[A-Z]','match'))==1;   %%this will break will anything with FC or App in title of bhv file... eekk
        mouse=temp;
        end 
    end 
end 
nidaqPath=char(findFILE(filepath, [run '_dsNidaq.mat']) )
try  dsnidaq= load(nidaqPath)     
catch
    sprintf('dsNidaq.mat not written/in different folder than BHV file!')
    Stim=[];
    return
end
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
Stim.oriTrace(ii) = characterOri{Stim.condition(ii)};
end
Stim.orientationsUsed=unique((Stim.oriTrace));
% Stim.stimTable=stimTable;
%% Saving struct
Filename=[filepath,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_', num2str(dsnidaq.run),'_','stim']
save(Filename, '-struct', 'Stim');
end 
