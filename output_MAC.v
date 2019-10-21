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

`include "constants.vh"

module output_MAC(
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

    reg [3:0] state;
    wire [3:0] next_state;
    wire [2:0] blk_cnt;
    
    //get next state
    blk_next_state bns(
        .clk(clk),
        .areset(areset),
        .state(state),
        .start(send_mac),
        .ack(data_ack_tx),

        .blk_cnt(blk_cnt),
        .next_state(next_state)
    );
 
    //-- State Sequential logic
    always @(posedge clk or areset) begin
        if(areset)
            state <= `IDLE;
        else
            state <= next_state;
    end

    //-- output based on state
    always @(posedge clk or areset) begin
        if (areset) begin
            data_valid  <= 1'b0;
            data_tx     <= 8'h0;
        end else begin
            if ((state == `IDLE) || (state == `END))
                data_valid      <= 1'b0;
            else
                data_valid      <= 1'b1;


            case(state)
                //-- shift in each value of blk_cnt*8 (>>3)
                `ETH_DEST_ADDR:
                    data_tx     <= (source_mac >> ((5-blk_cnt)*8));

                `ETH_SRC_ADDR:
                    data_tx     <= (my_mac >> ((5-blk_cnt)*8));

                `FRAME_TYPE:
                    data_tx     <= (`ARP_FRAME_TYPE >> ((1-blk_cnt)*8));

                `HW_TYPE:
                    data_tx     <= (`ETH_HW_TYPE >> ((1-blk_cnt)*8));
                                    
                `PROT_TYPE:
                    data_tx     <= (`IP_PROT_TYPE >> ((1-blk_cnt)*8));

                `HW_LEN:
                    data_tx     <= (`ETH_HW_LEN >> (blk_cnt*8));

                `PROT_LEN:
                    data_tx     <= (`IP_PROT_LEN >> (blk_cnt*8));

                `ARP_OP:
                    data_tx     <= (`REP_ARP_OP >> ((1-blk_cnt)*8));

                `ARP_SRC_ADDR:
                    data_tx     <= (my_mac >> ((5-blk_cnt)*8));

                `ARP_SRC_IP:
                    data_tx     <= (my_ip >> ((3-blk_cnt)*8));

                `ARP_DEST_ADDR:
                    data_tx     <= (source_mac >> ((5-blk_cnt)*8));

                `ARP_DEST_IP:
                    data_tx     <= (source_ip >> ((3-blk_cnt)*8));

                default:
                    data_tx     <= 8'h00;

            endcase
        end
    end
endmodule
