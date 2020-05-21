function [dsnidaq,success]=alignNidaq(path, graph)
dataDirectory    ='Z:\AFdata\2p2019\';            %% Change if working in entirely different drive. If data falls anywhere below 2p2019, this is okay.
%do I even need this?
%% whether to generate graphs
if nargin < 2, graph=1; end
%% creating paths to load
if contains(path,'.sbx')==1;            % Account for different potential inputs 
    root=extractBefore(path, '.sbx');   % So this can accept either paths without extension, with .sbx or _nidaq.mat at end
    nidaqPath = [root '_nidaq.mat'] 
elseif contains(path,'_nidaq.mat')==1;
     nidaqPath=path;
elseif contains(path,'_nidaq.mat')==0 && contains(path,'.sbx')==0;
    nidaqPath = [path '_nidaq.mat'] ;
end 
%% Check for presence of nidaq file
try nidaq=load(nidaqPath);
catch
    sprintf('No nidaq file written, check ReadsbxEphys was run')
    dsnidaq=[]
    success=0
    return
end 
%% binarize signals
%%% THERE NEEDS TO BE A WAY TO MAKE THIS MORE ROBUST. We should always have
%%% decent separation (>1.5), but if this changes, all signals binarized
%%% wrong

for i=1:length(nidaq.ensure);                             %%makes indexing much easier
    if nidaq.ensure(i)>1.5;
    nidaq2.ensure(i)=4;
    else 
    nidaq2.ensure(i)=0;
    end 
end
for i=1:length(nidaq.visstim);                             
    if nidaq.visstim(i)>1;
    nidaq2.visstim(i)=4;
    else 
    nidaq2.visstim(i)=1;
    end 
end

for i=1:length(nidaq.shock);                             
    if nidaq.shock(i)>1;
    nidaq2.shock(i)=5;
    else 
    nidaq2.shock(i)=0.5;
    end 
end

for i=1:length(nidaq.licking);                             
    if nidaq.licking(i)>=1;
    nidaq2.licking(i)=1;
    else 
    nidaq2.licking(i)=0;
    end 
end
%% Find pulses to align
C = find(diff(nidaq.frames2p)==3);
%% Check for presence of 2p pulses and if does not exist, substitute in another run
while length(C)<nidaq.nframes               %  while should keep this looping until finds a suitable 2p frames substitution
dlgtitle = ['Number of 2p pulses does not match number of frames']
dims = [1 80];
prompt = {'Please name of nidaq file (e.g. W05_200415_001) to substitute 2p pulses'}; % entered as plain text (no quotation marks etc, its string in cell as default)
answer = inputdlg(prompt,dlgtitle,dims); 

if contains(answer{1},'_nidaq.mat')==0;
    ext = [answer{1} '_nidaq.mat'] ;
elseif contains(answer{1},'_nidaq.mat')==1;
    ext = answer{1};
end
backupPath = findFilePathAF(dataDirectory,ext);
backupNidaq=load(backupPath{1});

 C = find(diff(backupNidaq.frames2p)==3);                                %% Make sure you're frames2p here is fully BINARIZED!!
if length(C)<nidaq.nframes 
    continue
end
end
%% Adjust for diff idx effect and cut off if pulses exceed nframes (extra pulses at end - very rare)
C=C+1;                                      % adjusts to be index of actual pulse instead of shifted by 1 bc of diff 
C=C(1:nidaq.nframes);
%% Downsampling by 2p pulses

% CONDENSE THIS?
dsnidaq.visstim=nidaq.visstim(C);
dsnidaq.timeStamps2p=nidaq.timeStamps(C)';
dsnidaq.shock=nidaq.shock(C);
dsnidaq.ensure=nidaq.ensure(C);
dsnidaq.quinine=nidaq.quinine(C);
dsnidaq.frames2p=nidaq.frames2p(C);
dsnidaq.Fs=nidaq.Fs;
dsnidaq.rig=nidaq.rig;
dsnidaq.framerate=nidaq.framerate;
dsnidaq.eyeframerate=nidaq.eyeframerate;
dsnidaq.mouse=nidaq.mouse;
dsnidaq.date=nidaq.date;
dsnidaq.run=nidaq.run;

if isfield(nidaq,'quad')
dsnidaq.quad=single(nidaq.quad);
dsnidaq.runVel=single(nidaq.runningVelocity);
end 

%% All other signals downsample fine EXCEPT for licks
%Lick pulses last ~100 ms, so can miss their onset/offset if only indexing
%by 2p pulses (if the pulse happens in middle of lick signal)

lickOnsets=diff(nidaq2.licking);          % Create a temporary trace that finds the onset of licks from
                                                % the original 1000 Hz trace
lickOnsets=[0,lickOnsets];                      % adjust for the diff. 
lickOnsets(lickOnsets<0)=0;

Ctemp=[1,C];                        % create 1-idx frame# 
for ii=2:(length(Ctemp))
   dsnidaq.licking(ii-1)=sum(lickOnsets(Ctemp(ii-1):Ctemp(ii)-1));          %extract for time period between frames, adjusted for window edges
end                                                                         %sum across lickOnsets that occur w/in isolated window
%% Plots to compare downsampled vs standard

%clean this up
if graph==1
figure
subplot(3,2,1)
plot(dsnidaq.timeStamps2p,dsnidaq.shock)
hold on
plot(nidaq.timeStamps, nidaq.shock)
legend('Downsampled','original');
title('Shock')

subplot(3,2,2)
plot(dsnidaq.timeStamps2p,dsnidaq.quinine);
hold on
plot(nidaq.timeStamps, nidaq.quinine)
title('Quinine'), ylim([-5 5])

subplot(3,2,3)
plot(dsnidaq.timeStamps2p,dsnidaq.ensure);
hold on
plot(nidaq.timeStamps, nidaq.ensure)
title('Ensure'), ylim([-5 5])

subplot(3,2,4)
plot(dsnidaq.timeStamps2p,dsnidaq.licking);
hold on
plot(nidaq.timeStamps, nidaq.licking)
title('Licking'), ylim([-5 5])

subplot(3,2,5)
plot(dsnidaq.timeStamps2p,dsnidaq.frames2p);
hold on
plot(nidaq.timeStamps, nidaq.frames2p)
title('Frames 2p')

subplot(3,2,6)
plot(dsnidaq.timeStamps2p,dsnidaq.visstim);
hold on
plot(nidaq.timeStamps, nidaq.visstim)
ylim([-1 6]), title('Visstim')
end
%% Save structure
[filepath]=fileparts(nidaqPath)
Filename=[filepath,'\',nidaq.mouse,'_',num2str(nidaq.date),'_', num2str(nidaq.run),'_','dsNidaq'];
save(Filename, '-struct', 'dsnidaq');
success=1;
end
