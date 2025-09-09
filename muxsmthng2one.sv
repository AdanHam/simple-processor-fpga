module muxsmthng2one (
    input wire [8:0] in0, in1, in2, in3, in4, in5, in6, in7, inD, inG,
    input wire [7:0] rsele,
    input wire gsele, dsele,
    output wire [8:0] out
);
    assign out = (gsele) ? inG :
                 (dsele) ? inD :
                 (rsele[0]) ? in0 :
                 (rsele[1]) ? in1 :
                 (rsele[2]) ? in2 :
                 (rsele[3]) ? in3 :
                 (rsele[4]) ? in4 :
                 (rsele[5]) ? in5 :
                 (rsele[6]) ? in6 :
                 (rsele[7]) ? in7 : 9'b0;
endmodule

