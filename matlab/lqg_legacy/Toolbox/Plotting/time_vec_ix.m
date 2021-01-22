function [ix_from, ix_to] = time_vec_ix(clsm, plot_mode, nsec)
  
    nsamples = length(clsm);
    
    switch plot_mode
        case 'all'
            ix_from = 1;
            ix_to = nsamples;
        case 'last_nsec'
            ix_from = 1;
            ix_to = nsamples;
            t_last = clsm(end);
            for k=nsamples-1:-1:1
                if t_last - clsm(k) > nsec*1E3;
                    ix_from = k+1;
                    break;
                end
            end             
        otherwise
            error('Unknown plot mode');
    end



end

