function m = struct2mtrx(structure)

[r k d] = size(structure); 
m = zeros(r, d);

for j = 1:d
    m(:,j) =  structure(:,:,j);
end