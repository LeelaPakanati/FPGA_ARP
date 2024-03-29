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
//ARP Response Design
//
//This is a module that recognizes a ARP request corresponding
//to its IP Address and repies with its MAC Address
//================================================================

module arp_response_block (
    input wire          ARESET,
    
    input wire [47:0]   MY_MAC,
    input wire [31:0]   MY_IPV4,

    input wire          CLK_RX,
    input wire          DATA_VALID_RX,
    input wire [7:0]    DATA_RX,

    input wire          CLK_TX,
    output wire         DATA_VALID_TX,
    output wire [7:0]   DATA_TX,
    input wire          DATA_ACK_TX
); 

    //buffers for asyc clock
    reg         arp_send;
    reg [47:0]  source_mac;
    reg [31:0]  source_ip;

    wire        arp_send_read;
    wire [47:0] source_mac_read;
    wire [31:0] source_ip_read;

    reg         sending;

    always @(posedge CLK_RX or posedge ARESET) begin
        if(ARESET)
            arp_send        <= 1'b0;
        else
            if(sending)
                arp_send    <= 1'b0;
            else
                arp_send    <= arp_send_read;
    end

    
    always @(posedge CLK_TX or ARESET) begin
        if(ARESET) begin
            source_mac      <= 48'h0;
            source_ip       <= 32'h0;
        end else begin
            if(arp_send_read) begin
                source_mac  <= source_mac_read;
                source_ip   <= source_ip_read;
            end else begin
                source_mac  <= source_mac;
                source_ip   <= source_ip;
            end
        end
    end

    always @(posedge CLK_TX or ARESET) begin
        if(ARESET)
            sending <= 1'b0;
        else 
            if(arp_send)
                sending <= 1'b1;
            else
                sending <= 1'b0;
    end

    input_det in0(
        .clk(CLK_RX),
        .areset(ARESET),
        .my_ip(MY_IPV4),
        .data_valid(DATA_VALID_RX),
        .data_rx(DATA_RX),

        .arp_send(arp_send_read),
        .source_mac(source_mac_read),
        .source_ip(source_ip_read)
    );

    output_MAC out0(
        .clk(CLK_TX),
        .data_valid(DATA_VALID_TX),
        .data_tx(DATA_TX),
        .data_ack_tx(DATA_ACK_TX),

        .send_mac(arp_send),
        .source_mac(source_mac),
        .source_ip(source_ip),
        .my_mac(MY_MAC),
        .my_ip(MY_IPV4)
    );

endmodule
