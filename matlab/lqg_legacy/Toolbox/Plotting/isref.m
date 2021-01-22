function ir = isref(name)
    if length(name) < 3 
        ir = false;
    else
        if strcmp(name(1:3), 'ref')
            ir = true;
        else
            ir = false;
        end
    end
end