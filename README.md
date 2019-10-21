# XR Trading FPGA Assesment  
This is a block that receive IP Network packets, detects an ARP Request and replies accordignly

## Files  
.  
├── arp_response_block.v    -   Top module for arp response  
├── blk_next_state.v        -   Logic for determining next state for input and output  
├── constants.vh            -   State constants and arp block values  
├── input_det.v             -   Detection of input data to see incoming arp request  
├── Makefile                -   Makefile for buiding/running/viewing -> see 'Compiling'  
├── output_MAC.v            -   Block to output arp response  
├── output_test_images/     -   Directory with waveform images  
├── output_waveforms/       -   Directory with waveforms  
├── README.md               -   This readme  
├── sim_execs/              -   Directory with executable to run testbenches and make waveforms  
└── test_benches/           -   Directory with testbenches  



## Compiling  
I used iverilog (Icarus Verilog Compiler) to compile my project.  
I used gtkwave to view the output of the simulations.  
Compilation has been automated with make.  

### Building

Needs iverilog for building  
Needs gtkwave for viewing waveforms

#### input_det testbench  
Build testbench executable  
```
make input_det_tb
```

Run testbench executable
```
make run_input_det
```

Display input_det_waveform
```
make display_input_det_waveform 
```

#### output_MAC testbench  
Build testbench executable  
```
make output_MAC_tb
```

Run testbench executable
```
make run_output_MAC
```

Display output_mac waveform
```
make display_output_MAC_waveform 
```

#### arp_response_block testbench  
Build testbench executable  
```
make arp_response_block_tb
```

Run testbench executable
```
make run_arp_response_block
```

Display output_mac waveform
```
make display_arp_response_block_waveform 
```
