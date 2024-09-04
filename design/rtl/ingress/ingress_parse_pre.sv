/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : ingress_parse_pre.v
Last Update     : 2024/09/05 00:27:14
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/05 00:27:14
Version         : 1.0
Description     : parse.
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_parse_pre(
    /********* system clock / reset *********/
    input   wire                                clk                 ,   //system clock
    input   wire                                `rst                ,   //reset signal

    /*********  *********/
    output  logic                                     s_axis_rx_tready    ,
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   s_axis_rx_tdata     ,
    input   logic       [`PCIE_DATA_KW        -1:0]   s_axis_rx_tkeep     ,
    input   logic                                     s_axis_rx_sop       ,
    input   logic                                     s_axis_rx_eop       ,
    input   logic                                     s_axis_rx_tvalid    ,
    input   logic       [`PCIE_TUSER_W        -1:0]   s_axis_rx_tuser     ,

    output  logic       [`PCIE_DATA_WIDTH     -1:0]   wrreq_data          ,
    output  tlp_head_t                                wrreq_meta          ,
    output  logic                                     wrreq_valid         ,

    output  logic       [`PCIE_DATA_WIDTH     -1:0]   rdreq_data          ,
    output  tlp_head_t                                rdreq_meta          ,
    output  logic                                     rdreq_valid         ,

    output  logic       [`PCIE_DATA_WIDTH     -1:0]   cpl_data            ,
    output  tlp_head_t                                cpl_meta            ,
    output  logic                                     cpl_valid            
);

logic wrreq_req;
logic rdreq_req;
logic cpl_req  ;

tlp_head_t rx_tlp_head;
generate 
if(`PCIE_TUSER_W == 128)begin
    logic sop_reg ;
    logic _sop_reg;

    assign _sop_reg = s_axis_rx_tready && s_axis_rx_tvalid && s_axis_rx_sop;

    always_ff @(`rst_block)begin
        if(`rst)
            rx_tlp_head.tlp_128b_t.dat[0] <= 'd0;
        else if(_sop_reg)
            rx_tlp_head.tlp_128b_t.dat[0] <= s_axis_rx_tdata;
    end

    always_ff @(`rst_block)begin
        if(`rst)
            sop_reg <= 'd0;
        else if(s_axis_rx_tready && s_axis_rx_tvalid)
            sop_reg <= _sop_reg;
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            {cpl_req,rdreq_req,wrreq_req} <= 'd0;
        end
        else if(sop_reg)begin case({rx_tlp_head.tlp_fmt,rx_tlp_head.tlp_type})
            `TLP_REQ_WD:{cpl_req,rdreq_req,wrreq_req} <= 3'b001;
            `TLP_REQ_RD:{cpl_req,rdreq_req,wrreq_req} <= 3'b010;
            `TLP_CPL_WD:{cpl_req,rdreq_req,wrreq_req} <= 3'b100;
            default:{cpl_req,rdreq_req,wrreq_req} <= 'd0;
        endcase end
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            wrreq_data  <= 'd0;
            wrreq_meta  <= 'd0;
            wrreq_valid <= 'd0;
        end
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
