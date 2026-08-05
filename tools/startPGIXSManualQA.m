function summary = startPGIXSManualQA(repoRoot, launchGui, reportPath)
% startPGIXSManualQA  Prepare files and reports for a manual GUI QA session.
%
% Example:
%   addpath(fullfile(pwd, 'tools'));
%   summary = startPGIXSManualQA(pwd, false)
%   summary = startPGIXSManualQA(pwd, true)  % also launches PGIXS
%   summary = startPGIXSManualQA(pwd, false, fullfile(tempdir, 'qa_report.md'))

    if nargin < 1 || isempty(repoRoot)
        repoRoot = pwd;
    end
    if nargin < 2 || isempty(launchGui)
        launchGui = false;
    end
    if nargin < 3 || isempty(reportPath)
        reportPath = fullfile(repoRoot, 'docs', 'PGIXS_manual_gui_qa_report_current.md');
    end

    addpath(fullfile(repoRoot, 'tools'));
    addpath(genpath(fullfile(repoRoot, 'functions')));
    addpath(genpath(fullfile(repoRoot, 'gui', 'tab1')));
    addpath(genpath(fullfile(repoRoot, 'gui', 'tab3')));

    sampleReports = createPGIXSManualQASamples(fullfile(repoRoot, 'manual_qa_samples'));
    preflight = runPGIXSPreflight(repoRoot);
    reportPath = writePGIXSManualQAReport(reportPath, repoRoot, ...
        'run separately before release decision');

    summary = struct();
    summary.SampleReports = sampleReports;
    summary.Preflight = preflight;
    summary.ReportPath = reportPath;
    summary.LaunchedGui = false;

    if launchGui
        PGIXS();
        summary.LaunchedGui = true;
    end
end
