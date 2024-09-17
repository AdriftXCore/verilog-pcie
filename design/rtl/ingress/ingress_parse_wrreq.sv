/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : ingress_parse_wrreq.v
Last Update     : 2024/09/08 22:53:19
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/08 22:53:19
Version         : 1.0
Description     : Distribute write request packages to each action module.
{CHANNEL_NUM} {DATA_OFFSETS} {ZERO}
------4-------------4-----------2--
0000 = Length of SG buffer for RX transaction                        (Write only)
0001 = PC low address of SG buffer for RX transaction                (Write only)
0010 = PC high address of SG buffer for RX transaction               (Write only)
0011 = Transfer length for RX transaction                            (Write only)
0100 = Offset/Last for RX transaction                                (Write only)
0101 = Length of SG buffer for TX transaction                        (Write only)
0110 = PC low address of SG buffer for TX transaction                (Write only)
0111 = PC high address of SG buffer for TX transaction               (Write only)

tx/rx
000 = Transfer length transaction
001 = Offset/Last transaction     
010 = Transferred length
011 = Length of SG buffer
100 = PC low address of SG buffer
101 = PC high address of SG buffer

=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_parse_wrreq(
    /********* system clock / reset *********/
    input   logic                                     clk         ,   //system clock
    input   logic                                     `rst_nm     ,   //reset signal

    /********* parse_pre in *********/
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   wrreq_data  ,
    input   logic       [`PCIE_DATA_KW        -1:0]   wrreq_keep  ,
    input   tlp_head_t                                wrreq_meta  ,
    input   logic                                     wrreq_valid ,
    output  logic                                     wrreq_rdy   ,

    output  logic                                     wr_req      ,
    output  logic       [10                   -1:0]   wr_tdest    ,//{register,action,channel}  
    output  logic       [32                   -1:0]   wr_tdata     
);

assign wrreq_rdy = 1;

always_ff @(`rst_block)begin
    if(`rst)begin
        wr_req   <= 'd0;
        wr_tdest <= 'd0;
        wr_tdata <= 'd0;
    end
    else if(wrreq_valid && wrreq_rdy)begin
        wr_tdest[0+:4] <= wrreq_meta.tlp_head_t.tlp_htail.tlp_r_t[CHANNEL_NUM_R];
        wr_req         <= 1'b1;
        wr_tdata       <= wrreq_data[32-1:0];
        case(rdreq_meta.tlp_head_t.tlp_htail.tlp_r_t[`DATA_OFFSET_R])
            //tx
            4'b0101:wr_tdest[4+:5] <= {3'b011,2'b00};//Length of SG buffer for TX transaction
            4'b0110:wr_tdest[4+:5] <= {3'b100,2'b00};//PC low address of SG buffer for TX transaction
            4'b0111:wr_tdest[4+:5] <= {3'b101,2'b00};//PC high address of SG buffer for TX transaction

            //rx
            4'b0000:wr_tdest[4+:5] <= {3'b011,2'b01};//Length of SG buffer for RX transaction
            4'b0001:wr_tdest[4+:5] <= {3'b100,2'b01};//PC low address of SG buffer for RX transaction
            4'b0010:wr_tdest[4+:5] <= {3'b101,2'b01};//PC high address of SG buffer for RX transaction
            4'b0011:wr_tdest[4+:5] <= {3'b000,2'b01};//Transfer length for RX transaction
            4'b0100:wr_tdest[4+:5] <= {3'b001,2'b01};//Offset/Last for RX transaction

            //global register
        endcase
    end
end

endmodule
