module cpu(
    input   logic           clk,
    input   logic           rst,
    output  logic   [31:0]  imem_addr,
    input   logic   [31:0]  imem_rdata,
    output  logic   [31:0]  dmem_addr,
    output  logic           dmem_write,
    output  logic   [3:0]   dmem_wmask,
    input   logic   [31:0]  dmem_rdata,
    output  logic   [31:0]  dmem_wdata
);

            logic   [31:0]  rs1_sel;
            logic   [31:0]  rs2_sel;
            logic   [31:0]  rd_sel;

            logic           alu_mux_1_sel;
            logic           alu_mux_2_sel;
            logic           alu_inv_rs2;
            logic           alu_cin;
            logic   [1:0]   alu_op;
            logic           shift_msb;
            logic           shift_dir;
            logic           cmp_mux_sel;
            logic           pc_mux_sel;
            logic   [2:0]   mem_mux_sel;
            logic   [2:0]   rd_mux_sel;

            logic           cmp_out;
            logic   [31:0]  imm;

            logic           cmp_lt;
            logic           cmp_eq;
            logic           cmp_a_31;
            logic           cmp_b_31;

    control control(
        .*
    );

    datapath datapath(
        .*
    );

endmodule
