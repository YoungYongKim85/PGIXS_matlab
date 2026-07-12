function reportPath = writePGIXSManualQAReport(outputFile, repoRoot, coreTestStatus)
% writePGIXSManualQAReport  Write a Markdown QA report seeded by preflight.
%
% Example:
%   addpath(fullfile(pwd, 'tools'));
%   writePGIXSManualQAReport(fullfile(pwd, 'docs', 'PGIXS_manual_gui_qa_report_current.md'), pwd, 'passed')

    if nargin < 2 || isempty(repoRoot)
        repoRoot = pwd;
    end
    if nargin < 3 || isempty(coreTestStatus)
        coreTestStatus = 'not run by this writer';
    end
    if nargin < 1 || isempty(outputFile)
        outputFile = fullfile(repoRoot, 'docs', 'PGIXS_manual_gui_qa_report_current.md');
    end

    preflight = runPGIXSPreflight(repoRoot);
    [folderPath, ~, ext] = fileparts(outputFile);
    if ~strcmpi(ext, '.md')
        error('PGIXS:InvalidReportFile', 'Manual QA report output must be a Markdown .md file.');
    end
    if ~isempty(folderPath) && ~isfolder(folderPath)
        mkdir(folderPath);
    end

    fileID = fopen(outputFile, 'w');
    if fileID < 0
        error('PGIXS:ReportOpenFailed', 'Could not open QA report for writing: %s', outputFile);
    end
    cleanup = onCleanup(@() fclose(fileID));

    fprintf(fileID, '# PGIXS Manual GUI QA Report\n\n');
    fprintf(fileID, '## Run Info\n\n');
    fprintf(fileID, '- Date: %s\n', char(datetime('today', 'Format', 'yyyy-MM-dd')));
    fprintf(fileID, '- MATLAB release: %s (`%s`)\n', preflight.MATLABRelease, preflight.MATLABVersion);
    fprintf(fileID, '- Platform: %s (`filesep=%s`, `pathsep=%s`)\n', ...
        preflight.Platform, preflight.FileSeparator, preflight.PathSeparator);
    fprintf(fileID, '- PGIXS workspace: `%s`\n', preflight.RepoRoot);
    fprintf(fileID, '- Tester:\n');
    fprintf(fileID, '- Dataset or sample files:\n');
    fprintf(fileID, '  - `manual_qa_samples/pgixs_manual_qa_gixs_2dinfo.mat`\n');
    fprintf(fileID, '  - `manual_qa_samples/pgixs_manual_qa_trxs_2dinfo.mat`\n\n');

    fprintf(fileID, '## Preflight\n\n');
    fprintf(fileID, '- `%s`: %s\n', preflight.CoreTestCommand, char(coreTestStatus));
    fprintf(fileID, '- `runPGIXSPreflight` summary:\n');
    writeBoolLine(fileID, 'HasFmincon', preflight.HasFmincon);
    writeBoolLine(fileID, 'IsWindows', preflight.IsWindows);
    writeBoolLine(fileID, 'IsLinux', preflight.IsLinux);
    writeBoolLine(fileID, 'RepoRootExists', preflight.RepoRootExists);
    writeBoolLine(fileID, 'RepoRootHasNonASCII', preflight.RepoRootHasNonASCII);
    writeBoolLine(fileID, 'HasDrawline', preflight.HasDrawline);
    writeBoolLine(fileID, 'HasDrawrectangle', preflight.HasDrawrectangle);
    writeBoolLine(fileID, 'HasGetpts', preflight.HasGetpts);
    writeBoolLine(fileID, 'HasGIXSSample', preflight.HasGIXSSample);
    writeBoolLine(fileID, 'HasTrXSSample', preflight.HasTrXSSample);
    writeBoolLine(fileID, 'GIXSSampleLoads', preflight.GIXSSampleLoads);
    writeBoolLine(fileID, 'TrXSSampleLoads', preflight.TrXSSampleLoads);
    writeBoolLine(fileID, 'ReadyForSyntheticTab3Smoke', preflight.ReadyForSyntheticTab3Smoke);
    writeBoolLine(fileID, 'ReadyForGIXSSolveQA', preflight.ReadyForGIXSSolveQA);
    writeBoolLine(fileID, 'ReadyForLineCutQA', preflight.ReadyForLineCutQA);
    writeBoolLine(fileID, 'ReadyForTrXSAutoIndexQA', preflight.ReadyForTrXSAutoIndexQA);
    writeBoolLine(fileID, 'ManualQASampleValidation.GIXS.OK', preflight.ManualQASampleValidation.GIXS.OK);
    writeBoolLine(fileID, 'ManualQASampleValidation.TrXS.OK', preflight.ManualQASampleValidation.TrXS.OK);
    fprintf(fileID, '- GIXS sample message: `%s`\n', preflight.GIXSSampleMessage);
    fprintf(fileID, '- TrXS sample message: `%s`\n', preflight.TrXSSampleMessage);
    fprintf(fileID, '- Notes:\n\n');

    writeManualSections(fileID);
    reportPath = outputFile;
end

function writeBoolLine(fileID, fieldName, value)
    fprintf(fileID, '  - `%s`: %s\n', fieldName, logicalText(value));
end

function textValue = logicalText(value)
    if value
        textValue = 'true';
    else
        textValue = 'false';
    end
end

function writeManualSections(fileID)
    fprintf(fileID, '## Synthetic Tab3 Smoke\n\n');
    fprintf(fileID, '- GIXS sample load:\n');
    fprintf(fileID, '- GIXS display modes:\n');
    fprintf(fileID, '- GIXS Plot/Smart/Line Cut:\n');
    fprintf(fileID, '- TrXS sample load:\n');
    fprintf(fileID, '- TrXS display modes:\n');
    fprintf(fileID, '- TrXS Plot/Smart/Line Cut/keyboard rotation:\n');
    fprintf(fileID, '- Notes:\n\n');

    fprintf(fileID, '## Representative Lab Data\n\n');
    fprintf(fileID, '- Tab1 GIXS raw load/process/save:\n');
    fprintf(fileID, '- Tab1 TrXS raw load/process/save:\n');
    fprintf(fileID, '- Tab3 GIXS load/index/save/export:\n');
    fprintf(fileID, '- Tab3 TrXS load/index/save/export:\n');
    fprintf(fileID, '- Retry/metadata failure handling:\n');
    fprintf(fileID, '- Notes:\n\n');

    fprintf(fileID, '## Findings\n\n');
    fprintf(fileID, '- Blocking issues:\n');
    fprintf(fileID, '- Non-blocking issues:\n');
    fprintf(fileID, '- Follow-up tests or helper refactors:\n\n');

    fprintf(fileID, '## Cleanup Status\n\n');
    fprintf(fileID, '- Tab3 `_temp.m` backups removed: yes\n');
    fprintf(fileID, '- Cleanup record: `docs/PGIXS_file_cleanup_record.md`\n');
    fprintf(fileID, '- Follow-up cleanup notes:\n');
end
