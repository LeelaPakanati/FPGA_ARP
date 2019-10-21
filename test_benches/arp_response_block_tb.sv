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
//arp_response_block -> Test arp_response_block module
//
//
//================================================================

module arp_response_block_tb();
    reg          ARESET;

    reg [47:0]   MY_MAC;
    reg [31:0]   MY_IPV4;

    reg          CLK_RX;
    reg          DATA_VALID_RX;
    reg [7:0]    DATA_RX;

    reg          CLK_TX;
    wire         DATA_VALID_TX;
    wire [7:0]   DATA_TX;
    reg          DATA_ACK_TX;

    arp_response_block arb0(
        .ARESET(ARESET),
        .MY_MAC(MY_MAC),
        .MY_IPV4(MY_IPV4),
                                       
        .CLK_RX(CLK_RX),
        .DATA_VALID_RX(DATA_VALID_RX),
        .DATA_RX(DATA_RX),
                                       
        .CLK_TX(CLK_TX),
        .DATA_VALID_TX(DATA_VALID_TX),
        .DATA_TX(DATA_TX),
        .DATA_ACK_TX(DATA_ACK_TX)
    );

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


    initial begin
        $dumpfile("output_waveforms/arp_response_block_tb.vcd");
        $dumpvars(0, ARESET, MY_MAC, MY_IPV4, CLK_RX, DATA_VALID_RX, DATA_RX, CLK_TX, DATA_VALID_TX, DATA_TX, DATA_ACK_TX, arb0.arp_send, arb0.source_mac, arb0.source_ip);
    end


    initial
        $monitor("Time: %t, data_tx: %h, data_valid: %h, data_ack: %h", $time, DATA_TX, DATA_VALID_TX, DATA_ACK_TX);

    always begin
            #5;
            CLK_RX         <=  !CLK_RX;
            CLK_TX         <=  !CLK_TX;
    end

    initial begin
        ARESET          <= 1'b1;

        MY_IPV4         <= 32'hC0A80102;
        MY_MAC          <= 48'h000223010203;

        CLK_RX          <= 1'b0;
        DATA_VALID_RX   <= 8'h00;
        DATA_RX         <= 8'h00;

        #1;
        CLK_TX          <= 1'b0;
        DATA_VALID_RX   <= 8'h00;
        DATA_RX         <= 8'h00;
        DATA_ACK_TX     <= 1'b0;

        #9;

        #20;
        ARESET          <= 1'b0;
        #10;
        
        DATA_VALID_RX   <= 1'b1;
        for (int i =0; i<42; i=i+1) begin
            DATA_RX <= (arp_request_block >> (41-i)*8);
            #10;
        end

        DATA_VALID_RX   <= 1'b0;
        DATA_RX         <= 8'b0;

        #50;
        DATA_ACK_TX     <= 1'b1;
        #10;
        DATA_ACK_TX     <= 1'b0;
        #500;

        $stop;
        $finish;
    end


endmodule
