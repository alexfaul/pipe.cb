function New_signal_ds = makenewvisstimsignal(data, AbsoluteTrialStartTime,startTime)
%%data is full size nidaq
if nargin<3, startTime=1
end 
clearvars -except data AbsoluteTrialStartTime startTime
fulllength= zeros(1,length(data(:,1))+10000);

for i=1:length(AbsoluteTrialStartTime(:,6))

    Hourtime(i) = AbsoluteTrialStartTime(i,4)*60*60;
    Minutetime(i) = AbsoluteTrialStartTime(i,5)*60;
    Secondtime(i) = AbsoluteTrialStartTime(i,6);
    
    Abstime(i) = Hourtime(i) + Minutetime(i) + Secondtime(i);
    
end

Abstimenew = round((Abstime - min(Abstime)) *1000) + 4000; %% put nothing in 1st 4 s 

fulllength(Abstimenew) = 5;
blankTime=4001;
for j=blankTime:1:length(fulllength); %%%
    
    if sum(fulllength(j-3600:j))>1 %%%% 3600
    New_signal(j) = 5;
    else 
    New_signal(j) = fulllength(j);
    end
end


twopframes = find(diff(data(:,2))>1);


New_signal_ds = New_signal(twopframes);

aa=find(diff(New_signal_ds)>1);
length(aa)
% 
% temp=zeros(1,startTime)
% temp2=[temp New_signal_ds temp]
% temp3=temp2

% 
% C = find(diff(frames2p)==3);
% C=C+1;                                      % adjusts to be index of actual pulse instead of shifted by 1 bc of diff 
% C=C(1:nframes);

% % 
% % temp=zeros(1,123)
% % temp2=[temp New_signal_ds]
% % temp3=temp2(1:14000)
% % 
% % figure
% % plot(temp3)
% % hold on
% % plot(T03_210204_002visstim)



end 
