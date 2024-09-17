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
1000 = Transfer length for TX transaction                            (Read only) (ACK'd on read)
1001 = Offset/Last for TX transaction                                (Read only)
1010 = Link rate, link width, bus master enabled, number of channels (Read only)
1011 = Interrupt vector 1                                            (Read only) (Reset on read)
1100 = Interrupt vector 2                                            (Read only) (Reset on read)
1101 = Transferred length for RX transaction                         (Read only) (ACK'd on read)
1110 = Transferred length for TX transaction                         (Read only) (ACK'd on read)
1111 = Name of FPGA                                                  (Read only)

tx/rx
000 = Transfer length transaction
001 = Offset/Last transaction     
010 = Transferred length
011 = Length of SG buffer
100 = PC low address of SG buffer
101 = PC high address of SG buffer

global
000 = Link rate, link width, bus master enabled, number of channels
001 = Interrupt vector 1
010 = Interrupt vector 2
011 = Name of FPGA

=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_parse_rdreq(
    /********* system clock / reset *********/
    input   logic                                     clk         ,   //system clock
    input   logic                                     `rst_nm     ,   //reset signal

    /********* parse_pre in *********/
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   rdreq_data  ,
    input   logic       [`PCIE_DATA_KW        -1:0]   rdreq_keep  ,
    input   tlp_head_t                                rdreq_meta  ,
    input   logic                                     rdreq_valid ,
    output  logic                                     rdreq_rdy   ,

    output  logic                                     rd_req      ,
    output  logic        [10                  -1:0]   rd_tdest     //{register,action,channel}
);

assign rdreq_rdy = 1'b1;

always_ff @(`rst_block)begin
    if(`rst)begin
        rd_req   <= 'd0;
        rd_tdest <= 'd0;
    end
    else if(rdreq_valid && rdreq_rdy)
        rd_tdest[0+:4] <= rdreq_meta.tlp_head_t.tlp_htail.tlp_r_t[CHANNEL_NUM_R];
        rd_req         <= 1'b1;
        case(rdreq_meta.tlp_head_t.tlp_htail.tlp_r_t[`DATA_OFFSET_R])
            //tx
            4'b1000:rd_tdest[4+:5] <= {3'b000,2'b00}; //Transfer length for TX transaction
            4'b1001:rd_tdest[4+:5] <= {3'b001,2'b00}; //Offset/Last
            4'b1110:rd_tdest[4+:5] <= {3'b010,2'b00}; //ransferred length for TX transaction

            //rx
            4'b1101:rd_tdest[4+:5] <= {3'b010,2'b01}; //Transferred length for RX transaction

            //global register
            4'b1010:rd_tdest[4+:5] <= {3'b000,2'b10};//Link rate, link width, bus master enabled, number of channels
            4'b1011:rd_tdest[4+:5] <= {3'b001,2'b10};//Interrupt vector 1
            4'b1100:rd_tdest[4+:5] <= {3'b010,2'b10};//Interrupt vector 2
            4'b1111:rd_tdest[4+:5] <= {3'b011,2'b10};//Name of FPGA
        endcase
    end
    else begin
        rd_req <= 'd0;
    end
end

endmodule
