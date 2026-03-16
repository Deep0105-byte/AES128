`timescale 1ns/1ps
// AES-128 Top Module – iterative (rolling) architecture
// One round datapath reused across 10 rounds
// State stored in column-major 4x4 byte matrix as a 128-bit register
module aes_top (
    input         clk,
    input         rst_n,
    input         start,
    input  [127:0] plaintext,
    input  [127:0] key,
    output [127:0] ciphertext,
    output         done
);
    // ── Key Schedule ──────────────────────────────────────────────
    wire [1407:0] key_schedule;
    key_expansion u_kexp (
        .key          (key),
        .key_schedule (key_schedule)
    );

    // Extract round key rk[r] = key_schedule[1407-r*128 -: 128]
    // rk[0] is the initial whitening key
    function [127:0] get_rk;
        input [3:0] r;
        input [1407:0] ks;
        begin
            get_rk = ks[1407 - r*128 -: 128];
        end
    endfunction

    // ── Controller ────────────────────────────────────────────────
    wire        done_w;
    wire [3:0]  round_num;
    wire        state_we;
    wire        is_final_round;
    wire        load_init;

    aes_controller u_ctrl (
        .clk           (clk),
        .rst_n         (rst_n),
        .start         (start),
        .done          (done_w),
        .round_num     (round_num),
        .state_we      (state_we),
        .is_final_round(is_final_round),
        .load_init     (load_init)
    );

    // ── State Register ────────────────────────────────────────────
    reg  [127:0] state;

    // ── Combinational Round Datapath ──────────────────────────────
    wire [127:0] rk_init   = key_schedule[1407:1280]; // rk[0]
    wire [127:0] rk_curr;

    // Mux round key based on round_num
    // During INIT load_init=1: we use rk[0] (AddRoundKey only)
    // During ROUND: use rk[round_num] (1-10)
    assign rk_curr = key_schedule[1407 - round_num*128 -: 128];

    // Pipeline: state -> SubBytes -> ShiftRows -> (MixColumns) -> AddRoundKey
    wire [127:0] after_sb, after_sr, after_mc, after_ark;

    subbytes   u_sb  (.state_in(state),    .state_out(after_sb));
    shiftrows  u_sr  (.state_in(after_sb), .state_out(after_sr));
    mixcolumns u_mc  (.state_in(after_sr), .state_out(after_mc));

    // Skip MixColumns in final round
    wire [127:0] before_ark = is_final_round ? after_sr : after_mc;
    addroundkey u_ark (.state_in(before_ark), .round_key(rk_curr), .state_out(after_ark));

    // Initial AddRoundKey (plaintext XOR rk[0])
    wire [127:0] init_state = plaintext ^ rk_init;

    // ── State Register Update ─────────────────────────────────────
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= 128'b0;
        else if (state_we) begin
            if (load_init)
                state <= init_state;
            else
                state <= after_ark;
        end
    end

    assign ciphertext = state;
    assign done       = done_w;
endmodule