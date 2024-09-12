/******************************************Copyright@2022**************************************
                                    YUSUR CO. LTD. ALL rights reserved
                            http://www.yusur.tech, http://www.carch.ac.cn
=========================================FILE INFO.============================================
FILE Name       : ingress_parse_cpl.v
Last Update     : 2024/09/12 23:54:35
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : zhanghx
Create date     : 2024/09/12 23:54:35
Version         : 1.0
Description     : var.
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
*************************************Confidential. Do NOT disclose****************************/
module ingress_parse_cpl(
    /********* system clock / reset *********/
    input   wire            clk         ,   //system clock
    input   wire            `rst        ,   //reset signal

    /********* parse_pre in *********/
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   cpl_data                ,
    input   logic       [`PCIE_DATA_KW        -1:0]   cpl_keep                ,
    input   tlp_head_t                                cpl_meta                ,
    input   logic                                     cpl_valid               ,
    output  logic                                     cpl_rdy                 ,

    //rx data completion
    input   logic                                     rxd_m_axis_tx_tready    ,
    output  logic       [`PCIE_DATA_WIDTH     -1:0]   rxd_m_axis_tx_tdata     ,
    output  logic       [`PCIE_DATA_KW        -1:0]   rxd_m_axis_tx_tkeep     ,
    output  logic                                     rxd_m_axis_tx_sop       ,
    output  logic                                     rxd_m_axis_tx_eop       ,
    output  logic                                     rxd_m_axis_tx_tvalid    ,
    output  logic       [`PCIE_TUSER_W        -1:0]   rxd_m_axis_tx_tuser     ,

    //rx sgl completion
    input   logic                                     rxs_m_axis_tx_tready    ,
    output  logic       [`PCIE_DATA_WIDTH     -1:0]   rxs_m_axis_tx_tdata     ,
    output  logic       [`PCIE_DATA_KW        -1:0]   rxs_m_axis_tx_tkeep     ,
    output  logic                                     rxs_m_axis_tx_sop       ,
    output  logic                                     rxs_m_axis_tx_eop       ,
    output  logic                                     rxs_m_axis_tx_tvalid    ,
    output  logic       [`PCIE_TUSER_W        -1:0]   rxs_m_axis_tx_tuser     ,

    //tx sgl completion
    input   logic                                     txd_m_axis_tx_tready    ,
    output  logic       [`PCIE_DATA_WIDTH     -1:0]   txd_m_axis_tx_tdata     ,
    output  logic       [`PCIE_DATA_KW        -1:0]   txd_m_axis_tx_tkeep     ,
    output  logic                                     txd_m_axis_tx_sop       ,
    output  logic                                     txd_m_axis_tx_eop       ,
    output  logic                                     txd_m_axis_tx_tvalid    ,
    output  logic       [`PCIE_TUSER_W        -1:0]   txd_m_axis_tx_tuser      
);




endmodule
