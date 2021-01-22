function log_files = getLogFilesSortedByDate(path)
    % Grab a list of log files in the 'log_path' dir
    log_files = dir(fullfile(path, '*.log'));
    [~, indices] = sort([log_files.datenum], 2, 'descend');
    log_files = log_files(indices);
end