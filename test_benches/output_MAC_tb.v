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
//output_MAC -> Test output_MAC module
//
//
//================================================================

module output_MAC_tb();
    reg          clk;
    reg          areset;

    wire         data_valid;
    wire [7:0]   data_tx;
    reg          data_ack_tx;

    reg          send_mac;
    reg [47:0]   source_mac;
    reg [31:0]   source_ip;
    reg [47:0]   my_mac;
    reg [31:0]   my_ip;

    output_MAC out0(  
        .clk(clk),
        .areset(areset),
                       
        .data_valid(data_valid),
        .data_tx(data_tx),
        .data_ack_tx(data_ack_tx),
                                  
        .send_mac(send_mac),
        .source_mac(source_mac),
        .source_ip(source_ip),
        .my_mac(my_mac),
        .my_ip(my_ip)
    );

    initial begin
        $dumpfile("output_waveforms/output_MAC_tb.vcd");
        $dumpvars(0,clk, areset, data_valid, data_tx, data_ack_tx, out0.state);
    end

    initial
        $monitor("Time: %t, data_tx: %h, data_valid: %h, data_ack: %h", $time, data_tx, data_valid, data_ack_tx);

    always begin
            #5;
            clk         <=  !clk;
    end

    initial begin
        clk         <= 1'b0;
        areset      <= 1'b1;
        data_ack_tx <= 1'b0;
        send_mac    <= 1'b0;
        source_mac  <= 48'h0123456789AB;
        source_ip   <= 32'h55555555;
        my_mac      <= 48'hBA9876543210;
        my_ip       <= 32'hAAAAAAAA;
        #20;
        areset      <= 1'b0;
        #10;
        send_mac    <= 1'b1;
        #10;
        send_mac    <= 1'b0;
        #30;
        data_ack_tx <= 1'b1;
        #10;
        data_ack_tx <= 1'b0;
        #500;
        $stop;
        $finish;
    end


endmodule
