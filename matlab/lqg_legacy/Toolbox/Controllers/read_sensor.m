function y = read_sensor(port)

global hc
try
    s = hc.getStatus(5);
    s.sensor_port(port)
catch e
   error('No connection to brick found'); 
end

end