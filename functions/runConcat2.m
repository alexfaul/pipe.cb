function runConcat2(nidaqs,fullRoot, dffTreatment)
for ii=1:length(nidaqs)
[path, fName{ii}]=fileparts(nidaqs{ii});  % getting filenames of nidaqs found
end
C=strsplit(path,'\')                      % 

%% try to find nidaqs associated with runs registered together by finding TIFFs present in same folder as 'suite2p' folder
% finding unique TIFF names in the same folder as the suite2p outputs

idcs   = strfind(fullRoot,filesep);
newdir = fullRoot(1:idcs(end-2)-1); %go up 2 folder levels from the Fall.mat file
%% Find Run # of Tiffs to match to nidaq
%By taking unique 3 digit numbers (TIFF naming scheme is Sut3_191127_001_-1 etc)
 ext = '.tif';
tifDir = findFILE(newdir,ext);
runsTemp = regexp(tifDir,'_\d\d\d_','match');
A=runsTemp(find(~cellfun(@isempty,runsTemp)));

B = (cellfun(@(x) [x{:}],A,'un',0));
nidaqRuns=unique(extractBetween(B,'_','_'));
runDirs=nidaqs(find(contains(nidaqs,nidaqRuns)));   % isolate nidaq files matching the runs detected from tiff names
runsConcatenate=[];                                            % set empty vector to still return if can't find correct nidaq files
if ~isempty(runDirs)
    runsConcatenate=runDirs;
end 
%% Pop up dialogue for run Treatment if not specified
if nargin>3
    dlgtitle = [(C{end}),' nidaq Runs Found: ', nidaqRuns{:}] %,)];
dims = [1 80];
    
prompt = {'Enter desired dff treatment corresponding to the runs registered together (if correct runs found listed in dialog box title): 1=percentile, 2=rolling'};
answer = inputdlg(prompt,dlgtitle,dims);   
    
dffTreatment = str2num(answer{1});
end 
%% Pass back to workspace
%     runsConcatenate=arrayfun(@(x) sprintf('%03d', mod(x,100)), runs, 'UniformOutput', false);     
    assignin('caller','runsConcatenate',runsConcatenate);
    % dffTreatment=arrayfun(@(x) sprintf('%03d', mod(x,100)), dffTreatment, 'UniformOutput', false);    
    assignin('caller','dffTreatment',dffTreatment); 
end