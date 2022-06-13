function besttarget(obj, best_day, bad_days)
% Function to aid in alignment of FOV registered using
% imregdemons. Creates best alignment obj.warpfields. If
% bad_days is empty, this is populated by a finalized best set
% of warpfields. If bad_days exist, creates tiffs to help user
% solve poorly registered days and populates obj.warpfields 
% with temporary two_stage warpfields. 
%% edge size hardcode
% edges= [10, 10, 10, 10];
%% 
edges=obj.pars.edges;
% populate properties of xday class
obj.warptarget = obj.best_day;
best_day=obj.best_day;
% load AllWarpFields
AWF = load(obj.warpdir);
AWF = AWF.AllWarpFields;

% load in the non registered FOV
% UnregMov = pipe.io.read_tiff([obj.savedir filesep ... 
%     'FOV_NONregistered_across_days.tif']);
for ii=1:(length(AWF))
 tempTif=imread([obj.savedir filesep ... 
    'FOV_NONregistered_across_days.tif'],ii);
UnregMov(:,:,ii)=tempTif;
end 
% If there are NO bad days, finalize target day and
% build warpfields property. If there ARE bad days, 
% create tiff stacks of bad days warped through other days.

AllWarpFields=AWF;
AWFbackup=AWF;
for ii=1:length(AllWarpFields)    
        %Buffer = zeros(512,796);
        cols_remove_l = edges(1);
        cols_remove_r = edges(2);
        rows_remove_top = edges(3);
        rows_remove_bottom = edges(4);
        
        col_buffer_r = zeros(size(AllWarpFields{1,ii}{1,ii},1),cols_remove_r,2); %hardcode  
        col_buffer_l = zeros(size(AllWarpFields{1,ii}{1,ii},1),cols_remove_l,2); %hardcode

        % now buffer back in both dimensions
        WarpField = [col_buffer_l AllWarpFields{1,ii}{1,ii} col_buffer_r];
        row_buffer_top = zeros(rows_remove_top, size(WarpField,2), ...
                           size(WarpField,3));
        row_buffer_bottom = zeros(rows_remove_bottom, size(WarpField,2), ...
                           size(WarpField,3));
        WarpField = [row_buffer_top; WarpField; row_buffer_bottom];
        AllWarpFields{1,ii}{1,ii}=WarpField
        disp(size(WarpField));
end 

% AWF=AllWarpFields

if nargin < 3 || isempty(bad_days)

    % register to best_day
    RegMov = zeros(size(UnregMov));
    for i = 1:length(obj.dffDirs)
        img = imwarp(UnregMov(:,:,i), AllWarpFields{1,best_day}{i});
        RegMov(:, :, i) = img;
    end

    % write tiff stack registered to best_day
    writeTiff(RegMov,[obj.savedir filesep ...
        'FOV_registered_to_day_' num2str(best_day) '_final.tif'])

    % write tiff stack registered to best_day
    writeTiff(UnregMov,[obj.savedir filesep ...
        'FOV_NONregistered_to_day_' num2str(best_day) '_final.tif'])

    % add finalized warpfields to xday object
    obj.warpfields = AllWarpFields{1,best_day}{i};
    %disp(size(obj.warpfields));
    obj.final_dates = obj.initial_dates;  %%%maybe go through and make these useful??
%     obj.final_runs = obj.initial_runs;
    obj.badwarpfields = '- no conflicts -';
  

else
    % create all possible warpfields for each two-stage registration
    badwarps = cell(length(bad_days));
    for j = 1:length(bad_days)
        k = bad_days(j);
        % preallocate
        for i = 1:length(obj.initial_dates)
            for m = 1:length(obj.initial_dates)
                two_stage_AWF{i}{m} = [];
            end
        end
        RegMov = [];
        for i = 1:length(obj.initial_dates)
            two_stage_AWF{i}{k} = AllWarpFields{1,best_day}{i} + AllWarpFields{1,best_day}{i}{k};
            img = imwarp(UnregMov(:,:,k), two_stage_AWF{i}{k});
            img2 = cat(3, UnregMov(:, :, best_day), img);
            RegMov = cat(3, RegMov, img2);
        end

        % save two_stage warps for each bad day 
        warpdir = [obj.savedir filesep 'bad_day_' num2str(k) ...
            '_warpfields.mat'];
        save(warpdir, 'two_stage_AWF', '-v7.3');

        % write tiff stack registered to best_day
        pipe.io.write_tiff(RegMov, [obj.savedir filesep ...
            'bad_day_' num2str(k) '_to_day_' num2str(best_day) ...
            '_two_stage.tif']);

        % hold onto your two stage warps in xday until you solve them
        badwarps{j} = two_stage_AWF;
    end

    % add temporary bad warpfields to xday object
    obj.badwarpfields = badwarps;
    obj.bad_days = bad_days;

    % output for user
    disp(['Two-stage registration done: Go to ' obj.savedir])
    disp(['    1. Please look through your bad_day_N_to_day_' ...
          num2str(best_day) '_two_stage.tifs'])
    disp('       to determine best two-stage registration path.')
    disp('    2. Run obj.finalizetarget...')
end

% save xday object
save([obj.savedir filesep 'xday_obj'],'obj','-v7.3');

end