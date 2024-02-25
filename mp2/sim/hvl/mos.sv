module NMOS_VTL(
    output  wire   D,
    input   wire   B,
    input   wire   G,
    input   wire   S
);

    always_comb begin
        automatic logic wack;
        wack = B;
    end

    nmos (D, S, G);

endmodule

module PMOS_VTL(
    output  wire   D,
    input   wire   B,
    input   wire   G,
    input   wire   S
);

    always_comb begin
        automatic logic wack;
        wack = B;
    end

    pmos (D, S, G);

endmodule
