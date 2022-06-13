function warp(obj, varargin)
% warp - Register the mean image of all days to each other using
% the imregdemons algorithm. 

%% Parse inputs
tic %starttimer
p = inputParser;
p.CaseSensitive = false;

% optional inputs
addOptional(p, 'n', 5); % sigma n, for first gaussian blurring kernel
addOptional(p, 'm', 10); % sigma m, for second gaussian blurring kernel
addOptional(p, 'edges', [10, 10, 10, 10]); %How many pixels to cut off, play with this if doesn't work great
addOptional(p,'pmt',0); %default to green, 1 is red. no fckn clue what to do if both
addOptional(p,'OS','LNX'); %default to  PC. obj.warp(obj,'OS','LNX') on Great Lakes
% parse
% parse(p, varargin{:});
parse(p);

p = p.Results;
edges = p.edges;
OS=p.OS
% % if ~exists(OS)
% %     OS='PC'
% % end
obj.pars.edges = p.edges;

%% Switch path syntax depending on OS
for ii=1:length(obj.dffDirs)
      pathTemp=obj.dffDirs{ii};
      if(strcmpi(OS,'PC') || strcmpi(OS,'Win')) || strcmpi (OS,'Mac')
        obj.dffDirs{ii}=strrep(pathTemp,'/','\');   
      elseif(strcmpi(OS,'LNX') || strcmpi(OS,'Linux'))        % should actually test this on Mac and Linux...
        obj.dffDirs{ii}=strrep(pathTemp,'\','/');

      end
end

%% 
% figure
% imshow(suite2pData.ops.refImg,[])
% figure
% imshow(suite2pData.ops.meanImg,[])
for ii=1:length(obj.dffDirs)
    
    load(char(obj.dffDirs{ii}))
    unReg_FOV(:,:,ii)=suite2pData.ops.refImg;
    magnification(ii)=suite2pData.config.Magnification;
    config(ii)=suite2pData.config(:);
    clear suite2pData
end 

NonReg_FOV=cast( int16(unReg_FOV ), 'uint16' );
writeTiff(NonReg_FOV, [obj.savedir filesep 'FOV_NONregistered_across_days'], class(NonReg_FOV))

% % % % % % % % % % % % % % % % % % % 
% crop and save 
NonReg_FOV_cropped2 = NonReg_FOV(edges(3):end-edges(4)-1,edges(1):end-edges(2)-1,:);
writeTiff(NonReg_FOV_cropped2,[obj.savedir filesep 'FOV_NONregistered_across_days_cropped']);

% preallocate AllWarpFields
nIm=length(obj.dffDirs) %number of images 

for i = 1:nIm
    for j = 1:nIm
        AllWarpFields{i}{j} = [];
    end
end
% register

sz = size(NonReg_FOV_cropped2);
% curr_im=5
parfor curr_im = 1:nIm
    other_im_ind = setdiff(1:nIm, curr_im);
    
    % process image by blurring
    stack = NonReg_FOV_cropped2(:, :, other_im_ind);
    target = NonReg_FOV_cropped2(:, :, curr_im);
    f_prime = double(target) - double(imgaussfilt(target, p.n));
    g_prime = f_prime./(imgaussfilt(f_prime.^2, p.m).^(1/2));   
    target = g_prime;
    % set curr image warpfield to zeros
    AllWarpFields{curr_im}{curr_im} = zeros(sz(1), sz(2), 2);
    for i = 1:size(stack, 3)
        f_prime = double(stack(:, :, i)) - double(imgaussfilt(double(stack(:, :, i)), p.n));
        g_prime = f_prime./(imgaussfilt(f_prime.^2, p.m).^(1/2));
        stack(:, :, i) = g_prime;
    end

    for i = 1:size(stack,3)
        [D, ~] = imregdemons(stack(:, :, i), target, ...
            [500 500 500 500], ...
            'AccumulatedFieldSmoothing', 2.5, 'PyramidLevels', 4);
            
        % pad wirth zeros to get correct dimensions
        %Buffer = zeros(512,796);
        cols_remove_l = edges(1);
        cols_remove_r = edges(2);
        rows_remove_top = edges(3);
        rows_remove_bottom = edges(4);
        col_buffer_l = zeros(size(D,1),cols_remove_l,size(D,3));
        col_buffer_r = zeros(size(D,1),cols_remove_r,size(D,3));  
        
        % now buffer back in both dimensions
        WarpField = [col_buffer_l D col_buffer_r];
        row_buffer_top = zeros(rows_remove_top, size(WarpField,2), ...
                           size(WarpField,3));
        row_buffer_bottom = zeros(rows_remove_bottom, size(WarpField,2), ...
                           size(WarpField,3));
        WarpField = [row_buffer_top; WarpField; row_buffer_bottom];
        AllWarpFields{curr_im}{other_im_ind(i)} = WarpField;
    end
end
% figure
% test=AllWarpFields{1,4}{1,8}
% test2=test(:,:,1)
% test3=test(:,:,2)
% figure
% imshow(test2,[])
% figure
% imshow(test3,[])


AllWarpFields2=AllWarpFields
for ii=1:length(AllWarpFields2)    
        Buffer = zeros(512,796);
        cols_remove_l = edges(1);
        cols_remove_r = edges(2);
        rows_remove_top = edges(3);
        rows_remove_bottom = edges(4);
        col_buffer_r = zeros(sz(1),cols_remove_r,2);  
        col_buffer_l = zeros(sz(1),cols_remove_r,2);  

        % now buffer back in both dimensions
        WarpField = [col_buffer_l AllWarpFields2{1,ii}{1,ii} col_buffer_r];
        row_buffer_top = zeros(rows_remove_top, size(WarpField,2), ...
                           size(WarpField,3));
        row_buffer_bottom = zeros(rows_remove_bottom, size(WarpField,2), ...
                           size(WarpField,3));
        WarpField = [row_buffer_top; WarpField; row_buffer_bottom];
        AllWarpFields2{1,ii}{1,ii}=WarpField
end 


% now make Reg_FOV image
RegFOV = [];
curr_im=1
for curr_im = 1:nIm
    curr_target = NonReg_FOV(:, :, curr_im);
    for i = 1:nIm
        tmp_reg_im = imwarp(NonReg_FOV(:, :, i), ...
                            AllWarpFields2{1,curr_im}{1, i});
        tmpstack = cat(3, curr_target, tmp_reg_im);
        RegFOV = cat(3, RegFOV, tmpstack);
    end
end

% figure
% imshow(tmp_reg_im,[])
% figure
% imshow(tmpstack,[])

% now write tiff of all mov reg to each other
chunk_size = nIm*2;
indtmp = 1;
for curr_day = 1:length(obj.dffDirs)
    save_dir_reg_im = [obj.savedir filesep 'Reg_FOV_each_target'];
    if ~exist(save_dir_reg_im, 'dir')
        mkdir(save_dir_reg_im)
    end
    writeTiff(RegFOV(:,:,indtmp:indtmp+chunk_size-1),[save_dir_reg_im filesep 'TargetFOV' num2str(curr_day)]);
    indtmp = indtmp + chunk_size;
end


% save
obj.magnification=magnification;
obj.warpdir = [obj.savedir filesep 'warpfields.mat'];
save(obj.warpdir, 'AllWarpFields', '-v7.3')
save([obj.savedir filesep 'xday_obj'],'obj','-v7.3')

% output for user
disp(['Registration (warping) done: Go to ' obj.savedir ])
disp('to select best warp (and identify any failed days).')
toc %endtimer
end
