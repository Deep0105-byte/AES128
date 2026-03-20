`timescale 1ns/1ps
// subbytes.v – AES SubBytes: 16 parallel S-Box lookups
// State is 128-bit column-major: byte[i] = state[127-8*i -: 8]
module subbytes (
    input  [127:0] state_in,
    output [127:0] state_out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : SB
            sbox u_sbox (
                .in  (state_in [127 - i*8 -: 8]),
                .out (state_out[127 - i*8 -: 8])
            );
        end
    endgenerate
endmodule
