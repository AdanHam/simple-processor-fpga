module top_processor2 (
    input logic Resetn,
    input logic Clock,
    input logic MClock,
    input logic Run,
    output logic Done,
    output logic [8:0] BusWires,
    output logic [8:0] R0_out,
    output logic [8:0] R1_out,
    output logic [8:0] RA_out,
    output logic [8:0] RG_out,
    output logic [8:0] IR_out,
    output logic [1:0] Tstep_state
);

// Instantiate your processor module here
// Example placeholder:
    porc P (
        .Resetn(Resetn),
        .Clock(Clock),
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
