function runConcat(nidaqs,fullRoot)

for ii=1:length(nidaqs)
[path, fName{ii}]=fileparts(nidaqs{ii});  % getting filenames of nidaqs found
end
C=strsplit(path,'\')                      % 

%% try to find nidaqs associated with runs registered together by 
% finding unique TIFF names in the same folder as the suite2p outputs

if nargin==2
idcs   = strfind(fullRoot,filesep);
newdir = fullRoot(1:idcs(end-2)-1); %taking path from before folder holding TIFFs

%IMPORTANT: If you do not put TIFFs in a separate folder below main folder or suite2p changes
%%its folder structure, THIS WILL BREAK HERE. Change the (end-2)to adjust 
%% Finding names of tiffs to match to nidaq runs found
% automatic way of detecting which runs were registered together. 
ext = '.tif';
tifDir = findFILE(newdir,ext);
runsTemp = regexp(tifDir,'_\d\d\d_','match');
A=runsTemp(find(~cellfun(@isempty,runsTemp)));

B = (cellfun(@(x) [x{:}],A,'un',0));
nidaqRuns=unique(extractBetween(B,'_','_'));
runDirs=nidaqs(find(contains(nidaqs,nidaqRuns)));   % isolate nidaq files matching the runs detected from tiff names

if ~isempty(runDirs)
dlgtitle = [(C{end}),' nidaq Runs Found: ', nidaqRuns{:}] %,)];
dims = [1 80];
    
prompt = {'Enter desired dff treatment corresponding to the runs registered together (if correct runs found listed in dialog box title): 1=percentile, 2=rolling'};
answer = inputdlg(prompt,dlgtitle,dims);   
    
runs = nidaqRuns;
dffTreatment = str2num(answer{1});
end 

if (nargin<2 || isempty(runDirs))
    fullRoot=[]
    runDirs=[]
    
    runsTemp = regexp(nidaqs,'_\d\d\d_','match');
    B = cellfun(@(x) [x{:}],runsTemp,'un',0);
    nidaqRuns=extractAfter(B,'_');

    dlgtitle=(nidaqRuns)
    prompt = {'Enter nidaq runs to be treated together corresponding to the runs registered together:','Enter dff treatment for each run: 1=percentile, 2=rolling'};
    answer = inputdlg(prompt,dlgtitle,dims);
    
    runs = str2num(answer{1});
    dffTreatment = str2num(answer{2});
end

    runsConcatenate=arrayfun(@(x) sprintf('%03d', mod(x,100)), runs, 'UniformOutput', false);     
    assignin('caller','runsConcatenate',runsConcatenate);
    % dffTreatment=arrayfun(@(x) sprintf('%03d', mod(x,100)), dffTreatment, 'UniformOutput', false);    
    assignin('caller','dffTreatment',dffTreatment);
end