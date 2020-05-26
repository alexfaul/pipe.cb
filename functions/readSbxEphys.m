function [nidaq, success] = readSbxEphys(path, freq, server, rig)               
%%  I/O
%   PATH     =  full path of file, with or without .sbx extension (eg:
%               'Z:\AFdata\2p2019\N07\191111_N07\N07_191111_001.sbx')
%   FREQ     =  frequency that nidaq data is acquired (NOT frequency of resonance scanner/imaging
%               collected). Expects numeric (ex: 1000)
%   SERVER   =  String specifying server. Default is 'yb-crburge'
%   RIG      =  String specifying 2-photon rig used. Default is 'medusa'
%   INTERP2P =  Whether to interpolate 2p pulses, default FALSE. Need to
%               write function to actually interpolate if need be....

%   nidaq    =  structure with all nidaq channels
%% Find and construct filenames and path
if contains(path,'.sbx')==1;
    root=extractBefore(path, '.sbx');
else contains(path,'.sbx')==0;
    root=path;
end 

infpath   =  path  ;                  % add extension of native scanbox outputs
epath     = [root '.ephys'];          % add extension of native scanbox outputs
ipath     = [root '.mat']  ;
qpath     = [root '_quadrature.mat']  ;
nidaqpath = [root '_nidaq.mat']  ;

%% see if already written

% % if isfile(nidaqpath)                                % File exists.
% %   prompt = 'File exists, overwrite? [y/n]-Enter';   % prompt user to overwrite nidaq file with new one or keep old
% %   str = input(prompt,'s');                          % do not move on until y/n key is pressed
% %         if strcmp(str, 'n')==1;
% %         disp('File not overwritten')
% %         success=1;
% %         nidaq=[];
% %         return
% %         elseif strcmp(str, 'n')~=1
% %             disp('Overwriting...')
% %         end  
% % end
 
%how to count number of characters - useful
% b=num2str(a)
% out=numel(regexprep(b,'[\s-]+',''))
%% Identify mouse, date, and run from name

[fullRoot,filename,~] = fileparts(root);

fileSplit=strsplit(filename,'_');
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
    elseif status==0 && contains(temp,'run')==0; 
        mouse=temp;
    end 
end 
%should add check for this maybe?
%% Fill in assumptions to initialize function
    if nargin < 2, freq = 1000;  end
    if nargin < 3, server = 'yb-crburge'; end
    if nargin < 4, rig = 'medusa'; end
    
    %% Change channel inputs below based on your rig/reconfig dates of nidaq
if strcmpi(rig, 'medusa') && date>=200425
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
        'licking', 5, ...
        'ensure', 6, ...
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
     try  info=readSbxInfo(infpath, ipath); %removed passing date, parses from filename
        catch
        sprintf('Problem opening sbx info file for %s %s %s, sbx file inaccessible, corrupted, or missing. nidaq=0', mouse, date, run) %6f
        success = 0;
        nidaq=[]
        return
     end  
    
    %% Open the ephys file and read
    ephys = fopen(epath);
     try  data = fread(ephys, 'float');
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
%% 
%nidaq=rmfield(nidaq,'data');%% Quality check
%Is there Visstim?
nidaq.visstim=(nidaq.visstim.*(-1))+5;
nidaq.visstim(nidaq.visstim<3)=1;
nidaq.visstim(nidaq.visstim>3)=5;
num_visstim=sum(diff(nidaq.visstim)==4)
%Is there Shock
%% Figure out number of pulses

figure 
plot(nidaq.frames2p)
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
%% Open quad and load in
try quad=load(qpath);
    nidaq.quad=quad.quad_data;
    nidaq.runningVelocity=[0,abs(diff(quad.quad_data))];
    catch
    sprintf('No quadrature file found, skipping writing quadrature')
end 
%% Save nidaq in .mat and pictures of first 60/30s of traces to ensure working as expected

ft=[fullRoot,'\',mouse,'_',num2str(date),'_', num2str(run),'.jpeg'];
saveas(gcf,(ft))
FileName=[fullRoot,'\',mouse,'_',num2str(date),'_', num2str(run),'_','nidaq'];
save(FileName, '-struct', 'nidaq');
success=1;
%% pop up checks for behavior
figure
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

end