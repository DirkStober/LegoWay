function [out dout ddout in] = prepDataForIdent(y, u, Ts)

    y   = deg2rad(y);                      % Convert to radians
    lpf = lpfilter(Ts);                    % Get lowpassfilter
    yf  = filter(lpf, y);                  % smooth quantization steps in the data   
    zf  = round(length(lpf.numerator)/2);  % number of samples that the filter will shift the inputsignal
    yf  = [yf(zf:end); zeros(zf-1,1)];     % filtered data, correctly alligned to original data  
    
    plot([y yf]);
    
    u  =  u(zf+1:end-zf);
    yf = yf(zf+1:end-zf);
    
    % It is the derivative of the measurments that is used in the
    % identification
    [dout cut_beg1 cut_end1]  = num_diff(yf, 1, Ts);
    [ddout cut_beg2 cut_end2] = num_diff(yf, 2, Ts);
    
    db = cut_beg1 - cut_beg2;
    de = cut_end1 - cut_end2;
    
    dout  = dout(1+max(0, -db):end-max(0,-de));
    ddout = ddout(1+max(0, db):end-max(0, de));
    
    cut_beg = max(cut_beg1, cut_beg2);
    cut_end = max(cut_end1, cut_end2);


    out = yf(1+cut_beg:end-cut_end);
    in  =  u(1+cut_beg:end-cut_end); %The outermost data samples are lost in the differentiation
    
end

