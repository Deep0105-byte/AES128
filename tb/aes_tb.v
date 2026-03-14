module aes_tb;

reg clk;
reg reset;
reg start;

reg [127:0] plaintext;
reg [127:0] key;

wire [127:0] ciphertext;
wire done;

aes_top DUT(
.clk(clk),
.reset(reset),
.start(start),
.plaintext(plaintext),
.key(key),
.ciphertext(ciphertext),
.done(done)
);

initial begin
clk=0;
forever #5 clk=~clk;
end

initial begin

reset=1;
start=0;

plaintext=128'h00112233445566778899aabbccddeeff;
key=128'h000102030405060708090a0b0c0d0e0f;

#20 reset=0;

#10 start=1;
#10 start=0;

#500;
$display("Plaintext  = %h", plaintext);
$display("Key        = %h", key);
$display("Ciphertext = %h", ciphertext);
$display("Round = %d", DUT.CTRL.round);
 $finish;

end

endmodule
