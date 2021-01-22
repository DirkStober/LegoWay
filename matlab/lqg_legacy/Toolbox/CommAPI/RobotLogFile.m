classdef RobotLogFile < handle
    properties
        filename;
        fd;
    end
    
    methods
        function obj = RobotLogFile(filename)
            obj.filename = filename;
            
            [obj.fd, err_msg] = fopen(obj.filename, 'rb');
            if ~isempty(err_msg)
                error(['LogFile: Failed to open file. ' err_msg]);
            end
        end
        
        % Destructor
        function delete(obj)
            if obj.fd >= 0
                fclose(obj.fd);
            end
        end
        
        function header = getHeader(obj)
            header = {};
            
            if obj.fd < 0
                error('Log file not open!');
            end
                
            % Move to the start of the file
            fseek(obj.fd, 0, 'bof');
            
            % Read file format version (ignored for now)
            fread(obj.fd, 1, 'uint16');
            
            % Read number of states, inputs and outputs
            nstates  = fread(obj.fd, 1, 'uint8');            
            ninputs  = fread(obj.fd, 1, 'uint8');            
            noutputs = fread(obj.fd, 1, 'uint8');
            
            % Read Sampling period measured in ms
            Ts_ms = fread(obj.fd, 1, 'uint16');
            
            % Check if there are empty fields
            if isempty(nstates) || isempty(ninputs) || isempty(noutputs) || isempty(Ts_ms)
                return;
            end            
            
            % Read the regulator name
            reg_name = RobotLogFile.readStr(obj.fd);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % SIGNAL NAMES
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Read the names of the STATES
            state_names = cell(nstates,1);
            for i=1:nstates
                state_names{i} = RobotLogFile.readStr(obj.fd);
            end
            
            % Read the names of the INPUTS
            input_names = cell(ninputs,1);
            for i=1:ninputs
                input_names{i} = RobotLogFile.readStr(obj.fd);
            end
            
            % Read the names of the OUTPUTS
            output_names = cell(noutputs,1);
            for i=1:noutputs
                output_names{i} = RobotLogFile.readStr(obj.fd);
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % UNIT NAMES
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Read the unit names of the STATES
            state_unit_names = cell(nstates,1);
            for i=1:nstates
                state_unit_names{i} = RobotLogFile.readStr(obj.fd);
            end
            
            % Read the names of the INPUTS
            input_unit_names = cell(ninputs,1);
            for i=1:ninputs
                input_unit_names{i} = RobotLogFile.readStr(obj.fd);
            end
            
            % Read the names of the OUTPUTS
            output_unit_names = cell(noutputs,1);
            for i=1:noutputs
                output_unit_names{i} = RobotLogFile.readStr(obj.fd);
            end
            
            
            header.Ts                 = Ts_ms/1000;
            header.RegName            = reg_name;
            header.StateName          = state_names;
            header.InputName          = input_names;
            header.OutputName         = output_names;
            header.StateUnit          = state_unit_names;
            header.InputUnit          = input_unit_names;
            header.OutputUnit         = output_unit_names;
            header.nstates            = nstates;
            header.ninputs            = ninputs;
            header.noutputs           = noutputs;
        end
        
        function [log_data, not_complete_flag] = getFullLog(obj)
            
            % First get the header
            log_data = obj.getHeader();
                        
            % Return early if the header is incomplete
            if isempty(log_data)
                return;
            end
            
            % Then fill in the signals
            log_data.ctrl_loop_start_ms = [];
            log_data.iter               = [];
            log_data.states             = [];
            log_data.inputs             = [];
            log_data.outputs            = [];
            
            % Size of one log entry item
            SIZEOF_DEC_T = 8;
            log_entry_len = 32/8 + 32/8 + 16/8 + SIZEOF_DEC_T*(log_data.nstates+log_data.ninputs+log_data.noutputs); %32/8 + 32/8 + SIZEOF_DOUBLE*(nx+nu+ny) = 8 + SIZEOF_DOUBLE*(nx+nu+ny)
            
            % Determine number of log entries
            pos = ftell(obj.fd);                                    %remember current pos
            fseek(obj.fd, 0, 'eof');                                %move to end of file
            len_filled_in = ftell(obj.fd) - pos;                    %determine the remaining length
            num_log_entries = floor(len_filled_in / log_entry_len); %compute number of log entries
            fseek(obj.fd, pos, 'bof');                              %rewind
            
            % Read signals
            log_data.iter               = RobotLogFile.readLogItemPart(obj.fd, 1, 'uint32', 32/8, log_entry_len, num_log_entries);
            log_data.ctrl_loop_start_ms = RobotLogFile.readLogItemPart(obj.fd, 1, 'uint32', 32/8, log_entry_len, num_log_entries);
            
            bat_volt                    = RobotLogFile.readLogItemPart(obj.fd, 1, 'uint16', 16/8, log_entry_len, num_log_entries);
            log_data.bat_volt           = bat_volt / 1000;

            log_data.states  = RobotLogFile.readLogItemPart(obj.fd, log_data.nstates,  'double', SIZEOF_DEC_T*log_data.nstates,  log_entry_len, num_log_entries);
            log_data.inputs  = RobotLogFile.readLogItemPart(obj.fd, log_data.ninputs,  'double', SIZEOF_DEC_T*log_data.ninputs,  log_entry_len, num_log_entries);
            log_data.outputs = RobotLogFile.readLogItemPart(obj.fd, log_data.noutputs, 'double', SIZEOF_DEC_T*log_data.noutputs, log_entry_len, num_log_entries);
        end
    end

    methods(Static)
%         function new_data = subset(old_data, i_from, i_to)
%             new_data = old_data;
% 
%             new_data.ctrl_loop_start_ms = new_data.ctrl_loop_start_ms(i_from:i_to);
%             new_data.iter = new_data.iter(i_from:i_to);
%             
%             if ~isempty(new_data.states)
%                 new_data.states = new_data.states(:,i_from:i_to);
%             end
%             if ~isempty(new_data.inputs)
%                 new_data.inputs = new_data.inputs(:,i_from:i_to);
%             end
%             if ~isempty(new_data.outputs)
%                 new_data.outputs = new_data.outputs(:,i_from:i_to);
%             end
%         end
        
        % Returns the packet receive success ratio
        %
        % ratio = receivedPacketsRatio(log_data)
        %
        % ratio will be a value between 0.0 and 1.0, where
        %  eg. 1.0 means no dropped packets, 0.5 implicates that
        %  50% of the packet were dropped.
        function ratio = receivedPacketsRatio(log_data)
            n_should_be = (log_data.ctrl_loop_start_ms(end) - log_data.ctrl_loop_start_ms(1)) / (log_data.Ts*1000);
            n_is = length(log_data.ctrl_loop_start_ms);
            ratio = n_is / n_should_be;
        end
        
        function s = readStr(fd)
            s = '';
            while 1
                c = fread(fd, 1, 'uint8');
                if feof(fd) || c==0 
                    %string read
                    break;
                end
                
                %append to string
                s = [s char(c)];
            end
        end
        
        % Reads 'num_log_entries' number of 1*vec_dim vectors of type
        % 'type', where each vector occupies 'len' bytes and where
        % 'tot_len - len' bytes separate each vector.
        function part = readLogItemPart(fd, vec_dim, type, len, tot_len, num_log_entries)
            part = [];
            
            if vec_dim == 0 || len == 0
                return;
            end
            
            pos_before = ftell(fd);
            part = fread(fd, [vec_dim num_log_entries], [int2str(vec_dim) '*' type], tot_len-len);
            fseek(fd, pos_before+len, 'bof');
        end
    end
end
