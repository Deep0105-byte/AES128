module subbytes(
input [127:0] state_in,
output [127:0] state_out
);

genvar i;

generate
for(i=0;i<16;i=i+1)
begin : sboxes
    sbox s(
        .a(state_in[i*8 +: 8]),
        .d(state_out[i*8 +: 8])
    );
end
endgenerate

endmodule