%ixu index of unessecary states
%ixn index of nessescary states

function [ixu ixn] = findUnessState(sys)
    
A = sys.A;
C = sys.C;

for i = 1:size(A,2)
    A(i,i) = 0;
end

T = [A; C];

ixu = find(sum(T ~= 0)==0);
ixn = find(sum(T ~= 0)~=0);    
end           