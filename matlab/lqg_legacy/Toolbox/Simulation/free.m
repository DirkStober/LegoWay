function f = free(t, ref)

if length(t) ~= length(ref)
    error('myApp:argChk', 'vectors must be of same length');
end

f.type      = 'free';
f.valueVec  = ref;
f.timeVec   = t;
f.time      = 0;