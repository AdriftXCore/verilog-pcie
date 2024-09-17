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
Description     : parse completion for rx sgl,tx sgl,rx data.
2'b00:rx sgl
2'b01:tx sgl
2'b11:rx data
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
*************************************Confidential. Do NOT disclose****************************/
module ingress_parse_cpl #(
    parameter TAG_I     = 0,
    parameter TAG_W     = 5,
    parameter DST_I     = 5,
    parameter DST_W     = 2,
    parameter T_W       = TAG_W + DST_W,
    parameter RAM_DW    = DST_W,
    parameter RAM_AW    = TAG_W,
    parameter POS_D     = `PCIE_DATA_WIDTH/32,
    parameter SK_W      = `PCIE_DATA_WIDTH/32,
    parameter CNT_W     = 3
)(
    /********* system clock / reset *********/
    input   wire                                      clk                     ,   //system clock
    input   wire                                      `rst_nm                 ,   //reset signal

    /********* parse_pre in *********/
    input   logic       [`PCIE_DATA_WIDTH     -1:0]   cpl_data                ,
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

logic                                               ram_wen     ;
logic   [RAM_AW -1:0]                               ram_waddr   ;
logic   [RAM_DW -1:0]                               ram_wdata   ;

logic                                               ram_ren     ;
logic   [RAM_AW -1:0]                               ram_raddr   ;
logic   [RAM_DW -1:0]                               ram_rdata   ;

logic   [2      -1:0]   [`PCIE_DATA_WIDTH     -1:0] packet_ram  ;
logic   [POS_D  -1:0]   [1                    -1:0] pos         ;
logic   [CNT_W  -1:0]                               cnt         ;
logic   [SK_W   -1:0]                               skew        ;

logic   [CNT_W    :0]                               wr_ptr      ;
logic   [CNT_W    :0]                               rd_ptr      ;
logic   [CNT_W  -1:0]                               ram_cnt     ;

logic                                               cpl_en      ;

always_ff @(`rst_block)begin
    if(`rst)begin
        ram_wen   <= 'd0;
        ram_waddr <= 'd0;
        ram_wdata <= 'd0;
    end
    else begin
        ram_wen   <= tag_vld;
        ram_waddr <= tag[TAG_I +: TAG_W];
        ram_wdata <= tag[DST_I +: DST_W];
    end
end

sdpram_wrapper #( 
    .AW                (RAM_AW        ), // depth
    .DW                (RAM_DW        ), // data width
    .CLOCKING_MODE     ("common_clock"),                
    .WRITE_MODE_B      ("write_first" ), // "read_first", "write_first"
    .INIT_FILE         ("none"        )
)
u_tag_sdpram_wrapper(
    .clk_a    (clk          ),  // write clk for port-A
    .en_a     (1'b1         ),  // memory enable for port-A, active high
    .wen_a    (ram_wen      ),  // write  enable for port-A, active high
    .addr_a   (ram_waddr    ),  // address for port-A
    .din_a    (ram_wdata    ),  // data input for port-A (write)

    .clk_b    (clk          ),  // read clk for port-B
    .rstn_b   (`ram_rst     ),  // reset for FPGA dout of port-B, active low
    .en_b     (ram_ren      ),  // memory enable for port-B, active high
    .addr_b   (ram_raddr    ),  // address for port-B
    .dout_b   (ram_rdata    )   // data output for port-B (read)
);  

sdpram_wrapper #( 
    .DEVICE            ("TINY"        ),
    .AW                (RAM_AW        ), // depth
    .DW                (RAM_DW        ), // data width
    .CLOCKING_MODE     ("common_clock"),                
    .WRITE_MODE_B      ("write_first" ), // "read_first", "write_first"
    .INIT_FILE         ("none"        )
)
u_maping_sdpram_wrapper [POS_D -1:0](
    .clk_a    (clk          ),  // write clk for port-A
    .en_a     (1'b1         ),  // memory enable for port-A, active high
    .wen_a    (             ),  // write  enable for port-A, active high
    .addr_a   (             ),  // address for port-A
    .din_a    (             ),  // data input for port-A (write)

    .clk_b    (clk          ),  // read clk for port-B
    .rstn_b   (`ram_rst     ),  // reset for FPGA dout of port-B, active low
    .en_b     (             ),  // memory enable for port-B, active high
    .addr_b   (             ),  // address for port-B
    .dout_b   (             )   // data output for port-B (read)
);  


assign cpl_en = cpl_rdy && cpl_valid;





endmodule
