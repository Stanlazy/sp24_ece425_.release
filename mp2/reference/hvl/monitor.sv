module monitor (
    mon_itf itf
);

    always @(posedge itf.clk iff !itf.rst) begin
        if ($isunknown(itf.valid)) begin
            $error("RVFI Interface Error: valid is 1'bx");
            itf.error <= 1'b1;
        end
    end

    always @(posedge itf.clk iff (!itf.rst && itf.valid)) begin
        if ($isunknown(itf.order)) begin
            $error("RVFI Interface Error: order contains 'x");
            itf.error <= 1'b1;
        end
        if ($isunknown(itf.inst)) begin
            $error("RVFI Interface Error: inst contains 'x");
            itf.error <= 1'b1;
        end
        if ($isunknown(itf.rs1_addr)) begin
            $error("RVFI Interface Error: rs1_addr contains 'x");
            itf.error <= 1'b1;
        end
        if ($isunknown(itf.rs2_addr)) begin
            $error("RVFI Interface Error: rs2_addr contains 'x");
            itf.error <= 1'b1;
        end
        if (itf.rs1_addr != '0) begin
            if ($isunknown(itf.rs1_rdata)) begin
                $error("RVFI Interface Error: rs1_rdata contains 'x");
                itf.error <= 1'b1;
            end
        end
        if (itf.rs2_addr != '0) begin
            if ($isunknown(itf.rs2_rdata)) begin
                $error("RVFI Interface Error: rs2_rdata contains 'x");
                itf.error <= 1'b1;
            end
        end
        if ($isunknown(itf.rd_addr)) begin
            $error("RVFI Interface Error: rd_addr contains 'x");
            itf.error <= 1'b1;
        end
        if (itf.rd_addr) begin
            if ($isunknown(itf.rd_wdata)) begin
                $error("RVFI Interface Error: rd_wdata contains 'x");
                itf.error <= 1'b1;
            end
        end
        if ($isunknown(itf.pc_rdata)) begin
            $error("RVFI Interface Error: pc_rdata contains 'x");
            itf.error <= 1'b1;
        end
        if ($isunknown(itf.pc_wdata)) begin
            $error("RVFI Interface Error: pc_wdata contains 'x");
            itf.error <= 1'b1;
        end
        if ($isunknown(itf.mem_rmask)) begin
            $error("RVFI Interface Error: mem_rmask contains 'x");
            itf.error <= 1'b1;
        end
        if ($isunknown(itf.mem_wmask)) begin
            $error("RVFI Interface Error: mem_wmask contains 'x");
            itf.error <= 1'b1;
        end
        if (|itf.mem_rmask || |itf.mem_wmask) begin
            if ($isunknown(itf.mem_addr)) begin
                $error("RVFI Interface Error: mem_addr contains 'x");
                itf.error <= 1'b1;
            end
        end
        if (|itf.mem_rmask) begin
            for (int i = 0; i < 4; i++) begin
                if (itf.mem_rmask[i]) begin
                    if ($isunknown(itf.mem_rdata[i*8 +: 8])) begin
                        $error("RVFI Interface Error: mem_rdata contains 'x");
                        itf.error <= 1'b1;
                    end
                end
            end
        end
        if (|itf.mem_wmask) begin
            for (int i = 0; i < 4; i++) begin
                if (itf.mem_wmask[i]) begin
                    if ($isunknown(itf.mem_wdata[i*8 +: 8])) begin
                        $error("RVFI Interface Error: mem_wdata contains 'x");
                        itf.error <= 1'b1;
                    end
                end
            end
        end
    end

    initial itf.halt = 1'b0;
    always @(posedge itf.clk) begin
        if ((!itf.rst && itf.valid) && ((itf.pc_rdata == itf.pc_wdata) || (itf.inst == 32'h00000063) || (itf.inst == 32'h0000006f) || (itf.inst == 32'hF0002013))) begin
            itf.halt <= 1'b1;
            $finish;
        end
    end

    bit [15:0] errcode;
    always @(posedge itf.clk) begin
        if (errcode != 0) begin
            $error("RVFI Monitor Error");
            itf.error <= 1'b1;
        end
    end

    longint inst_count = longint'(0);
    longint cycle_count = longint'(0);
    longint start_time = longint'(0);
    longint total_time = longint'(0);
    bit done_print_ipc = 1'b0;
    real ipc = real'(0);
    always @(posedge itf.clk) begin
        if ((!itf.rst && itf.valid) && (itf.inst == 32'h00102013)) begin
            inst_count = longint'(0);
            cycle_count = longint'(0);
            start_time = $time;
            $display("Monitor: Segment Start time is %t",$time); 
        end else begin
            cycle_count += longint'(1);
            if (!itf.rst && itf.valid) begin
                inst_count += longint'(1);
            end
        end
        if ((!itf.rst && itf.valid) && (itf.inst == 32'h00202013)) begin
            $display("Monitor: Segment Stop time is %t",$time); 
            done_print_ipc = 1'b1;
            ipc = real'(inst_count) / cycle_count;
            total_time = $time - start_time;
            $display("Monitor: Segment IPC: %f", ipc);
            $display("Monitor: Segment Time: %t", total_time);
        end
    end

    final begin
        if (!done_print_ipc) begin
            ipc = real'(inst_count) / cycle_count;
            total_time = $time - start_time;
            $display("Monitor: Total IPC: %f", ipc);
            $display("Monitor: Total Time: %t", total_time);
        end
    end

    riscv_formal_monitor_rv32i monitor(
        .clock              (itf.clk),
        .reset              (itf.rst),
        .rvfi_valid         (itf.valid),
        .rvfi_order         (itf.order),
        .rvfi_insn          (itf.inst),
        .rvfi_trap          (1'b0),
        .rvfi_halt          (itf.halt),
        .rvfi_intr          (1'b0),
        .rvfi_mode          (2'b00),
        .rvfi_rs1_addr      (itf.rs1_addr),
        .rvfi_rs2_addr      (itf.rs2_addr),
        .rvfi_rs1_rdata     (itf.rs1_addr ? itf.rs1_rdata : 32'd0),
        .rvfi_rs2_rdata     (itf.rs2_addr ? itf.rs2_rdata : 32'd0),
        .rvfi_rd_addr       (itf.rd_addr),
        .rvfi_rd_wdata      (itf.rd_addr ? itf.rd_wdata : 5'd0),
        .rvfi_pc_rdata      (itf.pc_rdata),
        .rvfi_pc_wdata      (itf.pc_wdata),
        .rvfi_mem_addr      (itf.mem_addr),
        .rvfi_mem_rmask     (itf.mem_rmask),
        .rvfi_mem_wmask     (itf.mem_wmask),
        .rvfi_mem_rdata     (itf.mem_rdata),
        .rvfi_mem_wdata     (itf.mem_wdata),
        .rvfi_mem_extamo    (1'b0),
        .errcode            (errcode)
    );

    int fd;
    initial fd = $fopen("./commit.log", "w");
    final $fclose(fd);

    always @ (posedge itf.clk) begin
        if(itf.valid) begin
            // if (itf.order % 1000 == 0) begin
            //     $display("dut commit No.%d, rd_s: x%02d, rd: 0x%h", itf.order, itf.rd_addr, itf.rd_addr ? itf.rd_wdata : 5'd0);
            // end
            if (itf.inst[1:0] == 2'b11) begin
                $fwrite(fd, "core   0: 3 0x%h (0x%h)", itf.pc_rdata, itf.inst);
            end else begin
                $fwrite(fd, "core   0: 3 0x%h (0x%h)", itf.pc_rdata, itf.inst[15:0]);
            end
            if (itf.rd_addr != 0) begin
                if (itf.rd_addr < 10)
                    $fwrite(fd, " x%0d  ", itf.rd_addr);
                else
                    $fwrite(fd, " x%0d ", itf.rd_addr);
                $fwrite(fd, "0x%h", itf.rd_wdata);
            end
            if (itf.mem_rmask != 0) begin
                $fwrite(fd, " mem 0x%h", itf.mem_addr);
            end
            if (itf.mem_wmask != 0) begin
                automatic int amount_o_1 = 0;
                for(int i = 0; i < 4; i++) begin
                    if(itf.mem_wmask[i]) begin
                        amount_o_1 += 1;
                    end
                end
                $fwrite(fd, " mem 0x%h", itf.mem_addr);
                case (amount_o_1)
                    1: begin
                        automatic logic[7:0] wdata_byte = itf.mem_wdata[0 +: 8];
                        $fwrite(fd, " 0x%h", wdata_byte);
                    end
                    2: begin
                        automatic logic[15:0] wdata_half = itf.mem_wdata[0 +: 16];
                        $fwrite(fd, " 0x%h", wdata_half);
                    end
                    4:
                        $fwrite(fd, " 0x%h", itf.mem_wdata);
                endcase
            end
            $fwrite(fd, "\n");
        end
    end

endmodule
