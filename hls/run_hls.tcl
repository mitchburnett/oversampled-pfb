# Create a project
open_project -reset os_pfb_prj

# The source file and test bench
add_files os_pfb.cpp
add_files -tb sim.cpp
add_files -tb data/

# Specify the top-level function for synthesis
set_top os_pfb

# Create solution1
open_solution -reset sol1

# Specify a Xilinx device and clock period
set_part  {xczu28dr-ffvg1517-2-e}
create_clock -period 10

config_dataflow -strict_mode warning -default_channel fifo -fifo_depth 1

# Simulate the C code 
csim_design

# Syntesize, Verify the RTL and produce IP (for sysgen add `-format sysgen`)
csynth_design
cosim_design 
export_design
exit

