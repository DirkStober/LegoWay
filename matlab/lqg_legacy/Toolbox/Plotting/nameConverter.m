function cnames = nameConverter(names)

    cnames = regexprep(names,'_','\\_');
%     n = length(names);
%     for i = 1:n
%         ix = strfind(names{i},'_');
%         names{i}(ix(1:end-1)) = '-';
%         if ~isempty(ix)
%             cnames{i} = regexprep(names{i}, '_', '_{');
%             cnames{i} = [cnames{i} '}'];
%         else
%             cnames{i} = names{i};
%         end
%     end
end