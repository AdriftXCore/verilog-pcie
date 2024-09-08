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
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_parse_wrreq(
    /********* system clock / reset *********/
    input   logic                                     clk         ,   //system clock
    input   logic                                     `rst        ,   //reset signal

    /********* parse_pre in *********/
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   wrreq_data  ,
    input   logic       [`PCIE_DATA_KW        -1:0]   wrreq_keep  ,
    input   tlp_head_t                                wrreq_meta  ,
    input   logic                                     wrreq_valid ,
    output  logic                                     wrreq_rdy   ,

    output  logic                                     wr_req      ,
    output  logic        [10                  -1:0]   wr_tdest     //{register,action,channel}  
);

assign wrreq_rdy = 1;


endmodule
