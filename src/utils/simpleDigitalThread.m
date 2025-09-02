function simpleDigitalThread()
    %SIMPLEDIGITALTHREAD Simple digital thread for UP1 numerical traceability
    %
    % Simple function-based approach for basic tracking
    
    fprintf('=== SIMPLE DIGITAL THREAD INITIALIZED ===\n');
    fprintf('Session ID: %s\n', generate_session_id());
    fprintf('Start Time: %s\n', datestr(now));
    
    fprintf('\nSimple digital thread ready for use!\n');
    fprintf('This is a basic working version.\n');
end

function session_id = generate_session_id()
    %GENERATE_SESSION_ID Generate unique session identifier
    
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    random_suffix = sprintf('%04d', randi(9999));
    session_id = sprintf('UP1_%s_%s', timestamp, random_suffix);
end
