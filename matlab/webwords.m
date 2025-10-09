% Main MATLAB/Octave script for WebWords processing
% Reads keyword and content from files, performs search, writes result

try
    % Read keyword from file
    if exist('/tmp/keyword.txt', 'file')
        fid = fopen('/tmp/keyword.txt', 'r');
        keyword = fgetl(fid);
        fclose(fid);
    else
        error('Keyword file not found');
    end
    
    % Read text content from file
    if exist('/tmp/content.txt', 'file')
        fid = fopen('/tmp/content.txt', 'r');
        content = fread(fid, '*char')';
        fclose(fid);
    else
        error('Content file not found');
    end
    
    % Perform MATLAB keyword search
    fprintf('MATLAB: Processing search for keyword "%s"\n', keyword);
    
    % Convert inputs to lowercase for case-insensitive search
    keyword_lower = lower(keyword);
    text_lower = lower(content);
    
    % Use MATLAB's string search capabilities
    found_positions = strfind(text_lower, keyword_lower);
    
    % Determine result
    if ~isempty(found_positions)
        search_result = 1;
        fprintf('MATLAB: Keyword "%s" found at positions: %s\n', keyword, mat2str(found_positions));
    else
        search_result = 0;
        fprintf('MATLAB: Keyword "%s" not found in text\n', keyword);
    end
    
    % Additional MATLAB-style analysis
    text_length = length(content);
    keyword_length = length(keyword);
    search_efficiency = keyword_length / text_length * 100;
    
    fprintf('MATLAB Analysis:\n');
    fprintf('  Text length: %d characters\n', text_length);
    fprintf('  Keyword length: %d characters\n', keyword_length);
    fprintf('  Search efficiency: %.2f%%\n', search_efficiency);
    
    % Write result to file
    fid = fopen('/tmp/matlab_result.txt', 'w');
    if search_result == 1
        fprintf(fid, 'true');
        fprintf('MATLAB: Result = true\n');
    else
        fprintf(fid, 'false');
        fprintf('MATLAB: Result = false\n');
    end
    fclose(fid);
    
    % Create MATLAB-style analysis report
    analysis = struct();
    analysis.keyword = keyword;
    analysis.content_length = length(content);
    analysis.keyword_length = length(keyword);
    analysis.found = search_result;
    analysis.timestamp = datestr(now);
    
    % Save analysis in MATLAB format
    save('/tmp/matlab_analysis.mat', 'analysis');
    fprintf('MATLAB: Analysis saved to matlab_analysis.mat\n');
    
catch err
    fprintf('MATLAB Error: %s\n', err.message);
    % Write error result
    fid = fopen('/tmp/matlab_result.txt', 'w');
    fprintf(fid, 'false');
    fclose(fid);
end