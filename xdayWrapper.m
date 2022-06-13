function xdayWrapper(mousedir,index)
%%%%%%%%%
%%% mousedir expects path to .mat workspace with list of .sbx files that ~can~
%%% be run through xDay. 
%%% index is numerical value to subselect which files are to be matched in xday (eg 1:3)
% ex: >xdayWrapper('/nfs/turbo/umms-crburge/Code/AF/newPipeline/pipe.cb/greatlakes/xday/workspace/temp/I03.mat', 1:3)

stimdir=load(mousedir)

stimDir=stimdir.stimdir(index)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% FIND SBX FILES %%%%%%%%%%%%%%%%%%%%%%%%%%
root ='/nfs/turbo/umms-crburge/AFdata/2p2019/Experiments/';

%yb
%root ='Z:/AFdata/2p2019/Experiments/';

% load('mouseid.mat');
mouseid='T01'
root= strcat(root,filesep,mouseid);
ext = 'Suite2p_dff.mat';
stimdir = findFILE(root,ext,'LNX');
% % stimDir = stimdir(3:end-1)


%  step 1 --> obj = pipe.xday.xday(mouse, varargin)
%        Initialize class object.
obj=xday.xdayAttempts(stimdir);  

%%%%%%%%%%%%
%%change index pulling from suite2p to config NOT nidaqAligned.config
%%Fix dffCalc so it doesnt skip the rest of the function

% step 2 --> obj.warp(obj, varargin)
% Register FOVs using imregdemons.
obj.warp(obj,'OS','LNX')  %%%%%%%%%%%% CHANGE OS IN WARP FOR NOW

% step 3 --> obj.besttarget(obj, best_day, bad_days)
% Validate registered FOVs.
obj.best_day = 8; %index
obj.bad_days = 9;
obj.besttarget(obj)             %pick best target from %% Reg_FOV_each_target
% step 4 --> obj.finalizetarget(obj, bad_days_to_keep, matched_days)
%        (only if step 3 had bad_days) Fix registration hiccups.
obj.finalizetarget(obj)
% %     % step 5.0 --> obj.align(obj, varargin)
% %     %        Align warped masks using CellReg algorithm.
%obj.align()
% %     % PLOTTING (outside of class, see pipe.xday)
% %     % --------
% %     % step 5.1 --> linear_plot_aligned_ROIs(obj, cell_score_threshold)
% %     %        Plot each ROI aligned across days cropped around
% %     %        mean centroid.
%   %%%%%%%%%%%%%%%%%%
%    linear_plot_aligned_ROIs(obj, 0.4) 
%    xday_qc_metrics(obj, 0.5)
% % %     %        Plot a number of simple metrics to check the quality of
% % %     %        your alignments.
 %%%%%%%%%%%%%%%%%%Still needs debug!!  xday_qc_metrics(obj, cell_score_threshold) 
% % %     % step 6 --> obj.getids(obj, varargin)
% % %     %        Write cell id and cell score .txt files for xday alignments.

%   obj.getids(obj, 'save_tag', '-yb2 attempt')
% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %%%%%%%%%%testdir = load stimdir %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %%% ISSUES:
% % % % 1. npixels (mircons per cell)
% % % % 2. Able to pass a path
% % % % 3. cell_score_threshold setting
% % % % 4. warp.m gaussian blur values
% % %     %check size of the kernel 
% % %     %optimizing sigma, we want the h-size (kernel size0 to 6sigmas 
% % %     %sigma= (k-1)/6
% % %     %fullwidth at half maximum measure (fwhm)
% % %     %shape of the curve stays preserved, the trunk stays gaussian 
% % % % 5. path of xday to the correct folder 
% % % % 6. warp.m: 72 [D, ~] = imregdemons(stack(:, :, i), target, ...
% % % %             [600 600 600 600], ...
% % % %             'AccumulatedFieldSmoothing', 2.5, 'PyramidLevels', 4);
% % % % 7. .mat file directly save to object 
% % 
% % % %%%Notes
% % %if the objects is not found, drag the object into the workspace from the
% % %folder 
% % %optimize path line 9 of runImageJ
% % %optimize path line 15 in writeTiff 

end