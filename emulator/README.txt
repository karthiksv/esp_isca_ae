This directory contains a python-based emulator of the BlitzCoin coin exchange algorithm, aimed at producing rapid evaluation and exploration of the convergence features of the algorithm under different paramters.

This code is expected to run with Python3 and uses the following python modules:
random
numpy
matplotlib

Note that due to the statistical analysis requiring multiple (100 to 1000) Monte Carlo runs:
a)The wall clock runime of the different emulation can be in the order of 10minutes to 1-2 hours (especially for convergence_random_pairing_N_20 and convergence_heterogeneity)
b)The results may show small variations compared to the data included in the paper due to the statistical nature of the Monte Carlo process

The following Python code can be run to reproduce the results presented in the paper:

1/convergence_speed_BC_4way.py and convergence_speed_BC_baseline.py 
This generates the 4-way (blue) and the 1-way data (red) respectively shown in figure 3

2/convergence_speed_TS_boxplot.py and convergence_speed_BS_boxplot.py
This generates the TokenSmart (TS, blue) and the BlitzCoin (BC, orange) respectively shown in figure 4

3/convergence_speed_BC_baseline.py and convergence_speed_BC_smart_timing.py
This generates the 'default' data (red) and the 'dynamic timing' data (blue) respectivel shown in figure 6

4/convergence_random_pairing_N_10.py and convergence_random_pairing_N_20.py 
Generates the data and histogram plots for the N=10x10 and N=20x20 cases of figure 7. Data is also saved as csv

5/convergence_heterogeneity.py. 
This generates the data presented in figure 8


