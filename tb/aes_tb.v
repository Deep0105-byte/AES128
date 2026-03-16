/**
 * aes_tb.v - Enhanced testbench for AES-128 encryption core
 * Uses NIST FIPS-197 test vector
 */
module aes_tb;

// Testbench signals
reg         clk;
reg         rst_n;
reg         start;
reg  [127:0] plaintext;
reg  [127:0] key;
wire [127:0] ciphertext;
wire         done;
wire [3:0]   round_num;

// Expected ciphertext for verification
parameter [127:0] EXPECTED_CIPHERTEXT = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;

// Known intermediate values for debugging (from NIST specification)
parameter [127:0] ROUND0 = 128'h00102030405060708090a0b0c0d0e0f0;
parameter [127:0] ROUND1 = 128'h89d810e8855ace682d1843d8cb128fe4;
parameter [127:0] ROUND2 = 128'h4915598f55e5d7a0daca94fa1f0a63f7;
parameter [127:0] ROUND9 = 128'hff87968431b86c51695151d9cbe7a7e6;
parameter [127:0] ROUND10 = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz clock
end

// Test vector
initial begin
    // NIST FIPS-197 test vector (Appendix B)
    plaintext = 128'h00112233445566778899aabbccddeeff;
    key = 128'h000102030405060708090a0b0c0d0e0f;
    
    // Initialize
    rst_n = 0;
    start = 0;
    
    // Release reset
    #20;
    rst_n = 1;
    
    // Display test vectors
    $display("========================================");
    $display("AES-128 Encryption Test");
    $display("========================================");
    $display("Plaintext:  %h", plaintext);
    $display("Key:        %h", key);
    $display("Round 0 (expected): %h", ROUND0);
    $display("----------------------------------------");
    
    // Start encryption
    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;
    
    // Wait for completion
    wait(done);
    
    // Display results
    $display("----------------------------------------");
    $display("Final Ciphertext: %h", ciphertext);
    
    // Verification
    if (ciphertext === EXPECTED_CIPHERTEXT) begin
        $display("----------------------------------------");
        $display("TEST PASSED - Ciphertext matches expected");
        $display("Expected:   %h", EXPECTED_CIPHERTEXT);
    end else begin
        $display("----------------------------------------");
        $display("TEST FAILED - Ciphertext mismatch");
        $display("Expected:   %h", EXPECTED_CIPHERTEXT);
        $display("Got:        %h", ciphertext);
    end
    $display("========================================");
    
    #100;
    $finish;
end

// Monitor round numbers and state
always @(posedge clk) begin
    if (round_num != 0) begin
        #1;  // Small delay to ensure stable values
        $display("Round %0d complete: state = %h", round_num, uut.state_reg);
        
        // Check against known intermediate values
        case (round_num)
            4'd1: if (uut.state_reg !== ROUND1) 
                    $display("  WARNING: Round 1 mismatch! Expected: %h", ROUND1);
            4'd2: if (uut.state_reg !== ROUND2) 
                    $display("  WARNING: Round 2 mismatch! Expected: %h", ROUND2);
            4'd9: if (uut.state_reg !== ROUND9) 
                    $display("  WARNING: Round 9 mismatch! Expected: %h", ROUND9);
            4'd10: if (uut.state_reg !== ROUND10) 
                    $display("  WARNING: Round 10 mismatch! Expected: %h", ROUND10);
        endcase
    end
end

// Instantiate DUT
aes_top uut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .plaintext(plaintext),
    .key(key),
    .ciphertext(ciphertext),
    .done(done),
    .round_num(round_num)
);

// Waveform dumping for simulation
initial begin
    $dumpfile("aes_tb.vcd");
    $dumpvars(0, aes_tb);
end

endmodule