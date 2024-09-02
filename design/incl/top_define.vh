`ifndef __TOP_DEFINE_VH
`define __TOP_DEFINE_VH 1

//device
`define XILINX_FPGA_K7
`define XIL_TX_USER_W 1
`define XIL_RX_USER_W 1

`define PCIE_DATA_WIDTH 128
`define PCIE_DATA_KW  (PCIE_DATA_WIDTH/8)
`define PCIE_TUSER_W    4

`define rst_block posedge clk
`define rst rst

`endif