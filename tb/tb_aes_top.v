// tb_aes_top.v - Enhanced for VCS with better debugging
`timescale 1ns / 1ps

module tb_aes_top;
    reg clk;
    reg rst;
    reg [127:0] key;
    reg [127:0] plaintext;
    reg start;
    wire [127:0] ciphertext;
    wire ready;
    
    // Test vectors from NIST FIPS-197
    localparam TEST_VECTORS = 3;
    
    // Test data
    reg [127:0] test_key [0:TEST_VECTORS-1];
    reg [127:0] test_plain [0:TEST_VECTORS-1];
    reg [127:0] test_cipher [0:TEST_VECTORS-1];
    
    integer i, errors;
    
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
        // Initialize test vectors
        // Vector 1: NIST test vector
        test_key[0] = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        test_plain[0] = 128'h3243f6a8885a308d313198a2e0370734;
        test_cipher[0] = 128'h3925841d02dc09fbdc118597196a0b32;
        
        // Vector 2: All zeros
        test_key[1] = 128'h00000000000000000000000000000000;
        test_plain[1] = 128'h00000000000000000000000000000000;
        test_cipher[1] = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;
        
        // Vector 3: All ones
        test_key[2] = 128'hffffffffffffffffffffffffffffffff;
        test_plain[2] = 128'hffffffffffffffffffffffffffffffff;
        test_cipher[2] = 128'h1e7e27f2f4f0fc73a408d3d675de8e2c;
        
        // Initialize
        clk = 0;
        rst = 1;
        start = 0;
        errors = 0;
        
        // Display header
        $display("\n==========================================");
        $display("AES-128 Encryption Testbench (VCS)");
        $display("==========================================\n");
        
        // Reset
        #20 rst = 0;
        #10;
        
        // Run all test vectors
        for (i = 0; i < TEST_VECTORS; i = i + 1) begin
            run_test(i);
        end
        
        // Summary
        $display("\n==========================================");
        if (errors == 0) begin
            $display("ALL TESTS PASSED! (%0d tests)", TEST_VECTORS);
        end
        else begin
            $display("TESTS FAILED: %0d errors", errors);
        end
        $display("==========================================");
        
        #50 $finish;
    end
    
    task run_test(input int test_num);
        begin
            // Apply test vectors
            key = test_key[test_num];
            plaintext = test_plain[test_num];
            
            $display("Test %0d:", test_num+1);
            $display("  Key:      %h", key);
            $display("  Plain:    %h", plaintext);
            $display("  Expected: %h", test_cipher[test_num]);
            
            // Start encryption
            @(negedge clk);
            start = 1;
            @(negedge clk);
            start = 0;
            
            // Wait for completion with timeout
            fork
                begin
                    wait(ready);
                    #10;
                    if (ciphertext === test_cipher[test_num]) begin
                        $display("  Result:   %h ✓ PASSED", ciphertext);
                    end
                    else begin
                        $display("  Result:   %h ✗ FAILED", ciphertext);
                        errors = errors + 1;
                    end
                end
                begin
                    #1000;
                    $display("  ERROR: Timeout!");
                    errors = errors + 1;
                end
            join_any
            disable fork;
            
            #20;
        end
    endtask
    
    // VCD dumping for waveform analysis
    initial begin
        $vcdpluson;
        $vcdplusmemon;
        $vcdplusfile("aes_waveform.vpd");
    end
    
    // Monitor for debugging (optional)
    initial begin
        $display("\nStarting simulation...\n");
    end
endmodule