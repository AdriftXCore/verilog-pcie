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
    input   wire                                      clk                 ,   //system clock
    input   wire                                      `rst                ,   //reset signal

    /*********  *********/
    output  logic                                     s_axis_rx_tready    ,
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   s_axis_rx_tdata     ,
    input   logic       [`PCIE_DATA_KW        -1:0]   s_axis_rx_tkeep     ,
    input   logic                                     s_axis_rx_sop       ,
    input   logic                                     s_axis_rx_eop       ,
    input   logic                                     s_axis_rx_tvalid    ,
    input   logic       [`PCIE_TUSER_W        -1:0]   s_axis_rx_tuser     ,

    output  logic       [`PCIE_DATA_WIDTH     -1:0]   wrreq_data          ,
    output  logic       [`PCIE_DATA_KW        -1:0]   wrreq_keep          ,
    output  tlp_head_t                                wrreq_meta          ,
    output  logic                                     wrreq_valid         ,

    output  logic       [`PCIE_DATA_WIDTH     -1:0]   rdreq_data          ,
    output  logic       [`PCIE_DATA_KW        -1:0]   rdreq_keep          ,
    output  tlp_head_t                                rdreq_meta          ,
    output  logic                                     rdreq_valid         ,

    output  logic       [`PCIE_DATA_WIDTH     -1:0]   cpl_data            ,
    output  logic       [`PCIE_DATA_KW        -1:0]   cpl_keep            ,
    output  tlp_head_t                                cpl_meta            ,
    output  logic                                     cpl_valid            
);

logic                                       wrreq_req    ;
logic                                       rdreq_req    ;
logic                                       cpl_req      ;

logic       [`PCIE_DATA_WIDTH     -1:0]     _wrreq_data  ;
logic       [`PCIE_DATA_KW        -1:0]     _wrreq_keep  ;
tlp_head_t                                  _wrreq_meta  ;
logic                                       _wrreq_valid ;

logic       [`PCIE_DATA_WIDTH     -1:0]     _rdreq_data  ;
logic       [`PCIE_DATA_KW        -1:0]     _rdreq_keep  ;
tlp_head_t                                  _rdreq_meta  ;
logic                                       _rdreq_valid ;

logic       [`PCIE_DATA_WIDTH     -1:0]     _cpl_data    ;
logic       [`PCIE_DATA_KW        -1:0]     _cpl_keep    ;
tlp_head_t                                  _cpl_meta    ;
logic                                       _cpl_valid   ;

logic                                       _dat_vld     ;
logic                                       dat_vld      ;

tlp_head_t                                  _rx_tlp_head ;
tlp_head_t                                  rx_tlp_head  ;

logic                                       is_3dw       ;

assign _dat_vld = s_axis_rx_tready && s_axis_rx_tvalid;

always_ff @(`rst_block)begin
    if(`rst)
        dat_vld <= 'd0;
    else
        dat_vld <= _dat_vld;
end

generate 
if(`PCIE_TUSER_W == 128)begin
    logic sop_reg ;
    logic _sop_reg;

    assign _sop_reg = _dat_vld && s_axis_rx_sop;

    assign _rx_tlp_head.tlp_128b_t.dat[0] = s_axis_rx_tdata;

    always_ff @(`rst_block)begin
        if(`rst)
            rx_tlp_head <= 'd0;
        else if(_sop_reg)
            rx_tlp_head <= _rx_tlp_head;
    end

    always_ff @(`rst_block)begin
        if(`rst)
            is_3dw <= 'd0;
        else if((_rx_tlp_head.tlp_h.tlp_fmt == `TLP_4DW) && _sop_reg)
            is_3dw <= 'd0;
        else if((_rx_tlp_head.tlp_h.tlp_fmt == `TLP_3DW) && _sop_reg)
            is_3dw <= 'd1;
    end

    always_ff @(`rst_block)begin
        if(`rst)
            sop_reg <= 'd0;
        else
            sop_reg <= _sop_reg;
    end

    always_comb begin
        case({rx_tlp_head.tlp_h.tlp_fmt,rx_tlp_head.tlp_h.tlp_type})
            `TLP_REQ_WD:{cpl_req,rdreq_req,wrreq_req} <= 3'b001;
            `TLP_REQ_RD:{cpl_req,rdreq_req,wrreq_req} <= 3'b010;
            `TLP_CPL_WD:{cpl_req,rdreq_req,wrreq_req} <= 3'b100;
            default:{cpl_req,rdreq_req,wrreq_req} <= 'd0;
        endcase
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            _wrreq_data <= 'd0;
            _rdreq_data <= 'd0;
            _cpl_data   <= 'd0;
        end
        else if(_dat_vld)begin
            _wrreq_data <= s_axis_rx_tdata;
            _rdreq_data <= s_axis_rx_tdata;
            _cpl_data   <= s_axis_rx_tdata;
        end
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            _wrreq_keep <= 'd0;
            _rdreq_keep <= 'd0;
            _cpl_keep   <= 'd0;
        end
        else if(_dat_vld)begin
            _wrreq_keep <= s_axis_rx_tkeep;
            _rdreq_keep <= s_axis_rx_tkeep;
            _cpl_keep   <= s_axis_rx_tkeep;
        end
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            wrreq_data <= 'd0;
            rdreq_data <= 'd0;
            cpl_data   <= 'd0;
        end
        else if(is_3dw)begin
            if(sop_reg)begin
                wrreq_data <= {32'd0,_wrreq_data[3*32 +: 32]};
                rdreq_data <= {32'd0,_rdreq_data[3*32 +: 32]};
                cpl_data   <= {32'd0,_cpl_data  [3*32 +: 32]};
            end
            else begin
                wrreq_data <= _wrreq_data;
                rdreq_data <= _rdreq_data;
                cpl_data   <= _cpl_data  ;
            end
        end
        else begin
            wrreq_data <= s_axis_rx_tdata;
            rdreq_data <= s_axis_rx_tdata;
            cpl_data   <= s_axis_rx_tdata;
        end
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            wrreq_keep <= 'd0;
            rdreq_keep <= 'd0;
            cpl_keep   <= 'd0;
        end
        else if(is_3dw)begin
            if(sop_reg)begin
                wrreq_keep <= 16'h000F;
                rdreq_keep <= 16'h000F;
                cpl_keep   <= 16'h000F;
            end
        end
        else begin
            wrreq_keep <= _wrreq_keep;
            rdreq_keep <= _rdreq_keep;
            cpl_keep   <= _cpl_keep  ;
        end
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            wrreq_meta <= 'd0;
            rdreq_data <= 'd0;
            cpl_meta   <= 'd0;
        end
        else if(sop_reg)begin
            wrreq_meta <= rx_tlp_head;
            rdreq_data <= rx_tlp_head;
            cpl_meta   <= rx_tlp_head;
        end
    end

    always_ff @(`rst_block)begin
        if(`rst)
            wrreq_valid <= 'd0;
        else if(wrreq_req && dat_vld)
            wrreq_valid <= 'd1;
        else
            wrreq_valid <= 'd0;
    end

    always_ff @(`rst_block)begin
        if(`rst)
            rdreq_valid <= 'd0;
        else if(rdreq_req && dat_vld)
            rdreq_valid <= 'd1;
        else
            rdreq_valid <= 'd0;
    end

    always_ff @(`rst_block)begin
        if(`rst)
            cpl_valid <= 'd0;
        else if(cpl_req && dat_vld)
            cpl_valid <= 'd1;
        else
            cpl_valid <= 'd0;
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
endgenerate



endmodule
