module subbytes(
input  [127:0] state_in,
output [127:0] state_out
);

wire [7:0] s0,s1,s2,s3,s4,s5,s6,s7;
wire [7:0] s8,s9,s10,s11,s12,s13,s14,s15;

wire [7:0] r0,r1,r2,r3,r4,r5,r6,r7;
wire [7:0] r8,r9,r10,r11,r12,r13,r14,r15;

/* Extract bytes (MSB first) */
assign s0  = state_in[127:120];
assign s1  = state_in[119:112];
assign s2  = state_in[111:104];
assign s3  = state_in[103:96];
assign s4  = state_in[95:88];
assign s5  = state_in[87:80];
assign s6  = state_in[79:72];
assign s7  = state_in[71:64];
assign s8  = state_in[63:56];
assign s9  = state_in[55:48];
assign s10 = state_in[47:40];
assign s11 = state_in[39:32];
assign s12 = state_in[31:24];
assign s13 = state_in[23:16];
assign s14 = state_in[15:8];
assign s15 = state_in[7:0];

/* Apply S-box */
sbox u0(s0,r0);   sbox u1(s1,r1);
sbox u2(s2,r2);   sbox u3(s3,r3);
sbox u4(s4,r4);   sbox u5(s5,r5);
sbox u6(s6,r6);   sbox u7(s7,r7);
sbox u8(s8,r8);   sbox u9(s9,r9);
sbox u10(s10,r10); sbox u11(s11,r11);
sbox u12(s12,r12); sbox u13(s13,r13);
sbox u14(s14,r14); sbox u15(s15,r15);

/* Reassemble */
assign state_out = {
r0,r1,r2,r3,
r4,r5,r6,r7,
r8,r9,r10,r11,
r12,r13,r14,r15
};

endmodule