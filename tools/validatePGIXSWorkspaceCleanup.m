function report = validatePGIXSWorkspaceCleanup(repoRoot)
% validatePGIXSWorkspaceCleanup  Check that cleanup-sensitive files are absent.
%
% This helper is intentionally lightweight and does not launch GUI windows.

    if nargin < 1 || isempty(repoRoot)
        repoRoot = pwd;
    end

    report = struct();
    report.RepoRoot = char(repoRoot);
    report.HasGIXSTempBackup = isfile(fullfile(repoRoot, 'gui', 'tab3', 'GIXSXtal2D_gui_temp.m'));
    report.HasTrXSTempBackup = isfile(fullfile(repoRoot, 'gui', 'tab3', 'TrXSXtal2D_gui_temp.m'));
    report.HasMatlabPrefTmp = isfolder(fullfile(repoRoot, '.matlab_pref_tmp'));
    report.HasMatlabPrefTest = isfolder(fullfile(repoRoot, '.matlab_pref_test'));
    report.HasOldCleanupCandidatesDoc = isfile(fullfile(repoRoot, 'docs', 'PGIXS_file_cleanup_candidates.md'));
    report.HasOldTempDecisionDoc = isfile(fullfile(repoRoot, 'docs', 'PGIXS_temp_cleanup_decision.md'));
    report.HasOldArchiveHelper = isfile(fullfile(repoRoot, 'tools', 'archivePGIXSTempFiles.m'));

    flags = [
        report.HasGIXSTempBackup
        report.HasTrXSTempBackup
        report.HasMatlabPrefTmp
        report.HasMatlabPrefTest
        report.HasOldCleanupCandidatesDoc
        report.HasOldTempDecisionDoc
        report.HasOldArchiveHelper
    ];
    report.OK = ~any(flags);
end
