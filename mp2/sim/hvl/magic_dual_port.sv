module magic_dual_port #(
    parameter MEMFILE = "memory.lst"
)(
    input   logic           clk,
    input   logic           rst,
    input   logic   [31:0]  imem_addr,
    output  logic   [31:0]  imem_rdata,
    input   logic   [31:0]  dmem_addr,
    input   logic           dmem_write,
    input   logic   [3:0]   dmem_wmask,
    output  logic   [31:0]  dmem_rdata,
    input   logic   [31:0]  dmem_wdata
);

    logic [7:0] internal_memory_array [2**29];

    always @(posedge clk iff rst) begin
        $readmemh(MEMFILE, internal_memory_array);
    end

    generate for (genvar i = 0; i < 4; i++) begin : magic_mem_read;
        assign imem_rdata[i*8+:8] = rst ? 'x : internal_memory_array[imem_addr[28:0] + i];
        assign dmem_rdata[i*8+:8] = rst ? 'x : internal_memory_array[dmem_addr[28:0] + i];
    end endgenerate

    always @(posedge clk) begin
        if (~rst && dmem_write) begin
            for (int i = 0; i < 4; i++) begin
                if (dmem_wmask[i]) begin
                    internal_memory_array[dmem_addr[28:0] + i] <= dmem_wdata[i*8+:8];
                end
            end
        end
    end

endmodule