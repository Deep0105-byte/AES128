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

// FSM state encoding
localparam IDLE          = 3'd0;
localparam INIT_ROUND    = 3'd1;
localparam PROCESS_ROUND = 3'd2;
localparam FINAL_ROUND   = 3'd3;
localparam DONE          = 3'd4;

reg [2:0] state, next_state;
reg [3:0] round_counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        round_counter <= 4'h0;
    end else begin
        state <= next_state;
        
        // Update round counter
        case (state)
            IDLE: begin
                if (start) round_counter <= 4'h0;
            end
            
            INIT_ROUND: begin
                round_counter <= 4'h1;
            end
            
            PROCESS_ROUND: begin
                if (round_counter < 4'h9) begin
                    round_counter <= round_counter + 1'b1;
                end else if (round_counter == 4'h9) begin
                    round_counter <= 4'hA;
                end
            end
            
            FINAL_ROUND: begin
                round_counter <= 4'hA;
            end
        endcase
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
            // Initial AddRoundKey (Round 0)
            round_key_sel = 1'b0;  // Use round_key[0]
            state_ld_en = 1'b1;
            next_state = PROCESS_ROUND;
        end
        
        PROCESS_ROUND: begin
            round_key_sel = 1'b1;  // Use subsequent round keys
            state_ld_en = 1'b1;
            
            if (round_counter < 4'h9) begin
                // Rounds 1-9
                skip_mixcolumns = 1'b0;
                next_state = PROCESS_ROUND;
            end else if (round_counter == 4'h9) begin
                // Last normal round, next is final round
                skip_mixcolumns = 1'b0;
                next_state = FINAL_ROUND;
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
        
        default: begin
            next_state = IDLE;
        end
    endcase
end

endmodule