function val = get_setting(key)
% val = get_setting(key)
%
% Returns the value for one of
% the following keys:
%
% * 'root_dir'           The root dir
% * 'default_com_port'   Default com port

    [~, hostname] = system('hostname');
    
    % Settings depending on computer
    switch (deblank(hostname))
        case 'i7'
            root_dir = 'C:\Users\Per\Dropbox\Hipster\PC_sw\Matlab';
            com_port = 'COM4';
            copy_mex_opts = false;
            
        case 'Olov-PC'
            root_dir = 'C:\Users\Olov2\Dropbox\Hipster\PC_sw\Matlab';
            try 
                com_port = getPort();
            catch e
                com_port = [];
            end
            copy_mex_opts = false;
            
        case 'Olov-PC2'
            root_dir = 'C:\Users\Olov\Dropbox\Hipster\PC_sw\Matlab';
            try 
                com_port = getPort();
            catch e
                com_port = [];
            end
            copy_mex_opts = false;
            
        case 'elite'
            root_dir = 'C:\Users\Per\Dropbox\Hipster\PC_sw\Matlab';
            com_port = 'COM4';  
            copy_mex_opts = false;
            
        case 'Olov-PC-Work'
            root_dir = 'C:\Users\Olov\Documents\My Dropbox\Hipster\PC_sw\Matlab';
            try 
                com_port = getPort();
            catch e
                com_port = [];
            end
            copy_mex_opts = false;
            
        otherwise
            
            root_dir = pwd; %'G:\Program\Systemteknik\RegTek2\ProcLabs\LQ_twip\LeConLab\Matlab';
            try 
                com_port = getPort();
            catch e
                com_port = [];
            end
            copy_mex_opts = true;
            %error(['Unknown host: ' hostname 'Add hostname in get_root.m to resolve the issue.']);
    end
    
    if isempty(com_port) 
        warning('No active BT connection to NXT found. Make sure a BT connection is established and that only one NXT is paired to the computer if you intend to execute the controller on the NXT hardware.')
    end
    
    % Which setting to return?
    switch (key)
        case 'root_dir'
            val = root_dir;
        case 'default_com_port'
            val = com_port;
        case 'copy_mex_opts'
            val = copy_mex_opts;
        otherwise
            error(['Unknown setting key ' key]);
    end
end

