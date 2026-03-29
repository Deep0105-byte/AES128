module addroundkey_tb;

reg [127:0] state_in;
reg [127:0] round_key;
wire [127:0] state_out;

addroundkey uut(
.state_in(state_in),
.round_key(round_key),
.state_out(state_out)
);

initial begin
state_in  = 128'h00112233445566778899aabbccddeeff;
round_key = 128'h000102030405060708090a0b0c0d0e0f;

#10;

$display("Result = %h", state_out);

$finish;
end

endmodule