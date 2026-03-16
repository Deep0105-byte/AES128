`timescale 1ns/1ps
// MixColumns: GF(2^8) matrix multiply per AES FIPS-197 Section 5.1.3
// Operates column by column on the 128-bit state (column-major)
module mixcolumns (
    input  [127:0] state_in,
    output [127:0] state_out
);
    // GF(2^8) multiply by 2 (xtime)
    function [7:0] xtime;
        input [7:0] b;
        begin
            xtime = (b[7]) ? ((b << 1) ^ 8'h1b) : (b << 1);
        end
    endfunction

    // GF multiply by 3 = xtime(b) XOR b
    function [7:0] mul3;
        input [7:0] b;
        begin
            mul3 = xtime(b) ^ b;
        end
    endfunction

    // MixColumns on one column [s0,s1,s2,s3]:
    // r0 = 2*s0 ^ 3*s1 ^   s2 ^   s3
    // r1 =   s0 ^ 2*s1 ^ 3*s2 ^   s3
    // r2 =   s0 ^   s1 ^ 2*s2 ^ 3*s3
    // r3 = 3*s0 ^   s1 ^   s2 ^ 2*s3
    function [31:0] mix_col;
        input [31:0] col; // {s0,s1,s2,s3}
        reg [7:0] s0,s1,s2,s3;
        begin
            s0 = col[31:24];
            s1 = col[23:16];
            s2 = col[15:8];
            s3 = col[7:0];
            mix_col[31:24] = xtime(s0) ^ mul3(s1) ^      s2  ^      s3;
            mix_col[23:16] =      s0   ^ xtime(s1) ^ mul3(s2) ^      s3;
            mix_col[15:8]  =      s0   ^      s1   ^ xtime(s2) ^ mul3(s3);
            mix_col[7:0]   = mul3(s0)  ^      s1   ^      s2   ^ xtime(s3);
        end
    endfunction

    assign state_out[127:96] = mix_col(state_in[127:96]);
    assign state_out[95:64]  = mix_col(state_in[95:64]);
    assign state_out[63:32]  = mix_col(state_in[63:32]);
    assign state_out[31:0]   = mix_col(state_in[31:0]);
endmodule