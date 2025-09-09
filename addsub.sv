module addsub (
    input wire sub,
    input wire [8:0] Bus,
    input wire [8:0] A,
    input wire shift,
    output wire [8:0] result
);
    assign result = sub ? (Bus - A) : (shift ? ((A >> 1) + A + (A << 1) + Bus) : (A + Bus));
endmodule

