function r = getRef(t, Ts, refStruct)

na  = length(refStruct);
N   = ceil(t/Ts);

r = zeros(N,1);

for i = 1:na
    type = refStruct{i}.type;
    time = refStruct{i}.time;
    
    if(time < t)
        switch type
            case 'step'
                n   = floor(time/Ts);
                h   = refStruct{i}.height;
                r   = r + [zeros(n,1); h*ones(N-n, 1)];
            case 'ramp'
                n   = floor(time/Ts);
                h   = refStruct{i}.height;
                m   = floor(refStruct{i}.length/Ts);
                r   = r + [zeros(n,1); linspace(0,h, m)'; h*ones(N-n-m, 1)];
            case 'free'
                n       = floor(refStruct{i}.timeVec/Ts);
                lastval = 0;
                tempInd = 0;
                for j = 1:N
                    tempInd = find(j == n);
                    if ~isempty(tempInd)
                        index   = tempInd(1);
                        r(j)    = r(j) + refStruct{i}.valueVec(index);
                        lastval = r(j);
                    else
                        r(j) = lastval;
                    end
                end
            case 'zero'
                r = r;
            otherwise
                error('myApp:argChk', 'refStruct must have type field "step", "ramp", "free" or "zero"');
        end
    end
end