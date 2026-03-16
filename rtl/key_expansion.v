`timescale 1ns/1ps
// AES-128 Key Expansion: generates 11 x 128-bit round keys
// key_schedule[1407:0] = {rk[0], rk[1], ..., rk[10]}  (rk[0] at MSB)
module key_expansion (
    input  [127:0] key,
    output [1407:0] key_schedule
);
    // w[0..43]: 44 words of 32 bits each
    // w[i] for i<4: direct from key
    // w[i] for i>=4:
    //   if i%4==0: w[i] = w[i-4] ^ SubWord(RotWord(w[i-1])) ^ Rcon[i/4-1]
    //   else:      w[i] = w[i-4] ^ w[i-1]

    wire [31:0] w [0:43];

    // Initial words from key (MSB-first column order)
    assign w[0] = key[127:96];
    assign w[1] = key[95:64];
    assign w[2] = key[63:32];
    assign w[3] = key[31:0];

    // SubWord function applied to RotWord output
    // RotWord: {w[7:0], w[31:8]} (left-rotate by one byte)

    // SubWord wires for each schedule step (10 steps)
    wire [31:0] subrot [1:10]; // subrot[i] = SubWord(RotWord(w[4i-1]))
    wire [7:0] sw1_b0, sw1_b1, sw1_b2, sw1_b3;
    wire [7:0] sw2_b0, sw2_b1, sw2_b2, sw2_b3;
    wire [7:0] sw3_b0, sw3_b1, sw3_b2, sw3_b3;
    wire [7:0] sw4_b0, sw4_b1, sw4_b2, sw4_b3;
    wire [7:0] sw5_b0, sw5_b1, sw5_b2, sw5_b3;
    wire [7:0] sw6_b0, sw6_b1, sw6_b2, sw6_b3;
    wire [7:0] sw7_b0, sw7_b1, sw7_b2, sw7_b3;
    wire [7:0] sw8_b0, sw8_b1, sw8_b2, sw8_b3;
    wire [7:0] sw9_b0, sw9_b1, sw9_b2, sw9_b3;
    wire [7:0] sw10_b0, sw10_b1, sw10_b2, sw10_b3;

    sbox u_sw1_b0(.in(w[3][23:16]), .out(sw1_b0));
    sbox u_sw1_b1(.in(w[3][15:8]),  .out(sw1_b1));
    sbox u_sw1_b2(.in(w[3][7:0]),   .out(sw1_b2));
    sbox u_sw1_b3(.in(w[3][31:24]), .out(sw1_b3));
    assign subrot[1] = {sw1_b0, sw1_b1, sw1_b2, sw1_b3};

    sbox u_sw2_b0(.in(w[7][23:16]), .out(sw2_b0));
    sbox u_sw2_b1(.in(w[7][15:8]),  .out(sw2_b1));
    sbox u_sw2_b2(.in(w[7][7:0]),   .out(sw2_b2));
    sbox u_sw2_b3(.in(w[7][31:24]), .out(sw2_b3));
    assign subrot[2] = {sw2_b0, sw2_b1, sw2_b2, sw2_b3};

    sbox u_sw3_b0(.in(w[11][23:16]), .out(sw3_b0));
    sbox u_sw3_b1(.in(w[11][15:8]),  .out(sw3_b1));
    sbox u_sw3_b2(.in(w[11][7:0]),   .out(sw3_b2));
    sbox u_sw3_b3(.in(w[11][31:24]), .out(sw3_b3));
    assign subrot[3] = {sw3_b0, sw3_b1, sw3_b2, sw3_b3};

    sbox u_sw4_b0(.in(w[15][23:16]), .out(sw4_b0));
    sbox u_sw4_b1(.in(w[15][15:8]),  .out(sw4_b1));
    sbox u_sw4_b2(.in(w[15][7:0]),   .out(sw4_b2));
    sbox u_sw4_b3(.in(w[15][31:24]), .out(sw4_b3));
    assign subrot[4] = {sw4_b0, sw4_b1, sw4_b2, sw4_b3};

    sbox u_sw5_b0(.in(w[19][23:16]), .out(sw5_b0));
    sbox u_sw5_b1(.in(w[19][15:8]),  .out(sw5_b1));
    sbox u_sw5_b2(.in(w[19][7:0]),   .out(sw5_b2));
    sbox u_sw5_b3(.in(w[19][31:24]), .out(sw5_b3));
    assign subrot[5] = {sw5_b0, sw5_b1, sw5_b2, sw5_b3};

    sbox u_sw6_b0(.in(w[23][23:16]), .out(sw6_b0));
    sbox u_sw6_b1(.in(w[23][15:8]),  .out(sw6_b1));
    sbox u_sw6_b2(.in(w[23][7:0]),   .out(sw6_b2));
    sbox u_sw6_b3(.in(w[23][31:24]), .out(sw6_b3));
    assign subrot[6] = {sw6_b0, sw6_b1, sw6_b2, sw6_b3};

    sbox u_sw7_b0(.in(w[27][23:16]), .out(sw7_b0));
    sbox u_sw7_b1(.in(w[27][15:8]),  .out(sw7_b1));
    sbox u_sw7_b2(.in(w[27][7:0]),   .out(sw7_b2));
    sbox u_sw7_b3(.in(w[27][31:24]), .out(sw7_b3));
    assign subrot[7] = {sw7_b0, sw7_b1, sw7_b2, sw7_b3};

    sbox u_sw8_b0(.in(w[31][23:16]), .out(sw8_b0));
    sbox u_sw8_b1(.in(w[31][15:8]),  .out(sw8_b1));
    sbox u_sw8_b2(.in(w[31][7:0]),   .out(sw8_b2));
    sbox u_sw8_b3(.in(w[31][31:24]), .out(sw8_b3));
    assign subrot[8] = {sw8_b0, sw8_b1, sw8_b2, sw8_b3};

    sbox u_sw9_b0(.in(w[35][23:16]), .out(sw9_b0));
    sbox u_sw9_b1(.in(w[35][15:8]),  .out(sw9_b1));
    sbox u_sw9_b2(.in(w[35][7:0]),   .out(sw9_b2));
    sbox u_sw9_b3(.in(w[35][31:24]), .out(sw9_b3));
    assign subrot[9] = {sw9_b0, sw9_b1, sw9_b2, sw9_b3};

    sbox u_sw10_b0(.in(w[39][23:16]), .out(sw10_b0));
    sbox u_sw10_b1(.in(w[39][15:8]),  .out(sw10_b1));
    sbox u_sw10_b2(.in(w[39][7:0]),   .out(sw10_b2));
    sbox u_sw10_b3(.in(w[39][31:24]), .out(sw10_b3));
    assign subrot[10] = {sw10_b0, sw10_b1, sw10_b2, sw10_b3};


    assign w[4] = w[0] ^ subrot[1] ^ 32'h01000000;
    assign w[5] = w[1] ^ w[4];
    assign w[6] = w[2] ^ w[5];
    assign w[7] = w[3] ^ w[6];
    assign w[8] = w[4] ^ subrot[2] ^ 32'h02000000;
    assign w[9] = w[5] ^ w[8];
    assign w[10] = w[6] ^ w[9];
    assign w[11] = w[7] ^ w[10];
    assign w[12] = w[8] ^ subrot[3] ^ 32'h04000000;
    assign w[13] = w[9] ^ w[12];
    assign w[14] = w[10] ^ w[13];
    assign w[15] = w[11] ^ w[14];
    assign w[16] = w[12] ^ subrot[4] ^ 32'h08000000;
    assign w[17] = w[13] ^ w[16];
    assign w[18] = w[14] ^ w[17];
    assign w[19] = w[15] ^ w[18];
    assign w[20] = w[16] ^ subrot[5] ^ 32'h10000000;
    assign w[21] = w[17] ^ w[20];
    assign w[22] = w[18] ^ w[21];
    assign w[23] = w[19] ^ w[22];
    assign w[24] = w[20] ^ subrot[6] ^ 32'h20000000;
    assign w[25] = w[21] ^ w[24];
    assign w[26] = w[22] ^ w[25];
    assign w[27] = w[23] ^ w[26];
    assign w[28] = w[24] ^ subrot[7] ^ 32'h40000000;
    assign w[29] = w[25] ^ w[28];
    assign w[30] = w[26] ^ w[29];
    assign w[31] = w[27] ^ w[30];
    assign w[32] = w[28] ^ subrot[8] ^ 32'h80000000;
    assign w[33] = w[29] ^ w[32];
    assign w[34] = w[30] ^ w[33];
    assign w[35] = w[31] ^ w[34];
    assign w[36] = w[32] ^ subrot[9] ^ 32'h1b000000;
    assign w[37] = w[33] ^ w[36];
    assign w[38] = w[34] ^ w[37];
    assign w[39] = w[35] ^ w[38];
    assign w[40] = w[36] ^ subrot[10] ^ 32'h36000000;
    assign w[41] = w[37] ^ w[40];
    assign w[42] = w[38] ^ w[41];
    assign w[43] = w[39] ^ w[42];

    assign key_schedule[1407:1280] = {w[0], w[1], w[2], w[3]};
    assign key_schedule[1279:1152] = {w[4], w[5], w[6], w[7]};
    assign key_schedule[1151:1024] = {w[8], w[9], w[10], w[11]};
    assign key_schedule[1023:896] = {w[12], w[13], w[14], w[15]};
    assign key_schedule[895:768] = {w[16], w[17], w[18], w[19]};
    assign key_schedule[767:640] = {w[20], w[21], w[22], w[23]};
    assign key_schedule[639:512] = {w[24], w[25], w[26], w[27]};
    assign key_schedule[511:384] = {w[28], w[29], w[30], w[31]};
    assign key_schedule[383:256] = {w[32], w[33], w[34], w[35]};
    assign key_schedule[255:128] = {w[36], w[37], w[38], w[39]};
    assign key_schedule[127:0] = {w[40], w[41], w[42], w[43]};

endmodule