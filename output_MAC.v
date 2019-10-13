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
//Input Detect Module
//
//This is a module that sends the MAC address of a device over 
//the IPv4 layer
//================================================================

module input_det(
    input wire          clk,
    input wire          areset,
    output reg          data_valid,
    output reg [7:0]    data_tx,
    input wire          data_ack_tx,

    input wire          send_mac,
    input wire [47:0]   source_mac,
    input wire [31:0]   source_ip,
    input wire [47:0]   my_mac,
    input wire [31:0]   my_ip
);

    //-- States: blocks to write
    parameter IDLE              = 4'h0;
    parameter ETH_DEST_ADDR     = 4'h1;
    parameter ETH_SRC_ADDR      = 4'h2;
    parameter FRAME_TYPE        = 4'h3;
    parameter HW_TYPE           = 4'h4;
    parameter PROT_TYPE         = 4'h5;
    parameter HW_LEN            = 4'h6;
    parameter PROT_LEN          = 4'h7;
    parameter ARP_OP            = 4'h8;
    parameter ARP_SRC_ADDR      = 4'h9;
    parameter ARP_SRC_IP        = 4'hA;
    parameter ARP_DEST_ADDR     = 4'hB;
    parameter ARP_DEST_IP       = 4'hC;
    parameter END               = 4'hD;

    reg [3:0] state;
    
    //-- State Sequential logic
    always @(posedge clk or areset) begin
        if(areset)
            state <= IDLE;
        else
            state <= next_state;
    end


    always
    always @(posedge clk or areset) begin
        if(areset) begin
            data_valid  <= 1'b0;
            data_tx     <= 8'h00;
            sending     <= 1'b0;
        end else begin
            if(sending) begin

            end else begin
                if(send_mac) sending <= 1'b1; else sending <= 1'b0; 
            end
        end
    end

end module
