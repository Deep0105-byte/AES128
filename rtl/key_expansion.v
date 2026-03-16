module key_expansion(
input  [127:0] key,
input  [3:0]   round,
output [127:0] round_key
);

reg [31:0] w[0:43];
integer i;

function [31:0] rcon;
input [3:0] r;
begin
case(r)
1:  rcon = 32'h01000000;
2:  rcon = 32'h02000000;
3:  rcon = 32'h04000000;
4:  rcon = 32'h08000000;
5:  rcon = 32'h10000000;
6:  rcon = 32'h20000000;
7:  rcon = 32'h40000000;
8:  rcon = 32'h80000000;
9:  rcon = 32'h1b000000;
10: rcon = 32'h36000000;
default: rcon = 32'h00000000;
endcase
end
endfunction

function [7:0] sbox;
input [7:0] a;
begin
case(a)
8'h00: sbox=8'h63; 8'h01: sbox=8'h7c; 8'h02: sbox=8'h77; 8'h03: sbox=8'h7b;
8'h04: sbox=8'hf2; 8'h05: sbox=8'h6b; 8'h06: sbox=8'h6f; 8'h07: sbox=8'hc5;
8'h08: sbox=8'h30; 8'h09: sbox=8'h01; 8'h0a: sbox=8'h67; 8'h0b: sbox=8'h2b;
default: sbox=8'h00;
endcase
end
endfunction

function [31:0] subword;
input [31:0] w;
begin
subword = {sbox(w[31:24]),sbox(w[23:16]),sbox(w[15:8]),sbox(w[7:0])};
end
endfunction

function [31:0] rotword;
input [31:0] w;
begin
rotword = {w[23:0],w[31:24]};
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
        w[i] = w[i-4] ^ subword(rotword(w[i-1])) ^ rcon(i/4);
    else
        w[i] = w[i-4] ^ w[i-1];
end

end

assign round_key =
(round==0)  ? {w[0],w[1],w[2],w[3]} :
(round==1)  ? {w[4],w[5],w[6],w[7]} :
(round==2)  ? {w[8],w[9],w[10],w[11]} :
(round==3)  ? {w[12],w[13],w[14],w[15]} :
(round==4)  ? {w[16],w[17],w[18],w[19]} :
(round==5)  ? {w[20],w[21],w[22],w[23]} :
(round==6)  ? {w[24],w[25],w[26],w[27]} :
(round==7)  ? {w[28],w[29],w[30],w[31]} :
(round==8)  ? {w[32],w[33],w[34],w[35]} :
(round==9)  ? {w[36],w[37],w[38],w[39]} :
              {w[40],w[41],w[42],w[43]};

endmodule