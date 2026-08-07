function outDir = build_dist_package(outDir)
% build_dist_package  Assemble a Tab3-excluded, compile-ready copy of
% the PGIXS app.
%
% Copies functions/, gui/tab1/, and dist/PGIXS.m (which excludes the
% Tab3 "2D Analysis" tab) into outDir, ready to hand to the MATLAB
% Application Compiler (deploytool) or mcc. gui/tab3 is never touched.
%
% Usage:
%   build_dist_package()               % writes to dist/build (default)
%   build_dist_package('C:/some/path') % writes to a custom folder
%
% See dist/README.md for the full packaging/compiling walkthrough.

    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    distRoot = fullfile(repoRoot, 'dist');

    if nargin < 1 || isempty(outDir)
        outDir = fullfile(distRoot, 'build');
    end

    if isfolder(outDir)
        rmdir(outDir, 's');
    end
    mkdir(outDir);

    fprintf('Assembling Tab3-excluded PGIXS package in:\n  %s\n\n', outDir);

    copyfile(fullfile(repoRoot, 'functions'), fullfile(outDir, 'functions'));
    fprintf('  copied functions/\n');

    copyfile(fullfile(repoRoot, 'gui', 'tab1'), fullfile(outDir, 'gui', 'tab1'));
    fprintf('  copied gui/tab1/\n');

    copyfile(fullfile(distRoot, 'PGIXS.m'), fullfile(outDir, 'PGIXS.m'));
    fprintf('  copied dist/PGIXS.m (Tab3-excluded entry point)\n');

    % Safety check: make sure nothing under gui/tab3 leaked in and that
    % the entry point really has no Tab3 wiring.
    assert(~isfolder(fullfile(outDir, 'gui', 'tab3')), ...
        'gui/tab3 must not be present in the distribution package.');
    entryText = fileread(fullfile(outDir, 'PGIXS.m'));
    assert(~contains(entryText, 'tab3'), ...
        'dist/PGIXS.m still references tab3 -- check the file.');

    fprintf('\nPackage assembled successfully (%d files).\n', numel(dir([outDir, filesep, '**', filesep, '*.*'])));
    fprintf('Next: open MATLAB Application Compiler (deploytool), set\n');
    fprintf('  Main file = %s\n', fullfile(outDir, 'PGIXS.m'));
    fprintf('and build. See dist/README.md for details.\n');
end
