classdef digitalThread < handle
    %DIGITALTHREAD Robust digital thread system for UP1 Environmental Noise Cancellation
    %
    % Tracks complete numerical workflow from data preprocessing through axiom validation
    % Ensures reproducibility and scientific rigor for all computational results
    
    properties
        % Core tracking properties
        session_id          % Unique session identifier
        start_time         % Session start timestamp
        project_root       % Project root directory
        data_sources       % Input data files and sources
        parameters         % All algorithm parameters and thresholds
        transformations    % Data transformation steps
        intermediate_results % Cached intermediate calculations
        final_results      % Final outputs and summaries
        execution_log      % Complete execution history
        performance_metrics % Computational performance tracking
        validation_checks  % Data quality and result validation
        dependencies       % External dependencies and versions
    end
    
    methods
        function obj = digitalThread(project_root)
            %DIGITALTHREAD Constructor - initialize digital thread session
            
            if nargin < 1
                obj.project_root = pwd;
            else
                obj.project_root = project_root;
            end
            
            % Initialize session
            obj.session_id = obj.generate_session_id();
            obj.start_time = datetime('now');
            obj.data_sources = struct();
            obj.parameters = struct();
            obj.transformations = struct();
            obj.intermediate_results = struct();
            obj.final_results = struct();
            obj.execution_log = struct();
            obj.performance_metrics = struct();
            obj.validation_checks = struct();
            obj.dependencies = obj.capture_dependencies();
            
            % Log session start
            obj.log_event('SESSION_START', sprintf('Digital thread session %s started', obj.session_id));
            obj.log_event('PROJECT_ROOT', obj.project_root);
            
            fprintf('=== UP1 DIGITAL THREAD INITIALIZED ===\n');
            fprintf('Session ID: %s\n', obj.session_id);
            fprintf('Start Time: %s\n', datestr(obj.start_time));
            fprintf('Project Root: %s\n', obj.project_root);
        end
        
        function log_data_source(obj, name, filepath, description, metadata)
            %LOG_DATA_SOURCE Record data source information
            
            if nargin < 5
                metadata = struct();
            end
            
            % Capture file information
            if exist(filepath, 'file')
                file_info = dir(filepath);
                file_size = file_info.bytes;
                file_date = file_info.date;
                file_hash = obj.calculate_file_hash(filepath);
            else
                file_size = NaN;
                file_date = 'N/A';
                file_hash = 'N/A';
            end
            
            obj.data_sources.(name) = struct(...
                'filepath', filepath, ...
                'description', description, ...
                'metadata', metadata, ...
                'file_size', file_size, ...
                'file_date', file_date, ...
                'file_hash', file_hash, ...
                'timestamp', datetime('now'));
            
            obj.log_event('DATA_SOURCE_LOADED', sprintf('Loaded: %s (%s)', name, filepath));
        end
        
        function log_parameter(obj, category, name, value, description)
            %LOG_PARAMETER Record algorithm parameter or threshold
            
            if ~isfield(obj.parameters, category)
                obj.parameters.(category) = struct();
            end
            
            obj.parameters.(category).(name) = struct(...
                'value', value, ...
                'description', description, ...
                'timestamp', datetime('now'), ...
                'data_type', class(value));
            
            obj.log_event('PARAMETER_SET', sprintf('%s.%s = %s', category, name, obj.value_to_string(value)));
        end
        
        function log_transformation(obj, step_name, input_data, output_data, method, parameters)
            %LOG_TRANSFORMATION Record data transformation step
            
            obj.transformations.(step_name) = struct(...
                'input_data', input_data, ...
                'output_data', output_data, ...
                'method', method, ...
                'parameters', parameters, ...
                'timestamp', datetime('now'), ...
                'input_shape', obj.get_data_shape(input_data), ...
                'output_shape', obj.get_data_shape(output_data));
            
            obj.log_event('TRANSFORMATION', sprintf('Applied %s: %s -> %s', ...
                method, obj.get_data_shape(input_data), obj.get_data_shape(output_data)));
        end
        
        function cache_result(obj, name, data, description, metadata)
            %CACHE_RESULT Cache intermediate calculation result
            
            if nargin < 5
                metadata = struct();
            end
            
            obj.intermediate_results.(name) = struct(...
                'data', data, ...
                'description', description, ...
                'metadata', metadata, ...
                'timestamp', datetime('now'), ...
                'data_shape', obj.get_data_shape(data), ...
                'data_type', class(data), ...
                'memory_usage', obj.estimate_memory_usage(data));
            
            obj.log_event('RESULT_CACHED', sprintf('Cached: %s (%s)', name, description));
        end
        
        function log_final_result(obj, name, result, description, validation_status)
            %LOG_FINAL_RESULT Record final output result
            
            if nargin < 5
                validation_status = 'UNVALIDATED';
            end
            
            obj.final_results.(name) = struct(...
                'result', result, ...
                'description', description, ...
                'validation_status', validation_status, ...
                'timestamp', datetime('now'), ...
                'data_shape', obj.get_data_shape(result), ...
                'data_type', class(result));
            
            obj.log_event('FINAL_RESULT', sprintf('Final result: %s (%s) - %s', ...
                name, description, validation_status));
        end
        
        function log_event(obj, event_type, message, details)
            %LOG_EVENT Record execution event
            
            if nargin < 4
                details = struct();
            end
            
            event_id = sprintf('EVENT_%06d', length(fieldnames(obj.execution_log)) + 1);
            
            obj.execution_log.(event_id) = struct(...
                'event_type', event_type, ...
                'message', message, ...
                'details', details, ...
                'timestamp', datetime('now'), ...
                'memory_usage', obj.get_current_memory_usage());
        end
        
        function start_performance_tracking(obj, operation_name)
            %START_PERFORMANCE_TRACKING Start timing an operation
            
            if ~isfield(obj.performance_metrics, operation_name)
                obj.performance_metrics.(operation_name) = struct();
            end
            
            obj.performance_metrics.(operation_name).start_time = tic;
            obj.performance_metrics.(operation_name).start_memory = obj.get_current_memory_usage();
            
            obj.log_event('PERFORMANCE_START', sprintf('Started tracking: %s', operation_name));
        end
        
        function end_performance_tracking(obj, operation_name)
            %END_PERFORMANCE_TRACKING End timing an operation
            
            if isfield(obj.performance_metrics, operation_name) && ...
               isfield(obj.performance_metrics.(operation_name), 'start_time')
                
                elapsed_time = toc(obj.performance_metrics.(operation_name).start_time);
                end_memory = obj.get_current_memory_usage();
                memory_delta = end_memory - obj.performance_metrics.(operation_name).start_memory;
                
                obj.performance_metrics.(operation_name).elapsed_time = elapsed_time;
                obj.performance_metrics.(operation_name).end_memory = end_memory;
                obj.performance_metrics.(operation_name).memory_delta = memory_delta;
                
                obj.log_event('PERFORMANCE_END', sprintf('Completed: %s (%.3f seconds)', ...
                    operation_name, elapsed_time));
            end
        end
        
        function add_validation_check(obj, check_name, check_type, status, details)
            %ADD_VALIDATION_CHECK Record data quality or result validation
            
            obj.validation_checks.(check_name) = struct(...
                'check_type', check_type, ...
                'status', status, ...
                'details', details, ...
                'timestamp', datetime('now'));
            
            obj.log_event('VALIDATION_CHECK', sprintf('%s: %s - %s', ...
                check_name, check_type, status));
        end
        
        function generate_report(obj, output_file)
            %GENERATE_REPORT Generate comprehensive digital thread report
            
            if nargin < 2
                output_file = sprintf('digital_thread_report_%s.txt', obj.session_id);
            end
            
            % Create report content
            report = obj.create_report_content();
            
            % Write to file
            fid = fopen(output_file, 'w');
            if fid ~= -1
                fprintf(fid, '%s', report);
                fclose(fid);
                fprintf('Digital thread report saved to: %s\n', output_file);
            else
                warning('Could not write report to file: %s', output_file);
            end
            
            % Also display summary
            obj.display_summary();
        end
        
        function export_session(obj, output_dir)
            %EXPORT_SESSION Export complete session data for reproducibility
            
            if nargin < 2
                output_dir = sprintf('session_export_%s', obj.session_id);
            end
            
            % Create export directory
            if ~exist(output_dir, 'dir')
                mkdir(output_dir);
            end
            
            % Export session data
            session_data = struct(...
                'session_id', obj.session_id, ...
                'start_time', obj.start_time, ...
                'project_root', obj.project_root, ...
                'data_sources', obj.data_sources, ...
                'parameters', obj.parameters, ...
                'transformations', obj.transformations, ...
                'intermediate_results', obj.intermediate_results, ...
                'final_results', obj.final_results, ...
                'execution_log', obj.execution_log, ...
                'performance_metrics', obj.performance_metrics, ...
                'validation_checks', obj.validation_checks, ...
                'dependencies', obj.dependencies);
            
            % Save as MAT file
            mat_file = fullfile(output_dir, 'session_data.mat');
            save(mat_file, 'session_data');
            
            % Save as JSON for portability
            json_file = fullfile(output_dir, 'session_data.json');
            obj.struct_to_json(session_data, json_file);
            
            % Generate report
            report_file = fullfile(output_dir, 'digital_thread_report.txt');
            obj.generate_report(report_file);
            
            fprintf('Session exported to: %s\n', output_dir);
            fprintf('Files: session_data.mat, session_data.json, digital_thread_report.txt\n');
        end
        
        function display_summary(obj)
            %DISPLAY_SUMMARY Display session summary
            
            fprintf('\n=== DIGITAL THREAD SESSION SUMMARY ===\n');
            fprintf('Session ID: %s\n', obj.session_id);
            duration = obj.get_session_duration();
    fprintf('Duration: %s\n', char(duration));
            fprintf('Data Sources: %d\n', length(fieldnames(obj.data_sources)));
            fprintf('Parameters: %d\n', obj.count_total_parameters());
            fprintf('Transformations: %d\n', length(fieldnames(obj.transformations)));
            fprintf('Cached Results: %d\n', length(fieldnames(obj.intermediate_results)));
            fprintf('Final Results: %d\n', length(fieldnames(obj.final_results)));
            fprintf('Events Logged: %d\n', length(fieldnames(obj.execution_log)));
            fprintf('Validation Checks: %d\n', length(fieldnames(obj.validation_checks)));
            
            % Performance summary
            if ~isempty(fieldnames(obj.performance_metrics))
                fprintf('\nPerformance Summary:\n');
                perf_fields = fieldnames(obj.performance_metrics);
                for i = 1:length(perf_fields)
                    perf = obj.performance_metrics.(perf_fields{i});
                    if isfield(perf, 'elapsed_time')
                        fprintf('  %s: %.3f seconds\n', perf_fields{i}, perf.elapsed_time);
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        function session_id = generate_session_id(obj)
            %GENERATE_SESSION_ID Generate unique session identifier
            
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            random_suffix = sprintf('%04d', randi(9999));
            session_id = sprintf('UP1_%s_%s', timestamp, random_suffix);
        end
        
        function dependencies = capture_dependencies(obj)
            %CAPTURE_DEPENDENCIES Capture MATLAB version and toolbox information
            
            dependencies = struct();
            
            % MATLAB version
            dependencies.matlab_version = version;
            dependencies.matlab_release = version('-release');
            
            % Toolbox information
            try
                ver_info = ver;
                dependencies.toolboxes = struct();
                for i = 1:length(ver_info)
                    if ~strcmp(ver_info(i).Name, 'MATLAB')
                        dependencies.toolboxes.(ver_info(i).Name) = ver_info(i).Version;
                    end
                end
            catch
                dependencies.toolboxes = 'Unable to detect';
            end
            
            % Platform information
            dependencies.platform = computer;
            dependencies.arch = computer('arch');
            
            % Working directory
            dependencies.working_directory = pwd;
        end
        
        function file_hash = calculate_file_hash(obj, filepath)
            %CALCULATE_FILE_HASH Calculate SHA-256 hash of file
            
            try
                % Read file content
                fid = fopen(filepath, 'r');
                if fid == -1
                    file_hash = 'ERROR_READING_FILE';
                    return;
                end
                
                content = fread(fid, inf, 'uint8');
                fclose(fid);
                
                % Simple hash (for demonstration - use proper hash in production)
                file_hash = sprintf('HASH_%08X', sum(content));
            catch
                file_hash = 'HASH_ERROR';
            end
        end
        
        function shape_str = get_data_shape(obj, data)
            %GET_DATA_SHAPE Get string representation of data shape
            
            if isnumeric(data) || islogical(data)
                shape_str = mat2str(size(data));
            elseif istable(data)
                shape_str = sprintf('[%dx%d table]', size(data, 1), size(data, 2));
            elseif isstruct(data)
                shape_str = sprintf('[struct with %d fields]', length(fieldnames(data)));
            elseif iscell(data)
                shape_str = sprintf('[%dx%d cell]', size(data, 1), size(data, 2));
            else
                shape_str = class(data);
            end
        end
        
        function memory_usage = estimate_memory_usage(obj, data)
            %ESTIMATE_MEMORY_USAGE Estimate memory usage of data in bytes
            
            try
                if isnumeric(data) || islogical(data)
                    memory_usage = numel(data) * 8; % Assume 8 bytes per element
                elseif istable(data)
                    memory_usage = obj.estimate_table_memory(data);
                elseif isstruct(data)
                    memory_usage = obj.estimate_struct_memory(data);
                else
                    memory_usage = NaN;
                end
            catch
                memory_usage = NaN;
            end
        end
        
        function memory_usage = estimate_table_memory(obj, table_data)
            %ESTIMATE_TABLE_MEMORY Estimate memory usage of table
            
            try
                memory_usage = 0;
                var_names = table_data.Properties.VariableNames;
                
                for i = 1:length(var_names)
                    var_data = table_data.(var_names{i});
                    if isnumeric(var_data)
                        memory_usage = memory_usage + numel(var_data) * 8;
                    elseif iscategorical(var_data)
                        memory_usage = memory_usage + numel(var_data) * 4;
                    else
                        memory_usage = memory_usage + numel(var_data) * 16; % Estimate
                    end
                end
            catch
                memory_usage = NaN;
            end
        end
        
        function memory_usage = estimate_struct_memory(obj, struct_data)
            %ESTIMATE_STRUCT_MEMORY Estimate memory usage of struct
            
            try
                memory_usage = 0;
                fields = fieldnames(struct_data);
                
                for i = 1:length(fields)
                    field_data = struct_data.(fields{i});
                    memory_usage = memory_usage + obj.estimate_memory_usage(field_data);
                end
            catch
                memory_usage = NaN;
            end
        end
        
        function memory_usage = get_current_memory_usage(obj)
            %GET_CURRENT_MEMORY_USAGE Get current MATLAB memory usage
            
            try
                memory_info = memory;
                memory_usage = memory_info.MemUsedMATLAB;
            catch
                memory_usage = NaN;
            end
        end
        
        function value_str = value_to_string(obj, value)
            %VALUE_TO_STRING Convert parameter value to string representation
            
            if isnumeric(value) && isscalar(value)
                value_str = num2str(value);
            elseif ischar(value) || isstring(value)
                value_str = char(value);
            elseif islogical(value)
                value_str = mat2str(value);
            elseif isnumeric(value) && ~isscalar(value)
                value_str = sprintf('[%s]', mat2str(size(value)));
            else
                value_str = class(value);
            end
        end
        
        function duration = get_session_duration(obj)
    %GET_SESSION_DURATION Calculate session duration
    
    current_time = datetime('now');
    duration = current_time - obj.start_time;
end
        
        function count = count_total_parameters(obj)
            %COUNT_TOTAL_PARAMETERS Count total number of parameters
            
            count = 0;
            categories = fieldnames(obj.parameters);
            
            for i = 1:length(categories)
                category_params = obj.parameters.(categories{i});
                count = count + length(fieldnames(category_params));
            end
        end
        
        function report = create_report_content(obj)
            %CREATE_REPORT_CONTENT Create comprehensive report content
            
            report = '';
            
            % Header
            report = [report, sprintf('=== UP1 ENVIRONMENTAL NOISE CANCELLATION ===\n')];
            report = [report, sprintf('DIGITAL THREAD REPORT\n')];
            report = [report, sprintf('Session ID: %s\n', obj.session_id)];
            report = [report, sprintf('Generated: %s\n', datestr(now))];
            report = [report, sprintf('Project Root: %s\n\n', obj.project_root)];
            
                % Session Information
    report = [report, sprintf('=== SESSION INFORMATION ===\n')];
    report = [report, sprintf('Start Time: %s\n', datestr(obj.start_time))];
    duration = obj.get_session_duration();
    report = [report, sprintf('Duration: %s\n', char(duration))];
    report = [report, sprintf('\n')];
            
            % Dependencies
            report = [report, sprintf('=== DEPENDENCIES ===\n')];
            report = [report, sprintf('MATLAB Version: %s\n', obj.dependencies.matlab_version)];
            report = [report, sprintf('Platform: %s\n', obj.dependencies.platform)];
            report = [report, sprintf('Architecture: %s\n', obj.dependencies.arch)];
            
            if isfield(obj.dependencies, 'toolboxes') && isstruct(obj.dependencies.toolboxes)
                report = [report, sprintf('Toolboxes:\n')];
                toolbox_names = fieldnames(obj.dependencies.toolboxes);
                for i = 1:length(toolbox_names)
                    report = [report, sprintf('  %s: %s\n', ...
                        toolbox_names{i}, obj.dependencies.toolboxes.(toolbox_names{i}))];
                end
            end
            report = [report, sprintf('\n')];
            
            % Data Sources
            report = [report, sprintf('=== DATA SOURCES ===\n')];
            source_names = fieldnames(obj.data_sources);
            for i = 1:length(source_names)
                source = obj.data_sources.(source_names{i});
                report = [report, sprintf('%s:\n', source_names{i})];
                report = [report, sprintf('  File: %s\n', source.filepath)];
                report = [report, sprintf('  Description: %s\n', source.description)];
                report = [report, sprintf('  Size: %s bytes\n', num2str(source.file_size))];
                report = [report, sprintf('  Hash: %s\n', source.file_hash)];
                report = [report, sprintf('  Loaded: %s\n', datestr(source.timestamp))];
                report = [report, sprintf('\n')];
            end
            
            % Parameters
            report = [report, sprintf('=== PARAMETERS ===\n')];
            categories = fieldnames(obj.parameters);
            for i = 1:length(categories)
                report = [report, sprintf('%s:\n', categories{i})];
                category_params = obj.parameters.(categories{i});
                param_names = fieldnames(category_params);
                
                for j = 1:length(param_names)
                    param = category_params.(param_names{j});
                    report = [report, sprintf('  %s = %s (%s)\n', ...
                        param_names{j}, obj.value_to_string(param.value), param.description)];
                end
                report = [report, sprintf('\n')];
            end
            
            % Transformations
            report = [report, sprintf('=== DATA TRANSFORMATIONS ===\n')];
            transform_names = fieldnames(obj.transformations);
            for i = 1:length(transform_names)
                transform = obj.transformations.(transform_names{i});
                report = [report, sprintf('%s:\n', transform_names{i})];
                report = [report, sprintf('  Method: %s\n', transform.method)];
                report = [report, sprintf('  Input: %s\n', transform.input_shape)];
                report = [report, sprintf('  Output: %s\n', transform.output_shape)];
                report = [report, sprintf('  Applied: %s\n', datestr(transform.timestamp))];
                report = [report, sprintf('\n')];
            end
            
            % Results
            report = [report, sprintf('=== INTERMEDIATE RESULTS ===\n')];
            result_names = fieldnames(obj.intermediate_results);
            for i = 1:length(result_names)
                result = obj.intermediate_results.(result_names{i});
                report = [report, sprintf('%s:\n', result_names{i})];
                report = [report, sprintf('  Description: %s\n', result.description)];
                report = [report, sprintf('  Shape: %s\n', result.data_shape)];
                report = [report, sprintf('  Type: %s\n', result.data_type)];
                report = [report, sprintf('  Cached: %s\n', datestr(result.timestamp))];
                report = [report, sprintf('\n')];
            end
            
            % Final Results
            report = [report, sprintf('=== FINAL RESULTS ===\n')];
            final_names = fieldnames(obj.final_results);
            for i = 1:length(final_names)
                result = obj.final_results.(final_names{i});
                report = [report, sprintf('%s:\n', final_names{i})];
                report = [report, sprintf('  Description: %s\n', result.description)];
                report = [report, sprintf('  Status: %s\n', result.validation_status)];
                report = [report, sprintf('  Generated: %s\n', datestr(result.timestamp))];
                report = [report, sprintf('\n')];
            end
        
            % Performance Metrics
            if ~isempty(fieldnames(obj.performance_metrics))
                report = [report, sprintf('=== PERFORMANCE METRICS ===\n')];
                perf_names = fieldnames(obj.performance_metrics);
                for i = 1:length(perf_names)
                    perf = obj.performance_metrics.(perf_names{i});
                    if isfield(perf, 'elapsed_time')
                        report = [report, sprintf('%s: %.3f seconds\n', ...
                            perf_names{i}, perf.elapsed_time)];
                    end
                end
                report = [report, sprintf('\n')];
            end
            
            % Validation Checks
            report = [report, sprintf('=== VALIDATION CHECKS ===\n')];
            check_names = fieldnames(obj.validation_checks);
            for i = 1:length(check_names)
                check = obj.validation_checks.(check_names{i});
                report = [report, sprintf('%s (%s): %s\n', ...
                    check_names{i}, check.check_type, check.status)];
            end
            report = [report, sprintf('\n')];
            
            % Execution Log
            report = [report, sprintf('=== EXECUTION LOG ===\n')];
            event_ids = fieldnames(obj.execution_log);
            for i = 1:length(event_ids)
                event = obj.execution_log.(event_ids{i});
                report = [report, sprintf('[%s] %s: %s\n', ...
                    datestr(event.timestamp), event.event_type, event.message)];
            end
            
            % Footer
            report = [report, sprintf('\n=== END OF REPORT ===\n')];
            report = [report, sprintf('Total Events: %d\n', length(event_ids))];
            report = [report, sprintf('Report Generated: %s\n', datestr(now))];
        end
        
        function struct_to_json(obj, data, filename)
            %STRUCT_TO_JSON Convert struct to JSON and save to file
            
            try
                % Convert to JSON string
                json_str = jsonencode(data, 'PrettyPrint', true);
                
                % Write to file
                fid = fopen(filename, 'w');
                if fid ~= -1
                    fprintf(fid, '%s', json_str);
                    fclose(fid);
                end
            catch
                warning('Could not export to JSON: %s', filename);
            end
        end
    end
end
