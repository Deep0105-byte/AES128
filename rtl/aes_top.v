module aes_top(
    input clk,
    input reset,
    input start,

    input  [127:0] plaintext,
    input  [127:0] key,

    output reg [127:0] ciphertext,
    output done
);

reg [127:0] state;

wire [127:0] sb_out;
wire [127:0] sr_out;
wire [127:0] mc_out;
wire [127:0] ark_out;
wire [127:0] round_key;

wire mix_en;
wire load_init;
wire state_en;
wire [3:0] round;

aes_controller CTRL(
    .clk(clk),
    .reset(reset),
    .start(start),
    .round(round),
    .mix_en(mix_en),
    .load_init(load_init),
    .state_en(state_en),
    .done(done)
);

key_expansion KEYGEN(
    .key(key),
    .round(round),
    .round_key(round_key)
);

subbytes SB(
    .state_in(state),
    .state_out(sb_out)
);

shiftrows SR(
    .state_in(sb_out),
    .state_out(sr_out)
);

mixcolumns MC(
    .state_in(sr_out),
    .state_out(mc_out)
);

wire [127:0] mix_mux;
assign mix_mux = mix_en ? mc_out : sr_out;

addroundkey ARK(
    .state_in(mix_mux),
    .round_key(round_key),
    .state_out(ark_out)
);

always @(posedge clk or posedge reset)
begin
    if(reset)
        state <= 0;
    else if(load_init)
        state <= plaintext ^ key;
    else if(state_en)
        state <= ark_out;
end

always @(posedge clk)
begin
    if(done)
        ciphertext <= state;
end

endmodule