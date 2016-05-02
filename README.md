# N-MLEM
Neutron spectrum reconstruction using MLEM

N-MLEM is a code for simple neutron spectrum unfolding of the Nested Neutron Spectrometer in current mode. It takes electrometer current measurements as input and unfolds the data into a 52-bin neutron spectrum ranging from thermal to fast neutron energies.

## Instructions

All data input into the code must be charge in units of nC or in count rates in units of counts per second. The code automatically converts the charge to count rate and vice versa using a manufacturer provided conversion coefficient 7 fA/cps.

![alt tag](https://raw.github.com/blakholesun/N-MLEM/master/figures/image03.png)

## Parameters

The default values for the parameters are shown in the figure above.

NNS Normalization: This is the normalization constant that is determined by Detec. All of their detectors are calibrated based on NNS-0. At McGill, the detector had a normalization constant of 1.21.

Iteration Cutoff: This sets a hard cutoff to the MLEM algorithm. It is needed because in some cases the MLEM algorithm is unable to stop itself using the Meas/Calc Ratio (described below). The default is set to 10,000 iterations.

Meas/Calc Ratio: This ratio determines the primary stopping condition for the algorithm. It compares the values input into the code with calculated ones. Once the ratio is reached for each of the data values, the code stops. The default is a ratio of 0.01 or 1%.

Time: The time of measurement is absolutely crucial to the code since it calculates fluence rates. Time (seconds) must be entered before any values can be input into the GUI.

## Raw Data

The raw data in either nC or counts per second is input into the corresponding column. Once a value is entered the other column is automatically updated. Values are stored in cps in the software.

## Choose Guess Spectrum

There are two guess/starting spectra available to the user: a uniform spectrum and a step spectrum. The step spectrum was determined to be the one that most optimally reproduced Monte carlo generated neutron spectra. The User must select a starting spectrum for the MLEM algorithm to begin. There may be a customizable spectrum added eventually.


## CALCULATE!

Once all the parameters have been input, selected and verified, press CALCULATE!

![alt tag](https://raw.github.com/blakholesun/N-MLEM/master/figures/image01.png)

After pressing CALCULATE!, a neutron spectrum appears and begins to converge towards a certain shape. Upon completion, an uncertainty calculation is performed and the code then asks the user to save a report of the unfolding.

![alt tag](https://raw.github.com/blakholesun/N-MLEM/master/figures/image00.png)
![alt tag](https://raw.github.com/blakholesun/N-MLEM/master/figures/image02.png)

You can save the report as a text file anywhere you have write permission. The figure can also be saved in any image format by clicking on the save button.

## Report

The report is comprised of three sections: initial conditions, data, and neutron spectrum. An example report associated to the above data is attached below.

Initial Condition: This section is a restatement of the parameters used when the data was input into the GUI.

Data: This section copies the raw data and compare it to the final calculated data as a ratio. This is the same ratio that is used to stop the algorithm. It also contains the number of iterations carried out by the code.

Neutron spectrum: This section provides the ambient equivalent dose in mSv/hr and the neutron spectrum data that was used to plot the figure.

## Tips for running

Ideally, we would want the Meas/Calc ratio to be 1. In this case the neutron spectrum would be perfectly reconstructed. The goal of the MLEM algorithm itself is to approach 1 for all ratios.

If the data is very good then it should be quite easy for the code to reach its stopping point (the default Meas/Calc ratio of 0.01). However, sometimes it does not and will stop at 10,000 iterations. There are two options in this case:

Increase the number of iterations to see whether or not the code stop for the given ratio

Change the Meas/Calc ratio to a larger value

Increasing the number of iterations may lead to the desired ration except that the spectrum may become excessively noisy.

Changing the ratio can allow the code to stop at a lesser precision if the data is not great.

Much of the process of unfolding comes from experience with the code and the expected final spectrum. It may take someone a while to get used to the unfolding process and have an eye for what the best spectrum can be.
