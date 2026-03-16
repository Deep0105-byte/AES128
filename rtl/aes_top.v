module aes_top(
input clk,
input reset,
input start,

input  [127:0] plaintext,
input  [127:0] key,

output reg [127:0] ciphertext,
output reg done
);

reg [127:0] state;
wire [127:0] sb_out;
wire [127:0] sr_out;
wire [127:0] mc_out;
wire [127:0] round_key;
wire [127:0] mix_mux;
wire [127:0] next_state;

reg [3:0] round;

/* SubBytes */
subbytes SB(
.state_in(state),
.state_out(sb_out)
);

/* ShiftRows */
shiftrows SR(
.state_in(sb_out),
.state_out(sr_out)
);

/* MixColumns */
mixcolumns MC(
.state_in(sr_out),
.state_out(mc_out)
);

/* Key Expansion */
key_expansion KE(
.key(key),
.round(round),
.round_key(round_key)
);

/* Disable MixColumns in final round */
assign mix_mux = (round == 10) ? sr_out : mc_out;

/* AddRoundKey */
addroundkey ARK(
.state_in(mix_mux),
.round_key(round_key),
.state_out(next_state)
);

/* AES Control */
always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        state <= 128'b0;
        round <= 0;
        done <= 0;
        ciphertext <= 0;
    end

    else if(start)
    begin
        state <= plaintext ^ key;   // Initial AddRoundKey
        round <= 1;
        done <= 0;
    end

    else if(round <= 10)
    begin
        state <= next_state;
        round <= round + 1;
    end

    else if(round == 11)
    begin
        ciphertext <= state;
        done <= 1;
    end
end

endmodule