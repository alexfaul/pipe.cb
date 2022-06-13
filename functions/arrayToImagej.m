function imp = arrayToImagej(array, typestr, ijroot,name)
    %IJARRAY2PLUS Converts MATLAB array to ImageJ ImagePlus object
    %   imp = ijarray2plus(array, typestr)
    %   array size [nRows,nCols,nFrames,nPlanes]
    % Edited Arthur Sugden 180731
    % Edited A faulkner 20/05/20, 1/27/22
    if nargin < 2 || isempty(typestr), typestr = class(array); end  
    if nargin < 3, disp('please pass/correct imageJ path in tiffLoop');
    ijroot = '/sw/med/centos7/fiji'; end
    %'/nfs/turbo/umms-crburge/Code/AF/newPipeline/pipe.cb/greatlakes/Fiji/Fiji.app'; end %greatlakes root 
    %this is default for YB, will have to change for other setups
    


%%%
    if nargin < 4, name = 'stack'; end %oh we can improve this!! Parse file name to actually name tiffs
     
    arraytype = class(array);
    runImageJ(ijroot); 
    [height, width, nframes, nplanes] = size(array);

    %% Handle different bit depths and RGB images
    
    if nplanes > 1
        assert(nplanes == 3, 'color channel (4th dim) must be size 3 -- RGB');
        assert(strcmp(arraytype, 'uint8'), 'RGB arrays must be 8 bit for ImageJ');
        process = @ij.process.ColorProcessor;
    else
        switch arraytype
            case {'uint8'}
                process = @ij.process.ByteProcessor;
            case {'uint16'}
                process = @ij.process.ShortProcessor;
            case {'uint32', 'single', 'double'}
                process = @ij.process.FloatProcessor;        
            otherwise
                error('Image type not supported');
        end

        if any(strcmp(arraytype, {'uint32', 'double'}))
            array = single(array); % uint32, double not supported in imagej
            arraytype = 'single';
        end
    end

    %% Make a stack and convert each frame
    
    stack = ij.ImageStack(width, height);

    for i = 1:nframes
        ip = process(width, height);
        if nplanes == 3
            % RGB
            rPix = reshape(array(:, :, i, 1)', width*height, 1);
            gPix = reshape(array(:, :, i, 2)', width*height, 1);        
            bPix = reshape(array(:, :, i, 3)', width*height, 1);                
            ip.setRGB(rPix, gPix, bPix);
        else
            % Grayscale
            pixels = reshape(array(:, :, i)', width*height, 1);
            ip.setPixels(pixels);                   
        end
        
        stack.addSlice('frame', ip);
    end

    imp = ij.ImagePlus(name, stack);

    %% Convert
    % If RGB, do not convert
    if nplanes == 3, return; end

    % dummy object to disable automatic scaling in StackConverter
    dummy = ij.process.ImageConverter(imp);
    dummy.setDoScaling(0);  % this is a static property

    if ~strcmp(arraytype, typestr)
        if nframes > 1
            converter = ij.process.StackConverter(imp);
        else
            converter = ij.process.ImageConverter(imp);
        end
        
        switch typestr
            case 'uint8'
                converter.convertToGray8;
            case 'uint16'
                converter.convertToGray16;
            case {'single','uint32','double'}
                converter.convertToGray32;
        end
    end
end
