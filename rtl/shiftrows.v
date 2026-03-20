`timescale 1ns/1ps
// shiftrows.v – AES ShiftRows (FIPS-197 Sec 5.1.2)
// Column-major state: byte[col*4+row] at state[127-8*(col*4+row) -: 8]
// Row r cyclically left-shifted by r byte positions
module shiftrows (
    input  [127:0] state_in,
    output [127:0] state_out
);
    // Row 0: no shift  (bytes 0,4,8,12  ← src 0,4,8,12)
    assign state_out[127:120] = state_in[127:120]; // byte 0  ← 0
    assign state_out[95:88]   = state_in[95:88];   // byte 4  ← 4
    assign state_out[63:56]   = state_in[63:56];   // byte 8  ← 8
    assign state_out[31:24]   = state_in[31:24];   // byte 12 ← 12

    // Row 1: left 1   (bytes 1,5,9,13  ← src 5,9,13,1)
    assign state_out[119:112] = state_in[87:80];   // byte 1  ← 5
    assign state_out[87:80]   = state_in[55:48];   // byte 5  ← 9
    assign state_out[55:48]   = state_in[23:16];   // byte 9  ← 13
    assign state_out[23:16]   = state_in[119:112]; // byte 13 ← 1

    // Row 2: left 2   (bytes 2,6,10,14 ← src 10,14,2,6)
    assign state_out[111:104] = state_in[47:40];   // byte 2  ← 10
    assign state_out[79:72]   = state_in[15:8];    // byte 6  ← 14
    assign state_out[47:40]   = state_in[111:104]; // byte 10 ← 2
    assign state_out[15:8]    = state_in[79:72];   // byte 14 ← 6

    // Row 3: left 3   (bytes 3,7,11,15 ← src 15,3,7,11)
    assign state_out[103:96]  = state_in[7:0];     // byte 3  ← 15
    assign state_out[71:64]   = state_in[103:96];  // byte 7  ← 3
    assign state_out[39:32]   = state_in[71:64];   // byte 11 ← 7
    assign state_out[7:0]     = state_in[39:32];   // byte 15 ← 11
endmodule
