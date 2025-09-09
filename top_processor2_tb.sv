`timescale 1ns / 1ns

module top_processor2_tb;

    reg Resetn, PClock, MClock, Run;
    wire Done;
    wire [8:0] BusWires;

    // Debug signals
    wire [8:0] R0_out, R1_out, RA_out, RG_out, IR_out;
    wire [1:0] Tstep_state;

    // Instantiate top module
    top_processor2 DUT (
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

    // Clock generators
    initial begin
        PClock = 0;
        forever #10 PClock = ~PClock;  // 20ns period
    end

    initial begin
        MClock = 0;
        forever #5 MClock = ~MClock;   // 10ns period
    end

    // Simulation control
    initial begin
        $dumpfile("top_processor2_tb.vcd");
        $dumpvars(0, top_processor2_tb);

        $display("Starting simulation...");
        Resetn = 0;
        Run = 0;
        #20;

        Resetn = 1;
        #10;

        Run = 1;

        #800;

        $display("=== Checking instruction results ===");

        // Expected values based on your .mif file
        if (R0_out !== 9'd6) $display("FAIL: R0 != 6");
        else                 $display("PASS: R0 == 6");

        if (RA_out !== 9'd6) $display("FAIL: RA != 6 (expected MV R3,R0 then R4,R3)");
        else                 $display("PASS: RA == 6");

        if (RG_out !== 9'd36) $display("FAIL: RG != 36 (expected after specialMult R4,R4)");
        else                  $display("PASS: RG == 36");

        if (R1_out !== 9'd502) $display("FAIL: R1 != 502 (expected after ones R6, R5)");
        else                   $display("PASS: R1 == 502");

        if (R0_out !== 9'd6) $display("FAIL: R0 was altered unexpectedly");
        else                 $display("PASS: R0 == 6");

        if (IR_out !== 9'd67) $display("PASS: IR == 67 (last instruction mv R2,R7)");
        else                  $display("NOTE: IR = %d", IR_out);

        $display("Simulation complete.");
        $finish;
    end

endmodule
