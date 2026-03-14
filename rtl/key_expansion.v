module key_expansion(
input  [127:0] key,
input  [3:0] round,
output reg [127:0] round_key
);

reg [31:0] w [0:43];
integer i;

wire [7:0] s0,s1,s2,s3;

function [31:0] rcon;
input [3:0] r;
begin
case(r)
1: rcon = 32'h01000000;
2: rcon = 32'h02000000;
3: rcon = 32'h04000000;
4: rcon = 32'h08000000;
5: rcon = 32'h10000000;
6: rcon = 32'h20000000;
7: rcon = 32'h40000000;
8: rcon = 32'h80000000;
9: rcon = 32'h1b000000;
10: rcon = 32'h36000000;
default: rcon = 32'h00000000;
endcase
end
endfunction

always @(*) begin

w[0] = key[127:96];
w[1] = key[95:64];
w[2] = key[63:32];
w[3] = key[31:0];

for(i=4;i<44;i=i+1)
begin
    if(i%4==0)
    begin
        w[i] = w[i-4] ^
               {s0,s1,s2,s3} ^
               rcon(i/4);
    end
    else
    begin
        w[i] = w[i-4] ^ w[i-1];
    end
end

end

sbox sb0(w[3][23:16], s0);
sbox sb1(w[3][15:8],  s1);
sbox sb2(w[3][7:0],   s2);
sbox sb3(w[3][31:24], s3);

always @(*) begin
case(round)

0: round_key = {w[0],w[1],w[2],w[3]};
1: round_key = {w[4],w[5],w[6],w[7]};
2: round_key = {w[8],w[9],w[10],w[11]};
3: round_key = {w[12],w[13],w[14],w[15]};
4: round_key = {w[16],w[17],w[18],w[19]};
5: round_key = {w[20],w[21],w[22],w[23]};
6: round_key = {w[24],w[25],w[26],w[27]};
7: round_key = {w[28],w[29],w[30],w[31]};
8: round_key = {w[32],w[33],w[34],w[35]};
9: round_key = {w[36],w[37],w[38],w[39]};
10: round_key = {w[40],w[41],w[42],w[43]};

default: round_key = 128'h0;

endcase
end

endmodule