module porc (
    input wire Resetn,
    input wire Clock,     // datapath/control clock
    input wire MClock,    // memory clock
    input wire Run,
    output reg Done,
    output [8:0] BusWires,

    // New debug outputs
    output wire [8:0] R0_out,
    output wire [8:0] R1_out,
    output wire [8:0] RA_out,
    output wire [8:0] RG_out,
    output wire [8:0] IR_out,
    output wire [1:0] Tstep_state
);

    // Internal declarations
    reg [7:0] Rin, ROmux;
    reg GOmux, DOmux;
    reg Ain, Gin, IRin;
    reg sub, shift;
    reg [1:0] Tstep_Q, Tstep_D;
    wire [8:0] IR, RA, RG, ALU;
    wire [8:0] R0, R1, R2, R3, R4, R5, R6, R7;
    wire [2:0] I = IR[8:6];
    wire [7:0] Xreg, Yreg;

    // Instruction memory
    reg [19:0] addr_reg;
    wire [19:0] addr = addr_reg;
    reg [8:0] rom_data;
    wire [8:0] DIN = rom_data;
    reg advance_addr;
    reg [8:0] memory [0:31];

    initial begin
        memory[0] = 9'b001000000; // mvi R0
        memory[1] = 9'b000000101; // #5
        memory[2] = 9'b000001000; // mv R1, R0
        memory[3] = 9'b010000001; // add R0, R1
        memory[4] = 9'b011000000; // sub R0, R0
        for (int i = 5; i < 32; i++) memory[i] = 9'b000000000;
    end

    always @(posedge MClock)
        rom_data <= memory[addr[4:0]];

    always @(posedge MClock or negedge Resetn)
        if (!Resetn) addr_reg <= 0;
        else if (advance_addr) addr_reg <= addr_reg + 1;

    // FSM timing logic
    parameter T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11;
    parameter MV = 3'b000, MVI = 3'b001, ADD = 3'b010, SUB = 3'b011, SPECIALM = 3'b101;

    dec3to8 decX(IR[5:3], 1'b1, Xreg);
    dec3to8 decY(IR[2:0], 1'b1, Yreg);

    always @(Tstep_Q or I or Run) begin
        case (Tstep_Q)
            T0: Tstep_D <= Run ? T1 : T0;
            T1: Tstep_D <= (I == MV || I == MVI) ? T0 : ((~Run) ? T2 : T1);
            T2: Tstep_D <= ~Run ? T3 : T2;
            T3: Tstep_D <= ~Run ? T0 : T3;
            default: Tstep_D <= T0;
        endcase
    end

    always @(Tstep_Q or I or Xreg or Yreg) begin    
        case (Tstep_Q)
            T0: begin
                Done <= 0; IRin <= 1; Rin <= 0;
                Ain <= 0; Gin <= 0; ROmux <= 0;
                GOmux <= 0; DOmux <= 1; advance_addr <= 0;
            end
            T1: begin
                IRin <= 0;
                case (I)
                    MV: begin
                        Rin <= Xreg; Ain <= 0; Done <= 1;
                        ROmux <= Yreg; GOmux <= 0; DOmux <= 0; Gin <= 0;
                        advance_addr <= 1;
                    end
                    MVI: begin
                        Rin <= Xreg; Ain <= 0; Done <= 1;
                        ROmux <= 0; GOmux <= 0; DOmux <= 1; Gin <= 0;
                        advance_addr <= 1;
                    end
                    ADD, SUB: begin
                        Ain <= 1; Done <= 0; ROmux <= Yreg;
                        DOmux <= 0; Rin <= 0; GOmux <= 0; advance_addr <= 0;
                    end
                    SPECIALM: begin
                        Ain <= 1; Done <= 0; ROmux <= Xreg;
                        DOmux <= 0; Rin <= 0; GOmux <= 0; advance_addr <= 0;
                    end
                    default: begin
                        Done <= 0; Ain <= 0; Gin <= 0; Rin <= 0;
                        ROmux <= 0; GOmux <= 0; DOmux <= 1; advance_addr <= 0;
                    end
                endcase
            end
            T2: begin
                Ain <= 0;
                case (I)
                    ADD: begin Gin <= 1; sub <= 0; ROmux <= Xreg; shift <= 0; end
                    SUB: begin Gin <= 1; sub <= 1; ROmux <= Xreg; shift <= 0; end
                    SPECIALM: begin Gin <= 1; sub <= 0; shift <= 1; ROmux <= Yreg; end
                    default: begin Gin <= 0; sub <= 0; shift <= 0; end
                endcase
            end
            T3: begin
                case (I)
                    SPECIALM: begin
                        Rin <= Yreg; Ain <= 0; Done <= 1;
                        ROmux <= 0; GOmux <= 1; DOmux <= 0; Gin <= 0; IRin <= 0;
                        advance_addr <= 1;
                    end
                    default: begin
                        Rin <= Xreg; Done <= 1;
                        GOmux <= 1; DOmux <= 0; Gin <= 0;
                        advance_addr <= 1;
                    end
                endcase
            end
        endcase
    end

    always @(posedge Clock or negedge Resetn)
        if (!Resetn) Tstep_Q <= T0;
        else         Tstep_Q <= Tstep_D;

    // Registers
    regn reg_0 (.R(BusWires), .Rin(Rin[0]), .Resetn(Resetn), .Clock(Clock), .Q(R0));
    regn reg_1 (.R(BusWires), .Rin(Rin[1]), .Resetn(Resetn), .Clock(Clock), .Q(R1));
    regn reg_RA (.R(BusWires), .Rin(Ain), .Resetn(Resetn), .Clock(Clock), .Q(RA));
    regn reg_RG (.R(ALU), .Rin(Gin), .Resetn(Resetn), .Clock(Clock), .Q(RG));
    regn reg_IR (.R(DIN), .Rin(IRin), .Resetn(Resetn), .Clock(Clock), .Q(IR));

    // ALU
    addsub _addsub (.sub(sub), .Bus(BusWires), .A(RA), .shift(shift), .result(ALU));

    // Mux
    muxsmthng2one _mux (
        .in0(R0), .in1(R1), .in2(R2), .in3(R3), .in4(R4), .in5(R5), .in6(R6), .in7(R7),
        .inD(DIN), .inG(RG),
        .rsele(ROmux), .gsele(GOmux), .dsele(DOmux),
        .out(BusWires)
    );

    // === Debug outputs ===
    assign R0_out = R0;
    assign R1_out = R1;
    assign RA_out = RA;
    assign RG_out = RG;
    assign IR_out = IR;
    assign Tstep_state = Tstep_Q;

endmodule
