function report = parsePGIXSManualQAReport(reportFile)
% parsePGIXSManualQAReport  Summarize a Markdown manual QA report.

    if nargin < 1 || isempty(reportFile)
        reportFile = fullfile(pwd, 'docs', 'PGIXS_manual_gui_qa_report_current.md');
    end
    if ~isfile(reportFile)
        error('PGIXS:QAReportMissing', 'Manual QA report not found: %s', reportFile);
    end

    reportText = fileread(reportFile);
    report = struct();
    report.Path = reportFile;
    report.CoreTestsPassed = contains(reportText, "`run('tests/run_pgixs_core_tests.m')`: passed");
    report.PreflightReady = contains(reportText, '`ReadyForSyntheticTab3Smoke`: true') ...
        && contains(reportText, '`ManualQASampleValidation.GIXS.OK`: true') ...
        && contains(reportText, '`ManualQASampleValidation.TrXS.OK`: true');

    report.EmptyItems = findEmptyQAItems(reportText);
    report.EmptyItemCount = numel(report.EmptyItems);
    report.PendingItems = findPendingQAItems(reportText);
    report.PendingItemCount = numel(report.PendingItems);
    report.HasBlockingIssues = hasNonEmptyItem(reportText, '- Blocking issues:');
    report.HasNonBlockingIssues = hasNonEmptyItem(reportText, '- Non-blocking issues:');
    report.ManualGateComplete = report.CoreTestsPassed && report.PreflightReady ...
        && report.EmptyItemCount == 0 && report.PendingItemCount == 0 ...
        && ~report.HasBlockingIssues;
end

function emptyItems = findEmptyQAItems(reportText)
    labels = manualQALabels();
    emptyItems = cell(numel(labels), 1);
    nEmpty = 0;
    for ii = 1:numel(labels)
        if ~hasNonEmptyItem(reportText, labels{ii})
            nEmpty = nEmpty + 1;
            emptyItems{nEmpty} = labels{ii};
        end
    end
    emptyItems = emptyItems(1:nEmpty);
end

function pendingItems = findPendingQAItems(reportText)
    labels = manualQALabels();
    pendingItems = cell(numel(labels), 1);
    nPending = 0;
    for ii = 1:numel(labels)
        value = getItemValue(reportText, labels{ii});
        if startsWith(lower(strtrim(value)), 'pending')
            nPending = nPending + 1;
            pendingItems{nPending} = labels{ii};
        end
    end
    pendingItems = pendingItems(1:nPending);
end

function labels = manualQALabels()
    labels = {
        '- GIXS sample load:'
        '- GIXS display modes:'
        '- GIXS Plot/Smart/Line Cut:'
        '- TrXS sample load:'
        '- TrXS display modes:'
        '- TrXS Plot/Smart/Line Cut/keyboard rotation:'
        '- Tab1 GIXS raw load/process/save:'
        '- Tab1 TrXS raw load/process/save:'
        '- Tab3 GIXS load/index/save/export:'
        '- Tab3 TrXS load/index/save/export:'
        '- Retry/metadata failure handling:'
    };
end

function tf = hasNonEmptyItem(reportText, label)
    tf = ~isempty(getItemValue(reportText, label));
end

function value = getItemValue(reportText, label)
    escapedLabel = regexptranslate('escape', label);
    pattern = [escapedLabel, '[ \t]*(?<value>[^\r\n]*)'];
    match = regexp(reportText, pattern, 'names', 'once');
    if isempty(match)
        value = '';
    else
        value = strtrim(match.value);
    end
end
