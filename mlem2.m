function [out, bin] = mlem2(ini, data, respmat, Bins, cutoff, error)
% MLEM algorithm in matrix form

one = ones(size(data)); 
i = 1;
while i<cutoff
    
    r = data./(respmat*ini);

    c = respmat'*r;

    ini = ini.*c./(respmat'*one);
      
    if isequal((1+error)>r,one) && isequal(r>(1-error),one)
        break
    end

    i = i+1;
    
end
out = ini;
bin = Bins;
end