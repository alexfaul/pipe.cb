function readSbxEphysCheck(path,customLabels, freq, server, rig )               
%for online check on 2p computer of signals
sbxDirs=path; %duplicate to run downsample
%%  I/O
%   PATH     =  full path of file, with or without .sbx extension (eg:
%               'Z:\AFdata\2p2019\N07\191111_N07\N07_191111_001.sbx')
%   QC       =  Whether to output quality control graphs, metrics, and
%               warnings. T/F, 1/0 boolean expected, default TRUE
%   FREQ     =  frequency that nidaq data is acquired (NOT frequency of resonance scanner/imaging
%               collected). Expects numeric (ex: 1000)
%   SERVER   =  String specifying server. Default is 'yb-crburge'
%   RIG      =  String specifying 2-photon rig used. Default is 'medusa'

%   nidaq    =  structure with all nidaq channels
%% Find and construct filenames and path
if contains(path,'.sbx')==1;
    root=extractBefore(path, '.sbx');
elseif contains(path,'.sbx')==0;
    root=path;
    path=[path '.sbx'];
end 

infpath   =  path  ;                  % add extension of native scanbox outputs
epath     = [root '.ephys'];          % add extension of native scanbox outputs
ipath     = [root '.mat']  ;
qpath     = [root '_quadrature.mat']  ;
nidaqpath = [root '_nidaq.mat']  ;

%% Identify mouse, date, and run from name

[fullRoot,filename,~] = fileparts(root);

fileSplit=strsplit(filename,'_');   
for ii=1:length(fileSplit);
    temp=fileSplit{ii};
    [num, status] = str2num(temp);                  %%% only mousename can't be converted w str2num
    if status==1 ;
        if num>999
          date=str2num(temp);
        else
            run=temp;
        end 
    elseif contains(temp,'run')==1;
        run=temp;
    elseif status==0 && contains(temp,'run')==0; 
        mouse=temp;
    end 
end 
%should add check for this maybe?
%% Fill in assumptions to initialize function
    if nargin < 3, freq = 1000;  end
    if nargin < 4, server = 'yb-crburge'; end
    if nargin < 5, rig = 'medusa'; end
    
if strcmpi(rig, 'medusa') && date>=200810 %switched config again 8/10
	medusa = struct( ...  
        'shock', 1, ...  
        'frames2p', 2, ...
        'quinine', 3, ...
        'EEG', 4, ...
        'licking', 5, ...
        'ensure', 6, ...
        'visstim', 7, ...
        'EMG', 8 ...
    );
end 
if strcmpi(rig, 'medusa') && date<200810 && date>=200425
	medusa = struct( ...  
        'frames2p', 1, ...  
        'quinine', 2, ...
        'shock', 3, ...
        'EEG', 4, ...
        'licking', 5, ...
        'ensure', 6, ...
        'visstim', 7, ...
        'EMG', 8 ...
    );
end 
if strcmpi(rig, 'medusa') && date>=191206 && date<200425
	medusa = struct( ...  
        'shock', 1, ...  
        'frames2p', 2, ...
        'quinine', 3, ...
        'EEG', 4, ...
        'ensure', 5, ...  %% switched ensure and licking 4/11/21, looked to be switched on graphs due to variability in "ensure" response
        'licking', 6, ...
        'visstim', 7, ...
        'EMG', 8 ...
    );
elseif strcmpi(rig, 'medusa')&& date<=191205
    medusa = struct( ...  
        'shock', 1, ...  
        'frames2p', 2, ...
        'quinine', 3, ...
        'EEG', 4, ...
        'licking', 5, ...
        'ensure', 6, ...
        'visstim', 7, ...
        'EMG', 8, ...
        'counter',9 ...
    );
end 

%% reference sbx info 
     try info=readSbxInfo(infpath,ipath); %%%swapped inputs 2/9/22
        catch
        sprintf('Problem opening sbx info file for %s %s %s, sbx file inaccessible, corrupted, or missing. nidaq=0', mouse, date, run) %6f
        success = 0;
        nidaq=[]
        return
     end  
    info.config.Magnification=str2num(info.config.magnification_list(info.config.magnification,:));
    info.config=rmfield(info.config,{'magnification_list','magnification'});
    
    %% Open the ephys file and read
ephys = fopen(epath);

     try data = fread(ephys, 'float');
        catch
        sprintf('Problem opening ephys file for %s %s %s, ephys file inaccessible, corrupted, or missing. nidaq=0', mouse, date, run) %6f
        success = 0;
        nidaq=[]
        return
     end   
    %data = fread(ephys, 'float');
    fclose(ephys);
   % nchannels=9;

    convert_to_sec = length(data)./freq;
    length_mov = info.nframes./info.framerate;
    nchannels = round(convert_to_sec./length_mov);
    
    
    sz = size(data');
    if nchannels > 10 || nchannels < 6
        try  data = reshape(data', nchannels, sz(2)/nchannels);
        catch
        sprintf('Problem with ephys file for %s %s %s, number channels = %s, nidaq=0', mouse, date, run, nchannels) %6f
        success = 0;
        nidaq=[]
        return
        end   
    end 
    data = reshape(data', nchannels, sz(2)/nchannels); 
    
   fclose('all');

%% Data into nidaq struct   
% Set the channels based on username and rig
nidaq.rig = rig;
nidaq.data = data';
    if strcmp(rig, 'medusa')
        nidaq.channels = medusa;        %if we get more than 1 rig, add here in else statement
    end    
% Add all channels to output
    channelnames = fieldnames(nidaq.channels);
    for i = 1:length(channelnames)
        if nidaq.channels.(channelnames{i}) <= nchannels
            nidaq.(channelnames{i}) = nidaq.data(:, nidaq.channels.(channelnames{i}))';
        end
    end
%Tack on additional useful info
nidaq.timeStamps(1,:) = ((1:size(nidaq.data, 1)) - 1)'./freq;
nidaq.Fs = freq;
nidaq.nframes = info.nframes;
nidaq.mouse=mouse;
nidaq.date=date;
nidaq.run=run;
nidaq.framerate=info.framerate;
nidaq.eyeframerate=info.framerate;
nidaq.config=info.config;

%% Make sure has more than 4 channels
if nchannels < 4
        sprintf('Problem with ephys file, NOT ENOUGH CHANNELS for %s %s %s, number channels = %s, nidaq=0', mouse, date, run, nchannels) %6f
        success = 0;
        nidaq=[]
        return   
end 
%% Filter for graphs only, will output raw data
datanew(:,1) = detrend(nidaq.EEG);
datanew(:,2) = detrend(nidaq.EMG);
 
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',58,'HalfPowerFrequency2',62, ...
               'DesignMethod','butter','SampleRate',1000);

nidaq.EEG(1,:) = filtfilt(d,datanew(:,1));
nidaq.EMG(1,:) = filtfilt(d,datanew(:,2));

%% binarize lick trace
for ii=1:length(nidaq.licking);                             
    if nidaq.licking(ii)>=1.5;
    nidaq.licking(ii)=4;
    else 
    nidaq.licking(ii)=0;
    end 
end
%% Flip and binarize Visstim and ensure signal 

%nidaq=rmfield(nidaq,'data');%% Quality check
%Is there Visstim?
nidaq.visstim=(nidaq.visstim.*(-1))+5;   %visstim is inverted
nidaq.visstim(nidaq.visstim<3)=1;
nidaq.visstim(nidaq.visstim>3)=5;
num_visstim=sum(diff(nidaq.visstim)==4)
%Is there Shock

nidaq.ensure(nidaq.ensure<1)=0;
nidaq.ensure(nidaq.ensure>3)=6;
%% Binarize frames2p, figure out number of pulses
% frames2p is when image is grabbed, used for aligning imagine with nidaq
% data (imagine Fs=15.63, nidaq Fs=1000 12/01/21)

nidaq.frames2p(nidaq.frames2p<3)=1;
nidaq.frames2p(nidaq.frames2p>3)=4;
num_pulses=sum(diff(nidaq.frames2p)==3);

if num_pulses == nidaq.nframes
    disp('Correct number of pulses for number of frames')
elseif num_pulses < nidaq.nframes
    disp('Fewer than expected number of pulses!')
elseif num_pulses < 0.1*nidaq.nframes
    disp('Check scanbox tower/psoc, far too pulses')
elseif num_pulses > 1.01* nidaq.nframes && num_pulses < (1.75*nidaq.nframes)
    disp('Extra pulses at end')
elseif num_pulses > (1.75*nidaq.nframes)
    disp('~ 2 times as many pulses as frames, eye camera acquired at 2x framerate. Take every other pulse when indexing for imaging')
    nidaq.eyeframerate=(nidaq.framerate*2);
end
% IDEA: POP UP GUI TO DECIDE WHAT TO DO?
%% Populate graphs 
%close all
set(0,'DefaultFigureWindowStyle','docked')
e=[mouse,' ',num2str(date),' ', num2str(run),' ',' Num Pulses=', num2str(num_pulses),'Fs=',num2str(nidaq.framerate)];

figure 
sgtitle(e)
subplot(4,2,1)
plot(nidaq.timeStamps,nidaq.shock);
title('Shock'), ylim([-5 5]), xlim([0 120])
subplot(4,2,2)
plot(nidaq.timeStamps,nidaq.quinine);
title('Quinine'), ylim([-5 5]), xlim([0 120])
subplot(4,2,3)
plot(nidaq.timeStamps,nidaq.ensure);
title('Ensure'), ylim([-5 5]), xlim([0 120])
subplot(4,2,4)
plot(nidaq.timeStamps,nidaq.licking);
title('Licking'), xlabel('Time (s)'), ylim([-5 5]), xlim([0 120])
subplot(4,2,5)
plot(nidaq.timeStamps,nidaq.frames2p);
title('Frames 2p'), xlim([0 30])
subplot(4,2,7)
plot(nidaq.timeStamps,nidaq.visstim);
ylim([-1 6]), title('Visstim'), xlabel('Time (s)'), xlim([0 120]);
subplot(4,2,6) 
plot(nidaq.timeStamps,nidaq.EEG);
title('EEG'), xlim([0 30])
subplot(4,2,8)
plot(nidaq.timeStamps,nidaq.EMG);
title('EMG'), xlim([0 30]);
ft=[fullRoot,'\',mouse,'_',num2str(date),'_', num2str(run),'.jpeg'];
saveas(gcf,(ft))
%% Open quad and load in
try quad=load(qpath);
    nidaq.quad=quad.quad_data;
    nidaq.runningVelocity=[0,abs(diff(quad.quad_data))];
    catch
    sprintf('No quadrature file found, skipping writing quadrature')
end 
%% Find trial onsets and offsets by when the pulse has a change from previous measurement
nidaq.trialonsets      = find(diff(nidaq.visstim)>=1)+1';   %%% temp offset variable bc if trial is rewarded, the offset is wrong bc monkeylogic hates me
nidaq.trialoffsetsTemp = find(diff(nidaq.visstim)<=-1)+1';  %All of these are +1 bc of fencepost of diff
nidaq.ensureOnsets     = find(diff(nidaq.ensure)>=1)+1';

numVisstim=min(length(nidaq.trialonsets),length(nidaq.trialoffsetsTemp))
%% Find # of offsets and onsets, account for visstim being started early or imaging ending during a trial
if nidaq.visstim(1)==5,               %if visstim trace already at 5
nidaq.onsetOffBy1=1;
else nidaq.onsetOffBy1=0; end 

if nidaq.visstim(end)==5,
nidaq.offsetOffBy1=1;
else nidaq.offsetOffBy1=0; end 

   
if nidaq.onsetOffBy1==1 && nidaq.offsetOffBy1==0  
    nidaq.trialoffsetsTemp = nidaq.trialoffsetsTemp((2:end));  
elseif nidaq.onsetOffBy1==0 && nidaq.offsetOffBy1==1
    nidaq.trialonsets = nidaq.trialonsets(1:end-1);  
elseif nidaq.onsetOffBy1==1 && nidaq.offsetOffBy1==1
    nidaq.trialonsets = nidaq.trialonsets(1:end-1);                                          %by adding the startIdx, fix off by 1 of diff AND resetting index from isolating section
    nidaq.trialoffsetsTemp = nidaq.trialoffsetsTemp(2:end);
end                                                                            %fewer offsets than onsets, indicating last visstim still on, so skip the last visstim
%%% checked logic of this again on 12/01/21, all good 

%% adjusting the trialoffsets to accomodate that event markers in MonkeyLogic are fucky

% if there is an ensure peak, the visual stimulus pulse picked up by the nidaq reads as "off" ~55
% nidaq frames before the first ensure pulse. Monkeylogic is counting the gray
% background as visual stim on, so it APPEARS the orientation visual stim
% is still on when Ensure is delivered. This is not the case with the ML
% configs used through 2022.
% changing the event markers creates abberant
% visstim pulses in the middle of blanks between trials, so
% unfortunately... this is a preferable solution

nidaq.trialoffsets=nidaq.trialoffsetsTemp;
for ii=1:length(nidaq.trialoffsets)
 [~,loc]=findpeaks(nidaq.ensure(nidaq.trialonsets(ii):nidaq.trialoffsetsTemp(ii)));
 if length(loc)>=1 % alternate way of having "if" statement about presence of ensure pulses
     nidaq.trialoffsets(ii)=nidaq.trialonsets(ii)+loc(1)-55; %55 frames was average difference b/w visstim OFF and ensure pulse delivery (using test event markers in MonkeyLogic)
    nidaq.visstim(nidaq.trialoffsets(ii)+1:nidaq.trialoffsetsTemp(ii))=1;
 end
end
%% 
if length(nidaq.ensureOnsets)>0  %if there are ensure pulses, then complete following loop. 
for ii=1:length(nidaq.ensureOnsets) 
 n=nidaq.ensureOnsets(ii);
 [~,idx(ii)]=min(abs(nidaq.trialoffsets-n));
end 
 
nidaq.rewardedTrials=unique(idx) 
nidaq.unrewardedTrials=setdiff((1:numVisstim),nidaq.rewardedTrials);
%% run alignment to downsample
% 
%   [dsnidaq,~]=alignNidaq(sbxDirs); 
%  
% for ii=1:length(dsnidaq.trialoffsetsTemp)
%     idx=[]
%   [~,idx] =findpeaks(dsnidaq.licking(dsnidaq.trialonsets(ii):dsnidaq.trialoffsetsTemp(ii)+5)); %150 extra frames to account for size of licking pulse
%     lickingByTrial(ii)=length(idx)
% end
 
%% percentage of licks that happen in rewarded trials vs unrewarded trials
%%%%%%
for ii=1:length(nidaq.trialoffsets)
    idx=[]
  [~,idx] =findpeaks(nidaq.licking(nidaq.trialonsets(ii):nidaq.trialoffsets(ii)+150)); %150 extra frames to account for size of licking pulse
   lickingByTrial(ii)=length(idx)
end
%%%%%%%%%%%
%% 
binaryLickbyTrial= lickingByTrial;
binaryLickbyTrial(binaryLickbyTrial>1)=1;

lickCSntrials    = binaryLickbyTrial(nidaq.unrewardedTrials);
lickCSplustrials = binaryLickbyTrial(nidaq.rewardedTrials);

faRate=sum(lickCSntrials)/(length(nidaq.unrewardedTrials));
% CR=length(lickCSntrials==0); %%%oh this doesnt work
hitRate=sum(lickCSplustrials)/(length(nidaq.rewardedTrials));
% miss=length(lickCSplustrials==0);
%%%%%%%%%%%%%%%%%%%

loglinearSignalAdj=length(nidaq.rewardedTrials)/length(nidaq.trialonsets);
loglinearNoiselAdj=length(nidaq.unrewardedTrials)/length(nidaq.trialonsets);

loglinearSignalTrials=(2*loglinearSignalAdj)+length(nidaq.rewardedTrials);
loglinearNoiseTrials=(2*loglinearNoiselAdj)+length(nidaq.unrewardedTrials);
faRateLogLinear=(sum(lickCSntrials)+loglinearNoiselAdj)/loglinearNoiseTrials
hitRateLogLinear=(sum(lickCSplustrials)+loglinearSignalAdj)/loglinearSignalTrials


nidaq.dPrime=norminv(hitRate)-norminv(faRate)
nidaq.dPrimelogLinear = norminv(hitRateLogLinear)-norminv(faRateLogLinear)
nidaq.aPrime=0.5+(((hitRate-faRate)*(1+hitRate-faRate))/((4*hitRate)*(1-faRate)))

nidaq.lickingByTrial=lickingByTrial;
end 

%% Save nidaq in .mat and pictures of first 60/30s of traces to ensure working as expected
%% pop up checks for behavior
if isfield(nidaq,'dPrimelogLinear')==1
    dPrint=num2str(nidaq.dPrimelogLinear)
    aPrint=num2str(nidaq.aPrime)
    percLickPrint=[num2str(sum(lickCSplustrials)),'/',num2str(length(nidaq.rewardedTrials))]
    percLickUnPrint=[num2str(sum(lickCSntrials)),'/',num2str(length(nidaq.unrewardedTrials))]
    behavior=[' d-prime (loglinear)=',dPrint,'  a-prime=',aPrint,' Licking RT: ',percLickPrint,'  Licking UT: ',percLickUnPrint]
else
    behavior=' - no rewarded behavior'
end 

if nargin<2,
    label=[mouse,' ',num2str(date),' ', num2str(run),' '];
else
   label=customLabels;
end
e=[label,' Fs=',num2str(nidaq.framerate),' ',behavior];

figure
sgtitle(e)
subplot(3,1,1)
plot(nidaq.visstim)
hold on
plot(nidaq.shock)
legend('visstim','shock');
title('Vis Stim Trace and Shock TTLs')
hold off
subplot(3,1,2)
plot(nidaq.visstim)
hold on
plot(nidaq.ensure)
legend('visstim','ensure');
title('Vis Stim Trace and Reward')
hold off
subplot(3,1,3)
plot(nidaq.visstim)
hold on
plot(nidaq.licking)
lgd2 = legend('visstim', 'licking');
title('Vis Stim Trace and Licking')
hold off

ft=[fullRoot '\' label 'behavioral performance.jpeg'];
saveas(gcf,(ft))

FileName=[fullRoot,'\',mouse,'_',num2str(date),'_', num2str(run),'_','nidaq'];
save(FileName, '-struct', 'nidaq');


  [~]=alignNidaq(sbxDirs,'PC'); 


end