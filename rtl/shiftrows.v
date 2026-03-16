`timescale 1ns/1ps
// ShiftRows: cyclic left-shift of rows in the 4x4 AES state (column-major)
// Row 0: no shift   Row 1: left 1   Row 2: left 2   Row 3: left 3
module shiftrows (
    input  [127:0] state_in,
    output [127:0] state_out
);
    // Column-major byte indexing: byte[col*4+row]
    // Row 0 (r=0): bytes 0,4,8,12  -> unchanged
    // Row 1 (r=1): bytes 1,5,9,13  -> shift left 1: 5,9,13,1
    // Row 2 (r=2): bytes 2,6,10,14 -> shift left 2: 10,14,2,6
    // Row 3 (r=3): bytes 3,7,11,15 -> shift left 3: 15,3,7,11
    // Helper macro: extract byte b (0-based) from state[127:0]
    // byte b occupies bits [127-8*b : 120-8*b]
    assign state_out[127:120] = state_in[127:120];
    assign state_out[119:112] = state_in[87:80];
    assign state_out[111:104] = state_in[47:40];
    assign state_out[103:96] = state_in[7:0];
    assign state_out[95:88] = state_in[95:88];
    assign state_out[87:80] = state_in[55:48];
    assign state_out[79:72] = state_in[15:8];
    assign state_out[71:64] = state_in[103:96];
    assign state_out[63:56] = state_in[63:56];
    assign state_out[55:48] = state_in[23:16];
    assign state_out[47:40] = state_in[111:104];
    assign state_out[39:32] = state_in[71:64];
    assign state_out[31:24] = state_in[31:24];
    assign state_out[23:16] = state_in[119:112];
    assign state_out[15:8] = state_in[79:72];
    assign state_out[7:0] = state_in[39:32];
endmodule