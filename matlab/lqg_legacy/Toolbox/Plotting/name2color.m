function c = name2color(name)
if length(name) > 3
   if strcmp(name(end-2:end),'hat')
       c = 'g';
   elseif strcmp(name(1:3),'ref')
       c = 'r';
   else
       c = 'b';
   end
else
    c = 'b';
end
       
end
