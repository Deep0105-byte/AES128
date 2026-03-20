`timescale 1ns/1ps
// mixcolumns.v – AES MixColumns (FIPS-197 Sec 5.1.3)
// GF(2^8) arithmetic with irreducible poly x^8+x^4+x^3+x+1 (0x11b)
module mixcolumns (
    input  [127:0] state_in,
    output [127:0] state_out
);
    function [7:0] xtime;
        input [7:0] b;
        xtime = b[7] ? ((b << 1) ^ 8'h1b) : (b << 1);
    endfunction

    function [7:0] mul3;
        input [7:0] b;
        mul3 = xtime(b) ^ b;
    endfunction

    function [31:0] mix_col;
        input [31:0] col;
        reg [7:0] s0,s1,s2,s3;
        begin
            s0=col[31:24]; s1=col[23:16]; s2=col[15:8]; s3=col[7:0];
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
