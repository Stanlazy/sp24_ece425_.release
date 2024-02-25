module mem_mux(
    input   logic           lb, lh, lw, lbu, lhu,
    input   logic   [2:0]   mem_mux_sel,
    output  logic           mem_mux_out
);
    always_comb begin
        unique case (mem_mux_sel)
            3'b000 : mem_mux_out = lb;
            3'b001 : mem_mux_out = lh;
            3'b010 : mem_mux_out = lw;
            3'b100 : mem_mux_out = lbu;
            3'b101 : mem_mux_out = lhu;
            default: mem_mux_out = 'x;
        endcase
    end
endmodule

module rd_mux(
    input   logic           alu_out, shift_out, cmp_out, imm, pcp4, mem_mux_out,
    input   logic   [2:0]   rd_mux_sel,
    output  logic           rd_mux_out
);
    always_comb begin
        unique case (rd_mux_sel)
            3'b000 : rd_mux_out = alu_out;
            3'b001 : rd_mux_out = shift_out;
            3'b010 : rd_mux_out = cmp_out;
            3'b011 : rd_mux_out = imm;
            3'b100 : rd_mux_out = pcp4;
            3'b101 : rd_mux_out = mem_mux_out;
            default: rd_mux_out = 'x;
        endcase
    end
endmodule

module pcadder(
    input   logic           pc,
    input   logic           pc_adder_4,
    input   logic           pc_cin,
    output  logic           pc_cout,
    output  logic           pcp4
);
            logic   [1:0]   add_temp;
    assign add_temp = pc + pc_adder_4 + pc_cin;
    assign pc_cout  = add_temp[1];
    assign pcp4     = add_temp[0];
endmodule

module regfile(
    input   logic           clk,
    input   logic   [31:0]  rd_sel,
    input   logic   [31:0]  rs1_sel,
    input   logic   [31:0]  rs2_sel,
    input   logic           rd_mux_out,
    output  logic           rs1_rdata,
    output  logic           rs2_rdata,
    output  logic   [31:0]  rf_data
);
    assign rf_data[0] = 1'b0;
    always @* begin
        for (int i = 1; i < 32; i++) begin
            rf_data[i] <= rd_sel[i] ? rd_mux_out : rf_data[i];
        end
    end
    always_latch begin
        if (clk) begin
            rs1_rdata = 1'b0;
            rs2_rdata = 1'b0;
            for (int i = 1; i < 32; i++) begin
                if (rs1_sel[i]) begin
                    rs1_rdata = rf_data[i];
                end
                if (rs2_sel[i]) begin
                    rs2_rdata = rf_data[i];
                end
            end
        end
    end
endmodule

module pc(
    input   logic           clk,
    input   logic           rst,
    input   logic           pc_reset_value,
    input   logic           pc_mux_sel,
    input   logic           pcp4,
    input   logic           alu_out,
    output  logic           pc
);
            logic           pc_next;
    assign pc_next = rst ? pc_reset_value : (pc_mux_sel ? alu_out : pcp4);
    always_ff @(posedge clk) begin
        pc <= pc_next;
    end
endmodule

module rs2_inverter(
    input   logic           rs2_rdata, alu_inv_rs2,
    output  logic           rs2_after_inv
);
    assign rs2_after_inv = rs2_rdata ^ alu_inv_rs2;
endmodule

module mux2 (
    input   logic           a, b, s,
    output  logic           z
);
    always_comb begin
        if      (~s) z = a;
        else if ( s) z = b;
        else         z = 'x;
    end
endmodule

module alu(
    input   logic           alu_mux_1_out,
    input   logic           alu_mux_2_out,
    input   logic           alu_cin,
    output  logic           alu_cout,
    input   logic   [1:0]   alu_op,
    output  logic           alu_out
);
            logic   [1:0]   add_temp;
    assign add_temp = alu_mux_1_out + alu_mux_2_out + alu_cin;
    assign alu_cout = add_temp[1];
    always_comb begin
        unique case (alu_op)
            2'b00  : alu_out = add_temp[0];
            2'b01  : alu_out = alu_mux_1_out ^ alu_mux_2_out;
            2'b10  : alu_out = alu_mux_1_out | alu_mux_2_out;
            2'b11  : alu_out = alu_mux_1_out & alu_mux_2_out;
            default: alu_out = 'x;
        endcase
    end
endmodule

module shift(
    input   logic           alu_mux_1_out,
    input   logic   [4:0]   shift_amount,
    input   logic           shift_dir,
    input   logic   [4:0]   shift_in_from_right,
    input   logic   [4:0]   shift_in_from_left,
    output  logic   [5:0]   shift_out
);
            logic   [4:0]   shift_in;
    assign shift_out[0]   = alu_mux_1_out;
    assign shift_in       = shift_dir ? shift_in_from_left : shift_in_from_right;
    generate for (genvar i = 0; i < 5; i++) begin : shifts
        assign shift_out[i+1] = shift_amount[i] ? shift_in[i] : shift_out[i];
    end endgenerate
endmodule

module cmp(
    input   logic           rs1_rdata,
    input   logic           cmp_mux_out,
    input   logic           cmp_eq_in,
    input   logic           cmp_lt_in,
    output  logic           cmp_eq_out,
    output  logic           cmp_lt_out
);
    assign cmp_eq_out = cmp_eq_in & (rs1_rdata == cmp_mux_out);
    assign cmp_lt_out = cmp_lt_in | (cmp_eq_in & (rs1_rdata < cmp_mux_out));
endmodule
