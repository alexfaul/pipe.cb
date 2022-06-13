function [Stim,dsNidaq]=alignStim(dsNidaq, runNums, newdir)
%% dsNidaq an existing structure
if ischar(dsNidaq)
 dsnidaq=load(dsNidaq);
 if nargin<3, [newdir,filename,~]=fileparts(dsNidaq); 
 clear dsNidaq
 dsNidaq=dsnidaq;
 end
end 
if nargin<2 | isempty(runNums)
    runNums={dsNidaq.run}; %this is always going to cause errors UGH
end
%% Parse input path
if ~iscell(runNums)
    runNums={runNums};
end

%% Update stim times for concatenated nidaq data
Stim.trialonsets=[];                                 
Stim.trialoffsets=[];
%trialonsets = [find(diff(dsNidaq.visstim)>=1)+1];  



if isfield(dsNidaq,'startIdx')==0
dsNidaq.startIdx=1;
dsNidaq.endIdx=length(dsNidaq.frames2p);
end

%% Loop through each run to adjust visstim onsets and offsets
for ii=1:length(dsNidaq.startIdx)                               %this loop fixes partial trials and eliminates any that dont
startIdx= dsNidaq.startIdx(ii)                                  %have full cyle (onset and offset)
endIdx  = dsNidaq.endIdx(ii)
tempVisstim=dsNidaq.visstim(startIdx:endIdx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% test whether beginning and end are at 'on values'
dsNidaq.onsetOffBy1(ii)=0;  %%assume no offset/onset problems
dsNidaq.offsetOffBy1(ii)=0;

if tempVisstim(1)==5        %%adjust if signal is on at beginning or end
    dsNidaq.onsetOffBy1(ii)=1;
elseif tempVisstim(end)==5
    dsNidaq.offsetOffBy1(ii)=1;
end
%% Adjust trial onsets and offsets
%%%%% correct for if for some reason, a run with NO visstim is showing as 
%%%% having ON visstim the whole time, then there's no way
%%%% for there to be an "onset/offset difference to correct for"
%%%% Believe this happens when MonkeyLogic is not pulled up on the screen??
%%%% Related, if you start the visstim BEFORE hitting record on scanbox
%%%% Just trash those runs, fam. Try again. ML must be started AFTER

OnsetsOffsets(ii,:) = [sum(diff(tempVisstim)>=1),sum(diff(tempVisstim)<=-1)] ; % by  using diff, 1 corresponds to an onset, -1 to an offset
numVisstim(ii)=min(OnsetsOffsets(ii,:));
if numVisstim(ii)==0
    dsNidaq.onsetOffBy1(ii)=0;
    dsNidaq.offsetOffBy1(ii)=0;
    dsNidaq.visstim(startIdx:endIdx)=1;
    tempVisstim=dsNidaq.visstim(startIdx:endIdx);
end
trialonsets = [find(diff(tempVisstim)>=1)+startIdx];   %by adding the startIdx, off by 1 of diff is corrected
trialoffsets= [find(diff(tempVisstim)<=-1)+startIdx];  %All of these are +1 bc of fencepost of diff,and add idx position of isolated trace     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% adjust trial onsets by if visstim was on during onset and/or offset of
%%% whole run

if dsNidaq.onsetOffBy1(ii)==1 & dsNidaq.offsetOffBy1(ii)==0;  
    trialoffsets = trialoffsets(2:end);  
elseif dsNidaq.onsetOffBy1(ii)==0 & dsNidaq.offsetOffBy1(ii)==1'
    trialonsets = trialonsets(1:end-1);  
elseif dsNidaq.onsetOffBy1(ii)==1 & dsNidaq.offsetOffBy1(ii)==1;
    trialonsets = trialonsets(1:end-1);                                          %by adding the startIdx, fix off by 1 of diff AND resetting index from isolating section
    trialoffsets = trialoffsets(2:end);
end            
% trialonsets = trialonsets;   %by adding the startIdx, fix off by 1 of diff AND resetting index from isolating section
trialonsets=trialonsets(1:numVisstim(ii))
Stim.trialonsets=[Stim.trialonsets trialonsets]  ;         % append temp variable to loop through
Stim.trialoffsets=[Stim.trialoffsets trialoffsets] ;
clearvars trialonsets trialoffsets
end   

Stim.numVisstim=numVisstim;
% Stim.visstimOnsets  = Stim.trialonsets;
% Stim.visstimOffsets = Stim.trialoffsets;
Stim.shockOnsets    = find(diff(dsNidaq.shock>0.5))+1;   
Stim.shockOffsets   = find(diff(dsNidaq.shock<-0.5))+1;  
Stim.lickOnsets     = find(diff(dsNidaq.licking>0.5))+1;   
Stim.ensureOnsets   = find(diff(dsNidaq.ensure>0.5))+1; 

%% find all assocaited BHV files
ext1 = 'bhv.mat';           %%what to do if there's more than 1 bhv file?? Ugh, can't just concat... too many cells characters etc... so ERRORPRONE
bhvdirs = findFILE(newdir,ext1);
    
idcs   = strfind(newdir,filesep);
if isempty(bhvdirs) %if previous directory is empty, go up one level
    bhvdirs = findFILE(newdir(1:idcs(end)),ext1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement
end
if isempty(bhvdirs) %if previous directory is empty, go up one level
    bhvdirs = findFILE(newdir(1:idcs(end-1)),ext1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement
end
if isempty(bhvdirs) %if previous directory is empty, go up one level
    bhvdirs = findFILE(newdir(1:idcs(end-2)),ext1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement
end

if isempty(bhvdirs)
    sprintf('BHV file not in expected location. Proceeding, but will abort if cant concatenate. Please move to folder above unregisteredTIFFs')
end

%% Find the bhv files that contain same run #s as ones passed for concatenated nidaq

 %allows blanks where can't find BHV files - MUST MAKE SURE BHV FILE IS IN
 %RIGHT SPOT
tempBHV=bhvdirs(find(contains(bhvdirs,num2str(dsNidaq.date))));
[~,bhvMatch]=cellfun(@fileparts,tempBHV,'UniformOutput', false)
for ii=1:length(bhvMatch)
    bhvMatch{ii}=erase(bhvMatch{ii}, num2str(dsNidaq.date))
end     
% ii=2
for ii=1:(length(runNums)) %allows blanks where can't find BHV files - MUST MAKE SURE BHV FILE IS IN RIGHT SPOT
temp=find(contains(bhvMatch,[runNums{ii}]));
bhvDirs{ii}=bhvdirs(temp);
end 
%% load in BHV leaving empty for spontaneous runs
for ii=1:length(runNums)
if isempty(bhvDirs{ii})
    fname=['Run' (runNums{ii})]  
    BHV.(fname).spontaneous=1
else 
[~,fname,~]=fileparts(char(bhvDirs{ii}{1}));                                     % Each mathcing BHV structure loaded as separate field
fname=['BHV' fname]  
BHV.(fname)=load(char(bhvDirs{ii}{1}));
end
end
%% Initialize index and fieldnames
bhvsIdx=fieldnames(BHV);
Stim.condition=[];
Stim.trial=[];
Stim.orientationsUsed=[];
Stim.oriTrace=[];
Stim.colors=[]
Stim.TaskObject={};
%% Append condition 

%condition idx 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%super thorough debug to make sure not off by 1
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%

for ii=1:length(runNums)   
    temp=BHV.(bhvsIdx{ii})
  if isfield(temp,'spontaneous')
      continue
  else
    condIdx=(1:numVisstim(ii)) 
    condition=temp.ConditionNumber(condIdx);
    Stim.condition=[Stim.condition;condition];
    trial=temp.TrialNumber(condIdx);
%     colors=temp.colors;
%     Stim.colors=[Stim.colors;colors];
    Stim.trial=[Stim.trial;trial] ;
        if istable(temp.TaskObject)==1
            taskobject=table2cell(temp.TaskObject,'uniformoutput',0);
        else  taskobject=temp.TaskObject
        end 
    Stim.TaskObject{ii}=taskobject;
    A = regexp(taskobject,'(?<=_).+?(?=deg)','match');
    B=cellfun(@(x) x{1},A(cellfun('length',A)>0),'uniformoutput',0);

    characterOri=cellfun(@str2double,B,'UniformOutput',0); 
    Stim.orientationsUsed=[Stim.orientationsUsed;characterOri];
  end  
end 
 
Stim.orientationsUsed=unique(cell2mat(Stim.orientationsUsed));

%%% add task object or timingfilebycond??
%% Isolate the numerical orientation from the Task Object in BHV file
for ii=1:length(Stim.TaskObject)
   if isempty(Stim.TaskObject{ii})
       Stim.orientations{ii}=[]
       continue
   else 
    A = regexp(Stim.TaskObject{ii},'(?<=_).+?(?=deg)','match');
    B=cellfun(@(x) x{1},A(cellfun('length',A)>0),'uniformoutput',0);
    temp2=cellfun(@str2double,B,'UniformOutput',0); 
     Stim.orientations{ii}=temp2;
   end 
end 

% Stim.TaskObject2=unique(Stim.TaskObject)
Stim.oriTrace=[]     


for kk=1:length(Stim.orientations)
    temp3=Stim.orientations{kk}
   if isempty(temp3)
       continue
   else
      %%%%%%%%% trialonsets=Stim.trialonsets(1:numVisstim(ii))
    trialPos=find(Stim.trialonsets>dsNidaq.startIdx(kk) & Stim.trialonsets<dsNidaq.endIdx(kk))
%     trialPos=trialPos(1:numVisstim(ii))
    conditionSlice=Stim.condition(trialPos);
    for ii=1:length(conditionSlice)
    oriTrace(ii)= temp3{conditionSlice(ii)};
    end
    Stim.oriTrace =  [Stim.oriTrace oriTrace];
    oriTrace=[];
end 
end

% Stim.colors=BHV.colors;
Stim.oriTrace=Stim.oriTrace';

Stim.nidaqAligned=dsNidaq;
Stim.nidaqAligned=dsNidaq;

dsNidaq.Stim=Stim;

% % %% Saving struct

% filename=newdir(idcs(end)+1:end)
% 
% if length(runNums)==1
% Filename=[newdir,'\',filename,'stim'];
% save(Filename, '-struct', 'Stim');
% end
end
