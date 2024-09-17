module  tiny_ram
#( 
    parameter   AW                  = 5                                , // depth
    parameter   DW                  = 256                              , // data width
    parameter   BYTE_WRITE_WIDTH_A  = DW                               , // BYTE WRITE WIDTH for port-A
    // local parameter
    parameter   DEPTH               = 2**AW                            ,// addr width 
)(

    // write port-A
    input  wire                                  clk      ,  // write clk for port-A
    input  wire                                  `rst_nm  ,  // reset for FPGA dout of port-B, active low
    input  wire                                  en_a     ,  // memory enable for port-A, active high
    input  wire  [DW/BYTE_WRITE_WIDTH_A-1:0]     wen_a    ,  // write  enable for port-A, active high
    input  wire  [AW  -1 : 0]                    addr_a   ,  // address for port-A
    input  wire  [DW  -1 : 0]                    din_a    ,  // data input for port-A (write)

    // read port-B
    input  wire                                  en_b     ,  // memory enable for port-B, active high
    input  wire  [AW  -1 : 0]                    addr_b   ,  // address for port-B
    output wire  [DW  -1 : 0]                    dout_b      // data output for port-B (read)
);

logic [DEPTH-1:0] [DW-1:0] sdpram;

generate 
    if(BYTE_WRITE_WIDTH_A == 8)begin
        
    end
    else begin
        for(genvar i = 0;i < DEPTH;i = i + 1)begin
            always_ff @(`rst_block)begin
                if(`rst)
                    sdpram[i] <= 'd0;
                else if(en_a & wen_a & i == addr_a)
                    sdpram[i] <= din_a;
            end

            always_ff @(`rst_block)begin
                if(en_b)
                    dout_b <= sdpram[addr_b];
                else
                    dout_b <= dout_b;
            end
        end
    end
endgenerate

endmodule