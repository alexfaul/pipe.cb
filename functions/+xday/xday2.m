classdef xday2 < handle
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
        sbxDirs
        dffDirs
        savedir
        warpdir
        initial_dates
        initial_runs
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
        
%         function obj=xday2(dffDirs, varargin)
%             [paths]=unique(cellfun(@fileparts,sbxDirs,'UniformOutput',false))
%             ext = repmat({'Suite2p_dff.mat'},length(paths),1);
%             dffDirs=cellfun(@findFILE,paths,ext,'UniformOutput',false)
%         end 
        
        function obj = xday2(sbxDirs, varargin)
            % Initialization step. Default is to use all dates in
            % a directory. Optionally can pass a vector of dates
            % to only loop over certain days. If empty brackets are
            % passed to 'dates', will use GUI to select date folders
            % from mouse directory. 

            %% Parse inputs
            p = inputParser;
            p.CaseSensitive = false;

            % optional inputs
            addOptional(p, 'force', false);
            addOptional(p, 'server', []);
            
            
         
            % parse
            parse(p, varargin{:});
            p = p.Results;

            % determine server and base directory
            
            filepathTemp=char(sbxDirs{1})
            idcs   = strfind(filepathTemp,filesep);
            basedir = filepathTemp(1:idcs(end-1)-1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement (ex: update of Suite2p that changes file locations)

            
            
            
            
            obj.savedir = sprintf('%s%s%s', basedir, filesep, 'xday'); 
            if ~exist(obj.savedir, 'dir') || p.force
                mkdir(obj.savedir)
            end

            % get dates to warp and align
%             if isempty(p.dates)
                
                
                
                pattern = ['_\d{6}_'];

                for ii=1:length(sbxDirs)
                [~,filename]=fileparts(char(sbxDirs{ii}));
                out= regexp(filename, pattern,'match');
                dates(ii)=str2double(extractBetween(out,'_','_'));
                end 
                
                obj.initial_dates = sort(dates);

%             end 
                
                
            % get runs
            runs = {};
            pattern = ('_\d{3}.sbx');
                for ii=1:length(sbxDirs)
                [~,filename,ext]=fileparts(char(sbxDirs{ii}));
                temp=[filename ext];
                out= regexp(temp, pattern,'match');
                runs{ii}=extractBetween(out,'_','.sbx');
                end 
            obj.initial_runs = runs;

            % save newly minted xday tracking object
            obj.mouse = filepathTemp(idcs(end-2)+1:idcs(end-1)-1);                                            % expects Fall.mat to be 3 folders up. This WILL break w diff file arrangement (ex: update of Suite2p that changes file locations)
            obj.sbxDirs = sbxDirs;
            obj.pars = p;
            
            
      
            
            save([obj.savedir filesep 'xday_obj'],'obj','-v7.3')
        end
       
        
    end
    
end