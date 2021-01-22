function sys_cut = removeStates(sys, indexToRemove)

if isempty(indexToRemove)
    sys_cut = sys;
    return
end

nx = size(sys.A,1);

select = true(nx,1);
select(indexToRemove) = 0; 

indexToKeep = 1:nx;
indexToKeep = indexToKeep(select);

A_cut = sys.A(indexToKeep, indexToKeep);
B_cut = sys.B(indexToKeep, :);
C_cut = sys.C(:, indexToKeep);
D_cut = sys.D; 

sys_cut = ss(A_cut,B_cut,C_cut,D_cut);
sys_cut.inputgroup = sys.inputgroup;
sys_cut.outputgroup = sys.outputgroup;