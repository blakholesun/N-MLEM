function [ phi ] = fluence( fluence)
%Gives the fluence as the sum of the spectral bins
%   fluence is the result of the unfolding
%   same untis as unfolding n*cm^-2*s^-1

phi = sum(fluence);

end

