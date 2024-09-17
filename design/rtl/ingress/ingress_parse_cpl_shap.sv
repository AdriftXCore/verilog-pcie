/******************************************Copyright@2024**************************************
                                    AdriftXCore  ALL rights reserved
                                    https://www.cnblogs.com/cnlntr/
=========================================FILE INFO.============================================
FILE Name       : ingress_parse_cpl_shap.v
Last Update     : 2024/09/17 23:12:12
Latest Versions : 1.0
========================================AUTHOR INFO.===========================================
Created by      : AdriftXCore
Create date     : 2024/09/17 23:12:12
Version         : 1.0
Description     : completin data shaping.
=======================================UPDATE HISTPRY==========================================
Modified by     : 
Modified date   : 
Version         : 
Description     : 
******************************Licensed under the GPL-3.0 License******************************/
module ingress_parse_cpl_shap #(
    parameter TAG_I     = 0,
    parameter TAG_W     = 5,
    parameter DST_I     = 5,
    parameter DST_W     = 2,
    parameter T_W       = TAG_W + DST_W,
    parameter RAM_DW    = DST_W,
    parameter RAM_AW    = TAG_W,
    parameter MRAM_AW   = 1,
    parameter MRAM_DW   = 32,
    parameter KMRAM_AW  = MRAM_AW,
    parameter KMRAM_DW  = 1,
    parameter MRAM_N    = `PCIE_DATA_WIDTH/32,
    parameter POS_D     = `PCIE_DATA_WIDTH/32,
    parameter SK_W      = $clog2(`PCIE_DATA_WIDTH/32),
    parameter CNT_W     = $clog2((2**MRAM_AW)*MRAM_N),
    parameter FIFO_W    = `PCIE_DATA_WIDTH + `PCIE_DATA_KW + 1 + 1 + `PCIE_TUSER_W 
)(
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

logic                                                               ram_wen     ;
logic   [RAM_AW                 -1:0]                               ram_waddr   ;
logic   [RAM_DW                 -1:0]                               ram_wdata   ;

logic                                                               ram_ren     ;
logic   [RAM_AW                 -1:0]                               ram_raddr   ;
logic   [RAM_DW                 -1:0]                               ram_rdata   ;

logic   [2                      -1:0]   [`PCIE_DATA_WIDTH     -1:0] packet_ram  ;
logic   [POS_D                  -1:0]   [MRAM_AW              -1:0] pos         ;
logic   [CNT_W                  -1:0]                               cnt         ;
logic   [SK_W                   -1:0]                               skew        ;

logic   [CNT_W                    :0]                               wr_ptr      ;
logic   [CNT_W                    :0]                               _rd_ptr     ;
logic   [CNT_W                    :0]                               rd_ptr      ;
logic   [CNT_W                  -1:0]                               _ram_cnt    ;
logic   [CNT_W                  -1:0]                               ram_cnt     ;

logic                                                               cpl_en      ;
logic                                                               cpl_eop_    ;  

logic   [CNT_W                    :0]                               keep_num    ;   
logic   [CNT_W                    :0]                               _keep_num   ;   

logic   [MRAM_N                 -1:0]                               mram_wen    ;
logic   [`PCIE_DATA_WIDTH       -1:0]                               mram_wdat   ;
logic   [MRAM_N*MRAM_AW         -1:0]                               mram_waddr  ;

logic                                                               mram_ren    ;
logic                                                               mram_ren_   ;
logic   [MRAM_N*MRAM_AW         -1:0]                               mram_raddr  ;
logic   [`PCIE_DATA_WIDTH       -1:0]                               mram_rdat   ;
logic   [`PCIE_DATA_KW          -1:0]                               kmram_rdat  ;


logic   [`PCIE_DATA_WIDTH       -1:0]                               int_dat     ;                                                            
logic                                                               int_sop     ;
logic                                                               int_eop     ;
logic                                                               int_vld     ;
logic   [`PCIE_TUSER_W          -1:0]                               int_usr     ;
logic   [`PCIE_DATA_KW          -1:0]                               _int_kep    ;
logic   [`PCIE_DATA_KW          -1:0]                               int_kep     ;

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

assign ram_ren   = cpl_en && cpl_sop;
assign ram_raddr = cpl_meta.tlp_h.tlp_c_t.tlp_tag;

sdpram_wrapper #( 
    .DEVICE            ("TINY"        ),
    .AW                (MRAM_AW       ), // depth
    .DW                (MRAM_DW       ), // data width
    .CLOCKING_MODE     ("common_clock")               
)
u_maping_sdpram_wrapper [MRAM_N -1:0](
    .clk_a    (clk          ),  // write clk for port-A
    .en_a     (1'b1         ),  // memory enable for port-A, active high
    .wen_a    (mram_wen     ),  // write  enable for port-A, active high
    .addr_a   (mram_waddr   ),  // address for port-A
    .din_a    (mram_wdat    ),  // data input for port-A (write)

    .clk_b    (clk          ),  // read clk for port-B
    .rstn_b   (`ram_rst     ),  // reset for FPGA dout of port-B, active low
    .en_b     (mram_ren     ),  // memory enable for port-B, active high
    .addr_b   (mram_raddr   ),  // address for port-B
    .dout_b   (mram_rdat    )   // data output for port-B (read)
);  

sdpram_wrapper #( 
    .DEVICE            ("TINY"        ),
    .AW                (KMRAM_AW      ), // depth
    .DW                (KMRAM_DW      ), // data width
    .CLOCKING_MODE     ("common_clock")               
)
u_kmaping_sdpram_wrapper [MRAM_N -1:0](
    .clk_a    (clk          ),  // write clk for port-A
    .en_a     (1'b1         ),  // memory enable for port-A, active high
    .wen_a    (mram_wen     ),  // write  enable for port-A, active high
    .addr_a   (mram_waddr   ),  // address for port-A
    .din_a    (mram_wen     ),  // data input for port-A (write)

    .clk_b    (clk          ),  // read clk for port-B
    .rstn_b   (`ram_rst     ),  // reset for FPGA dout of port-B, active low
    .en_b     (mram_ren     ),  // memory enable for port-B, active high
    .addr_b   (mram_raddr   ),  // address for port-B
    .dout_b   (kmram_rdat   )   // data output for port-B (read)
);  

assign cpl_en = cpl_rdy && cpl_valid;

always_ff @(`rst_block)begin
    if(`rst)
        cnt <= 'd0;
    else if(cpl_en)
        cnt <= cnt + keep_num;
end

assign skew = cnt[SK_W -1:0];

always_ff @(`rst_block)begin
    if(`rst)
        mram_wdat <= 'd0;
    else
        mram_wdat <= (cpl_data << (skew<<5)) | (cpl_data >> (MRAM_N - (skew<<5)));
end

always_ff @(`rst_block)begin
    if(`rst)
        mram_wen <= 'd0;
    else if(cpl_en)
        mram_wen <= (cpl_keep << skew) | (cpl_keep >> (MRAM_N - skew));
end

generate for(genvar i = 0;i < POS_D;i = i + 1)begin
    always_ff @(`rst_block)begin
        if(`rst)
            pos[i] <= 'd0;
        else if(mram_wen[i])
            pos[i] <= pos[i] + 1;
    end

    assign mram_waddr[i*MRAM_AW +: MRAM_AW] = pos[i];

end endgenerate

always_comb begin
    keep_num = 0;
    for(i = 0;i < `PCIE_DATA_KW;i = i + 1)begin    
        _keep_num = keep_num + cpl_keep[i];
        keep_num  = _keep_num;
    end
end

always_ff @(`rst_block)begin
    if(`rst)
        wr_ptr <= 'd0;
    else if(cpl_en)
        wr_ptr <= wr_ptr + keep_num;
end

always_ff @(`rst_block)begin
    if(`rst)
        rd_ptr <= 'd0;
    else if(mram_ren)
        rd_ptr <= _rd_ptr;
end
assign _rd_ptr =  rd_ptr + 'd4;

assign ram_cnt = (wr_ptr[CNT_W] == rd_ptr[CNT_W]) ? (wr_ptr[CNT_W-1:0] - rd_ptr[CNT_W-1:0]) : ((2**CNT_W) + wr_ptr[CNT_W-1:0] - rd_ptr[CNT_W-1:0]);
assign _ram_cnt = (wr_ptr[CNT_W] == _rd_ptr[CNT_W]) ? (wr_ptr[CNT_W-1:0] - _rd_ptr[CNT_W-1:0]) : ((2**CNT_W) + wr_ptr[CNT_W-1:0] - _rd_ptr[CNT_W-1:0]);

always_ff @(`rst_block)begin
    if(`rst)
        mram_ren <= 'd0;
    else if(cpl_eop_ && (ram_cnt != 0)))
        mram_ren <= 'd1;
    else if((ram_cnt >= 4) && (!mram_ren))
        mram_ren <= 'd1;
    else if((_ram_cnt >= 4) && (mram_ren))
        mram_ren <= 'd1;
    else
        mram_ren <= 'd0;
end

always_ff @(`rst_block)begin
    if(`rst)
        mram_ren_ <= 'd0;
    else
        mram_ren_ <= mram_ren;
end

assign mram_raddr = rd_ptr[CNT_W-1:0];

always_ff @(`rst_block)begin
    if(`rst)
        int_sop <= 'd0;
    else if(int_sop && int_vld)
        int_sop <= 'd1;
    else if(cpl_en && cpl_sop)
        int_sop <= 'd1;
end

assign int_vld = mram_ren_;
assign int_dat = mram_rdat;

always_ff @(`rst_block)begin
    if(`rst)
        cpl_eop_ <= 'd0;
    else if(cpl_en && cpl_eop)
        cpl_eop_ <= 'd1;
    else
        cpl_eop_ <= 'd0;
end

assign int_eop = ((_ram_cnt == 0) | (ram_cnt == 0))? (cpl_en && cpl_eop) : cpl_eop_;
assign int_kep = kmram_rdat;

assign int_usr = ram_rdata;

logic  [FIFO_W -1:0]    fifo_din     ;
logic                   fifo_push    ;
logic                   fifo_pop     ;
logic                   fifo_full    ;
logic  [FIFO_W -1:0]    fifo_dout    ;
logic                   fifo_empty   ;

tiny_fifo 
#(
    .DW    (FIFO_W),
    .DEPTH (4     )
u_tiny_fifo(
    .clk         (clk                   ),
    .`rst_nm     (`fifo_rst             ),
    .data_i      (fifo_din              ),
    .push        (fifo_push             ),
    .pop         (fifo_pop              ),
    .full        (fifo_full             ),
    .data_o      (fifo_dout             ),
    .empty       (fifo_empty            )
);

assign fifo_din  = {int_sop,int_eop,int_usr,int_kep,int_dat};
assign fifo_push = int_vld && (~fifo_full);
assign fifo_pop  = m_axis_tx_tready && (~fifo_empty);
assign {m_axis_tx_sop,m_axis_tx_eop,m_axis_tx_tuser,m_axis_tx_tkeep,m_axis_tx_tdata} = fifo_dout;
assign cpl_rdy   = ~fifo_full;

endmodule
