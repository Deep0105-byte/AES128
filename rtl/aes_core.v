// aes_core.v - AES-128 Encryption Core
module aes_core (
    input         clk,
    input         rst,
    input  [127:0] plaintext,
    input  [1407:0] round_keys,
    input         start,
    output reg [127:0] ciphertext,
    output reg    done
);
    // State and control
    reg [127:0] state;
    reg [3:0] round;
    reg [2:0] current_state;
    
    // Module instances
    wire [127:0] subbytes_out, shiftrows_out, mixcolumns_out;
    wire [127:0] addroundkey_out;
    
    // SubBytes
    generate
        genvar i;
        for (i = 0; i < 16; i = i + 1) begin : sbox_gen
            sbox sbox_inst (
                .data_in(state[127 - 8*i -: 8]),
                .data_out(subbytes_out[127 - 8*i -: 8])
            );
        end
    endgenerate
    
    // ShiftRows
    shift_rows shift_rows_inst (
        .state_in(subbytes_out),
        .state_out(shiftrows_out)
    );
    
    // MixColumns
    mix_columns mix_columns_inst (
        .state_in(shiftrows_out),
        .state_out(mixcolumns_out)
    );
    
    // AddRoundKey
    assign addroundkey_out = state ^ round_keys[1407 - 128*round -: 128];
    
    // FSM states
    localparam IDLE = 3'd0,
               ADD_ROUND_KEY_0 = 3'd1,
               ROUNDS = 3'd2,
               FINAL_ROUND = 3'd3,
               DONE_STATE = 3'd4;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 128'd0;
            round <= 4'd0;
            ciphertext <= 128'd0;
            done <= 1'b0;
            current_state <= IDLE;
        end
        else begin
            case (current_state)
                IDLE: begin
                    if (start) begin
                        state <= plaintext;
                        round <= 4'd0;
                        done <= 1'b0;
                        current_state <= ADD_ROUND_KEY_0;
                    end
                end
                
                ADD_ROUND_KEY_0: begin
                    // Initial AddRoundKey
                    state <= plaintext ^ round_keys[1407:1280];
                    round <= 4'd1;
                    current_state <= ROUNDS;
                end
                
                ROUNDS: begin
                    if (round < 4'd10) begin
                        // SubBytes -> ShiftRows -> MixColumns -> AddRoundKey
                        state <= mixcolumns_out ^ round_keys[1407 - 128*round -: 128];
                        round <= round + 1;
                    end
                    else begin
                        current_state <= FINAL_ROUND;
                    end
                end
                
                FINAL_ROUND: begin
                    // Last round: no MixColumns
                    state <= shiftrows_out ^ round_keys[1407 - 128*round -: 128];
                    current_state <= DONE_STATE;
                end
                
                DONE_STATE: begin
                    ciphertext <= state;
                    done <= 1'b1;
                    current_state <= IDLE;
                end
                
                default: current_state <= IDLE;
            endcase
        end
    end
endmodule