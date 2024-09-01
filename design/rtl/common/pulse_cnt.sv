/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : pulse_cnt.v
Last Update     : 2024/09/01 23:52:26
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/01 23:52:26
Version         : 1.0
Description     : calc signal pulse.
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
*************************************Confidential. Do NOT disclose****************************/
module pulse_cnt #(
    parameter CNT_WIDTH = 32
)(
    /********* system clock / reset *********/
    input   logic                       clk    ,   //system clock
    input   logic                       `rst   ,   //reset signal

    input   logic                       clc    ,
    input   logic                       d_i    ,
    output  logic  [CNT_WIDTH   -1:0]   d_o    
);

always_ff @(`rst_block)begin
    if(`rst)
        d_o <= 'd0;
    else if(clc)
        d_o <= 'd0;
    else if(d_i)
        d_o <= d_o + 1'b1;
end

endmodule
