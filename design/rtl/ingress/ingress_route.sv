/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : ingress_route.v
Last Update     : 2024/09/18 23:02:16
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/18 23:02:16
Version         : 1.0
Description     : route any module .
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_route(
    /********* system clock / reset *********/
    input   logic            clk         ,   //system clock
    input   logic            `rst_nm     ,   //reset signal

    /********* rx data completion *********/
    output  logic                                     s_axis_tx_tready      ,
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   s_axis_tx_tdata       ,
    input   logic       [`PCIE_DATA_KW        -1:0]   s_axis_tx_tkeep       ,
    input   logic                                     s_axis_tx_sop         ,
    input   logic                                     s_axis_tx_eop         ,
    input   logic                                     s_axis_tx_tvalid      ,
    input   logic       [`PCIE_TUSER_W        -1:0]   s_axis_tx_tuser       ,

    /********* rx wrreq *********/
    input   logic                                     wr_req                ,
    input   logic       [10                   -1:0]   wr_tdest              ,//{register,action,channel}  
    input   logic       [32                   -1:0]   wr_tdata              ,

    /********* rx rdreq *********/
    input  logic                                      rd_req                ,
    input  logic        [10                  -1:0]    rd_tdest              ,
);






endmodule
