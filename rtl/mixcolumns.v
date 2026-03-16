module mixcolumns (
    input  [127:0] state_in,
    output [127:0] state_out
);
    function [7:0] gmul2(input [7:0] x);
        gmul2 = {x[6:0], 1'b0} ^ (x[7] ? 8'h1b : 8'h00);
    endfunction

    function [7:0] gmul3(input [7:0] x);
        gmul3 = gmul2(x) ^ x;
    endfunction

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : col_loop
            wire [7:0] s0 = state_in[i*32 + 0  +: 8];
            wire [7:0] s1 = state_in[i*32 + 8  +: 8];
            wire [7:0] s2 = state_in[i*32 + 16 +: 8];
            wire [7:0] s3 = state_in[i*32 + 24 +: 8];

            assign state_out[i*32 + 0  +: 8] = gmul2(s0) ^ gmul3(s1) ^ s2 ^ s3;
            assign state_out[i*32 + 8  +: 8] = s0 ^ gmul2(s1) ^ gmul3(s2) ^ s3;
            assign state_out[i*32 + 16 +: 8] = s0 ^ s1 ^ gmul2(s2) ^ gmul3(s3);
            assign state_out[i*32 + 24 +: 8] = gmul3(s0) ^ s1 ^ s2 ^ gmul2(s3);
        end
    endgenerate
endmodule