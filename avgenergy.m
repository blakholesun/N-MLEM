function [ energy] = avgenergy( spectrum, Bins )
%UNTITLED AVG energy of spectrum MeV
%   Detailed explanation goes here
specmod = spectrum./sum(spectrum);
energy = sum(Bins.*specmod);

end

