/**
 * key_expansion.v - AES-128 Key Expansion
 * Generates 11 round keys from initial 128-bit key
 */
module key_expansion (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        key_expand_en,
    input  wire [127:0] cipher_key,
    output reg  [127:0] round_key [0:10]
);

// Rcon for AES-128 (10 rounds)
wire [31:0] rcon [0:10];
assign rcon[0]  = 32'h00000000;
assign rcon[1]  = 32'h01000000;
assign rcon[2]  = 32'h02000000;
assign rcon[3]  = 32'h04000000;
assign rcon[4]  = 32'h08000000;
assign rcon[5]  = 32'h10000000;
assign rcon[6]  = 32'h20000000;
assign rcon[7]  = 32'h40000000;
assign rcon[8]  = 32'h80000000;
assign rcon[9]  = 32'h1b000000;
assign rcon[10] = 32'h36000000;

// Internal registers for key expansion
reg [31:0] w [0:43];  // 44 words for AES-128
integer i;

// SubWord function using S-Box
function [31:0] subword;
    input [31:0] word;
    reg [7:0] sb_out [0:3];
    integer j;
    begin
        for (j = 0; j < 4; j = j + 1) begin
            sbox u_sbox (
                .addr(word[8*j +: 8]),
                .data(sb_out[j])
            );
        end
        subword = {sb_out[3], sb_out[2], sb_out[1], sb_out[0]};
    end
endfunction

// RotWord function
function [31:0] rotword;
    input [31:0] word;
    begin
        rotword = {word[23:0], word[31:24]};
    end
endfunction

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 44; i = i + 1) begin
            w[i] <= 32'h0;
        end
    end else if (key_expand_en) begin
        // Initialize first 4 words with cipher key
        w[0] <= cipher_key[127:96];
        w[1] <= cipher_key[95:64];
        w[2] <= cipher_key[63:32];
        w[3] <= cipher_key[31:0];
        
        // Generate remaining words
        for (i = 4; i < 44; i = i + 4) begin
            w[i]   <= w[i-4] ^ subword(rotword(w[i-1])) ^ rcon[i/4];
            w[i+1] <= w[i-3] ^ w[i];
            w[i+2] <= w[i-2] ^ w[i+1];
            w[i+3] <= w[i-1] ^ w[i+2];
        end
    end
end

// Assign round keys (each 4 words)
always @(*) begin
    for (i = 0; i <= 10; i = i + 1) begin
        round_key[i] = {w[4*i], w[4*i+1], w[4*i+2], w[4*i+3]};
    end
end

endmodule