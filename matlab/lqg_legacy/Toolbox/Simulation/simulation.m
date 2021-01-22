function sim_data = simulation(reg, t, refCell, stdvPn, stdvMn, state_init, model_handle)
    
    if iscell(reg) 
        nr = length(reg);
        for i = 1:nr
            emsg = checkReg(reg{i});
            if emsg ~= 0
               error(emsg); 
            end
            disp(['Simulating controller ' num2str(i)]);
            sim_data(2*(i-1)+1:2*i) = nlin_sim(reg{i}, t, refCell, stdvPn, stdvMn, state_init, model_handle);
        end
    else
        emsg = checkReg(reg);
        if emsg ~= 0
           error(emsg); 
        end
        sim_data = nlin_sim(reg, t, refCell, stdvPn, stdvMn, state_init, model_handle);
    end
end