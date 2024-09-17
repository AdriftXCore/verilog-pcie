/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : ingress_top.v
Last Update     : 2024/09/01 22:01:41
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/01 22:01:41
Version         : 1.0
Description     :   Receives PCIE data from the PCIE IP core
                    converts it to the AXIS interface,
                    parses the information of the PCIE packet and routes it to the corresponding ACTION module
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/

module ingress_top(
    /********* system clock / reset *********/
    input   logic                               clk                 ,   //system clock
    input   logic                               `rst_nm             ,   //reset signal

    /********* pcie if rx*********/
    output  logic                               s_axis_rx_tready    ,
    input   logic [`PCIE_DATA_WIDTH     -1:0]   s_axis_rx_tdata     ,
    input   logic [`PCIE_DATA_KW        -1:0]   s_axis_rx_tkeep     ,
    input   logic                               s_axis_rx_tlast     ,
    input   logic                               s_axis_rx_tvalid    ,
    input   logic [`XIL_RX_USER_W       -1:0]   s_axis_rx_tuser     ,

    /********* pcie if tx*********/
    input   logic                               m_axis_tx_tready    ,
    output  logic [`PCIE_DATA_WIDTH     -1:0]   m_axis_tx_tdata     ,
    output  logic [`PCIE_DATA_KW        -1:0]   m_axis_tx_tkeep     ,
    output  logic                               m_axis_tx_tlast     ,
    output  logic                               m_axis_tx_tvalid    ,
    output  logic [`XIL_TX_USER_W       -1:0]   m_axis_tx_tuser     ,

    /********* fpga send action *********/
    input   logic                               sd_m_axis_tx_tready ,
    output  logic [`PCIE_DATA_WIDTH     -1:0]   sd_m_axis_tx_tdata  ,
    output  logic [`PCIE_DATA_KW        -1:0]   sd_m_axis_tx_tkeep  ,
    output  logic                               sd_m_axis_tx_sop    ,
    output  logic                               sd_m_axis_tx_eop    ,
    output  logic                               sd_m_axis_tx_tvalid ,
    output  logic [`PCIE_TUSER_W        -1:0]   sd_m_axis_tx_tuser  ,

    /********* fpga recieve action *********/
    input   logic                               rc_m_axis_tx_tready ,
    output  logic [`PCIE_DATA_WIDTH     -1:0]   rc_m_axis_tx_tdata  ,
    output  logic [`PCIE_DATA_KW        -1:0]   rc_m_axis_tx_tkeep  ,
    output  logic                               rc_m_axis_tx_sop    ,
    output  logic                               rc_m_axis_tx_eop    ,
    output  logic                               rc_m_axis_tx_tvalid ,
    output  logic [`PCIE_TUSER_W        -1:0]   rc_m_axis_tx_tuser  ,

    /********* fpga register action *********/
    input   logic                               rg_m_axis_tx_tready ,
    output  logic [`PCIE_DATA_WIDTH     -1:0]   rg_m_axis_tx_tdata  ,
    output  logic [`PCIE_DATA_KW        -1:0]   rg_m_axis_tx_tkeep  ,
    output  logic                               rg_m_axis_tx_sop    ,
    output  logic                               rg_m_axis_tx_eop    ,
    output  logic                               rg_m_axis_tx_tvalid ,
    output  logic [`PCIE_TUSER_W        -1:0]   rg_m_axis_tx_tuser   
);



endmodule
