`ifndef __TLP_VH
`define __TLP_VH 1

`define TLP_LENGTH_W        10
`define TLP_AT_W            2
`define TLP_ATTR0_W         2
`define TLP_EP_W            1
`define TLP_TD_W            1
`define TLP_TH_W            1
`define TLP_ATTR1_W         1
`define TLP_TC_W            3
`define TLP_TYPE_W          5
`define TLP_FMT_W           4
`define TLP_F_DWBE_W        4
`define TLP_L_DWBE_W        4
`define TLP_TAG_W           8
`define TLP_REQID_W         16
`define TLP_ADDR4DW_W       64
`define TLP_ADDR3DW_W       32
`define TLP_BC_W            12
`define TLP_BCM_W           1
`define TLP_CMPSTA          3
`define TLP_CMPLETERID      16
`define LOWADDR             8 

`define TLP_TYPE_CPL        `TLP_TYPE_W'b01010
`define TLP_TYPE_REQ        `TLP_TYPE_W'b00000

`define TLP_FMT_CPL_ND      `TLP_FMT_W'b000
`define TLP_FMT_CPL_WD      `TLP_FMT_W'b010     
`define TLP_FMT_REQ_WD      `TLP_FMT_W'b01x
`define TLP_FMT_REQ_RD      `TLP_FMT_W'b00x

`define TLP_4DW             `TLP_FMT_W'bxx1
`define TLP_3DW             `TLP_FMT_W'bxx0

`define TLP_CPL_ND          {TLP_FMT_CPL_ND,TLP_TYPE_CPL}
`define TLP_CPL_WD          {TLP_FMT_CPL_WD,TLP_TYPE_CPL}
`define TLP_REQ_WD          {TLP_FMT_REQ_WD,TLP_TYPE_REQ}
`define TLP_REQ_RD          {TLP_FMT_REQ_RD,TLP_TYPE_REQ}

unions packed{
    struct packed{
        logic [`TLP_LENGTH_W    -1:0]   tlp_length  ;
        logic [`TLP_AT_W        -1:0]   tlp_at      ;
        logic [`TLP_ATTR0_W     -1:0]   tlp_attr0   ;
        logic [`TLP_EP_W        -1:0]   tlp_ep      ;
        logic [`TLP_TD_W        -1:0]   tlp_td      ;
        logic [`TLP_TH_W        -1:0]   tlp_th      ;
        logic [1                -1:0]   tlp_reserve0;
        logic [`TLP_ATTR1_W     -1:0]   tlp_attr1   ;
        logic [1                -1:0]   tlp_reserve1;
        logic [`TLP_TC_W        -1:0]   tlp_tc      ;
        logic [1                -1:0]   tlp_reserve2;
        logic [`TLP_TYPE_W      -1:0]   tlp_type    ;
        logic [`TLP_FMT_W       -1:0]   tlp_fmt     ;
        unions packed{
            struct packed{
                logic [`TLP_F_DWBE_W    -1:0]   tlp_fdwbe   ;
                logic [`TLP_L_DWBE_W    -1:0]   tlp_ldwbe   ;
                logic [`TLP_TAG_W       -1:0]   tlp_tag     ;
                logic [`TLP_REQID_W     -1:0]   tlp_reqid   ;
                logic [`TLP_ADDR4DW_W   -1:0]   tlp_addr    ;
            }tlp_r4dw_t;
            struct packed{
                logic [`TLP_F_DWBE_W    -1:0]   tlp_fdwbe   ;
                logic [`TLP_L_DWBE_W    -1:0]   tlp_ldwbe   ;
                logic [`TLP_TAG_W       -1:0]   tlp_tag     ;
                logic [`TLP_REQID_W     -1:0]   tlp_reqid   ;
                logic [`TLP_ADDR3DW_W   -1:0]   tlp_addr    ;
                logic [32               -1:0]   tlp_reserve3;
            }tlp_r3dw_t;
            struct packed{
                logic [`TLP_F_DWBE_W    -1:0]   tlp_fdwbe   ;
                logic [`TLP_L_DWBE_W    -1:0]   tlp_ldwbe   ;
                logic [`TLP_TAG_W       -1:0]   tlp_tag     ;
                logic [`TLP_REQID_W     -1:0]   tlp_reqid   ;
                logic [`TLP_ADDR4DW_W   -1:0]   tlp_addr    ;
            }tlp_r_t;
            struct packed{
                logic [`TLP_BC_W        -1:0]   tlp_byte_cnt;
                logic [`TLP_BCM_W       -1:0]   tlp_bcm     ;
                logic [`TLP_CMPSTA      -1:0]   tlp_cmpsta  ;
                logic [`TLP_CMPLETERID  -1:0]   tlp_cmplt   ;
                logic [`LOWADDR         -1:0]   tlp_laddr   ;
                logic [`TLP_TAG_W       -1:0]   tlp_tag     ;
                logic [`TLP_REQID_W     -1:0]   tlp_reqid   ;
                logic [32               -1:0]   tlp_reserve3;
            }tlp_c_t;
        }tlp_htail;
    }tlp_h;
    struct packed{
        logic [4 -1:0] [32  -1:0] dat;
    }tlp_32b_t;
    struct packed{
        logic [2 -1:0] [64  -1:0] dat;
    }tlp_64b_t;
    struct packed{
        logic [1 -1:0] [128 -1:0] dat;
    }tlp_128b_t;
} tlp_head_t;

`endif
