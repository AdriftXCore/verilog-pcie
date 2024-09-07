/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : ingress_parse_rdreq.v
Last Update     : 2024/09/07 17:59:37
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/07 17:59:37
Version         : 1.0
Description     : Distribute read request packages to each action module.
{CHANNEL_NUM} {DATA_OFFSETS} {ZERO}
------4-------------4-----------2--
//tx
1000 = Transfer length for TX transaction                            (Read only) (ACK'd on read)
1001 = Offset/Last for TX transaction                                (Read only)
1110 = Transferred length for TX transaction                         (Read only) (ACK'd on read)

//rx
1101 = Transferred length for RX transaction                         (Read only) (ACK'd on read)

//register
1010 = Link rate, link width, bus master enabled, number of channels (Read only)
1011 = Interrupt vector 1                                            (Read only) (Reset on read)
1100 = Interrupt vector 2                                            (Read only) (Reset on read)
1111 = Name of FPGA                                                  (Read only)
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_parse_rdreq(
    /********* system clock / reset *********/
    input   logic                                     clk         ,   //system clock
    input   logic                                     `rst        ,   //reset signal

    /********* parse pre in *********/
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   rdreq_data  ,
    input   logic       [`PCIE_DATA_KW        -1:0]   rdreq_keep  ,
    input   tlp_head_t                                rdreq_meta  ,
    input   logic                                     rdreq_valid ,
    output  logic                                     rdreq_rdy    
);




endmodule
