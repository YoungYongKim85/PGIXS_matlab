function report = runPGIXSPreflight(repoRoot)
% runPGIXSPreflight  Summarize local readiness for PGIXS manual QA.
%
% Example:
%   addpath(fullfile(pwd, 'tools'));
%   report = runPGIXSPreflight(pwd)

    if nargin < 1 || isempty(repoRoot)
        repoRoot = pwd;
    end
    functionsPath = fullfile(repoRoot, 'functions');
    if isfolder(functionsPath)
        addpath(genpath(functionsPath));
    end

    report = struct();
    report.RepoRoot = char(repoRoot);
    report.Platform = computer;
    report.IsWindows = ispc;
    report.IsLinux = isunix && ~ismac;
    report.FileSeparator = filesep;
    report.PathSeparator = pathsep;
    report.RepoRootExists = isfolder(repoRoot);
    report.RepoRootHasNonASCII = any(double(char(repoRoot)) > 127);
    report.MATLABVersion = version;
    report.MATLABRelease = version('-release');
    report.HasFmincon = hasFunction('fmincon');
    report.HasDrawline = hasFunction('drawline');
    report.HasDrawrectangle = hasFunction('drawrectangle');
    report.HasGetpts = hasFunction('getpts');
    report.HasCoreTestFile = isfile(fullfile(repoRoot, 'tests', 'run_pgixs_core_tests.m'));
    report.CoreTestCommand = "run('tests/run_pgixs_core_tests.m')";

    sampleDir = fullfile(repoRoot, 'manual_qa_samples');
    report.ManualQASampleDir = sampleDir;
    gixsSample = fullfile(sampleDir, 'pgixs_manual_qa_gixs_2dinfo.mat');
    trxsSample = fullfile(sampleDir, 'pgixs_manual_qa_trxs_2dinfo.mat');
    report.HasGIXSSample = isfile(gixsSample);
    report.HasTrXSSample = isfile(trxsSample);
    [report.GIXSSampleLoads, report.GIXSSampleMessage] = validateSample(gixsSample, 'GIXS');
    [report.TrXSSampleLoads, report.TrXSSampleMessage] = validateSample(trxsSample, 'TrXS');
    report.ManualQASampleValidation = validatePGIXSManualQASamples(repoRoot);
    report.ReadyForSyntheticTab3Smoke = report.ManualQASampleValidation.OK;
    report.ReadyForGIXSSolveQA = report.HasFmincon && report.HasDrawrectangle;
    report.ReadyForLineCutQA = report.HasDrawline;
    report.ReadyForTrXSAutoIndexQA = report.HasGetpts;
end

function tf = hasFunction(functionName)
    tf = exist(functionName, 'file') == 2 || exist(functionName, 'builtin') == 5;
end

function [ok, message] = validateSample(filePath, expectedMode)
    ok = false;
    message = '';
    if ~isfile(filePath)
        message = 'Sample file is missing.';
        return;
    end
    try
        [~, loadReport] = loadPGIXS2DInfo(filePath, expectedMode);
        ok = loadReport.OK;
        if ~ok
            message = strjoin(loadReport.MissingRequired, ', ');
        end
    catch ME
        message = ME.message;
    end
end
