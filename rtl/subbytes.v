module subbytes(
input  [127:0] state_in,
output [127:0] state_out
);

wire [7:0] s [0:15];
wire [7:0] r [0:15];

/* Correct AES byte mapping (column-major) */

assign {s[0],s[1],s[2],s[3],
        s[4],s[5],s[6],s[7],
        s[8],s[9],s[10],s[11],
        s[12],s[13],s[14],s[15]} = state_in;

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
assign state_out = {r[0],r[1],r[2],r[3],
                    r[4],r[5],r[6],r[7],
                    r[8],r[9],r[10],r[11],
                    r[12],r[13],r[14],r[15]};

endmodule