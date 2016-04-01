function [ qsource ] = sourcestrength( fluence, doserate, distance, surface )
%Gives the neutron source strength in neutrons per Gy at isocentre
%   Fluence in n/cm^2/s
%   Distance in cm
%   Surface in cm^2

qsource = sum(fluence)*(60/(doserate/100))/(0.93/(4*pi*(distance)^2)+5.4*0.93/(surface)+1.3/(surface));

end

