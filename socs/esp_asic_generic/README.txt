To start a simulation, after following the build steps listed in the paper's appendix:

TEST_PROGRAM=soft-build/ariane/baremetal/token_pm_3x3<x>.exe make xmsim-gui

This will start xcelium gui.

Then load the pre-saved signal window.

File>Source command script.
File name: ../restore_all.tcl.svcf
Send commands to "Simvision console"
Next window - Use the simulator "simulator"

The most important signals are "token_next", which represents the number of coins allocated to one of the 6 accelerators (tile 2...8) and activity which shows when each accelerator is running. 
LDOCTRL is the 8 bit control of the tile frequency. In a full ASIC it would control the LDO regulator, while in this simulation it is connected to a behavioral DCO whose frequency is a function of the LDOCTRL value. 

Start the simulation ("run")

After about 2-3 hours wall time you should see the xmsim terminal print a report of the different workloads runtime
(This is expected to take approximately 2700-2800us of simulator time)
You can then pause the simulation and export the signals for post-processing, using the xcelium gui menu

Then export all recorded variables variables as csv. Set trigger strobe 40ns, output radix as decimal and output time unit as ns in advanced csv options (cf screenshot export_settings.png in this folder).

Finally run
python3 post_process.py

This takes the generated csv as an input, and based on each tile's frequency and activity computes the estimated power at each point in time.
The command takes about 1-2min to run due to the parsing of the large csv file.

The command generates the graph of the power trace (fig 16 a) in the paper) as well as the total token count vs time and total run time.
The response time is not automatically computed but can be manually extracted by looking at the settling time after a transition (e.g. when the NVDLA workload ends).

