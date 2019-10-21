//-- Blocks to read
`define IDLE            4'h0
`define ETH_DEST_ADDR   4'h1
`define ETH_SRC_ADDR    4'h2
`define FRAME_TYPE      4'h3
`define HW_TYPE         4'h4
`define PROT_TYPE       4'h5
`define HW_LEN          4'h6
`define PROT_LEN        4'h7
`define ARP_OP          4'h8
`define ARP_SRC_ADDR    4'h9
`define ARP_SRC_IP      4'hA
`define ARP_DEST_ADDR   4'hB
`define ARP_DEST_IP     4'hC
`define END             4'hD


//-- frame values
`define BRDCAST_DEST_ADDR  48'hFFFFFFFFFFFF
`define ARP_FRAME_TYPE     16'h0806
`define ETH_HW_TYPE        16'h0001
`define IP_PROT_TYPE       16'h0800
`define ETH_HW_LEN         8'h06
`define IP_PROT_LEN        8'h04
`define REQ_ARP_OP         16'h0001
`define REP_ARP_OP         16'h0002
`define ARP_REQ_ADDR       48'h000000000000
