`timescale 1ns / 1ns

module top_processor_tb;

    // Inputs
    reg Resetn, PClock, MClock, Run;

    // Outputs
    wire Done;
    wire [8:0] BusWires;

    // Debug outputs from internal processor
    wire [8:0] R0_out, R1_out, RA_out, RG_out, IR_out;
    wire [1:0] Tstep_state;

    // Instantiate the processor
    top_processor dut (
        .Resetn(Resetn),
        .PClock(PClock),
        .MClock(MClock),
        .Run(Run),
        .Done(Done),
        .BusWires(BusWires),

        // Debug outputs
        .R0_out(R0_out),
        .R1_out(R1_out),
        .RA_out(RA_out),
        .RG_out(RG_out),
        .IR_out(IR_out),
        .Tstep_state(Tstep_state)
    );

    // Generate clocks
    initial begin
        PClock = 0;
        forever #10 PClock = ~PClock;  // 50 MHz
    end

    initial begin
        MClock = 0;
        forever #15 MClock = ~MClock;  // 33 MHz
    end

    // Stimulus
    initial begin
        // Dump simulation signals
        $dumpfile("top_processor_tb.vcd");
        $dumpvars(0, top_processor_tb);
        $dumpvars(1, BusWires, R0_out, R1_out, RA_out, RG_out, IR_out, Tstep_state);

        // Reset
        Resetn = 0;
        Run = 0;
        #30;
        Resetn = 1;

        // Execute ROM instructions one by one
        repeat (20) begin
            Run = 1;
            #20;
            Run = 0;
            wait (Done == 1);
            #20;
        end

        #100;
        $finish;
    end

endmodule
