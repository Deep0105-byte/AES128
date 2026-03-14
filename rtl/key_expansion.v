module key_expansion(
    input  [127:0] key,
    input  [3:0]   round,
    output [127:0] round_key
);

wire [31:0] w[0:43];

assign w[0] = key[127:96];
assign w[1] = key[95:64];
assign w[2] = key[63:32];
assign w[3] = key[31:0];

genvar i;

generate
for(i=4;i<44;i=i+1)
begin: key_schedule

    wire [31:0] temp;
    wire [31:0] rot;
    wire [31:0] sub;
    wire [31:0] rcon_val;

    assign temp = w[i-1];

    assign rot = {temp[23:0], temp[31:24]};

    wire [7:0] sb0,sb1,sb2,sb3;

    sbox s0(rot[31:24], sb0);
    sbox s1(rot[23:16], sb1);
    sbox s2(rot[15:8],  sb2);
    sbox s3(rot[7:0],   sb3);

    assign sub = {sb0,sb1,sb2,sb3};

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

    assign rcon_val = rcon(i/4);

    wire [31:0] g;

    assign g = sub ^ rcon_val;

    assign w[i] = (i%4==0) ? w[i-4] ^ g : w[i-4] ^ temp;

end
endgenerate

assign round_key =
    (round==0)  ? {w[0],w[1],w[2],w[3]}   :
    (round==1)  ? {w[4],w[5],w[6],w[7]}   :
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