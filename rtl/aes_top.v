module aes_top (
    input clk, rst, start,
    input [127:0] plaintext,
    input [127:0] key,
    output [127:0] ciphertext,
    output done,
    output [3:0] round_out
);
    wire [127:0] state_reg;
    reg  [127:0] state_next;
    wire [3:0] round;
    wire [127:0] round_key;
    
    // Modules
    wire [127:0] sub_out, shift_out, mix_out, add_out;
    wire busy, load_init;

    aes_controller ctrl (.clk(clk), .rst(rst), .start(start), .round(round), .busy(busy), .done(done));
    
    // Datapath
    subbytes   sb (.state_in(state_reg), .state_out(sub_out));
    shiftrows  sr (.state_in(sub_out), .state_out(shift_out));
    mixcolumns mc (.state_in(shift_out), .state_out(mix_out));
    
    // Round Mux: Round 10 skips MixColumns
    wire [127:0] next_to_add = (round == 10) ? shift_out : mix_out;
    addroundkey ark (.state_in(next_to_add), .round_key(round_key), .state_out(add_out));

    // Key expansion instance (simplified for brevity)
    // In a full design, we generate keys for rounds 0-10
    key_expansion_logic ke (.key(key), .round(round), .rk(round_key));

    reg [127:0] state_ff;
    always @(posedge clk) begin
        if (load_init) state_ff <= plaintext ^ round_key; // Round 0
        else if (busy) state_ff <= add_out;
    end

    assign state_reg = state_ff;
    assign ciphertext = state_ff;
    assign round_out = round;

endmodule