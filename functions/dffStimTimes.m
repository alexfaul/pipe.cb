function Stim=alignStim(dsNidaq, runNums, newdir)
%% Parse input path

for ii=1:length(dsNidaq.startIdx)
startIdx= dsNidaq.startIdx(ii)
endIdx  = dsNidaq.endIdx(ii)
numVisstim(ii) = max(sum(diff(dsNidaq.visstim(startIdx:endIdx))>=1),sum(diff(dsNidaq.visstim(startIdx:endIdx))<=-1)) ;
end 

%% Update stim times for concatenated nidaq data

for ii=1:length(dsNidaq.startIdx)
Stim.trialonsets = find(diff(dsNidaq.visstim)>=1)+1';   
Stim.trialoffsets= find(diff(dsNidaq.visstim)<=-1)+1';  %All of these are +1 bc of fencepost of diff

Stim.visstimOnsets  = Stim.trialonsets;
Stim.visstimOffsets = Stim.trialoffsets;
Stim.shockOnsets    = find(diff(dsNidaq.shock>0.5))+1;   
Stim.shockOffsets   = find(diff(dsNidaq.shock<-0.5))+1;  
Stim.lickOnsets     = find(diff(dsNidaq.licking>0.5))+1;   
Stim.ensureOnsets   = find(diff(dsNidaq.ensure>0.5))+1; 
end 
%% find all assocaited BHV files
ext1 = 'bhv.mat';           %%what to do if there's more than 1 bhv file?? Ugh, can't just concat... too many cells characters etc... so ERRORPRONE
bhvdirs = findFILE(newdir,ext1);
    
idcs   = strfind(newdir,filesep);
if isempty(bhvdirs) %if previous directory is empty, go up one level
    bhvdirs = findFILE(newdir(1:idcs(end)-1),ext1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement
end
if isempty(bhvdirs)
    sprintf('dsNidaq file not in expected location. Proceeding, but will abort if cant concatenate. Please move to folder above unregisteredTIFFs')
end
%% 
for ii=1:(length(runNums)) %allows blanks where can't find BHV files - MUST MAKE SURE BHV FILE IS IN RIGHT SPOT
temp=bhvdirs(find(contains(bhvdirs,runNums{ii})));
bhvDirs{ii}=temp
end 
%% load in BHV leaving empty for spontaneous runs
for ii=1:length(runNums)
if isempty(bhvDirs{ii})
    BHV.spontaneous=[];
else 
[~,fname,~]=fileparts(char(bhvDirs{ii}));                                     % runDirs has 
fname=['BHV' fname]  
BHV.(fname)=load(char(bhvDirs{ii}));
end
end
%%
bhvsIdx=fieldnames(BHV);
Stim.condition=[];
Stim.trial=[];
Stim.orientationsUsed=[];
Stim.oriTrace=[];
Stim.TaskObject={};

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
Stim.oriTrace=[]                            %% so this whole section will NOT work if the taskObjects (timing files) are differnt!!
for kk=1:length(Stim.orientations)
    temp3=Stim.orientations{kk}
   if isempty(temp3)
       continue
   else
    for ii=1:length(Stim.condition)
    Stim.oriTrace(ii) = temp3{Stim.condition(ii)};
    end
   end 
end

Stim.oriTrace=Stim.oriTrace';
% % %% Saving struct
% % Filename=[filepath,'\',dsnidaq.mouse,'_',num2str(dsnidaq.date),'_', num2str(dsnidaq.run),'_','stim']
% % save(Filename, '-struct', 'Stim');
end
