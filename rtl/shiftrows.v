/**
 * shiftrows.v - AES ShiftRows transformation
 * Column-major format: state[127:0] = {col0, col1, col2, col3}
 * Each column = {row3, row2, row1, row0}
 */
module shiftrows (
    input  wire [127:0] data_in,
    output reg  [127:0] data_out
);

always @(*) begin
    // Row 0: no shift
    data_out[127:120] = data_in[127:120];  // row0 col3
    data_out[95:88]   = data_in[95:88];    // row0 col2
    data_out[63:56]   = data_in[63:56];    // row0 col1
    data_out[31:24]   = data_in[31:24];    // row0 col0
    
    // Row 1: shift left by 1
    data_out[119:112] = data_in[87:80];    // row1 col3 <- row1 col2
    data_out[87:80]   = data_in[55:48];    // row1 col2 <- row1 col1
    data_out[55:48]   = data_in[23:16];    // row1 col1 <- row1 col0
    data_out[23:16]   = data_in[119:112];  // row1 col0 <- row1 col3
    
    // Row 2: shift left by 2
    data_out[111:104] = data_in[79:72];    // row2 col3 <- row2 col1
    data_out[79:72]   = data_in[47:40];    // row2 col2 <- row2 col0
    data_out[47:40]   = data_in[111:104];  // row2 col1 <- row2 col3
    data_out[15:8]    = data_in[15:8];     // row2 col0 <- row2 col2
    
    // Row 3: shift left by 3 (right by 1)
    data_out[103:96]  = data_in[71:64];    // row3 col3 <- row3 col2
    data_out[71:64]   = data_in[39:32];    // row3 col2 <- row3 col1
    data_out[39:32]   = data_in[7:0];      // row3 col1 <- row3 col0
    data_out[7:0]     = data_in[103:96];   // row3 col0 <- row3 col3
end

endmodule