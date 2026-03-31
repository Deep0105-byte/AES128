module sbox(
input  [7:0] in,
output [7:0] out
);

reg [7:0] sbox_mem [0:255];

initial begin
$readmemh("sbox.mem", sbox_mem);
end

assign out = sbox_mem[in];

endmodule