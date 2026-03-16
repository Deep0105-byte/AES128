 /**
 * aes_top.v - Top module for AES-128 iterative architecture
 */
module aes_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    output reg  [127:0] ciphertext,
    output reg         done,
    output reg  [3:0]  round_num
);

// Internal signals
wire [127:0] round_key [0:10];
wire [127:0] state_in;
wire [127:0] state_out;
wire [127:0] subbytes_out;
wire [127:0] shiftrows_out;
wire [127:0] mixcolumns_out;
wire [127:0] addroundkey_out;
wire [127:0] selected_round_key;

// Control signals
wire        busy;
wire        round_key_sel;
wire        state_ld_en;
wire        round_done;
wire [3:0]  round_count;
wire        skip_mixcolumns;
wire        key_expand_en;

// State register
reg [127:0] state_reg;

// Round key selection (0 for initial, 1 for rounds 1-10)
assign selected_round_key = round_key_sel ? round_key[round_count] : round_key[0];

// Datapath connections
assign state_in = (round_count == 4'h0 && start) ? (plaintext ^ key) : addroundkey_out;

// SubBytes
subbytes u_subbytes (
    .clk(clk),
    .data_in(state_reg),
    .data_out(subbytes_out)
);

// ShiftRows
shiftrows u_shiftrows (
    .data_in(subbytes_out),
    .data_out(shiftrows_out)
);

// MixColumns (bypassed in final round)
mixcolumns u_mixcolumns (
    .data_in(shiftrows_out),
    .data_out(mixcolumns_out)
);

// AddRoundKey
addroundkey u_addroundkey (
    .state(skip_mixcolumns ? shiftrows_out : mixcolumns_out),
    .round_key(selected_round_key),
    .state_out(addroundkey_out)
);

// Key Expansion
key_expansion u_key_expansion (
    .clk(clk),
    .rst_n(rst_n),
    .key_expand_en(key_expand_en),
    .cipher_key(key),
    .round_key(round_key)
);

// Controller
aes_controller u_controller (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .busy(busy),
    .round_key_sel(round_key_sel),
    .state_ld_en(state_ld_en),
    .round_done(round_done),
    .round_count(round_count),
    .skip_mixcolumns(skip_mixcolumns),
    .key_expand_en(key_expand_en)
);

// State register update
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state_reg <= 128'h0;
    end else if (state_ld_en) begin
        state_reg <= state_in;
    end
end

// Output registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ciphertext <= 128'h0;
        done <= 1'b0;
        round_num <= 4'h0;
    end else begin
        round_num <= round_count;
        
        if (round_done && round_count == 4'hA) begin
            ciphertext <= state_reg;
            done <= 1'b1;
        end else begin
            done <= 1'b0;
        end
    end
end

endmodule