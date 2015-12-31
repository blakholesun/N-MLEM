function print_report( handles )
%print_report Prints a report of the NNS neutron spectrum unfolding
%   Detailed explanation goes here

[filename,pathname] = uiputfile('*.txt', 'Save Report As');
fullname = strcat(pathname,filename);
if isequal(fullname,0)
    return
end

fid = fopen(fullname, 'w');

fprintf(fid, strcat(filename,'\n\n', '---- Generated on: ', char(datetime), ' ----\n\n\n' ));

fprintf(fid, '1) Initial Conditions\n\n');
fprintf(fid, 'NNS Normalization:     %5.3f\n', handles.normalization);
fprintf(fid, 'Iterattion Cutoff:     %d\n', handles.iteration);
fprintf(fid, 'Meas/Calc Diff:       %5.3f\n', handles.ratio);
fprintf(fid, 'Time [s]:              %d\n\n', handles.time);

fprintf(fid, '2) Data\n\n');
fprintf(fid, 'Final Iteration Number:   %d\n\n ',handles.final.finali);
fprintf(fid, 'Raw Data [cps]       Calculated Data [cps]       Ratio\n\n');
fprintf(fid, '% 12.2f            % 12.2f           % 5.3f\n', ...
    [handles.meas; handles.final.sim_data'; handles.final.err']);

fprintf(fid, '\n3) Neutron Spectrum\n\n');
fprintf(fid, 'Ambient equivalent dose: % 5.3f mSv/hr\n\n', getdoseh10(handles.final.specout,handles.icruconv));
fprintf(fid, 'Bins [MeV]       Fluence Rate [n*cm^-2*s^-1]\n\n');
fprintf(fid, '% 4.2e       % 12.2f\n', [handles.Bins'; handles.final.specout']);

fclose(fid);


end

