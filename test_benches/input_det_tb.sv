`timescale 1ns / 1ps
//================================================================
// \ \/ /  _ \  |_   _| __ __ _  __| (_)_ __   __ _  
//  \  /| |_) |   | || '__/ _` |/ _` | | '_ \ / _` | 
//  /  \|  _ <    | || | | (_| | (_| | | | | | (_| | 
// /_/\_\_| \_\   |_||_|  \__,_|\__,_|_|_| |_|\__, | 
//                                            |___/  
//  _____ ____   ____    _     ____            _           _   
// |  ___|  _ \ / ___|  / \    |  _ \ _ __ ___ (_) ___  ___| |_ 
// | |_  | |_) | |  _  / _ \   | |_) | '__/ _ \| |/ _ \/ __| __|
// |  _| |  __/| |_| |/ ___ \  |  __/| | | (_) | |  __/ (__| |_ 
// |_|   |_|    \____/_/   \_\ |_|   |_|  \___// |\___|\___|\__|
//                                           |__/              
//Leela Pakanati
//input_det -> Test input_det module
//
//
//================================================================

module input_det_tb();
    reg          clk;
    reg          areset;
    reg [31:0]   my_ip = 32'hC0A80102;
    reg          data_valid;
    reg [7:0]    data_rx;

    wire         arp_send;
    wire [47:0]  source_mac;
    wire [31:0]  source_ip;

    parameter [8*42-1:0] arp_request_block = 
        {
            //-- dest mac addr
            8'hff,
            8'hff,
            8'hff,
            8'hff,
            8'hff,
            8'hff,
            //-- source mac addr
            8'h00,
            8'h01,
            8'h42,
            8'h00,
            8'h5F,
            8'h68,
            //-- frame type
            8'h08,
            8'h06,
            //-- HW Type
            8'h00,
            8'h01,
            //-- Protocol Type
            8'h08,
            8'h00,
            //-- HW len
            8'h06,
            //-- Protocol len
            8'h04,
            //-- ARP Operation
            8'h00,
            8'h01,
            //-- source mac addr
            8'h00,
            8'h01,
            8'h42,
            8'h00,
            8'h5F,
            8'h68,
            //-- source ip addr
            8'hc0,
            8'ha8,
            8'h01,
            8'h01,
            //-- dest mac addr
            8'h00,
            8'h00,
            8'h00,
            8'h00,
            8'h00,
            8'h00,
            //-- dest ip addr
            8'hC0,
            8'hA8,
            8'h01,
            8'h02
        };


    input_det in0(  
        .clk(clk),
        .areset(areset),
                       
        .my_ip(my_ip),
        .data_valid(data_valid),
        .data_rx(data_rx),

        .arp_send(arp_send),
        .source_mac(source_mac),
        .source_ip(source_ip)
    );

    initial begin
        $dumpfile("output_waveforms/input_det_tb.vcd");
        $dumpvars(0, clk, areset, my_ip, data_valid, data_rx, arp_send, source_mac, source_ip, in0.state);
    end

    //initial
    //    $monitor("Time: %t, ", $time, data_tx);

    always begin
            #5;
            clk         <=  !clk;
    end

    initial begin
        clk         <= 1'b0;
        areset      <= 1'b1;

        my_ip       <= 32'hC0A80102;
        data_valid  <= 1'b0;
        data_rx     <= 8'h00;
        
        #20;
        areset      <= 1'b0;
        #10;
        
        data_valid  <= 1'b1;
        for (int i =0; i<42; i=i+1) begin
            data_rx <= (arp_request_block >> (41-i)*8);
            #10;
        end

        data_valid  <= 1'b0;
        data_rx     <= 8'b0;
        #50;

        $stop;
        $finish;
    end


endmodule
