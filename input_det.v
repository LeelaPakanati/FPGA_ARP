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

    //-- Blocks to read
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
    reg [3:0] next_state;
    reg [2:0] blk_cnt; 

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
            if (data_valid) state <= END; else state <= IDLE;
        end else state <= next_state;
    end

    // Determine Next state Logic
    always @(state, blk_cnt, data_valid) begin
        case(state)
            IDLE:
                if(data_valid) next_state <= ETH_DEST_ADDR; else next_state <= IDLE;
            ETH_DEST_ADDR:
                if(blk_cnt == 3'h5) next_state <= ETH_SRC_ADDR; else next_state <= ETH_DEST_ADDR;
            ETH_SRC_ADDR:
                if(blk_cnt == 3'h5) next_state <= FRAME_TYPE; else next_state <= ETH_SRC_ADDR;
            FRAME_TYPE:
                if(blk_cnt == 3'h1) next_state <= HW_TYPE; else next_state <= FRAME_TYPE;
            HW_TYPE:
                if(blk_cnt == 3'h1) next_state <= PROT_TYPE; else next_state <= HW_TYPE;
            PROT_TYPE:
                if(blk_cnt == 3'h1) next_state <= HW_LEN; else next_state <= PROT_TYPE;
            HW_LEN:
                next_state <= HW_LEN;
            PROT_LEN:
                next_state <= ARP_OP;
            ARP_OP:
                if(blk_cnt == 3'h1) next_state <= ARP_SRC_ADDR; else next_state <= ARP_OP;
            ARP_SRC_ADDR:
                if(blk_cnt == 3'h5) next_state <= ARP_SRC_IP; else next_state <= ARP_SRC_ADDR;
            ARP_SRC_IP:
                if(blk_cnt == 3'h3) next_state <= ARP_DEST_ADDR; else next_state <= ARP_SRC_IP;
            ARP_DEST_ADDR:
                if(blk_cnt == 3'h5) next_state <= ARP_DEST_IP; else next_state <= ARP_DEST_ADDR;
            ARP_DEST_IP:
                if(blk_cnt == 3'h3) next_state <= END; else next_state <= ARP_DEST_IP;
            END:
                if(!data_valid) next_state <= IDLE; else next_state <= END;
            default:
                next_state <= IDLE;
        endcase
    end

    //-- Block Count logic
    always @(posedge clk or areset) begin
        if(areset)  blk_cnt <= 4'h0;
        else begin
            //-- if states remains teh same, then count up, else reset to 0
            if (state == next_state) blk_cnt <= blk_cnt + 1; else blk_cnt <= 4'h0;
        end
    end

    //-- store data
    always @(posedge clk or areset) begin
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
                ETH_DEST_ADDR:
                    eth_dest_addr   <=  {eth_dest_addr[39:0], data_rx};
                ETH_SRC_ADDR:
                    eth_src_addr    <=  {eth_src_addr[39:0], data_rx};
                FRAME_TYPE:
                    frame_type      <=  {frame_type[7:0], data_rx};
                HW_TYPE:
                    hw_type         <=  {hw_type[7:0], data_rx};
                PROT_TYPE:
                    prot_type       <=  {prot_type[7:0], data_rx};
                HW_LEN:
                    hw_len          <=  data_rx;
                PROT_LEN:
                    prot_len        <=  data_rx;
                ARP_OP:
                    arp_op          <=  {arp_op[7:0], data_rx};
                ARP_SRC_ADDR:
                    arp_src_addr    <=  {arp_src_addr[39:0], data_rx};
                ARP_SRC_IP:
                    arp_src_ip      <=  {arp_src_ip[23:0], data_rx};
                ARP_DEST_ADDR:
                    arp_dest_addr   <=  {arp_dest_addr[39:0], data_rx};
                ARP_DEST_IP:
                    arp_dest_ip     <=  {arp_dest_ip[23:0], data_rx};
            endcase
        end
    end

    //-- valid frame values
    parameter BRDCAST_DEST_ADDR = 48'hFFFF;
    parameter ARP_FRAME_TYPE    = 16'h0806;
    parameter ETH_HW_TYPE       = 16'h0001;
    parameter IP_PROT_TYPE      = 16'h0800;
    parameter ETH_HW_LEN        = 8'h06;
    parameter IP_PROT_LEN       = 8'h04;
    parameter REQ_ARP_OP        = 16'h0001;
    parameter ARP_REQ_ADDR      = 48'h0000;

    //-- check data and drive outputs
    always @(state) begin
        if( (state          == END)                 &&
            (eth_dest_addr  == BRDCAST_DEST_ADDR)   &&
            (frame_type     == ARP_FRAME_TYPE)      &&
            (hw_type        == ETH_HW_TYPE)         &&
            (prot_type      == IP_PROT_TYPE)        &&
            (hw_len         == ETH_HW_LEN)          &&
            (prot_len       == IP_PROT_LEN)         &&
            (arp_op         == REQ_ARP_OP)          &&
            (arp_dest_addr  == ARP_REQ_ADDR)        &&
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
