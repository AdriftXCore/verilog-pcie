/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : ingress_parse.v
Last Update     : 2024/09/02 00:06:38
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/02 00:06:38
Version         : 1.0
Description     : The TLP packet was parsed.
The Mem/IO read/write address space should be at least 8 bits wide. This 
means we'll need at least 10 bits of BAR 0, at least 1024 bytes. The bottom
two bits must always be zero (i.e. all addresses are 4 byte word aligned).
The Mem/IO read/write address space is partitioned as illustrated below.
{CHANNEL_NUM} {DATA_OFFSETS} {ZERO}
------4-------------4-----------2--
The lower 2 bits are always zero. The middle 4 bits are used according to
the listing below. The top 4 bits differentiate between channels for values
defined in the table below.
0000 = Length of SG buffer for RX transaction                        (Write only)
0001 = PC low address of SG buffer for RX transaction                (Write only)
0010 = PC high address of SG buffer for RX transaction               (Write only)
0011 = Transfer length for RX transaction                            (Write only)
0100 = Offset/Last for RX transaction                                (Write only)
0101 = Length of SG buffer for TX transaction                        (Write only)
0110 = PC low address of SG buffer for TX transaction                (Write only)
0111 = PC high address of SG buffer for TX transaction               (Write only)
1000 = Transfer length for TX transaction                            (Read only) (ACK'd on read)
1001 = Offset/Last for TX transaction                                (Read only)
1010 = Link rate, link width, bus master enabled, number of channels (Read only)
1011 = Interrupt vector 1                                            (Read only) (Reset on read)
1100 = Interrupt vector 2                                            (Read only) (Reset on read)
1101 = Transferred length for RX transaction                         (Read only) (ACK'd on read)
1110 = Transferred length for TX transaction                         (Read only) (ACK'd on read)
1111 = Name of FPGA                                                  (Read only)
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_parse(
    /********* system clock / reset *********/
    input   wire                                clk                 ,   //system clock
    input   wire                                `rst                ,   //reset signal

    /*********  *********/
    output  logic                               s_axis_rx_tready    ,
    input   logic [`PCIE_DATA_WIDTH     -1:0]   s_axis_rx_tdata     ,
    input   logic [`PCIE_DATA_KW        -1:0]   s_axis_rx_tkeep     ,
    input   logic                               s_axis_rx_sop       ,
    input   logic                               s_axis_rx_eop       ,
    input   logic                               s_axis_rx_tvalid    ,
    input   logic [`PCIE_TUSER_W        -1:0]   s_axis_rx_tuser     ,

    /*********  *********/
    input   logic                               m_axis_tx_tready    ,
    output  logic [`PCIE_DATA_WIDTH     -1:0]   m_axis_tx_tdata     ,
    output  logic [`PCIE_DATA_KW        -1:0]   m_axis_tx_tkeep     ,
    output  logic                               m_axis_tx_sop       ,
    output  logic                               m_axis_tx_eop       ,
    output  logic                               m_axis_tx_tvalid    ,
    output  logic [`PCIE_TUSER_W        -1:0]   m_axis_tx_tuser     ,
);

tlp_head_t rx_tlp_head;
generate 
if(`PCIE_TUSER_W == 128)begin
    always_ff @(`rst_block)begin
        if(`rst)
            rx_tlp_head.tlp_128b_t.dat[0] <= 'd0;
        else if(s_axis_rx_tready && s_axis_rx_tvalid && s_axis_rx_sop)
            rx_tlp_head.tlp_128b_t.dat[0] <= s_axis_rx_tdata;
    end
end
else if(`PCIE_TUSER_W == 64)begin
    logic [2 -1:0] sop_reg ;
    logic [2 -1:0] _sop_reg;

    assign _sop_reg = {sop_reg[0],s_axis_rx_sop};

    always_ff @(`rst_block)begin
        if(`rst)
            sop_reg <= 'd0;
        else if(s_axis_rx_tready && s_axis_rx_tvalid)
            sop_reg <= _sop_reg;
    end

    always_ff @(`rst_block)begin
        if(`rst)
            {rx_tlp_head.tlp_64b_t.dat[1],rx_tlp_head.tlp_64b_t.dat[0]} <= 'd0;
        else if(|_sop_reg)
            {rx_tlp_head.tlp_64b_t.dat[1],rx_tlp_head.tlp_64b_t.dat[0]} <= {rx_tlp_head.tlp_64b_t.dat[0],s_axis_rx_tdata};
    end
end
else if(`PCIE_TUSER_W == 32)begin
    logic [4 -1:0] sop_reg ;
    logic [4 -1:0] _sop_reg;

    assign _sop_reg = {sop_reg[2:0],s_axis_rx_sop}

    always_ff @(`rst_block)begin
        if(`rst)
            sop_reg <= 'd0;
        else if(s_axis_rx_tready && s_axis_rx_tvalid)
            sop_reg <= _sop_reg;
    end
    always_ff @(`rst_block)begin
        if(`rst)
            {rx_tlp_head.tlp_32b_t.dat[3],rx_tlp_head.tlp_32b_t.dat[2],rx_tlp_head.tlp_32b_t.dat[1],rx_tlp_head.tlp_32b_t.dat[0]} <= 'd0;
        else if(|_sop_reg)
            {rx_tlp_head.tlp_32b_t.dat[3],rx_tlp_head.tlp_32b_t.dat[2],rx_tlp_head.tlp_32b_t.dat[1],rx_tlp_head.tlp_32b_t.dat[0]} <= {rx_tlp_head.tlp_32b_t.dat[2],rx_tlp_head.tlp_32b_t.dat[1],rx_tlp_head.tlp_32b_t.dat[0],s_axis_rx_tdata};
    end
end
endgenerate

endmodule
