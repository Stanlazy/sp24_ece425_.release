module top_tb;

    timeunit 1ns;
    timeprecision 1ns;

    bit clk;
    always #1 clk = ~clk;

    bit rst;

            logic   [31:0]  imem_addr;
            logic   [31:0]  imem_rdata;
            logic   [31:0]  dmem_addr;
            logic           dmem_write;
            logic   [3:0]   dmem_wmask;
            logic   [31:0]  dmem_rdata;
            logic   [31:0]  dmem_wdata;

    cpu dut(.*);
    magic_dual_port mem(.*);

    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst <= 1'b0;
        #1000;
        $finish;
    end

endmodule
