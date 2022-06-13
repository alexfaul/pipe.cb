%%%%%%%%%Startup file for Great Lakes jobs submission%%%%%%%%%%%
% 1. Create paths to turbo-experiments, turbo-newPipeline, Fiji 
% 2. Set-up root to the experiment folders 
% 3. Save the directory for xdayWrapper 

function xdaymouseID(mouse)
%%% mouseid is CHAR (eg 'I03')
% ex:
% > xdaymouseID('I03')
%%%%%%%%%%
%%% Function will print stimdir--the paths to all possible files to match for that mouse
%%% And save those path directories in savdir in greatlakes folder

%%% 1. Run xdaystartup.m,
%%% 2. Decide which files to match 
%%% 3. THEN run xdayWrapper with path to stimdir 
%%%[ e.g. '/nfs/turbo/umms-crburge/Code/AF/newPipeline/pipe.cb/greatlakes/xday/workspace/temp/I03.mat']
%%% and the [index positions] of the files you want to be matched across days
%%% ex: >xdayWrapper( '/nfs/turbo/umms-crburge/Code/AF/newPipeline/pipe.cb/greatlakes/xday/workspace/temp/I03.mat', 1:3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Set-up%%
mouseid=mouse;
root ='/nfs/turbo/umms-crburge/AFdata/2p2019/Experiments/';

root= strcat(root,mouseid);
ext = 'Suite2p_dff.mat';
stimdir = findFILE(root,ext,'LNX')

savdir = strcat('/nfs/turbo/umms-crburge/Code/AF/newPipeline/pipe.cb/greatlakes/xday/workspace/temp/',mouseid,'.mat')
save(savdir,'stimdir');
%disp(stimdir)
% disp(savedir)
end







