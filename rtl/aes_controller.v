`timescale 1ns/1ps
// aes_controller.v – AES FSM Controller
// States: IDLE → INIT → ROUND(1-10) → DONE → IDLE
module aes_controller (
    input            clk,
    input            rst_n,       // active-low reset
    input            start,
    output reg       done,
    output reg [3:0] round_num,   // current round: 1-10 during ROUND state
    output reg       state_we,    // write-enable for state register
    output reg       is_final,    // high during round 10 (suppress MixColumns)
    output reg       load_init    // high during INIT (load plaintext XOR rk0)
);
    localparam IDLE  = 2'd0,
               INIT  = 2'd1,
               ROUND = 2'd2,
               DONE  = 2'd3;

    reg [1:0] cs, ns;

    // ── State Register ────────────────────────────────────────────
    always @(posedge clk or negedge rst_n)
        if (!rst_n) cs <= IDLE;
        else        cs <= ns;

    // ── Next-State Logic ──────────────────────────────────────────
    always @(*) begin
        ns = cs;
        case (cs)
            IDLE:  if (start)              ns = INIT;
            INIT:                          ns = ROUND;
            ROUND: if (round_num == 4'd10) ns = DONE;
            DONE:                          ns = IDLE;
            default:                       ns = IDLE;
        endcase
    end

    // ── Output Logic (registered) ─────────────────────────────────
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done      <= 1'b0;
            round_num <= 4'd0;
            state_we  <= 1'b0;
            is_final  <= 1'b0;
            load_init <= 1'b0;
        end else begin
            // Default: de-assert all pulses
            done      <= 1'b0;
            state_we  <= 1'b0;
            load_init <= 1'b0;
            is_final  <= 1'b0;

            case (cs)
                IDLE: begin
                    round_num <= 4'd0;
                end

                INIT: begin
                    load_init <= 1'b1;   // initial ARK: plaintext XOR rk[0]
                    state_we  <= 1'b1;
                    round_num <= 4'd1;   // prime round counter for ROUND state
                end

                ROUND: begin
                    state_we <= 1'b1;
                    is_final <= (round_num == 4'd10);
                    if (round_num < 4'd10)
                        round_num <= round_num + 4'd1;
                end

                DONE: begin
                    done <= 1'b1;        // 1-cycle pulse
                end
            endcase
        end
    end
endmodule
