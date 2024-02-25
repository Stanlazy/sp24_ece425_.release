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

    mon_itf mon_itf(.*);
    monitor monitor(.itf(mon_itf));

            logic [31:0] rs1_rdata;
            logic [31:0] rd_wdata;
            logic [31:0] pc_wdata;

    generate for (genvar i = 0; i < 32; i++) begin : rvfi_sig
        assign rs1_rdata[i] = dut.datapath.bitslices[i].bitslice.rs1_rdata;
        assign rd_wdata [i] = dut.datapath.bitslices[i].bitslice.rd_mux_out;
        assign pc_wdata [i] = dut.datapath.bitslices[i].bitslice.pc_.pc_next;
    end endgenerate

    always_comb begin
        mon_itf.valid       = ~rst;
        mon_itf.order       = '0;
        mon_itf.inst        = imem_rdata;
        mon_itf.rs1_addr    = dut.control.rs1_s;
        mon_itf.rs2_addr    = dut.control.rs2_s;
        mon_itf.rs1_rdata   = rs1_rdata;
        mon_itf.rs2_rdata   = dmem_wdata;
        mon_itf.rd_addr     = dut.control.rd_s;
        mon_itf.rd_wdata    = rd_wdata;
        mon_itf.pc_rdata    = imem_addr;
        mon_itf.pc_wdata    = pc_wdata;
        mon_itf.mem_addr    = dmem_addr;
        mon_itf.mem_rmask   = dut.control.dmem_rmask;
        mon_itf.mem_wmask   = dmem_wmask;
        mon_itf.mem_rdata   = dmem_rdata;
        mon_itf.mem_wdata   = dmem_wdata;
    end

    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst <= 1'b0;
        #100000000;
        $finish;
    end

endmodule
