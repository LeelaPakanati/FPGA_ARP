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
//Block next state module
//
//This is a module that is able to parse the next state
//from the current state and number of blocks counted
//================================================================

`include "constants.vh"

module blk_next_state(
    input wire       clk,
    input wire       areset,
    input wire [3:0] state,
    input wire       start,
    input wire       ack,

    output reg [2:0] blk_cnt,
    output reg [3:0] next_state
);

    // Determine Next state Logic
    always @(areset, state, blk_cnt, start) begin
        if(areset)
            next_state  <= 4'h0;
        else
            case(state)
                `IDLE:
                     if(start) next_state <= `ETH_DEST_ADDR; else next_state <= `IDLE;
                `ETH_DEST_ADDR:
                     if(blk_cnt == 3'h5) next_state <= `ETH_SRC_ADDR; else next_state <= `ETH_DEST_ADDR;
                `ETH_SRC_ADDR:
                     if(blk_cnt == 3'h5) next_state <= `FRAME_TYPE; else next_state <= `ETH_SRC_ADDR;
                `FRAME_TYPE:
                     if(blk_cnt == 3'h1) next_state <= `HW_TYPE; else next_state <= `FRAME_TYPE;
                `HW_TYPE:
                     if(blk_cnt == 3'h1) next_state <= `PROT_TYPE; else next_state <= `HW_TYPE;
                `PROT_TYPE:
                     if(blk_cnt == 3'h1) next_state <= `HW_LEN; else next_state <= `PROT_TYPE;
                `HW_LEN:
                     next_state <= `PROT_LEN;
                `PROT_LEN:
                     next_state <= `ARP_OP;
                `ARP_OP:
                     if(blk_cnt == 3'h1) next_state <= `ARP_SRC_ADDR; else next_state <= `ARP_OP;
                `ARP_SRC_ADDR:
                     if(blk_cnt == 3'h5) next_state <= `ARP_SRC_IP; else next_state <= `ARP_SRC_ADDR;
                `ARP_SRC_IP:
                     if(blk_cnt == 3'h3) next_state <= `ARP_DEST_ADDR; else next_state <= `ARP_SRC_IP;
                `ARP_DEST_ADDR:
                     if(blk_cnt == 3'h5) next_state <= `ARP_DEST_IP; else next_state <= `ARP_DEST_ADDR;
                `ARP_DEST_IP:
                     if(blk_cnt == 3'h3) next_state <= `END; else next_state <= `ARP_DEST_IP;
                `END:
                    if(!start) next_state <= `IDLE; else next_state <= `END;
                default:
                    next_state <= `IDLE;
            endcase
    end

    //-- Block Count logic
    always @(posedge clk or areset) begin
        if(areset)
            blk_cnt <= 4'h0;
        else begin
            //-- for sending, on first sending block, don't increment blk_cnt
            //-- until ack is registered as high
            if ((state == `ETH_DEST_ADDR) && (blk_cnt == 0))
                if(ack)
                    blk_cnt <= blk_cnt + 1;
                else
                    blk_cnt <= 4'h0;

            else if ((state == `IDLE) || (state == `END))
                blk_cnt <= 4'h0;

            else
                //-- if states remains the same, then count up, else reset to 0
                if (state == next_state)
                    blk_cnt <= blk_cnt + 1;
                else
                    blk_cnt <= 4'h0;
        end
    end
endmodule
