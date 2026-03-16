/**
 * aes_controller.v - FSM for AES iterative rounds
 */
module aes_controller (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    output reg         busy,
    output reg         round_key_sel,
    output reg         state_ld_en,
    output reg         round_done,
    output reg  [3:0]  round_count,
    output reg         skip_mixcolumns,
    output reg         key_expand_en
);

// FSM states
typedef enum logic [2:0] {
    IDLE,
    INIT_ROUND,
    PROCESS_ROUND,
    FINAL_ROUND,
    DONE
} state_t;

state_t state, next_state;

reg [3:0] round_counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        round_counter <= 4'h0;
    end else begin
        state <= next_state;
        
        // Update round counter
        if (state == IDLE && start) begin
            round_counter <= 4'h0;
        end else if (state == PROCESS_ROUND && round_counter < 4'h9) begin
            round_counter <= round_counter + 1'b1;
        end else if (state == PROCESS_ROUND && round_counter == 4'h9) begin
            round_counter <= 4'hA;
        end
    end
end

always @(*) begin
    // Default outputs
    next_state = state;
    busy = 1'b1;
    round_key_sel = 1'b0;
    state_ld_en = 1'b0;
    round_done = 1'b0;
    skip_mixcolumns = 1'b0;
    key_expand_en = 1'b0;
    round_count = round_counter;
    
    case (state)
        IDLE: begin
            busy = 1'b0;
            if (start) begin
                next_state = INIT_ROUND;
                key_expand_en = 1'b1;
            end
        end
        
        INIT_ROUND: begin
            // Initial AddRoundKey
            round_key_sel = 1'b0;  // Use round_key[0]
            state_ld_en = 1'b1;
            next_state = PROCESS_ROUND;
        end
        
        PROCESS_ROUND: begin
            if (round_counter < 4'h9) begin
                // Rounds 1-9
                round_key_sel = 1'b1;
                state_ld_en = 1'b1;
                skip_mixcolumns = 1'b0;
                round_done = (round_counter == 4'h8) ? 1'b1 : 1'b0;
                next_state = (round_counter == 4'h8) ? FINAL_ROUND : PROCESS_ROUND;
            end else begin
                next_state = FINAL_ROUND;
            end
        end
        
        FINAL_ROUND: begin
            // Round 10 - no MixColumns
            round_key_sel = 1'b1;
            state_ld_en = 1'b1;
            skip_mixcolumns = 1'b1;
            round_done = 1'b1;
            next_state = DONE;
        end
        
        DONE: begin
            busy = 1'b0;
            round_done = 1'b0;
            next_state = IDLE;
        end
    endcase
end

endmodule