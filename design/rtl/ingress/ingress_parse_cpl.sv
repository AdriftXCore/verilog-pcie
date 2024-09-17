/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : ingress_parse_cpl.v
Last Update     : 2024/09/17 22:59:37
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/17 22:59:37
Version         : 1.0
Description     : parse completion pack.
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_parse_cpl(
    /********* system clock / reset *********/
    input   wire                                      clk                     ,   //system clock
    input   wire                                      `rst_nm                 ,   //reset signal

    /********* parse_pre in *********/
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   cpl_data                ,
    input   logic                                     cpl_sop                 ,
    input   logic                                     cpl_eop                 ,
    input   logic       [`PCIE_DATA_KW        -1:0]   cpl_keep                ,
    input   tlp_head_t                                cpl_meta                ,
    input   logic                                     cpl_valid               ,
    output  logic                                     cpl_rdy                 ,

    /********* tag *********/
    input   logic       [T_W                    -1:0] tag                     ,
    input   logic                                     tag_vld                 ,

    //rx data completion
    input   logic                                     m_axis_tx_tready        ,
    output  logic       [`PCIE_DATA_WIDTH     -1:0]   m_axis_tx_tdata         ,
    output  logic       [`PCIE_DATA_KW        -1:0]   m_axis_tx_tkeep         ,
    output  logic                                     m_axis_tx_sop           ,
    output  logic                                     m_axis_tx_eop           ,
    output  logic                                     m_axis_tx_tvalid        ,
    output  logic       [`PCIE_TUSER_W        -1:0]   m_axis_tx_tuser          
);

logic                                     cpl_a_valid               ;
logic                                     cpl_a_rdy                 ;
logic       [`PCIE_DATA_WIDTH     -1:0]   m_axis_tx_a_tdata         ;
logic       [`PCIE_DATA_KW        -1:0]   m_axis_tx_a_tkeep         ;
logic                                     m_axis_tx_a_sop           ;
logic                                     m_axis_tx_a_eop           ;
logic                                     m_axis_tx_a_tvalid        ;
logic       [`PCIE_TUSER_W        -1:0]   m_axis_tx_a_tuser         ;
logic                                     m_axis_tx_a_tready        ;

logic                                     cpl_b_valid               ;
logic                                     cpl_b_rdy                 ;
logic       [`PCIE_DATA_WIDTH     -1:0]   m_axis_tx_b_tdata         ;
logic       [`PCIE_DATA_KW        -1:0]   m_axis_tx_b_tkeep         ;
logic                                     m_axis_tx_b_sop           ;
logic                                     m_axis_tx_b_eop           ;
logic                                     m_axis_tx_b_tvalid        ;
logic       [`PCIE_TUSER_W        -1:0]   m_axis_tx_b_tuser         ;
logic                                     m_axis_tx_b_tready        ;

logic                                     rx_sel                    ;
logic                                     tx_sel                    ;

ingress_parse_cpl_shap  u_ingress_parse_cpl_shap_a(
    .clk                     (clk    ),   //system clock
    .`rst_nm                 (`rst_nm),   //reset signal

    .cpl_data                (cpl_data          ),
    .cpl_sop                 (cpl_sop           ),
    .cpl_eop                 (cpl_eop           ),
    .cpl_keep                (cpl_keep          ),
    .cpl_meta                (cpl_meta          ),
    .cpl_valid               (cpl_a_valid       ),
    .cpl_rdy                 (cpl_a_rdy         ),

    .tag                     (tag               ),
    .tag_vld                 (tag_vld           ),

    .m_axis_tx_tready        (m_axis_tx_a_tready ),
    .m_axis_tx_tdata         (m_axis_tx_a_tdata ),
    .m_axis_tx_tkeep         (m_axis_tx_a_tkeep ),
    .m_axis_tx_sop           (m_axis_tx_a_sop   ),
    .m_axis_tx_eop           (m_axis_tx_a_eop   ),
    .m_axis_tx_tvalid        (m_axis_tx_a_tvalid),
    .m_axis_tx_tuser         (m_axis_tx_a_tuser ) 
);

ingress_parse_cpl_shap  u_ingress_parse_cpl_shap_b(
    .clk                     (clk               ),   //system clock
    .`rst_nm                 (`rst_nm           ),   //reset signal

    .cpl_data                (cpl_data          ),
    .cpl_sop                 (cpl_sop           ),
    .cpl_eop                 (cpl_eop           ),
    .cpl_keep                (cpl_keep          ),
    .cpl_meta                (cpl_meta          ),
    .cpl_valid               (cpl_b_valid       ),
    .cpl_rdy                 (cpl_b_rdy         ),

    .tag                     (tag               ),
    .tag_vld                 (tag_vld           ),

    .m_axis_tx_tready        (m_axis_tx_b_tready),
    .m_axis_tx_tdata         (m_axis_tx_b_tdata ),
    .m_axis_tx_tkeep         (m_axis_tx_b_tkeep ),
    .m_axis_tx_sop           (m_axis_tx_b_sop   ),
    .m_axis_tx_eop           (m_axis_tx_b_eop   ),
    .m_axis_tx_tvalid        (m_axis_tx_b_tvalid),
    .m_axis_tx_tuser         (m_axis_tx_b_tuser ) 
);

always_ff @(`rst_block)begin
    if(`rst)
        rx_sel <= 'd0;
    else if(cpl_rdy && cpl_valid && cpl_sop)
        rx_sel <= ~rx_sel;
end

assign cpl_rdy = rx_sel ? cpl_b_rdy : cpl_a_rdy;
assign {cpl_a_valid,cpl_b_valid} = rx_sel ? {1'b0,cpl_valid} : {cpl_valid,1'b0}

always_ff @(`rst_block)begin
    if(`rst)
        tx_sel <= 'd0;
    else if(m_axis_tx_tvalid && m_axis_tx_tready && m_axis_tx_b_eop)
        tx_sel <= ~tx_sel;
end
assign {m_axis_tx_a_tready,m_axis_tx_b_tready} = tx_sel ? {1'b0,m_axis_tx_tready} : {m_axis_tx_tready,1'b0};

assign m_axis_tx_tdata  =  tx_sel ? m_axis_tx_b_tdata : m_axis_tx_a_tdata ;
assign m_axis_tx_tkeep  =  tx_sel ? m_axis_tx_b_tkeep : m_axis_tx_a_tkeep ;
assign m_axis_tx_sop    =  tx_sel ? m_axis_tx_b_sop   : m_axis_tx_a_sop   ;
assign m_axis_tx_eop    =  tx_sel ? m_axis_tx_b_eop   : m_axis_tx_a_eop   ;
assign m_axis_tx_tvalid =  tx_sel ? m_axis_tx_b_tvalid: m_axis_tx_a_tvalid;
assign m_axis_tx_tuser  =  tx_sel ? m_axis_tx_b_tuser : m_axis_tx_a_tuser ;

endmodule
