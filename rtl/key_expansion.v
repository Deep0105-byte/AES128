// key_expansion.v - AES-128 Key Expansion
module key_expansion (
    input         clk,
    input         rst,
    input  [127:0] cipher_key,
    input         key_valid,
    output [1407:0] round_keys,
    output        key_ready
);
    // Round constants
    localparam [31:0] Rcon [0:9] = '{
        32'h01000000, 32'h02000000, 32'h04000000, 32'h08000000,
        32'h10000000, 32'h20000000, 32'h40000000, 32'h80000000,
        32'h1b000000, 32'h36000000
    };
    
    reg [127:0] w [0:43];
    reg [3:0] round;
    reg ready;
    
    // S-box instance for key expansion
    wire [7:0] sbox_out0, sbox_out1, sbox_out2, sbox_out3;
    sbox sbox0 (.data_in(w[round*4+3][23:16]), .data_out(sbox_out0));
    sbox sbox1 (.data_in(w[round*4+3][15:8]),  .data_out(sbox_out1));
    sbox sbox2 (.data_in(w[round*4+3][7:0]),   .data_out(sbox_out2));
    sbox sbox3 (.data_in(w[round*4+3][31:24]), .data_out(sbox_out3));
    
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            round <= 0;
            ready <= 0;
            for (i = 0; i < 44; i = i + 1) w[i] <= 128'd0;
        end
        else if (key_valid && !ready) begin
            // Initial key
            w[0] <= cipher_key;
            
            // Generate all round keys
            for (i = 1; i < 44; i = i + 1) begin
                if (i % 4 == 0) begin
                    // RotWord + SubWord + Rcon
                    w[i] <= w[i-4] ^ 
                           {sbox_out3, sbox_out0, sbox_out1, sbox_out2} ^ 
                           {Rcon[(i/4)-1], 32'd0};
                end
                else begin
                    w[i] <= w[i-4] ^ w[i-1];
                end
            end
            
            ready <= 1;
        end
    end
    
    // Combine round keys (11 rounds * 128 bits)
    generate
        genvar r;
        for (r = 0; r < 11; r = r + 1) begin : key_combine
            assign round_keys[1407 - 128*r -: 128] = {w[r*4+3], w[r*4+2], w[r*4+1], w[r*4]};
        end
    endgenerate
    
    assign key_ready = ready;
endmodule