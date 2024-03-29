function [features]=generate_features(eeg, Fs)
%% Initialize
% clear all
% load('eeg.mat')
 if (nargin<2);
 Fs=173.61;
 end
 
x=size(eeg); % this should be (r,c)(subject,signal) order
if x(1)>x(2) % Flip array if a different orientation is loaded in: (signal,subject)
    eeg=eeg';
    samples=x(2);
end 

samples=x(1);        %Num of signals
%% Bandpass Raw Data

Fn = Fs/2;              %Nyquist Frequency (Hz) to normalize
range=[0.5 25];         %Range in Hz
range_Wn=range./Fn;      %Normalized Nyquist frequency of range
n = 5;                                        
[rb,ra] = butter(n,range_Wn,'bandpass');            %bandpassing each band (theta,delta,alpha,beta) separately was unstable, not
                                                    %great attenuation of signals outside range and
for i=1:samples;                                     %created frequency drift plus relative power in any given band wasn't representative                                      
 Filt_eeg(i,:)=filtfilt(rb, ra, eeg(i,:));  %bidirectional filtering
end
clear ra rb i Fn range range_Wn n
%% Wavelet to get lower frequency (delta/theta)
%bands_wav={'delta_a5';'theta_d5';'alphabeta_d4';'range'};
for i=1:samples;
    [C(i,:),L]=wavedec(eeg(i,:),5,'sym9'); %decompose 5 levels, using sym9 mother wavelet.                                                   
end                                                %db3 and db5 were also good choices, but sym9 produced best a5
cut=(sum(L(1:3)))+1;                             %SUM of all elements after d4
delta_a5=C;bandwidth=C;
for i=1:samples;                                  
delta_a5(i,L(1)+1:end)=0;                    %delta cutting out from signal for all subjects
bandwidth(i,cut:end)=0;                      %cutting out from signal everything above about 20 Hz
end 

for i=1:samples;
    Wav.delta(i,:)=waverec(delta_a5(i,:),L,'sym9');     %denoised ecg reconstructed from a5 only
    Wav.bandwidth(i,:)=waverec(bandwidth(i,:),L,'sym9'); %denoised ecg reconstructed from a5,d5,d4
end 
for j=1:samples  ;  
    pw_tot.delta(j,:)= mean(Wav.delta(j,:).^2);             %Find total power in A5
    pw_tot.bandwidth(j,:)= mean(Wav.bandwidth(j,:).^2);     %Find total power in A5, d5, d4                   
end 

a5_rel_pw=100*(pw_tot.delta./pw_tot.bandwidth);   %Find relative power of a5 compared to relevant physiological signals(0.5-about 20Hz), 
                                                     %roughly corresponding to delta band
clear i j cut C L bandwidth delta_a5
%% Generate Features

% The main conclusions
% of these works were to recommend ? = 1 and m the highest possible value, with N > 5m!
% 
% S. M. Pincus, the inventor of ApEn, suggested to use a small value of embedding dimension m (usually m = 2 or 3), an epoch duration of at least 10m�20m
% 
% 10^3

rms_eeg=rms(Filt_eeg');                      %root square mean by subject of bandpass filtered data
r=std(Filt_eeg)*0.2;
for i=1:samples;                                  %Get sample entropy     
   samp_ent(i,:)=(SampEn(2,r(i),Filt_eeg(i,:))*10);  %optimal embedded dimension is 2 for class 1 data, 5 for class 2 but less of drop for class 2 in 2nd embedded dimension
end                                                   % x10 to put on same scale for classifiers that are scale sensitive
                                                       %Cao's method (not shown bc won't be recalculating embedded dimension)
features=[rms_eeg;samp_ent';a5_rel_pw' ]' %taking rms and sample entropy of bandpassed signal, relative power of wavelet reconstructed a5
%Have to flip orientations of some features
end

