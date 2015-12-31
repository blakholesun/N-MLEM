function [ dose ] = getdoseh10( spectrum,icruconv )
%GetDose Calculates the ambient dose equivalent based on ICRU report 57
%pSv/fluence
%fluence to dose conversion factors. Units mSv/hr
%   Detailed explanation goes here

dose = 3600*sum(spectrum.*icruconv)*1e-12*1000;

end

