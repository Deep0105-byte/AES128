timescale 1ns/1ps
// AES Controller FSM
// States: IDLE -> INIT -> ROUND (x10) -> DONE
module aes_controller (
    input        clk,
    input        rst_n,
    input        start,
    output reg   done,
    output reg [3:0] round_num,   // 0-10
    output reg   state_we,        // write-enable for state register
    output reg   is_final_round,  // suppress MixColumns when asserted
    output reg   load_init        // load plaintext XOR key[0]
);
    localparam IDLE  = 2'd0,
               INIT  = 2'd1,
               ROUND = 2'd2,
               DONE  = 2'd3;

    reg [1:0] cs, ns;

    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cs <= IDLE;
        else        cs <= ns;
    end

    // Next-state logic
    always @(*) begin
        ns = cs;
        case (cs)
            IDLE:  if (start) ns = INIT;
            INIT:  ns = ROUND;
            ROUND: ns = (round_num == 4'd10) ? DONE : ROUND;
            DONE:  ns = IDLE;
        endcase
    end

    // Output logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done          <= 1'b0;
            round_num     <= 4'd0;
            state_we      <= 1'b0;
            is_final_round<= 1'b0;
            load_init     <= 1'b0;
        end else begin
            done          <= 1'b0;
            state_we      <= 1'b0;
            load_init     <= 1'b0;
            is_final_round<= 1'b0;

            case (cs)
                IDLE: begin
                    round_num <= 4'd0;
                end

                INIT: begin
                    load_init  <= 1'b1;
                    state_we   <= 1'b1;
                    round_num  <= 4'd1;
                end

                ROUND: begin
                    is_final_round <= (round_num == 4'd10);
                    state_we       <= 1'b1;
                    if (round_num < 4'd10)
                        round_num <= round_num + 4'd1;
                end

                DONE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end
endmodule