function ix = names2index(names, name)

ix = [];
nn = length(name);
for i = 1:nn
    in = find(strcmp(names,name{i}));
    if(~isempty(in))
        ix = [ix in];
    end
end

end