all: run_arp_response_block run_arp_response_block run_output_MAC

arp_response_block_tb: blk_next_state.v input_det.v output_MAC.v arp_response_block.v test_benches/arp_response_block_tb.sv 
	iverilog -g2012 $^ -s arp_response_block_tb -o sim_execs/arp_response_block.out

run_arp_response_block: arp_response_block_tb
	echo finish | ./sim_execs/arp_response_block.out

display_arp_response_block_waveform: run_arp_response_block
	gtkwave output_waveforms/arp_response_block_tb.vcd

input_det_tb: blk_next_state.v input_det.v test_benches/input_det_tb.sv 
	iverilog -g2012 $^ -s input_det_tb -o sim_execs/input_det.out

run_input_det: input_det_tb
	echo finish | ./sim_execs/input_det.out

display_input_det_waveform: run_input_det
	gtkwave output_waveforms/input_det_tb.vcd

output_MAC_tb: blk_next_state.v output_MAC.v test_benches/output_MAC_tb.v 
	iverilog $^ -s output_MAC_tb -o sim_execs/output_MAC.out

run_output_MAC: output_MAC_tb
	echo finish | ./sim_execs/output_MAC.out
	

display_output_MAC_waveform: run_output_MAC
	gtkwave output_waveforms/output_MAC_tb.vcd
