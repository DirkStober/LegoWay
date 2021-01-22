function port_cur=getPort()
%Gets the active COM-port used by the Bluetooth interface from the windows
%registry.

try
    ddir='BTHENUM\{00001101-0000-1000-8000-00805f9b34fb}_LOCALMFG&000a';
    N=length(ddir)+2;
    names=winqueryreg('name','HKEY_LOCAL_MACHINE','SYSTEM\CurrentControlSet\services\BTHMODEM\Enum');
    for k=1:length(names)
        keys=winqueryreg('HKEY_LOCAL_MACHINE','SYSTEM\CurrentControlSet\services\BTHMODEM\Enum',names{k});
        found=~isempty(strfind(keys,ddir));
        if found
            uniqueID=keys(N:end);
            break;
        end
    end

    port_cur=winqueryreg('HKEY_LOCAL_MACHINE',['SYSTEM\CurrentControlSet\Enum\BTHENUM\{00001101-0000-1000-8000-00805f9b34fb}_LOCALMFG&000a\' uniqueID '\Device Parameters'],'PortName');
catch e
    port_cur = [];
    error('No active BT connection to NXT found. Make sure a BT connection is established and that only one NXT is paired to the computer');
end