function align(obj)
% Run the CellReg algorithm to align masks across 
% days. Apply calculated warp registration to masks
% for each day and pass to CellRegAuto (script to run
% CellReg with no GUI. 

% get frame size
% if ~isfield(obj.pars, 'sz')
%     sbxpath = pipe.path(obj.mouse, obj.final_dates(1), obj.final_runs{1}(end), 'sbx', obj.pars.server);
%     info = pipe.metadata(sbxpath);
%     sz = info.sz;
% else
%     sz = obj.pars.sz;
% end
%% 
load(obj.warpdir)
sz=[size(AllWarpFields{1}{1})]
%if the cell 1,1 and cell 1,2 AllwarpFields = obj.warpfields(best_days)
%for ww = 1:length(AllWarpFields)
%     AllWarpFields{1,ww}= obj.warpfields;
% end% 


if isempty(obj)
edges= [10, 10, 10, 10];
else
    edges=obj.pars.edges;
end

% ensure that pixel_size is set
if isempty(obj.pixelsize_microns)
%     obj.pixelsize_microns = 1.53; %measured on Medusa 01/25/2022 by
%     using pollen grain to go end to end knowing pixel dimensions are 512
%     (h) x 796(w) compared to micron movement registered on knobby control
%     on scope
%%%%%%%%%%%%%
% assuming all same magnification
% have a catch for if not same and put into bad days
    obj.pixelsize_microns=(1.53*obj.magnification(1))
    disp('1x zoom with 16x objective is ~1.5 microns per pixel on Medusa ...')
end


%AWFbackup=AWF;
%% 

for ii=1:length(AllWarpFields)    
%                 Buffer = zeros(512,796);
        cols_remove_l = edges(1);
        cols_remove_r = edges(2);
        rows_remove_top = edges(3);
        rows_remove_bottom = edges(4);
        col_buffer_r = zeros(492,cols_remove_r,2);  
        col_buffer_l = zeros(492,cols_remove_r,2);  

        % now buffer back in both dimensions
        WarpField = [col_buffer_l AllWarpFields{1,ii}{1,ii} col_buffer_r];
        row_buffer_top = zeros(rows_remove_top, size(WarpField,2), ...
                           size(WarpField,3));
        row_buffer_bottom = zeros(rows_remove_bottom, size(WarpField,2), ...
                           size(WarpField,3));
        WarpField = [row_buffer_top; WarpField; row_buffer_bottom];
        AllWarpFields{1,ii}{1,ii}=WarpField;
end 

sz=[size(AllWarpFields{1}{1})]



% Get all masks for all days
% masks_original = zeros(sz(1), sz(2), length(AllWarpFields)); %changed from final_dates
% for i = 1:length(obj.final_dates)
%     date = obj.final_dates(i);
%     run = obj.final_runs{i}(end);
%     simp = pipe.load(obj.mouse, date, run, 'simpcell', ...
%                obj.pars.server);
%     masks_original(:,:,i) = (simp.masks');
% end


for mm=1:length(obj.dffDirs)
testData=load(char(obj.dffDirs{mm}));
cellIdx=find(testData.suite2pData.iscell(:,1)==1);
for ii=1:length(cellIdx)
    emptyMat=zeros(size(testData.suite2pData.ops.meanImg,1),size(testData.suite2pData.ops.meanImg,2));
        emptyMat2=zeros(size(testData.suite2pData.ops.meanImg,1),size(testData.suite2pData.ops.meanImg,2));

   for kk=1:length(testData.suite2pData.stat{1,cellIdx(ii)}.xpix)
   
   emptyMat(testData.suite2pData.stat{1,cellIdx(ii)}.ypix(kk),testData.suite2pData.stat{1,cellIdx(ii)}.xpix(kk))=testData.suite2pData.stat{1,cellIdx(ii)}.lam(kk);
   emptyMat2(testData.suite2pData.stat{1,cellIdx(ii)}.ypix(kk),testData.suite2pData.stat{1,cellIdx(ii)}.xpix(kk))=ii;

   end 
   ROIs(:,:,ii)=emptyMat;
   ROIs2(:,:,ii)=emptyMat2;
end
masks_original{mm}(:,:,:)= ROIs;
masks_original2(:,:,mm)=sum(ROIs,3);
masks_original3(:,:,mm)=sum(ROIs2,3);
clear ROIs emptyMat cellIdx emptyMat2 %ROIs2 
end
masks_original2=round(masks_original2)
test2=sum(ROIs2,3);

% figure
% imshow(emptyMat2,[])
unique(nonzeros(test2))
% Unpack all masks into filtermask tensors and 
% flattened warped masks
    best_day=obj.best_day;
    obj.warpfields = AllWarpFields{best_day};
%changed from 


filtermasks = {};
masks_warped = zeros(sz(1), sz(2), length(obj.dffDirs)); 

% figure
% imshow(warp_mask,[])
% test=AllWarpFields{4}{5};
% figure
% imshow(test(:,:,1),[])
for i = 1:length(AllWarpFields) %% originally final_dates
    masks = masks_original3(:,:,i);
    top_ind = round(max(masks(:)));
    masks_tensor = zeros(top_ind, sz(1), sz(2));
    for k = 1:top_ind
        bin_mask = masks == k;
        warp_mask = imwarp(bin_mask, obj.warpfields{i});
        warp_mask = warp_mask > 0;
        % Add a fabricated pixel to the top row of the image
        % if there is no mask. Ziv cannot handle empties
        if sum(warp_mask(:)) == 0
%             disp(['Empty mask in day ' ...
%                   num2str(obj.dffDirs{i}) ...
%                   ', ROI index ' num2str(k) ...
%                   ', adding fake pixel...']);
            fake_pixel_ind = randi([1 sz(2)], 1, 1);
            warp_mask(1, fake_pixel_ind) = 1;
        end
        masks_tensor(k,:,:) = warp_mask;
        masks_warped(:,:,i) = masks_warped(:,:,i).*(warp_mask == 0);
        masks_warped(:,:,i) = masks_warped(:,:,i) + (warp_mask.*k);
    end
    filtermasks{i} = masks_tensor; 
end

% populate properties
obj.masks_original = masks_original3;
obj.masks_warped = masks_warped;


% run cellreg (ziv algo)
[ ...
optimal_cell_to_index_map, ...
registered_cells_centroids, ...
centroid_locations_corrected, ...
cell_scores, ...
cell_scores_positive, ... 
cell_scores_negative, ...
cell_scores_exclusive, ...
p_same_registered_pairs, ...
all_to_all_p_same_centroid_distance_model, ...
centroid_distances_distribution, ...
p_same_centers_of_bins, ...
uncertain_fraction_centroid_distances, ...
cdf_p_same_centroid_distances, ...
false_positive_per_distance_threshold, ...
true_positive_per_distance_threshold ...
] = xday.CellRegAuto(filtermasks, obj.pixelsize_microns);

% create aligned data structure
xdayalignment.cell_to_index_map = optimal_cell_to_index_map;
xdayalignment.registered_cells_centroids = registered_cells_centroids;
xdayalignment.centroid_locations_corrected = centroid_locations_corrected;
xdayalignment.cell_scores = cell_scores;
xdayalignment.cell_scores_positive = cell_scores_positive;
xdayalignment.cell_scores_negative = cell_scores_negative;
xdayalignment.cell_scores_exclusive = cell_scores_exclusive;
xdayalignment.p_same_registered_pairs = p_same_registered_pairs;
xdayalignment.centroid_distances_distribution = centroid_distances_distribution;
xdayalignment.p_same_centers_of_bins = p_same_centers_of_bins;
xdayalignment.uncertain_fraction_centroid_distances = uncertain_fraction_centroid_distances;
xdayalignment.cdf_p_same_centroid_distances = cdf_p_same_centroid_distances;
xdayalignment.false_positive_per_distance_threshold = false_positive_per_distance_threshold;
xdayalignment.true_positive_per_distance_threshold = true_positive_per_distance_threshold;
xdayalignment.all_to_all_p_same_centroid_distance_model = all_to_all_p_same_centroid_distance_model;

% populate properties
obj.xdayalignment = xdayalignment;

% save object
save([obj.savedir filesep 'xday_obj'],'obj','-v7.3')

end