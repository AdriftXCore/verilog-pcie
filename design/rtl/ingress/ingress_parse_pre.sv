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
Description     : Parses pcie input data into pure data and pure meta.
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_parse_pre #(
    //localparam
    parameter TDEST_W       = 3,
    parameter FIFO_TDEST_I  = 0,
    parameter FIFO_WIDTH    = `PCIE_DATA_WIDTH + `PCIE_DATA_KW + 128 + TDEST_W     //data,keep,meta,tddst
    parameter FIFO_DEPTH    = 16
)
(
    /********* system clock / reset *********/
    input   wire                                      clk                 ,   //system clock
    input   wire                                      `rst                ,   //reset signal

    /********* pcie axiif *********/
    output  logic                                     s_axis_rx_tready    ,
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   s_axis_rx_tdata     ,
    input   logic       [`PCIE_DATA_KW        -1:0]   s_axis_rx_tkeep     ,
    input   logic                                     s_axis_rx_sop       ,
    input   logic                                     s_axis_rx_eop       ,
    input   logic                                     s_axis_rx_tvalid    ,
    input   logic       [`PCIE_TUSER_W        -1:0]   s_axis_rx_tuser     ,

    /********* parse pre out *********/
    output  logic       [`PCIE_DATA_WIDTH     -1:0]   wrreq_data          ,
    output  logic       [`PCIE_DATA_KW        -1:0]   wrreq_keep          ,
    output  tlp_head_t                                wrreq_meta          ,
    output  logic                                     wrreq_valid         ,
    input   logic                                     wrreq_rdy           ,

    output  logic       [`PCIE_DATA_WIDTH     -1:0]   rdreq_data          ,
    output  logic       [`PCIE_DATA_KW        -1:0]   rdreq_keep          ,
    output  tlp_head_t                                rdreq_meta          ,
    output  logic                                     rdreq_valid         ,
    input   logic                                     rdreq_rdy           ,

    output  logic       [`PCIE_DATA_WIDTH     -1:0]   cpl_data            ,
    output  logic       [`PCIE_DATA_KW        -1:0]   cpl_keep            ,
    output  tlp_head_t                                cpl_meta            ,
    output  logic                                     cpl_valid           ,
    input   logic                                     cpl_rdy              
);

logic                                       wrreq_req    ;
logic                                       rdreq_req    ;
logic                                       cpl_req      ;

logic       [`PCIE_DATA_WIDTH     -1:0]     data         ;
logic       [`PCIE_DATA_KW        -1:0]     keep         ;
tlp_head_t                                  meta         ;
logic                                       valid        ;
logic                                       rdy          ;

logic       [`PCIE_DATA_WIDTH     -1:0]     _data        ;
logic       [`PCIE_DATA_KW        -1:0]     _keep        ;
tlp_head_t                                  _meta        ;
logic                                       _valid       ;

logic                                       _dat_vld     ;
logic                                       dat_vld      ;
logic                                       dat_vld_     ;

tlp_head_t                                  _rx_tlp_head ;
tlp_head_t                                  rx_tlp_head  ;

logic                                       is_3dw       ;

logic       [3                   -1:0]      tdest        ;

/********* fifo *********/
logic                                       fifo_wr_en         ;
logic                                       fifo_din           ;
logic                                       fifo_rd_en         ;
logic       [FIFO_WIDTH          -1:0]      fifo_dout          ;
logic                                       fifo_empty         ;
logic                                       fifo_full          ;


assign _dat_vld = s_axis_rx_tready && s_axis_rx_tvalid;

always_ff @(`rst_block)begin
    if(`rst)begin
        dat_vld  <= 'd0;
        dat_vld_ <= 'd0;
    end
    else begin
        dat_vld  <= _dat_vld;
        dat_vld_ <= dat_vld;
    end
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
            default:    {cpl_req,rdreq_req,wrreq_req} <= 'd0;
        endcase
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            _data <= 'd0;
        end
        else if(_dat_vld)begin
            _data <= s_axis_rx_tdata;
        end
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            _keep <= 'd0;
        end
        else if(_dat_vld)begin
            _keep <= s_axis_rx_tkeep;
        end
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            data <= 'd0;
        end
        else if(is_3dw)begin
            if(sop_reg)begin
                data <= {32'd0,_data[3*32 +: 32]};
            end
            else begin
                data <= _data;
            end
        end
        else begin
            data <= s_axis_rx_tdata;
        end
    end

    always_ff @(`rst_block)begin
        if(`rst)begin
            keep <= 'd0;
        end
        else if(is_3dw)begin
            if(sop_reg)begin
                keep <= 16'h000F;
            end
        end
        else begin
            keep <= _keep;
        end
    end

    assign _meta = {rx_tlp_head.dat[0][64 +:32],32'd0,rx_tlp_head.dat[0][0 +: 64]};    

    always_ff @(`rst_block)begin
        if(`rst)begin
            meta <= 'd0;
        end
        else if(sop_reg)begin
            if(is_3dw)begin
                meta <= _meta;
            end
            else begin
                meta <= rx_tlp_head;
            end
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
    assign tdest = {wrreq_valid,rdreq_valid,cpl_valid};

    fifo_wrapper#(
        .DEVICE           ( MICRO_DEVICE),
        .DEPTH            ( FIFO_DEPTH  ),
        .DW               ( FIFO_WIDTH  ),
        .CLOCK_MODE       ( "sync"      ),
        .READ_MODE        ( "fwft"      ),
        .READ_LATENCY     ( 1           ),
        .MEMORY_TYPE      ( "auto"      ),
        .PROG_EMPTY_THRESH( 5           ),
        .PROG_FULL_THRESH ( 5           ) 
    )u_fifo_wrapper(
        .clk              (  clk              ),
        .rst              (  `fifo_rst        ),
        .wr_en            (  fifo_wr_en       ),
        .din              (  fifo_din         ),
        .rd_en            (  fifo_rd_en       ),
        .dout             (  fifo_dout        ),
        .empty            (  fifo_empty       ),
        .full             (                   ),
        .prog_full        (  fifo_full        ),
    );


    assign s_axis_rx_tready =  ~fifo_full;
    assign rdy        = (wrreq_rdy & fifo_dout[0]) | (rdreq_rdy & fifo_dout[1]) | (cpl_rdy & fifo_dout[2]);
    assign fifo_wr_en = dat_vld_;
    assign fifo_din   = {data, keep, meta.tlp_128b_t.dat[0], tdest};
    assign fifo_rd_en = ~fifo_empty && rdy;

    assign {wrreq_data,wrreq_keep,wrreq_meta.tlp_128b_t.dat[0]} = fifo_dout[FIFO_WIDTH-1:3];
    assign {wrreq_valid,rdreq_valid,cpl_valid} = fifo_dout[FIFO_TDEST_I+:TDEST_W];
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
    //reserve
end
endgenerate

endmodule
