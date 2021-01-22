function ih = ishat(name)
    if length(name) < 3 
        ih = false;
    else
        if strcmp(name(end-2:end), 'hat')
            ih = true;
        else
            ih = false;
        end
    end
end