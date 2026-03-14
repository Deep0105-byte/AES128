module aes_controller(
    input clk,
    input reset,
    input start,

    output reg [3:0] round,
    output reg mix_en,
    output reg load_init,
    output reg state_en,
    output reg done
);

reg [2:0] state;

parameter IDLE=0, INIT=1, ROUND=2, FINAL=3, DONE=4;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        state <= IDLE;
        round <= 0;
    end
    else
    begin
        case(state)

        IDLE:
        if(start) state <= INIT;

        INIT:
        begin
            round <= 1;
            state <= ROUND;
        end

        ROUND:
        begin
            if(round==9)
                state <= FINAL;
            else
                round <= round + 1;
        end

        FINAL:
        begin
            round <= 10;
            state <= DONE;
        end

        DONE:
            state <= IDLE;

        endcase
    end
end

always @(*)
begin
    load_init = 0;
    state_en = 0;
    mix_en = 1;
    done = 0;

    case(state)

    INIT:
        load_init = 1;

    ROUND:
        state_en = 1;

    FINAL:
    begin
        state_en = 1;
        mix_en = 0;
    end

    DONE:
        done = 1;

    endcase
end

endmodule