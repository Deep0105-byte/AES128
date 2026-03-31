module subbytes(
input  [127:0] state_in,
output [127:0] state_out
);

wire [7:0] s [0:15];
wire [7:0] r [0:15];

genvar i;

/* Split state into bytes */
generate
for(i=0;i<16;i=i+1)
assign s[i] = state_in[127 - i*8 -: 8];
endgenerate

/* Apply S-box */
sbox s0  (s[0],  r[0]);
sbox s1  (s[1],  r[1]);
sbox s2  (s[2],  r[2]);
sbox s3  (s[3],  r[3]);
sbox s4  (s[4],  r[4]);
sbox s5  (s[5],  r[5]);
sbox s6  (s[6],  r[6]);
sbox s7  (s[7],  r[7]);
sbox s8  (s[8],  r[8]);
sbox s9  (s[9],  r[9]);
sbox s10 (s[10], r[10]);
sbox s11 (s[11], r[11]);
sbox s12 (s[12], r[12]);
sbox s13 (s[13], r[13]);
sbox s14 (s[14], r[14]);
sbox s15 (s[15], r[15]);

/* Reassemble */
generate
for(i=0;i<16;i=i+1)
assign state_out[127 - i*8 -: 8] = r[i];
endgenerate

endmodule