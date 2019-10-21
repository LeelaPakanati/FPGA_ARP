

output_MAC_tb: blk_next_state.v output_MAC.v test_benches/output_MAC_tb.v 
	iverilog $^ -s output_MAC_tb -o sim_execs/output_MAC.out

# Need to input comment "finish" after iverilog runs
run_output_MAC: output_MAC_tb
	./sim_execs/output_MAC.out
	

display_output_MAC_test: run_output_MAC
	gtkwave output_waveforms/output_MAC_tb.vcd
