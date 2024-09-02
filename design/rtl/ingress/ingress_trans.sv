/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : ingress_trans.v
Last Update     : 2024/09/01 22:32:00
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/01 22:32:00
Version         : 1.0
Description     : Receives PCIE data from the PCIE IP core,converts it to the AXIS interface.
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_trans  #(
    //localparam
    parameter FIFO_WIDTH = `PCIE_DATA_WIDTH + `PCIE_DATA_KW + 1 + 1,
    parameter FIFO_DEPTH = 2
)
(
    /********* system clock / reset *********/
    input   logic                               clk                 ,   //system clock
    input   logic                               `rst                ,   //reset signal
    /********* config debug *********/
    output  logic [32                   -1:0]   rx_packet_len       ,  
    output  logic [32                   -1:0]   rx_sop_cnt          ,
    output  logic [32                   -1:0]   rx_eop_cnt          ,   

    /********* pcie send *********/
    output  logic                               s_axis_rx_tready    ,
    input   logic [`PCIE_DATA_WIDTH     -1:0]   s_axis_rx_tdata     ,
    input   logic [`PCIE_DATA_KW        -1:0]   s_axis_rx_tkeep     ,
    input   logic                               s_axis_rx_tlast     ,
    input   logic                               s_axis_rx_tvalid    ,
    input   logic [`XIL_RX_USER_W       -1:0]   s_axis_rx_tuser     ,

    /********* trans axis *********/
    input   logic                               m_axis_tx_tready    ,
    output  logic [`PCIE_DATA_WIDTH     -1:0]   m_axis_tx_tdata     ,
    output  logic [`PCIE_DATA_KW        -1:0]   m_axis_tx_tkeep     ,
    output  logic                               m_axis_tx_sop       ,
    output  logic                               m_axis_tx_eop       ,
    output  logic                               m_axis_tx_tvalid    ,
    output  logic [`PCIE_TUSER_W        -1:0]   m_axis_tx_tuser      
);

logic [FIFO_WIDTH          - 1:0]   tinyfifo_data_i         ;
logic                               tinyfifo_push           ;
logic                               tinyfifo_pop            ;
logic                               tinyfifo_full           ;
logic [FIFO_WIDTH          - 1:0]   tinyfifo_data_o         ;
logic                               tinyfifo_empty          ;

logic                               fifo_axis_tx_tready    ;
logic [`PCIE_DATA_WIDTH     -1:0]   fifo_axis_tx_tdata     ;
logic [`PCIE_DATA_KW        -1:0]   fifo_axis_tx_tkeep     ;
logic                               fifo_axis_tx_sop       ;
logic                               fifo_axis_tx_eop       ;
logic                               fifo_axis_tx_tvalid    ;
logic [`PCIE_TUSER_W        -1:0]   fifo_axis_tx_tuser     ;

logic [32                   -1:0]   cnt_axi                 ;
logic                               add_cnt_axi             ;
logic                               end_cnt_axi             ;
logic [32                   -1:0]   rx_packet_len           ;

logic [`PCIE_DATA_WIDTH     -1:0]   fifo_axis_rx_tdata_be   ;

generate for(genvar i = 0;i < `PCIE_DATA_WIDTH/32;i = i + 1)begin
    assign fifo_axis_rx_tdata_be[i*32 +: 32] = {s_axis_rx_tdata[0 +:8],s_axis_rx_tdata[8 +:8],s_axis_rx_tdata[16 +:8],s_axis_rx_tdata[24 +: 8]};
end

tinyfifo 
#(
    .DW     (`FIFO_WIDTH    ),
    .DEPTH  ( FIFO_DEPTH    )
)
u_tinyfifo(
    .clk        (clk            ),
    .rst        (`rst           ),
    .data_i     (tinyfifo_data_i),
    .push       (tinyfifo_push  ),
    .pop        (tinyfifo_pop   ),
    .full       (tinyfifo_full  ),
    .data_o     (tinyfifo_data_o),
    .empty      (tinyfifo_empty ) 
);

assign tinyfifo_data_i = {fifo_axis_rx_tdata_be,s_axis_rx_tkeep,s_axis_rx_tlast,s_axis_rx_tvalid};
assign s_axis_rx_tready = tinyfifo_full;
assign tinyfifo_push   = ~tinyfifo_full;
assign tinyfifo_pop    = ~tinyfifo_empty & m_axis_tx_tready;

assign fifo_axis_tx_tready = m_axis_tx_tready;
assign {fifo_axis_rx_tdata,fifo_axis_rx_tkeep,fifo_axis_rx_tlast,fifo_axis_rx_tvalid} = tinyfifo_data_o;

assign {m_axis_rx_tdata,m_axis_rx_tkeep,m_axis_rx_teop,m_axis_rx_tvalid} = {fifo_axis_rx_tdata,fifo_axis_rx_tkeep,fifo_axis_rx_tlast,fifo_axis_rx_tvalid};
assign m_axis_tx_sop   = (cnt_axi == 0);
assign m_axis_tx_tuser = 'd0;

always_ff @(`rst_block)begin
    if(`rst)begin
        cnt_axi <= 'd0;
    end
    else if(add_cnt_axi)begin
        if(end_cnt_axi)
            cnt_axi <= 'd0;
        else
            cnt_axi <= cnt_axi + 'd1;
    end
end
assign add_cnt_axi = m_axis_tx_tready & m_axis_rx_tvalid;
assign end_cnt_axi = add_cnt_axi && m_axis_rx_tvalid;

pulse_cnt u_pulse_cnt_sop(
    .clk    (clk                                                ),   //system clock
    .`rst   (`rst                                               ),   //reset signal

    .clc    (1'b0                                               ),
    .d_i    (m_axis_tx_tready & m_axis_rx_tvalid & m_axis_tx_sop),
    .d_o    (rx_sop_cnt                                         )
);

pulse_cnt u_pulse_cnt_sop(
    .clk    (clk                                                ),   //system clock
    .`rst   (`rst                                               ),   //reset signal

    .clc    (1'b0                                               ),
    .d_i    (m_axis_tx_tready & m_axis_rx_tvalid & m_axis_tx_eop),
    .d_o    (rx_eop_cnt                                         )
);

endmodule
