`timescale 1ns/1ps
// aes_top.v – AES-128 Top Module, Iterative (Rolling) Architecture
// One round datapath reused across 10 rounds (area-optimized for FPGA)
// Compliant with NIST FIPS-197 AES-128 specification
//
// Port Map:
//   clk        – clock (rising edge)
//   rst_n      – active-low asynchronous reset
//   start      – pulse high for 1 cycle to begin encryption
//   plaintext  – 128-bit input block
//   key        – 128-bit cipher key
//   ciphertext – 128-bit encrypted output (valid when done=1)
//   done       – 1-cycle pulse when encryption is complete
module aes_top (
    input          clk,
    input          rst_n,
    input          start,
    input  [127:0] plaintext,
    input  [127:0] key,
    output [127:0] ciphertext,
    output         done
);
    // ── Key Schedule (fully combinational) ───────────────────────
    wire [1407:0] key_schedule;
    key_expansion u_kexp (
        .key          (key),
        .key_schedule (key_schedule)
    );

    wire [127:0] rk0 = key_schedule[1407:1280]; // rk[0] always available

    // ── Controller FSM ────────────────────────────────────────────
    wire        done_w;
    wire [3:0]  round_num;
    wire        state_we;
    wire        is_final;
    wire        load_init;

    aes_controller u_ctrl (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (start),
        .done      (done_w),
        .round_num (round_num),
        .state_we  (state_we),
        .is_final  (is_final),
        .load_init (load_init)
    );

    // ── State Register ────────────────────────────────────────────
    reg [127:0] state;

    // ── Current Round Key Mux ─────────────────────────────────────
    // round_num = 1-10 during ROUND state
    wire [127:0] rk_curr = key_schedule[1407 - round_num*128 -: 128];

    // ── Combinational Round Datapath ──────────────────────────────
    wire [127:0] after_sb;
    wire [127:0] after_sr;
    wire [127:0] after_mc;
    wire [127:0] pre_ark;
    wire [127:0] after_ark;

    subbytes   u_sb  (.state_in(state),    .state_out(after_sb));
    shiftrows  u_sr  (.state_in(after_sb), .state_out(after_sr));
    mixcolumns u_mc  (.state_in(after_sr), .state_out(after_mc));

    // Bypass MixColumns in round 10 (final round)
    assign pre_ark = is_final ? after_sr : after_mc;

    addroundkey u_ark (
        .state_in  (pre_ark),
        .round_key (rk_curr),
        .state_out (after_ark)
    );

    // Initial AddRoundKey: plaintext XOR rk[0]
    wire [127:0] init_state = plaintext ^ rk0;

    // ── State Register Update ─────────────────────────────────────
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= 128'b0;
        else if (state_we) begin
            if (load_init)
                state <= init_state;   // Round 0: plaintext XOR rk[0]
            else
                state <= after_ark;    // Rounds 1-10
        end
    end

    assign ciphertext = state;
    assign done       = done_w;

endmodule
