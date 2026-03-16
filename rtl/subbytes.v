`timescale 1ns/1ps
// SubBytes: 16 parallel S-Box lookups on the 128-bit state (column-major 4x4)
module subbytes (
    input  [127:0] state_in,
    output [127:0] state_out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : sb
            sbox u_sbox (
                .in  (state_in [127 - i*8 -: 8]),
                .out (state_out[127 - i*8 -: 8])
            );
        end
    endgenerate
endmodule