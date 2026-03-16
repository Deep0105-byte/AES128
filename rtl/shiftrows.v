module shiftrows(
input  [127:0] state_in,
output [127:0] state_out
);

wire [7:0] s[0:15];
wire [7:0] r[0:15];

genvar i;

/* Split state into bytes */
generate
for(i=0;i<16;i=i+1)
assign s[i] = state_in[127-i*8 -: 8];
endgenerate

/* Row 0 (no shift) */
assign r[0]  = s[0];
assign r[4]  = s[4];
assign r[8]  = s[8];
assign r[12] = s[12];

/* Row 1 (shift left 1) */
assign r[1]  = s[5];
assign r[5]  = s[9];
assign r[9]  = s[13];
assign r[13] = s[1];

/* Row 2 (shift left 2) */
assign r[2]  = s[10];
assign r[6]  = s[14];
assign r[10] = s[2];
assign r[14] = s[6];

/* Row 3 (shift left 3) */
assign r[3]  = s[15];
assign r[7]  = s[3];
assign r[11] = s[7];
assign r[15] = s[11];

/* Reassemble state */
generate
for(i=0;i<16;i=i+1)
assign state_out[127-i*8 -: 8] = r[i];
endgenerate

endmodule
