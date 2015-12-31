function [specout, sq, s, err, sim_data,finali] = MLEMTRON(meas, testin, respmat, Bins, cutoff, norm, error)

% NEUTRON ML-EM
% This is where all the work is done! See mlem for details
[specout, err, ~, sim_data,finali] = mlem(testin,meas'*norm, respmat, Bins, cutoff, error);

% ----------------------------------------------------------------------%

% Error MC

% Use a vector of random numbers from a Poisson distribution to get the
% input data

% Initialize matrix
hold on
initial_matrix = size(respmat);
spec = zeros(initial_matrix(2));

h = waitbar(0, 'Please wait: Calculating Uncertainty...');

numberofSpectrumBins = length(spec);
% Default number
numberofSpectra = 1000;

%See how long the uncertainty caluclation takes
tic
parfor i = 1:numberofSpectra
    % here is where the data is sampled to give pseudo measurements
    prot = poissrnd(meas'*norm);
    % mlem2 does the same job as mlem w/o visualization
    [spec(:,i),~] = mlem2(testin, prot, respmat, Bins, cutoff, error);
    waitbar(i/numberofSpectra);
    
end
toc
close(h)

% Initialize and calculate the variance and standard deviation from all
% spectra
sq = zeros(numberofSpectrumBins,1);
n_samples= size(spec,2);
for i = 1:numberofSpectrumBins
    
    sq(i) = 1/n_samples*sum((spec(i,:)-specout(i)).^2);
    
end
s = sqrt(sq);

%Plot the uncertainty on top of the spectrum

bline_bins = Bins + (Bins*(10^0.2) - Bins)/2;
[hl,~] = boundedline(bline_bins, specout, s, '.', 'alpha');
delete(hl)
set(gca,'YLim', [0 max(specout)*1.25]);
end