module tb;

    // create top level wires here

    // instantiate your top level here

    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
        // insert your test vector here
        $finish;
    end

endmodule
