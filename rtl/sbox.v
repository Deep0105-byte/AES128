module sbox(
input  [7:0] in,
output reg [7:0] out
);

always @(*) begin
case(in)

8'h00: out = 8'h63;
8'h01: out = 8'h7c;
8'h02: out = 8'h77;
8'h03: out = 8'h7b;
8'h04: out = 8'hf2;
8'h05: out = 8'h6b;
8'h06: out = 8'h6f;
8'h07: out = 8'hc5;
8'h08: out = 8'h30;
8'h09: out = 8'h01;
8'h0a: out = 8'h67;
8'h0b: out = 8'h2b;
8'h0c: out = 8'hfe;
8'h0d: out = 8'hd7;
8'h0e: out = 8'hab;
8'h0f: out = 8'h76;

default: out = 8'h00;

endcase
end

endmodule