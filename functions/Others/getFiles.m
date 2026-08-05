function [filesSortedRelative, filesSortedAbsolute, numberOfFolders] = getFiles(startPath, stringCriterion, selectCriterion)
% retrives folder names in a directory that correspond to an input string
% criterion

% get folder names in this directory
files = dir(startPath);

files = files(~[files.isdir]);

%% filter first stage
% select only those which correspond to string criterion
filesMask = contains({files(:).name}, stringCriterion);

% filter out the non-relevant directories
filesSortedRelative = {files(filesMask).name};


%% filter 2nd stage
% select only those which correspond to string criterion
filesMask = contains(filesSortedRelative, selectCriterion);

% filter out the non-relevant directories
filesSortedRelative = filesSortedRelative(filesMask);



% add startPath to get full path name
filesSortedAbsolute = fullfile(startPath, filesSortedRelative);

% number of relevant folders
numberOfFolders = numel(filesSortedRelative);

end
