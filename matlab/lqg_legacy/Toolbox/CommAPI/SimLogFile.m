classdef SimLogFile < handle
    properties
        mat_data;
    end
    
    methods
        function obj = SimLogFile(filename)      
            obj.mat_data = load(filename, 'sim_data', '-mat');
        end
        
        function header = getHeader(obj)
            header = obj.mat_data.sim_data;
            
            header.nstates            = length(header.StateName);
            header.ninputs            = length(header.InputName);
            header.noutputs           = length(header.OutputName);
        end
        
        function [log_data, not_complete_flag] = getFullLog(obj)
            
            % First get the header
            %log_data = obj.getHeader();
                        
            % Return early if the header is incomplete
%             if isempty(log_data)
%                 return;
%             end
            
            log_data = obj.mat_data.sim_data;
        end
    end
end
