package rv32i_types;

    typedef enum logic [6:0] {
        op_lui          = 7'b0110111, // U load upper immediate
        op_auipc        = 7'b0010111, // U add upper immediate PC
        op_jal          = 7'b1101111, // J jump and link
        op_jalr         = 7'b1100111, // I jump and link register
        op_br           = 7'b1100011, // B branch
        op_load         = 7'b0000011, // I load
        op_store        = 7'b0100011, // S store
        op_imm          = 7'b0010011, // I arith ops with register/immediate operands
        op_reg          = 7'b0110011  // R arith ops with register operands
    } rv32i_op_t;

    typedef enum logic [2:0] {
        arith_f3_add    = 3'b000, // check logic 30 for sub if op_reg op
        arith_f3_sll    = 3'b001,
        arith_f3_slt    = 3'b010,
        arith_f3_sltu   = 3'b011,
        arith_f3_xor    = 3'b100,
        arith_f3_sr     = 3'b101, // check logic 30 for logical/arithmetic
        arith_f3_or     = 3'b110,
        arith_f3_and    = 3'b111
    } arith_f3_t;

    typedef enum logic [2:0] {
        load_f3_lb      = 3'b000,
        load_f3_lh      = 3'b001,
        load_f3_lw      = 3'b010,
        load_f3_lbu     = 3'b100,
        load_f3_lhu     = 3'b101
    } load_f3_t;

    typedef enum logic [2:0] {
        store_f3_sb     = 3'b000,
        store_f3_sh     = 3'b001,
        store_f3_sw     = 3'b010
    } store_f3_t;

    typedef enum logic [2:0] {
        branch_f3_beq   = 3'b000,
        branch_f3_bne   = 3'b001,
        branch_f3_blt   = 3'b100,
        branch_f3_bge   = 3'b101,
        branch_f3_bltu  = 3'b110,
        branch_f3_bgeu  = 3'b111
    } branch_f3_t;

    typedef enum logic {
        alu_mux_1_rs1   = 1'b0,
        alu_mux_1_pc    = 1'b1
    } alu_mux_1_sel_t;

    typedef enum logic {
        alu_mux_2_rs2   = 1'b0,
        alu_mux_2_imm   = 1'b1
    } alu_mux_2_sel_t;

    typedef enum logic [1:0] {
        alu_op_add      = 2'b00,
        alu_op_xor      = 2'b01,
        alu_op_or       = 2'b10,
        alu_op_and      = 2'b11
    } alu_op_t;

    typedef enum logic {
        shift_left      = 1'b0,
        shift_right     = 1'b1
    } shift_dir_t;

    typedef enum logic {
        cmp_mux_rs2     = 1'b0,
        cmp_mux_imm     = 1'b1
    } cmp_mux_sel_t;

    typedef enum logic {
        pc_mux_pc_p_4   = 1'b0,
        pc_mux_alu      = 1'b1
    } pc_mux_sel_t;

    typedef enum logic [2:0] {
        mem_mux_lb      = 3'b000,
        mem_mux_lh      = 3'b001,
        mem_mux_lw      = 3'b010,
        mem_mux_lbu     = 3'b100,
        mem_mux_lhu     = 3'b101
    } mem_mux_sel_t;

    typedef enum logic [2:0] {
        rd_mux_alu      = 3'b000,
        rd_mux_shift    = 3'b001,
        rd_mux_cmp      = 3'b010,
        rd_mux_imm      = 3'b011,
        rd_mux_pc_p_4   = 3'b100,
        rd_mux_mem      = 3'b101
    } rd_mux_sel_t;

endpackage : rv32i_types

module control
import rv32i_types::*;
(
    input   logic           clk,

    ///////////////////////////////////////
    ////// control signal to memory  //////
    ///////////////////////////////////////

    input   logic   [31:0]  imem_rdata,

    output  logic           dmem_write,
    output  logic   [3:0]   dmem_wmask,

    ///////////////////////////////////////
    ///// control signal to datapath  /////
    ///////////////////////////////////////

    output  logic   [31:0]  rs1_sel,
    output  logic   [31:0]  rs2_sel,
    output  logic   [31:0]  rd_sel,

    output  logic           alu_mux_1_sel,
    output  logic           alu_mux_2_sel,
    output  logic           alu_inv_rs2,
    output  logic           alu_cin,
    output  logic   [1:0]   alu_op,
    output  logic           shift_msb,
    output  logic           shift_dir,
    output  logic           cmp_mux_sel,
    output  logic           pc_mux_sel,
    output  logic   [2:0]   mem_mux_sel,
    output  logic   [2:0]   rd_mux_sel,

    output  logic           cmp_out,

    ///////////////////////////////////////
    ////////// data to datapath  //////////
    ///////////////////////////////////////

    output  logic   [31:0]  imm,

    ///////////////////////////////////////
    //// control signal from datapath  ////
    ///////////////////////////////////////

    input   logic           cmp_lt,
    input   logic           cmp_eq,
    input   logic           cmp_a_31,
    input   logic           cmp_b_31
);

            logic           dmem_read;
            logic   [3:0]   dmem_rmask;

            logic   [2:0]   funct3;
            logic           funct7;
            logic   [6:0]   opcode;
            logic   [31:0]  i_imm;
            logic   [31:0]  s_imm;
            logic   [31:0]  b_imm;
            logic   [31:0]  u_imm;
            logic   [31:0]  j_imm;
            logic   [4:0]   rs1_s;
            logic   [4:0]   rs2_s;
            logic   [4:0]   rd_s;
            logic   [31:0]  rs1_s_onehot;
            logic   [31:0]  rs2_s_onehot;
            logic   [31:0]  rd_s_onehot;

    always_comb begin
        funct3                          = imem_rdata[14:12];
        funct7                          = imem_rdata[30];
        opcode                          = imem_rdata[6:0];
        i_imm                           = {{21{imem_rdata[31]}}, imem_rdata[30:20]};
        s_imm                           = {{21{imem_rdata[31]}}, imem_rdata[30:25], imem_rdata[11:7]};
        b_imm                           = {{20{imem_rdata[31]}}, imem_rdata[7], imem_rdata[30:25], imem_rdata[11:8], 1'b0};
        u_imm                           = {imem_rdata[31:12], 12'h000};
        j_imm                           = {{12{imem_rdata[31]}}, imem_rdata[19:12], imem_rdata[20], imem_rdata[30:21], 1'b0};
        rs1_s                           = (opcode inside {op_jalr, op_br, op_load, op_store, op_imm, op_reg}) ? imem_rdata[19:15] : 5'd0;
        rs2_s                           = (opcode inside {op_br, op_store, op_reg}) ? imem_rdata[24:20] : 5'd0;
        rd_s                            = (opcode inside {op_lui, op_auipc, op_jal, op_jalr, op_load, op_imm, op_reg}) ? imem_rdata[11: 7] : 5'd0;
        rs1_s_onehot                    = 32'd1 << rs1_s;
        rs2_s_onehot                    = 32'd1 << rs2_s;
        rd_s_onehot                     = (32'd1 << rd_s) & {32{~clk}};

        dmem_read                       = 1'b0;
        dmem_rmask                      = 4'd0;
        dmem_write                      = 1'b0;
        dmem_wmask                      = 4'd0;
        rs1_sel                         = 32'd1;
        rs2_sel                         = 32'd1;
        rd_sel                          = 32'd1 & {32{~clk}};
        alu_mux_1_sel                   = 'x;
        alu_mux_2_sel                   = 'x;
        alu_inv_rs2                     = 1'b0;
        alu_cin                         = 1'b0;
        alu_op                          = 'x;
        shift_msb                       = 'x;
        shift_dir                       = 'x;
        cmp_mux_sel                     = 'x;
        pc_mux_sel                      = pc_mux_pc_p_4;
        mem_mux_sel                     = 'x;
        rd_mux_sel                      = 'x;
        cmp_out                         = 'x;
        imm                             = 'x;

        unique case (opcode)
        op_lui   : begin
            rd_sel                      = rd_s_onehot;
            rd_mux_sel                  = rd_mux_imm;
            imm                         = u_imm;
        end
        op_auipc : begin
            rd_sel                      = rd_s_onehot;
            alu_mux_1_sel               = alu_mux_1_pc;
            alu_mux_2_sel               = alu_mux_2_imm;
            alu_op                      = alu_op_add;
            rd_mux_sel                  = rd_mux_alu;
            imm                         = u_imm;
        end
        op_jal   : begin
            rd_sel                      = rd_s_onehot;
            alu_mux_1_sel               = alu_mux_1_pc;
            alu_mux_2_sel               = alu_mux_2_imm;
            alu_op                      = alu_op_add;
            pc_mux_sel                  = pc_mux_alu;
            rd_mux_sel                  = rd_mux_pc_p_4;
            imm                         = j_imm;
        end
        op_jalr  : begin
            rs1_sel                     = rs1_s_onehot;
            rd_sel                      = rd_s_onehot;
            alu_mux_1_sel               = alu_mux_1_rs1;
            alu_mux_2_sel               = alu_mux_2_imm;
            alu_op                      = alu_op_add;
            pc_mux_sel                  = pc_mux_alu;
            rd_mux_sel                  = rd_mux_pc_p_4;
            imm                         = i_imm;
        end
        op_br    : begin
            unique case (funct3)
                branch_f3_beq : cmp_out =   cmp_eq;
                branch_f3_bne : cmp_out =  ~cmp_eq;
                branch_f3_blt : cmp_out =   cmp_lt ^ cmp_a_31 ^ cmp_b_31;
                branch_f3_bge : cmp_out = ~(cmp_lt ^ cmp_a_31 ^ cmp_b_31);
                branch_f3_bltu: cmp_out =   cmp_lt;
                branch_f3_bgeu: cmp_out =  ~cmp_lt;
                default       : cmp_out = 1'bx;
            endcase
            rs1_sel                     = rs1_s_onehot;
            rs2_sel                     = rs2_s_onehot;
            alu_mux_1_sel               = alu_mux_1_pc;
            alu_mux_2_sel               = alu_mux_2_imm;
            alu_op                      = alu_op_add;
            cmp_mux_sel                 = cmp_mux_rs2;
            pc_mux_sel                  = cmp_out ? pc_mux_alu : pc_mux_pc_p_4;
            imm                         = b_imm;
        end
        op_load  : begin
            dmem_read                   = 1'b1;
            rs1_sel                     = rs1_s_onehot;
            rd_sel                      = rd_s_onehot;
            alu_mux_1_sel               = alu_mux_1_rs1;
            alu_mux_2_sel               = alu_mux_2_imm;
            alu_op                      = alu_op_add;
            unique case (funct3)
                load_f3_lb :mem_mux_sel = mem_mux_lb;
                load_f3_lh :mem_mux_sel = mem_mux_lh;
                load_f3_lw :mem_mux_sel = mem_mux_lw;
                load_f3_lbu:mem_mux_sel = mem_mux_lbu;
                load_f3_lhu:mem_mux_sel = mem_mux_lhu;
                default    :mem_mux_sel = 'x;
            endcase
            unique case (funct3)
                load_f3_lb : dmem_rmask = 4'b0001;
                load_f3_lh : dmem_rmask = 4'b0011;
                load_f3_lw : dmem_rmask = 4'b1111;
                load_f3_lbu: dmem_rmask = 4'b0001;
                load_f3_lhu: dmem_rmask = 4'b0011;
                default    : dmem_rmask = '0;
            endcase
            rd_mux_sel                  = rd_mux_mem;
            imm                         = i_imm;
        end
        op_store : begin
            dmem_write                  = 1'b1;
            unique case (funct3)
                store_f3_sb: dmem_wmask = 4'b0001;
                store_f3_sh: dmem_wmask = 4'b0011;
                store_f3_sw: dmem_wmask = 4'b1111;
                default    : dmem_wmask = 4'b0000;
            endcase
            rs1_sel                     = rs1_s_onehot;
            rs2_sel                     = rs2_s_onehot;
            alu_mux_1_sel               = alu_mux_1_rs1;
            alu_mux_2_sel               = alu_mux_2_imm;
            alu_op                      = alu_op_add;
            imm                         = s_imm;
        end
        op_imm   : begin
            rs1_sel                     = rs1_s_onehot;
            rd_sel                      = rd_s_onehot;
            imm                         = i_imm;
            unique case(funct3)
            arith_f3_add : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_imm;
                alu_op                  = alu_op_add;
                rd_mux_sel              = rd_mux_alu;
            end
            arith_f3_sll : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_imm;
                shift_msb               = 1'b0;
                shift_dir               = shift_left;
                rd_mux_sel              = rd_mux_shift;
            end
            arith_f3_slt : begin
                cmp_mux_sel             = cmp_mux_imm;
                cmp_out                 = cmp_lt ^ cmp_a_31 ^ cmp_b_31;
                rd_mux_sel              = rd_mux_cmp;
            end
            arith_f3_sltu: begin
                cmp_mux_sel             = cmp_mux_imm;
                cmp_out                 = cmp_lt;
                rd_mux_sel              = rd_mux_cmp;
            end
            arith_f3_xor : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_imm;
                alu_op                  = alu_op_xor;
                rd_mux_sel              = rd_mux_alu;
            end
            arith_f3_sr  : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_imm;
                shift_msb               = funct7 ? cmp_a_31 : 1'b0;
                shift_dir               = shift_right;
                rd_mux_sel              = rd_mux_shift;
            end
            arith_f3_or  : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_imm;
                alu_op                  = alu_op_or;
                rd_mux_sel              = rd_mux_alu;
            end
            arith_f3_and : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_imm;
                alu_op                  = alu_op_and;
                rd_mux_sel              = rd_mux_alu;
            end
            default: begin end
            endcase
        end
        op_reg   : begin
            rs1_sel                     = rs1_s_onehot;
            rs2_sel                     = rs2_s_onehot;
            rd_sel                      = rd_s_onehot;
            unique case(funct3)
            arith_f3_add : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_rs2;
                alu_inv_rs2             = funct7 ? 1'b1 : 1'b0;
                alu_op                  = alu_op_add;
                alu_cin                 = funct7 ? 1'b1 : 1'b0;
                rd_mux_sel              = rd_mux_alu;
            end
            arith_f3_sll : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_rs2;
                shift_msb               = 1'b0;
                shift_dir               = shift_left;
                rd_mux_sel              = rd_mux_shift;
            end
            arith_f3_slt : begin
                cmp_mux_sel             = cmp_mux_rs2;
                cmp_out                 = cmp_lt ^ cmp_a_31 ^ cmp_b_31;
                rd_mux_sel              = rd_mux_cmp;
            end
            arith_f3_sltu: begin
                cmp_mux_sel             = cmp_mux_rs2;
                cmp_out                 = cmp_lt;
                rd_mux_sel              = rd_mux_cmp;
            end
            arith_f3_xor : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_rs2;
                alu_op                  = alu_op_xor;
                rd_mux_sel              = rd_mux_alu;
            end
            arith_f3_sr  : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_rs2;
                shift_msb               = funct7 ? cmp_a_31 : 1'b0;
                shift_dir               = shift_right;
                rd_mux_sel              = rd_mux_shift;
            end
            arith_f3_or  : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_rs2;
                alu_op                  = alu_op_or;
                rd_mux_sel              = rd_mux_alu;
            end
            arith_f3_and : begin
                alu_mux_1_sel           = alu_mux_1_rs1;
                alu_mux_2_sel           = alu_mux_2_rs2;
                alu_op                  = alu_op_and;
                rd_mux_sel              = rd_mux_alu;
            end
            default: begin end
            endcase
        end
        default  : begin end
        endcase
    end

endmodule
