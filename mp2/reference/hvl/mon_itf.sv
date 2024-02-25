interface mon_itf(
    input   bit             clk,
    input   bit             rst
);

            logic           valid;
            logic   [63:0]  order;
            logic   [31:0]  inst;
            logic           halt;
            logic   [4:0]   rs1_addr;
            logic   [4:0]   rs2_addr;
            logic   [31:0]  rs1_rdata;
            logic   [31:0]  rs2_rdata;
            logic   [4:0]   rd_addr;
            logic   [31:0]  rd_wdata;
            logic   [31:0]  pc_rdata;
            logic   [31:0]  pc_wdata;
            logic   [31:0]  mem_addr;
            logic   [3:0]   mem_rmask;
            logic   [3:0]   mem_wmask;
            logic   [31:0]  mem_rdata;
            logic   [31:0]  mem_wdata;

            bit             error = 1'b0;

endinterface
