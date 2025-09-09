module porc (
    input wire Resetn,
    input wire Clock,
    input wire MClock,
    input wire Run,
    output wire Done,
    output wire [8:0] BusWires,

    // Debug outputs
    output wire [8:0] R0_out,
    output wire [8:0] R1_out,
    output wire [8:0] RA_out,
    output wire [8:0] RG_out,
    output wire [8:0] IR_out,
    output wire [1:0] Tstep_state
);

    reg [1:0] Tstep_Q;
    reg DoneReg;
    assign Done = DoneReg;
    assign Tstep_state = Tstep_Q;

    // Instruction ROM
    reg [4:0] addr;
    wire [8:0] rom_data;
    my_mem rom (.address(addr), .clock(MClock), .q(rom_data));

    // IR register
    wire IRin = (Tstep_Q == 2'b00);
    wire [8:0] IR;
    regn #(9) ir_reg (.R(BusWires), .Rin(IRin), .Clock(Clock), .Resetn(Resetn), .Q(IR));

    wire [2:0] opcode = IR[8:6];
    wire [2:0] dst = IR[5:3];
    wire [2:0] src = IR[2:0];

    // Decoder signals
    wire [7:0] Rin, Rout;
    dec3to8 dec_rin (.W(dst), .En(Tstep_Q == 2'b11), .Y(Rin));
    dec3to8 dec_rout (.W(src), .En(1'b1), .Y(Rout));

    // Registers R0-R7
    wire [8:0] R[7:0];
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : reg_block
            regn #(9) reg_i (.R(BusWires), .Rin(Rin[i]), .Clock(Clock), .Resetn(Resetn), .Q(R[i]));
        end
    endgenerate

    // A register
    wire [8:0] A;
    wire Ain = (Tstep_Q == 2'b01 && opcode >= 3'b010);
    regn #(9) A_reg (.R(BusWires), .Rin(Ain), .Clock(Clock), .Resetn(Resetn), .Q(A));

    // G register and ALU
    wire [8:0] G;
    wire [8:0] alu_result;
    wire sub = (opcode == 3'b011);
    wire shift = (opcode == 3'b100);
    regn #(9) G_reg (.R(alu_result), .Rin(Tstep_Q == 2'b10), .Clock(Clock), .Resetn(Resetn), .Q(G));
    addsub alu (.sub(sub), .shift(shift), .Bus(BusWires), .A(A), .result(alu_result));

    // Mux output
    wire [8:0] mux_out;
    muxsmthng2one mux (
        .in0(R[0]), .in1(R[1]), .in2(R[2]), .in3(R[3]),
        .in4(R[4]), .in5(R[5]), .in6(R[6]), .in7(R[7]),
        .inD(IR), .inG(G),
        .rsele(Rout),
        .gsele(1'b0), .dsele(1'b0),
        .out(mux_out)
    );

    // Bus logic
    reg [8:0] bus_internal;
    always @(*) begin
        case (Tstep_Q)
            2'b00: bus_internal = rom_data;
            2'b01: bus_internal = mux_out;
            2'b10: bus_internal = 9'b0;
            2'b11: bus_internal = (opcode == 3'b000 || opcode == 3'b001) ? mux_out : G;
            default: bus_internal = 9'b0;
        endcase
    end
    assign BusWires = bus_internal;

    // FSM logic
    always @(posedge Clock or negedge Resetn) begin
        if (!Resetn) begin
            Tstep_Q <= 0;
            DoneReg <= 0;
        end else if (Run) begin
            if (Tstep_Q == 2'b11) begin
                Tstep_Q <= 0;
                DoneReg <= 1;
            end else begin
                Tstep_Q <= Tstep_Q + 1;
                DoneReg <= 0;
            end
        end else begin
            Tstep_Q <= 0;
            DoneReg <= 0;
        end
    end

    // ROM address control
    always @(posedge MClock or negedge Resetn) begin
        if (!Resetn)
            addr <= 0;
        else if (Run && Tstep_Q == 2'b00)
            addr <= addr + 1;
    end

    // Debug outputs
    assign R0_out = R[0];
    assign R1_out = R[1];
    assign RA_out = A;
    assign RG_out = G;
    assign IR_out = IR;

endmodule
