function [out, err, h, sim_data,finali] = mlem(ini, data, respmat, Bins, cutoff, error)
% MLEM algorithm in matrix form

% Helper function to grab variable name for YdataSource
vartostr = @(x) inputname(1);

% Initialization
one = ones(size(data));
h = figure;
i = 1;

n = 0;

h1 = stairs(Bins,ini,'YDataSource', vartostr(ini));
title('Neutron Spectrum');
xlabel('Energy [Mev]');
ylabel('Fluence Rate [ncm^{-2}s^{-1}]');
set(gca,'Xscale','log');

% iteration of MLEM method
while i<cutoff

    % ratio of data to convolution of changing guess spectrum with response
    r = data./(respmat*ini);
    
    c = respmat'*r;
    
    ini = ini.*c./(respmat'*one);
    
    if mod(i,10) == 0
        n = n+1;
        refreshdata(h1, 'caller');
        drawnow;
    end
    
    if isequal((1+error)>r,one) && isequal(r>(1-error),one)
        break
    end
    
    i = i+1;
    r;
end

out = ini;
finali = i;
% this is the ratio of measured to mlem generated counts
err = r;
sim_data = respmat*ini;
end