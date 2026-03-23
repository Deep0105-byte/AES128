// mix_columns.v - AES MixColumns transformation
module mix_columns (
    input  [127:0] state_in,
    output [127:0] state_out
);
    // Helper function for multiplication by 2 in GF(2^8)
    function [7:0] xtime;
        input [7:0] x;
        xtime = {x[6:0], 1'b0} ^ (8'h1b & {8{x[7]}});
    endfunction
    
    // Helper function for multiplication by 3 in GF(2^8)
    function [7:0] mul3;
        input [7:0] x;
        mul3 = xtime(x) ^ x;
    endfunction
    
    genvar c;
    generate
        for (c = 0; c < 4; c = c + 1) begin : column_loop
            wire [7:0] s0 = state_in[127 - 32*c -: 8];
            wire [7:0] s1 = state_in[95 - 32*c -: 8];
            wire [7:0] s2 = state_in[63 - 32*c -: 8];
            wire [7:0] s3 = state_in[31 - 32*c -: 8];
            
            wire [7:0] new_s0 = xtime(s0) ^ mul3(s1) ^ s2 ^ s3;
            wire [7:0] new_s1 = s0 ^ xtime(s1) ^ mul3(s2) ^ s3;
            wire [7:0] new_s2 = s0 ^ s1 ^ xtime(s2) ^ mul3(s3);
            wire [7:0] new_s3 = mul3(s0) ^ s1 ^ s2 ^ xtime(s3);
            
            assign state_out[127 - 32*c -: 8] = new_s0;
            assign state_out[95 - 32*c -: 8] = new_s1;
            assign state_out[63 - 32*c -: 8] = new_s2;
            assign state_out[31 - 32*c -: 8] = new_s3;
        end
    endgenerate
endmodule