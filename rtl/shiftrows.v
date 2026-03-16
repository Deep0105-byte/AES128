module shiftrows (
    input  [127:0] state_in,
    output [127:0] state_out
);
    // AES column-major storage: 
    // [0..7]   = s0,0; [8..15]  = s1,0; [16..23] = s2,0; [24..31] = s3,0
    // [32..39] = s0,1; [40..47] = s1,1; ...
    assign state_out[127:0] = {
        state_in[127:120], state_in[87:80],   state_in[47:40],   state_in[7:0],   // Col 3
        state_in[95:88],   state_in[55:48],   state_in[15:8],    state_in[103:96], // Col 2
        state_in[63:56],   state_in[23:16],   state_in[111:104], state_in[71:64], // Col 1
        state_in[31:24],   state_in[119:112], state_in[79:72],   state_in[39:32]  // Col 0
    };
endmodule