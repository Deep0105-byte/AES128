module mixcolumns(
input  [127:0] state_in,
output [127:0] state_out
);

function [7:0] xtime;
input [7:0] x;
begin
xtime = (x<<1) ^ ((x[7]) ? 8'h1b : 8'h00);
end
endfunction

function [7:0] mul2;
input [7:0] x;
begin
mul2 = xtime(x);
end
endfunction

function [7:0] mul3;
input [7:0] x;
begin
mul3 = xtime(x) ^ x;
end
endfunction

wire [7:0] s [0:15];
wire [7:0] r [0:15];

genvar i;

generate
for(i=0;i<16;i=i+1)
assign s[i] = state_in[127 - i*8 -: 8];
endgenerate

/* column 0 */
assign r[0] = mul2(s[0]) ^ mul3(s[1]) ^ s[2] ^ s[3];
assign r[1] = s[0] ^ mul2(s[1]) ^ mul3(s[2]) ^ s[3];
assign r[2] = s[0] ^ s[1] ^ mul2(s[2]) ^ mul3(s[3]);
assign r[3] = mul3(s[0]) ^ s[1] ^ s[2] ^ mul2(s[3]);

/* column 1 */
assign r[4] = mul2(s[4]) ^ mul3(s[5]) ^ s[6] ^ s[7];
assign r[5] = s[4] ^ mul2(s[5]) ^ mul3(s[6]) ^ s[7];
assign r[6] = s[4] ^ s[5] ^ mul2(s[6]) ^ mul3(s[7]);
assign r[7] = mul3(s[4]) ^ s[5] ^ s[6] ^ mul2(s[7]);

/* column 2 */
assign r[8]  = mul2(s[8]) ^ mul3(s[9]) ^ s[10] ^ s[11];
assign r[9]  = s[8] ^ mul2(s[9]) ^ mul3(s[10]) ^ s[11];
assign r[10] = s[8] ^ s[9] ^ mul2(s[10]) ^ mul3(s[11]);
assign r[11] = mul3(s[8]) ^ s[9] ^ s[10] ^ mul2(s[11]);

/* column 3 */
assign r[12] = mul2(s[12]) ^ mul3(s[13]) ^ s[14] ^ s[15];
assign r[13] = s[12] ^ mul2(s[13]) ^ mul3(s[14]) ^ s[15];
assign r[14] = s[12] ^ s[13] ^ mul2(s[14]) ^ mul3(s[15]);
assign r[15] = mul3(s[12]) ^ s[13] ^ s[14] ^ mul2(s[15]);

generate
for(i=0;i<16;i=i+1)
assign state_out[127 - i*8 -: 8] = r[i];
endgenerate

endmodule