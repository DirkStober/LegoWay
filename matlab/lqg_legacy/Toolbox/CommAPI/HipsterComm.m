classdef HipsterComm < HipsterCommDLL
    properties (SetAccess = private)
    end
    
    methods
        function obj = HipsterComm(log_path, dll_path)
            obj = obj@HipsterCommDLL(log_path, dll_path);
        end
        
        function hipster_status = pollForStatus(obj, timeout)
            if nargin < 2 || isempty(timeout)
                timeout = 30; %seconds
            end

            hipster_status.conn_state = 'disconnected';
            hipster_status.running_state = 'unknown';
            hipster_status.reg_exists = 0;
            try
                [status, ret] = obj.getStatus(timeout);

                if ret == 0
                    hipster_status.conn_state = 'connected';
                    switch status.cur_state
                        case 1
                            hipster_status.running_state = 'stopped';
                        case 2
                            hipster_status.running_state = 'running';
                    end
                    hipster_status.reg_exists = status.reg_exists;
                end
            catch e
                hipster_status.conn_state = 'disconnected';
            end
        end
    end
    
    methods (Access = private)
    end
    
    methods(Static)
    end
end
