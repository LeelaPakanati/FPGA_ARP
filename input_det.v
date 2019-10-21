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
//This is a module that recognizes a ARP request corresponding
//to its IP Address 
//================================================================

`include "constants.vh"

module input_det(
    input wire          clk,
    input wire          areset,
    input wire [31:0]   my_ip,
    input wire          data_valid,
    input wire [7:0]    data_rx,

    output reg          arp_send,
    output reg [47:0]   source_mac,
    output reg [31:0]   source_ip
);


    reg [3:0] state;
    wire [3:0] next_state;
    wire [2:0] blk_cnt; 

    reg [47:0] eth_dest_addr;
    reg [47:0] eth_src_addr;
    reg [15:0] frame_type;
    reg [15:0] hw_type;
    reg [15:0] prot_type;
    reg [7:0]  hw_len;
    reg [7:0]  prot_len;
    reg [15:0] arp_op;
    reg [47:0] arp_src_addr;
    reg [31:0] arp_src_ip;
    reg [47:0] arp_dest_addr;
    reg [31:0] arp_dest_ip;

    //-- State Sequential logic
    always @(posedge clk or areset) begin
        if(areset) begin
            //if currently reading a byte go to state END
            //else go to IDLE
            if (data_valid) state <= `END; else state <= `IDLE;
        end else state <= next_state;
    end

    //get next state
    blk_next_state bns(
        .clk(clk),
        .areset(areset),
        .state(state),
        .start(data_valid),
        .ack(1'b1),

        .blk_cnt(blk_cnt),
        .next_state(next_state)
    );


    //-- store data
    always @(state, blk_cnt or areset) begin
        if (areset) begin
            eth_dest_addr   <= 48'h0;
            eth_src_addr    <= 48'h0;
            frame_type      <= 15'h0;
            hw_type         <= 15'h0;
            prot_type       <= 15'h0;
            hw_len          <= 8'h0;
            prot_len        <= 8'h0;
            arp_op          <= 15'h0;
            arp_src_addr    <= 48'h0;
            arp_src_ip      <= 32'h0;
            arp_dest_addr   <= 48'h0;
            arp_dest_ip     <= 32'h0;

        end else begin
            case(state)
                `ETH_DEST_ADDR:
                     eth_dest_addr   <=  {eth_dest_addr[39:0], data_rx};
                `ETH_SRC_ADDR:
                     eth_src_addr    <=  {eth_src_addr[39:0], data_rx};
                `FRAME_TYPE:
                     frame_type      <=  {frame_type[7:0], data_rx};
                `HW_TYPE:
                     hw_type         <=  {hw_type[7:0], data_rx};
                `PROT_TYPE:
                     prot_type       <=  {prot_type[7:0], data_rx};
                `HW_LEN:
                     hw_len          <=  data_rx;
                `PROT_LEN:
                     prot_len        <=  data_rx;
                `ARP_OP:
                     arp_op          <=  {arp_op[7:0], data_rx};
                `ARP_SRC_ADDR:
                     arp_src_addr    <=  {arp_src_addr[39:0], data_rx};
                `ARP_SRC_IP:
                     arp_src_ip      <=  {arp_src_ip[23:0], data_rx};
                `ARP_DEST_ADDR:
                     arp_dest_addr   <=  {arp_dest_addr[39:0], data_rx};
                `ARP_DEST_IP:
                    arp_dest_ip     <=  {arp_dest_ip[23:0], data_rx};
                `END: begin
                    eth_dest_addr   <= eth_dest_addr;
                    eth_src_addr    <= eth_src_addr;
                    frame_type      <= frame_type;
                    hw_type         <= hw_type;
                    prot_type       <= prot_type;
                    hw_len          <= hw_len;        
                    prot_len        <= prot_len;      
                    arp_op          <= arp_op;
                    arp_src_addr    <= arp_src_addr;
                    arp_src_ip      <= arp_src_ip;
                    arp_dest_addr   <= arp_dest_addr;
                    arp_dest_ip     <= arp_dest_ip;
                end

                default: begin
                    eth_dest_addr   <= 48'h0;
                    eth_src_addr    <= 48'h0;
                    frame_type      <= 15'h0;
                    hw_type         <= 15'h0;
                    prot_type       <= 15'h0;
                    hw_len          <= 8'h0;
                    prot_len        <= 8'h0;
                    arp_op          <= 15'h0;
                    arp_src_addr    <= 48'h0;
                    arp_src_ip      <= 32'h0;
                    arp_dest_addr   <= 48'h0;
                    arp_dest_ip     <= 32'h0;
                end
            endcase
        end
    end


    //-- check data and drive outputs
    always @(state) begin
        if( (state          == `END)                &&
            (eth_dest_addr  == `BRDCAST_DEST_ADDR)   &&
            (frame_type     == `ARP_FRAME_TYPE)      &&
            (hw_type        == `ETH_HW_TYPE)         &&
            (prot_type      == `IP_PROT_TYPE)        &&
            (hw_len         == `ETH_HW_LEN)          &&
            (prot_len       == `IP_PROT_LEN)         &&
            (arp_op         == `REQ_ARP_OP)          &&
            (arp_dest_addr  == `ARP_REQ_ADDR)        &&
            (arp_dest_ip    == my_ip)               
          ) begin
              
            arp_send    <= 1'b1;
            source_mac  <= arp_src_addr;
            source_ip   <= arp_src_ip;
        end else begin
            arp_send    <= 1'b0;
            source_mac  <= 48'h0;
            source_ip   <= 31'h0;

        end
    end

endmodule
