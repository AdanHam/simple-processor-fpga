module top_processor (
    input wire Resetn,
    input wire PClock,
    input wire MClock,
    input wire Run,
    output wire Done,
    output wire [8:0] BusWires,

    // debug signals
    output wire [8:0] R0_out,
    output wire [8:0] R1_out,
    output wire [8:0] RA_out,
    output wire [8:0] RG_out,
    output wire [8:0] IR_out,
    output wire [1:0] Tstep_state
);

    porc processor_unit (
        .Resetn(Resetn),
        .Clock(PClock),
        .MClock(MClock),
        .Run(Run),
        .Done(Done),
        .BusWires(BusWires),

        .R0_out(R0_out),
        .R1_out(R1_out),
        .RA_out(RA_out),
        .RG_out(RG_out),
        .IR_out(IR_out),
        .Tstep_state(Tstep_state)
    );

endmodule
