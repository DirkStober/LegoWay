function sim_data = simulate_hipster(reg, time)
    % Initial state
    x0  = [0 0 0 0 0 0]';  
    
    
    % Reference signals
    ref{1}  = {step(0,45*pi/180)};
    ref{2}  = {zero()};
    ref{3}  = {step(0.5,0.1)};  
    
    % Process and measurement noise standard deviation
    noise_intensities = 10; 
    stdvPn = noise_intensities*sqrt([1 1])';       
    stdvMn = noise_intensities*sqrt(1e-7*[10 10 1])';                                                   
    
    % Function handle to the nonlinear model
    model_handle = getHipsterModel();
    
    % Simulation
    sim_data = simulation(reg, time, ref, stdvPn, stdvMn, x0, model_handle); 
end