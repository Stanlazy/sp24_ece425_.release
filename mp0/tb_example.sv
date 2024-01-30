module tb;

    logic   A;
    logic   Z;

    inv dut(
        .A(A),
        .Z(Z)
    );

    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
        A <= 1'b0;
        #1;
        A <= 1'b1;
        #1;
        A <= 1'b0;
        #1;
        $finish;
    end

endmodule
