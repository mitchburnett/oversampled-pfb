# HLS Oversampled Polyphase Filterbank

Source code is found in hls directory. To synthesize and export the IP in its
current configuration (32-pt FFT, decimate by 24, 4/3 oversample ratio) change
into the hls directory and run `vivado_hls run_hls.tcl`. This will simulate the
current configuration in sim.cpp, synthesize, and export IP into the sol1/impl
directory.

A vivado project with the HLS core, MPSoC and DMA for the built IP is in the
vivado directory.
