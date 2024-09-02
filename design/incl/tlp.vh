`ifndef __TLP_VH
`define __TLP_VH 1

`define TLP_LENGTH_I 0
`define TLP_LENGTH_W 10
`define TLP_LENGGTH_R (`TLP_LENGTH_I +: `TLP_LENGTH_W)

`define TLP_AT_I 10
`define TLP_AT_W 2
`define TLP_AT_R (`TLP_AT_I +: `TLP_AT_W)

`define TLP_ATTR0_I 12
`define TLP_ATTR0_W 2
`define TLP_ATTR0_R (`TLP_ATTR0_I +: `TLP_ATTR0_W)

`define TLP_EP_I 14
`define TLP_EP_W 1
`define TLP_EP_R (`TLP_EP_I +: `TLP_EP_W)

`define TLP_TD_I 15
`define TLP_TD_W 1
`define TLP_TD_R (`TLP_TD_I +: `TLP_TD_W)

`define TLP_TH_I 16
`define TLP_TH_W 1
`define TLP_TH_R (`TLP_TH_I +: `TLP_TH_W)

`define TLP_ATTR1_I 18
`define TLP_ATTR1_W 1
`define TLP_ATTR1_R (`TLP_ATTR1_I +: `TLP_ATTR1_W)

`define TLP_TC_I 20
`define TLP_TC_W 3
`define TLP_TC_R (`TLP_TC_I +: `TLP_TC_W)

`define TLP_TYPE_I 24
`define TLP_TYPE_W 5
`define TLP_TYPE_R (`TLP_TYPE_I +: `TLP_TYPE_W)

`define TLP_FMT_I 29
`define TLP_FMT_W 4
`define TLP_FMT_R (`TLP_FMT_I +: `TLP_FMT_W)



`endif
