function [ FList ] = findFILE(DataFolder,ext,os)
% DataFolder, extList, OS all expect characters inputs ('example')

% This function reads all file names contained in Datafolder and it's subfolders
% with the extension given by extList variable
% This will find directory of ALL files under your root that contain the extList
% in ANY part of the file name (so use ext that is specific - preferably filetype!)

%% example inputs
%DataFolder='Z:\AFdata\2p2019\'
%extList={'jpg','peg','tif','iff','png','sbx'};
%extList={'bhv2'}; 
%extList={'sbx','avi'};
%OS='PC'
%% Set parsing parameters
persistent extList 
persistent OS 
extList=ext;

if nargin < 3 
     os = 'PC'; 
end         %assumes windows file name rules
OS=os;




if(strcmpi(OS,'PC') || strcmpi(OS,'Win')) || strcmpi (OS,'Mac')
    NameSeparator='\';
elseif(strcmpi(OS,'LNX') || strcmpi(OS,'Linux'))        % should actually test this on Mac and Linux...
    NameSeparator='/';
end

DirContents=dir(DataFolder);
FList=[];

%% %find files - recursive loop

for i=1:numel(DirContents)
    if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..')))
        if(~DirContents(i).isdir)
            extension=DirContents(i).name;
            if(numel(find(contains(extension,extList)))~=0)
                FList=cat(1,FList,{[DataFolder,NameSeparator,DirContents(i).name]});
            end
        else
            getlist=findFILE([DataFolder,NameSeparator,DirContents(i).name],extList,os);
            FList=cat(1,FList,getlist);
        end
    end
end

end