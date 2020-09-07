function Stim=alignStim(dsNidaq, runNums, newdir)
%% Parse input path
%% Update stim times for concatenated nidaq data
Stim.trialonsets=[]                                 
Stim.trialoffsets=[]
%trialonsets = [find(diff(dsNidaq.visstim)>=1)+1];   
for ii=1:length(dsNidaq.startIdx)                               %this loop fixes partial trials and eliminates any that dont
startIdx= dsNidaq.startIdx(ii)                                  %have full cyle (onset and offset)
endIdx  = dsNidaq.endIdx(ii)

numVisstim(ii) = min(sum(diff(dsNidaq.visstim(startIdx:endIdx))>=1),sum(diff(dsNidaq.visstim(startIdx:endIdx))<=-1)) ;

trialonsets = [find(diff(dsNidaq.visstim(startIdx:endIdx))>=1)+startIdx];   %by adding the startIdx, fix off by 1 of diff AND resetting index from isolating section
Stim.trialonsets=[Stim.trialonsets trialonsets(1:numVisstim(ii))]           % append temp variable to loop through

trialoffsets= [find(diff(dsNidaq.visstim(startIdx:endIdx))<=-1)+startIdx];  %All of these are +1 bc of fencepost of diff,and add idx position of isolated trace
Stim.trialoffsets=[Stim.trialoffsets trialoffsets(1:numVisstim(ii))]    
end 
Stim.numVisstim=numVisstim;
Stim.visstimOnsets  = Stim.trialonsets;
Stim.visstimOffsets = Stim.trialoffsets;
Stim.shockOnsets    = find(diff(dsNidaq.shock>0.5))+1;   
Stim.shockOffsets   = find(diff(dsNidaq.shock<-0.5))+1;  
Stim.lickOnsets     = find(diff(dsNidaq.licking>0.5))+1;   
Stim.ensureOnsets   = find(diff(dsNidaq.ensure>0.5))+1; 
 
%% find all assocaited BHV files
ext1 = 'bhv.mat';           %%what to do if there's more than 1 bhv file?? Ugh, can't just concat... too many cells characters etc... so ERRORPRONE
bhvdirs = findFILE(newdir,ext1);
    
idcs   = strfind(newdir,filesep);
if isempty(bhvdirs) %if previous directory is empty, go up one level
    bhvdirs = findFILE(newdir(1:idcs(end)-1),ext1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement
end
if isempty(bhvdirs)
    sprintf('BHV file not in expected location. Proceeding, but will abort if cant concatenate. Please move to folder above unregisteredTIFFs')
end
%% Find the bhv files that contain same run #s as ones passed for concatenated nidaq
for ii=1:(length(runNums)) %allows blanks where can't find BHV files - MUST MAKE SURE BHV FILE IS IN RIGHT SPOT
temp=bhvdirs(find(contains(bhvdirs,[runNums{ii} '_'])));
bhvDirs{ii}=temp
end 
%% load in BHV leaving empty for spontaneous runs
for ii=1:length(runNums)
if isempty(bhvDirs{ii})
    BHV.spontaneous=[]
else 
[~,fname,~]=fileparts(char(bhvDirs{ii}));                                     % Each mathcing BHV structure loaded as separate field
fname=['BHV' fname]  
BHV.(fname)=load(char(bhvDirs{ii}));
end
end
%% Initialize index and fieldnames
bhvsIdx=fieldnames(BHV);
Stim.condition=[];
Stim.trial=[];
Stim.orientationsUsed=[];
Stim.oriTrace=[];
Stim.TaskObject={};
%% Append condition 

for ii=1:length(runNums)   
    temp=BHV.(bhvsIdx{ii})
    if isempty(temp)
        continue
    else
    condition=temp.ConditionNumber(1:numVisstim(ii));
    Stim.condition=[Stim.condition;condition];
    trial=temp.TrialNumber(1:numVisstim(ii));
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
    trialPos=find(Stim.trialonsets>=dsNidaq.startIdx(kk) & Stim.trialonsets<=dsNidaq.endIdx(kk))
    conditionSlice=Stim.condition(trialPos);
    for ii=1:(numVisstim(kk))
    oriTrace(ii)= temp3{conditionSlice(ii)};
    end
    Stim.oriTrace =  [Stim.oriTrace oriTrace];
    oriTrace=[]
end 
end

Stim.oriTrace=Stim.oriTrace';
% % %% Saving struct
% % Filename=[filepath,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_', num2str(dsnidaq.run),'_','stim']
% % save(Filename, '-struct', 'Stim');
end
