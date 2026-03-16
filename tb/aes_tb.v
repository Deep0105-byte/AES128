`timescale 1ns/1ps
module aes_tb;

    reg         clk, rst_n, start;
    reg  [127:0] plaintext, key;
    wire [127:0] ciphertext;
    wire         done;

    aes_top dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .plaintext  (plaintext),
        .key        (key),
        .ciphertext (ciphertext),
        .done       (done)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("SIM START at time=%0t", $time);

        plaintext = 128'h00112233445566778899aabbccddeeff;
        key       = 128'h000102030405060708090a0b0c0d0e0f;
        rst_n     = 0;
        start     = 0;

        // Reset
        #20;
        rst_n = 1;
        $display("Reset released at time=%0t", $time);

        // Start
        #10;
        start = 1;
        #10;
        start = 0;
        $display("Start pulsed at time=%0t", $time);

        // Wait fixed time (no event-driven wait)
        #200;

        $display("=== RESULT AT time=%0t ===", $time);
        $display("ciphertext = %032h", ciphertext);
        $display("done       = %b",    done);
        $display("state      = %032h", dut.state);

        if (ciphertext === 128'h69c4e0d86a7b0430d8cdb78070b4c55a)
            $display("PASS - AES encryption correct!");
        else
            $display("FAIL - got %032h, expected 69c4e0d86a7b0430d8cdb78070b4c55a", ciphertext);

        $finish;
    end

endmodule
