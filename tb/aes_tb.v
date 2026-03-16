`timescale 1ns/1ps

module aes_tb;
    reg clk, rst, start;
    reg [127:0] plaintext, key;
    wire [127:0] ciphertext;
    wire done;
    wire [3:0] round;

    aes_top uut (
        .clk(clk), .rst(rst), .start(start),
        .plaintext(plaintext), .key(key),
        .ciphertext(ciphertext), .done(done), .round_out(round)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; start = 0;
        plaintext = 128'h00112233445566778899aabbccddeeff;
        key       = 128'h000102030405060708090a0b0c0d0e0f;

        #20 rst = 0;
        #20 start = 1;
        #10 start = 0;

        $display("--- AES-128 Iterative Core Test ---");
        $display("Plaintext: %h", plaintext);
        $display("Key:       %h", key);

        wait(done);
        $display("Final Ciphertext: %h", ciphertext);
        
        if (ciphertext == 128'h69c4e0d86a7b0430d8cdb78070b4c55a)
            $display("SUCCESS: Test Vector Matches!");
        else
            $display("FAILURE: Expected 69c4e0d86a7b0430d8cdb78070b4c55a");
        
        $finish;
    end

    always @(posedge clk) begin
        if (!done && round > 0)
            $display("Round %0d processing...", round);
    end
endmodule