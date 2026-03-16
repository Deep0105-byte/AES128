module aes_controller (
    input clk, rst, start,
    output reg [3:0] round,
    output reg busy, done,
    output reg load_init, load_round
);
    parameter IDLE = 2'b00, INIT = 2'b01, WORK = 2'b10, DONE = 2'b11;
    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            round <= 0;
            busy <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        state <= INIT;
                        busy <= 1;
                    end
                end
                INIT: begin
                    load_init <= 1;
                    round <= 0;
                    state <= WORK;
                end
                WORK: begin
                    load_init <= 0;
                    if (round == 10) begin
                        state <= DONE;
                    end else begin
                        round <= round + 1;
                    end
                end
                DONE: begin
                    busy <= 0;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule