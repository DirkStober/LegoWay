classdef HipsterCommDLL < handle
    properties (SetAccess = protected)
        dll_loaded = false;
        dll_name;
        log_path;
    end
    
    methods
        function obj = HipsterCommDLL(log_path, dll_path)
            arch = computer('arch');
            if ~strcmp(arch, 'win32') && ~strcmp(arch, 'win64')
                error('Unknown CPU architecture (not win32 or win64)');
            end
            
            obj.dll_name = 'TheDLL';
            
%             dll_path = '../../../Binaries/';

            % Save log files to C:\Logs\[current date].log
            obj.log_path = log_path;
            if ~exist(obj.log_path, 'dir')
                [success, msg] = mkdir(obj.log_path);
                if ~success
                    error(['Could not create log directory: ' obj.log_path ' (Error: ' msg]);
                end
            end

            dll_file    = fullfile(dll_path, [obj.dll_name '_' arch '.dll']);
            header_file = fullfile(dll_path, [obj.dll_name '.h']);
            [notfound, warnings] = loadlibrary(dll_file, header_file, 'alias', obj.dll_name);
            if isempty(notfound)
                obj.dll_loaded = true;
            else
                error('Could not load DLL!:\n\n%s', warnings);
            end
        end
        
        function delete(obj)
            if obj.dll_loaded
                try
                    obj.powerOff();
                    %obj.disconnect();
                catch e
                end
                unloadlibrary(obj.dll_name);
            end
        end
        
        function ret = powerOff(obj)
            ret = obj.call('hipsterPwrOff');
        end
        
        function ret = setVerboseLevel(obj, level)
            ret = obj.call('hipsterSetVerboseLevel', level);
        end
        
        function lost_connection = isConnectionLost(obj)            
            ret = obj.call('hipsterConnLost');
            
            lost_connection = true;
            if ret == 3
                lost_connection = false;
            end
        end
              
        function [status, ret] = getStatus(obj, timeout)
            % Create an empty Status struct
            status = {};
           
            % Create a pointer to the struct
            status_ptr = libpointer('hipster_status_t', status);
            %status_ptr.Value

            ret = obj.call('hipsterGetStatus', status_ptr, timeout);
            
            status = status_ptr.Value;
            clear status_ptr
            
            % Only throw exeption when 'ret' is not asked for
            if nargout < 2
                switch ret
                    case 2
                        error('Connection error');
                    case 3
                        error('Timeout occured while waiting for status response. Is the program running on the NXT brick?');
                end
            end
        end
        
        function ret = requestNewLogFile(obj)
            ret = obj.call('hipsterRequestNewLogFile');
            
            switch ret
                case 1
                    error('Connection error');
            end
        end
        
        function ret = setRefSeqStoreSignals(obj, sigs)
            % Set up a bank of signals
            %
            % obj.setRefSeqStoreSignals(sigs)
            %
            %    sigs  -  A struct array with fields:
            %                   sig - The raw signal
            %                   dt  - The time between
            %
            % Eg.    sigs = [struct('sig', sin(t), 'dt', 0.05) ;
            %                struct('sig', cos(t), 'dt', 0.05)];
            %        hc.setRefSeqStoreSignals(sigs)
            
            warning('Ignoring ''dt'' fields (not implemented yet). Controller sample period will be used instead.');
            
            num_sigs = length(sigs);
            props = [];
            raw_signal = [];
            for k=1:num_sigs
                props = [props ; length(sigs(k).sig) ; 1000*sigs(k).dt];
                raw_signal = [raw_signal ; sigs(k).sig(:)];
            end
            
            ret = obj.call('hipsterRefSeqStoreSig', num_sigs, props, raw_signal);
            
            switch ret
                case 2
                    error('The signal vector is too big!');
                case 3
                    error('Too many signals!');
            end
        end
        
        function ret = setRefSeqSetSequence(obj, seq_id, sig_id, ref_id, multiplier)
            % Set up a sequence entry, which defines how a reference
            %  should be affected by a signal
            %
            % obj.setRefSeqSetSequence(seq_id, sig_id, ref_id, multiplier)
            %
            %    seq_id     -  A sequence id between 0 and 7
            %    sig_id     -  A signal id between 0 and 7
            %    ref_id     -  Which reference to change
            %    multiplier -  Multiplier (default: 1)
            %
            % Eg. hc.setRefSeqSetSequence(0, 0, 0, 1)
            
            if nargin < 5
                multiplier = 1;
            end

            ret = obj.call('hipsterRefSeqSetSeq', seq_id, sig_id, ref_id, multiplier);
        end
        
        function ret = setRefSeqStart(obj)
            % Runs the Reference Sequence, prev. set up using obj.setRefSeqStoreSignals()
            % followed by obj.setRefSeqSetSequence
            %
            % obj.setRefSeqStart()            

            ret = obj.call('hipsterRefSeqStart');
        end
        
        function ret = setRefSeqReset(obj)
            % Resets the entire Reference Sequence Machine. This command
            % will stop the machine and reset all signals and sequences.
            %
            % obj.setRefSeqReset()            

            ret = obj.call('hipsterRefSeqReset');
        end
        
        function ret = setRef(obj, index, value, type)
            % Set reference
            
            ret = obj.call('hipsterSetRef', index, value, type);
        end
        
        % Set regulator
        function ret = setReg(obj, reg)
            % Pre-compiled regulator or LTI regulator?
            if isfield(reg.UserData, 'creg') && ~isempty(reg.UserData.creg)
                % It's a CReg
                A = [];
                B = [];
                C = [];
                D = [];
                
                if ~isfield(reg.UserData, 'nstates') || ~isfield(reg.UserData, 'ninputs') || ~isfield(reg.UserData, 'noutputs')
                    error('The regulator object has to contain the fields ''.UserData.nstates'', ''.UserData.ninputs'' and ''.UserData.noutputs'' when using pre-compiled reglator.');
                end
                nstates  = reg.UserData.nstates;
                ninputs  = reg.UserData.ninputs;
                noutputs = reg.UserData.noutputs;

                creg_len = length(reg.UserData.creg);
                creg = reg.UserData.creg;
            else
                % It's a LTI reg
                A = reg.A;
                B = reg.B;
                C = reg.C;
                D = reg.D;
                
                % Determine reglator dimensions
                nstates  = size(A,1);
                ninputs  = max(size(B,2), size(D,2));
                noutputs = max(size(C,1), size(D,1));
                
                creg_len = 0;
                creg = [];
            end
            
            % Make sure all signals are named
            if isempty(reg.Note)
                error('The field ''Note'' must not be empty.');
            end
            if nstates > 0 && length(reg.StateName) ~= nstates
                error('The field ''StateName'' must contain as many state names as there are states.');
            end
            if ninputs > 0 && length(reg.InputName) ~= ninputs
                error('The field ''InputName'' must contain as many input names as there are inputs.');
            end
            if noutputs > 0 && length(reg.OutputName) ~= noutputs
                error('The field ''OutputName'' must contain as many output names as there are outputs.');
            end
            
            % Make sure that all signals have unit names
            if nstates > 0 && length(reg.StateUnit) ~= nstates
                error('The field ''StateUnit'' must contain as many state units as there are states.');
            end
            if ninputs > 0 && length(reg.InputUnit) ~= ninputs
                error('The field ''InputUnit'' must contain as many input units as there are inputs.');
            end
            if noutputs > 0 && length(reg.OutputUnit) ~= noutputs
                error('The field ''OutputUnit'' must contain as many output units as there are outputs.');
            end
            
            % Are the sensorsAndRefs mappings valid?
            if ~isfield(reg.UserData, 'sensorsAndRefs')
                error('The field ''UserData.sensorsAndRefs'' must contain a sensors-and-reference mapping matrix');
            end
            if ~isequal(size(reg.UserData.sensorsAndRefs), [ninputs 2])
                error('Invalid dimension of ''UserData.sensorsAndRefs''');
            end
            
            % Are the actuator mappings valid?
            if ~isfield(reg.UserData, 'actuators')
                error('The field ''UserData.actuators'' must contain an actuator mapping matrix');
            end
            if ~isequal(size(reg.UserData.actuators), [noutputs 2])
                error('Invalid dimension of ''UserData.actuators''');
            end
            
            % Is the sample period not a positive number
            if reg.Ts <= 0
                error('The sample period reg.Ts must be a positive number');
            end
            
            if nstates > 0
                StateName = reg.StateName(:);
                StateUnit = reg.StateUnit(:);
            else
                StateName = {};
                StateUnit = {};
            end
            
            if ninputs > 0
                InputName = reg.InputName(:);
                InputUnit = reg.InputUnit(:);
            else
                InputName = {};
                InputUnit = {};
            end
            
            if noutputs > 0
                OutputName = reg.OutputName(:);
                OutputUnit = reg.OutputUnit(:);
            else
                OutputName = {};
                OutputUnit = {};
            end
            
            reg_names  = [reg.Note ; StateName ; InputName ; OutputName];
            unit_names = [           StateUnit ; InputUnit ; OutputUnit];
            
            ret = obj.call('hipsterSetReg', nstates, ninputs, noutputs, ...
                creg_len, creg, ...
                obj.matrixToRowMajor(A), ...
                obj.matrixToRowMajor(B), ...
                obj.matrixToRowMajor(C), ...
                obj.matrixToRowMajor(D), ...
                obj.matrixToRowMajor(reg.UserData.sensorsAndRefs), ...
                obj.matrixToRowMajor(reg.UserData.actuators), ...
                reg.Ts*1000, ...
                reg_names, unit_names);
            
            switch ret
                case 2
                    error('The regulator is too big.');
                case 3
                    error('The regulator has too many signals (states/inputs/outputs)');
                case 4
                    error('One of the signal names is too big');
                case 5
                    error('One of the signal unit names is too big');
            end
        end
        
        % Stop Hipster
        function ret = stop(obj)
            ret = obj.call('hipsterStop');
        end
        
        % Start Hipster
        function ret = start(obj)
            ret = obj.call('hipsterStart');
        end
        
        % Disconnect
        function ret = disconnect(obj)
            ret = obj.call('hipsterDisconnect');
        end
        
        % Connect
        function ret = connect(obj, port)
            match = regexp(port, 'COM\d+', 'match');
            if isempty(match) || ~isequal(match{1}, port)
                warning('The port argument should be on the form COMnn, where nn is a number. Eg. ''COM4''');
            end
            ret = obj.call('hipsterConnect', port, obj.log_path);
            
            switch ret
                case 2
                    error('Already connected');
                case 3
                    error('Internal error occured while trying to connect to NXT');
            end
        end
    end
    
    methods (Access = protected)
        function ret = call(obj, func, varargin)
            if obj.dll_loaded
%                 tic;
                ret = calllib(obj.dll_name, func, varargin{:});
                if ret == 1
                    error('Connection error! Have you called hc.connect()?');
                end
%                 toc;
            else
                ret = 1;
            end
        end
    end
    
    methods(Static)
        function m = matrixToRowMajor(m)
            mT = m.';
            m = mT(:);
        end
        
%         function n = numCharsInCellArrayIncNull(a)
%             n=0;
%             for e=a.'
%                 n = n + length(cell2mat(e)) + 1;
%             end
%         end
    end
end