// shift_rows.v - AES ShiftRows transformation
module shift_rows (
    input  [127:0] state_in,
    output [127:0] state_out
);
    // Row 0: no shift
    // Row 1: left shift by 1 byte
    // Row 2: left shift by 2 bytes
    // Row 3: left shift by 3 bytes
    
    assign state_out[127:120] = state_in[127:120];           // Row0 Col0
    assign state_out[119:112] = state_in[119:112];           // Row0 Col1
    assign state_out[111:104] = state_in[111:104];           // Row0 Col2
    assign state_out[103:96]  = state_in[103:96];            // Row0 Col3
    
    assign state_out[95:88]   = state_in[87:80];             // Row1 Col0 <- Col1
    assign state_out[87:80]   = state_in[79:72];             // Row1 Col1 <- Col2
    assign state_out[79:72]   = state_in[71:64];             // Row1 Col2 <- Col3
    assign state_out[71:64]   = state_in[95:88];             // Row1 Col3 <- Col0
    
    assign state_out[63:56]   = state_in[47:40];             // Row2 Col0 <- Col2
    assign state_out[55:48]   = state_in[39:32];             // Row2 Col1 <- Col3
    assign state_out[47:40]   = state_in[63:56];             // Row2 Col2 <- Col0
    assign state_out[39:32]   = state_in[55:48];             // Row2 Col3 <- Col1
    
    assign state_out[31:24]   = state_in[7:0];               // Row3 Col0 <- Col3
    assign state_out[23:16]   = state_in[31:24];             // Row3 Col1 <- Col0
    assign state_out[15:8]    = state_in[23:16];             // Row3 Col2 <- Col1
    assign state_out[7:0]     = state_in[15:8];              // Row3 Col3 <- Col2
    
endmodule
