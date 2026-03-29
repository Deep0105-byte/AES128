module sbox_tb;

reg [7:0] in;
wire [7:0] out;

sbox uut(
.in(in),
.out(out)
);

initial begin

in = 8'h00; #10;
$display("SBOX(00) = %h", out);

in = 8'h01; #10;
$display("SBOX(01) = %h", out);

in = 8'h02; #10;
$display("SBOX(02) = %h", out);

$finish;

end

endmodule