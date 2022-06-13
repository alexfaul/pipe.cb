classdef xdayAttempts < handle
    % Class that includes functions for aligning FOVs and masks
    % across days

    % ALIGNMENT
    % ---------
    % step 1 --> obj = pipe.xday.xday(mouse, varargin)
    %        Initialize class object.
    % step 2 --> obj.warp(obj, varargin)
    %        Register FOVs using imregdemons. 
    % step 3 --> obj.besttarget(obj, best_day, bad_days)
    %        Validate registered FOVs.
    % step 4 --> obj.finalizetarget(obj, bad_days_to_keep, matched_days)
    %        (only if step 3 had bad_days) Fix registration hiccups.
    % step 5.0 --> obj.align(obj, varargin)
    %        Align warped masks using CellReg algorithm.
    % step 6 --> obj.getids(obj, varargin)
    %        Write cell id and cell score .txt files for xday alignments.
    % 
    % PLOTTING (outside of class, see pipe.xday)
    % --------
    % step 5.1 --> linear_plot_aligned_ROIs(obj, cell_score_threshold)
    %        Plot each ROI aligned across days cropped around 
    %        mean centroid.
    % step 5.2 --> xday_qc_metrics(obj, cell_score_threshold)
    %        Plot a number of simple metrics to check the quality of
    %        your alignments. 
    
    % class properties
    properties
        pars
        mouse
        magnification
        sbxDirs
        dffDirs
        savedir
        warpdir
        initial_dates
        initial_runs
        best_day
        bad_days
        badwarpfields
        warptarget
        warpfields
        final_dates
        final_runs
        pixelsize_microns
        masks_original
        masks_warped
        xdayalignment
    end
    
    % class methods
    methods
        warp(obj, varargin)
        besttarget(obj, best_day, bad_days)
        finalizetarget(obj, bad_days_to_keep, matched_days)
        align(obj)
        getids(obj, varargin)
     
        
        function obj = xdayAttempts(dffDirs,varargin)
            
   
            p = inputParser;
            p.CaseSensitive = false;dffDirs;

            % optional inputs
            addOptional(p, 'force', true);
            addOptional(p, 'server', []);
            
            % parse
            parse(p, varargin{:}); %%unused now but may come in handy later
            p = p.Results;
            
            
            filepathTemp = fileparts(char(dffDirs{1}));
            idcs   = strfind(filepathTemp,filesep);
            basedir = filepathTemp(1:idcs(end)-1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement (ex: update of Suite2p that changes file locations)
            
            obj.savedir = sprintf('%s%s%s', basedir, filesep, 'xday'); 
            obj.dffDirs=dffDirs;
            if ~exist(obj.savedir, 'dir') || p.force
                mkdir(obj.savedir)
            end

        end 
    end 
end 
