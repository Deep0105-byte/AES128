// tb_aes_top.v - Testbench for AES-128
`timescale 1ns / 1ps

module tb_aes_top;
    reg clk;
    reg rst;
    reg [127:0] key;
    reg [127:0] plaintext;
    reg start;
    wire [127:0] ciphertext;
    wire ready;
    
    // Expected results (NIST FIPS-197 test vector)
    localparam EXPECTED = 128'h3925841d02dc09fbdc118597196a0b32;
    
    // Instantiate DUT
    aes_top dut (
        .clk(clk),
        .rst(rst),
        .key(key),
        .plaintext(plaintext),
        .start(start),
        .ciphertext(ciphertext),
        .ready(ready)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        plaintext = 128'h3243f6a8885a308d313198a2e0370734;
        start = 0;
        
        // Reset
        #20 rst = 0;
        
        // Start encryption
        #10 start = 1;
        #10 start = 0;
        
        // Wait for completion
        wait(ready);
        #10;
        
        // Check result
        if (ciphertext == EXPECTED) begin
            $display("TEST PASSED!");
            $display("Ciphertext: %h", ciphertext);
            $display("Expected:   %h", EXPECTED);
        end
        else begin
            $display("TEST FAILED!");
            $display("Got:      %h", ciphertext);
            $display("Expected: %h", EXPECTED);
        end
        
        #50 $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time=%t, ready=%b, ciphertext=%h", $time, ready, ciphertext);
    end
endmodule