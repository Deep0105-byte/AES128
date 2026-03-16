/**
 * mixcolumns.v - AES MixColumns transformation
 * Implements GF(2^8) multiplication with fixed matrix:
 * [2 3 1 1] for each column
 * [1 2 3 1]
 * [1 1 2 3]
 * [3 1 1 2]
 */
module mixcolumns (
    input  wire [127:0] data_in,
    output reg  [127:0] data_out
);

// GF(2^8) multiplication functions
function [7:0] xtime;
    input [7:0] x;
    begin
        xtime = {x[6:0], 1'b0} ^ (x[7] ? 8'h1b : 8'h00);
    end
endfunction

function [7:0] mul2;
    input [7:0] x;
    begin
        mul2 = xtime(x);
    end
endfunction

function [7:0] mul3;
    input [7:0] x;
    begin
        mul3 = xtime(x) ^ x;
    end
endfunction

integer col;
reg [7:0] a0, a1, a2, a3;

always @(*) begin
    for (col = 0; col < 4; col = col + 1) begin
        // Extract column bytes (row3, row2, row1, row0 order)
        a0 = data_in[32*col + 24 +: 8];  // row0
        a1 = data_in[32*col + 16 +: 8];  // row1
        a2 = data_in[32*col + 8  +: 8];  // row2
        a3 = data_in[32*col + 0  +: 8];  // row3
        
        // Compute new column values
        data_out[32*col + 24 +: 8] = mul2(a0) ^ mul3(a1) ^ a2 ^ a3;        // row0
        data_out[32*col + 16 +: 8] = a0 ^ mul2(a1) ^ mul3(a2) ^ a3;        // row1
        data_out[32*col + 8  +: 8] = a0 ^ a1 ^ mul2(a2) ^ mul3(a3);        // row2
        data_out[32*col + 0  +: 8] = mul3(a0) ^ a1 ^ a2 ^ mul2(a3);        // row3
    end
end

endmodule