module mixcolumns(
input  [127:0] state_in,
output [127:0] state_out
);

function [7:0] xtime;
input [7:0] b;
begin
xtime = (b<<1) ^ (8'h1b & {8{b[7]}});
end
endfunction

function [7:0] mul3;
input [7:0] b;
begin
mul3 = xtime(b) ^ b;
end
endfunction

wire [7:0] s[15:0];
wire [7:0] r[15:0];

genvar i;

generate
for(i=0;i<16;i=i+1)
assign s[i] = state_in[i*8 +: 8];
endgenerate

assign r[0] = xtime(s[0]) ^ mul3(s[1]) ^ s[2] ^ s[3];
assign r[1] = s[0] ^ xtime(s[1]) ^ mul3(s[2]) ^ s[3];
assign r[2] = s[0] ^ s[1] ^ xtime(s[2]) ^ mul3(s[3]);
assign r[3] = mul3(s[0]) ^ s[1] ^ s[2] ^ xtime(s[3]);

assign r[4] = xtime(s[4]) ^ mul3(s[5]) ^ s[6] ^ s[7];
assign r[5] = s[4] ^ xtime(s[5]) ^ mul3(s[6]) ^ s[7];
assign r[6] = s[4] ^ s[5] ^ xtime(s[6]) ^ mul3(s[7]);
assign r[7] = mul3(s[4]) ^ s[5] ^ s[6] ^ xtime(s[7]);

assign r[8] = xtime(s[8]) ^ mul3(s[9]) ^ s[10] ^ s[11];
assign r[9] = s[8] ^ xtime(s[9]) ^ mul3(s[10]) ^ s[11];
assign r[10] = s[8] ^ s[9] ^ xtime(s[10]) ^ mul3(s[11]);
assign r[11] = mul3(s[8]) ^ s[9] ^ s[10] ^ xtime(s[11]);

assign r[12] = xtime(s[12]) ^ mul3(s[13]) ^ s[14] ^ s[15];
assign r[13] = s[12] ^ xtime(s[13]) ^ mul3(s[14]) ^ s[15];
assign r[14] = s[12] ^ s[13] ^ xtime(s[14]) ^ mul3(s[15]);
assign r[15] = mul3(s[12]) ^ s[13] ^ s[14] ^ xtime(s[15]);

generate
for(i=0;i<16;i=i+1)
assign state_out[i*8 +: 8] = r[i];
endgenerate

endmodule