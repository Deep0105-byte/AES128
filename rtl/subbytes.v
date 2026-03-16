/**
 * subbytes.v - Parallel S-Box substitution for 16 bytes
 */
module subbytes (
    input  wire        clk,
    input  wire [127:0] data_in,
    output reg  [127:0] data_out
);

// Generate 16 S-Box instances
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : sbox_inst
        wire [7:0] sbox_in  = data_in[8*i +: 8];
        wire [7:0] sbox_out;
        
        sbox u_sbox (
            .addr(sbox_in),
            .data(sbox_out)
        );
        
        always @(posedge clk) begin
            data_out[8*i +: 8] <= sbox_out;
        end
    end
endgenerate

endmodule