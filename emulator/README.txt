This directory contains a python-based emulator of the BlitzCoin coin exchange algorithm, aimed at producing rapid evaluation and exploration of the convergence features of the algorithm under different paramters.

This code is expected to run with Python3 and 

The following Python code can be run to reproduce the results presented in the paper:

1/convergence_speed_BC_baseline.py 
This generates the 'default' data (red) shown in figure 6
2/convergence_speed_BC_smart_timing.py 
This generates the 'dynamic timing' data (blue) shown in figure 6
3/convergence_heterogeneity.py
This generates the data presented in figure 8

Note that the results of the simulations are displayed in text format and can be post-processed [TBD]

