/**
 * aes_tb.v - Testbench for AES-128 encryption core
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
    $display("Ciphertext: %h", ciphertext);
    $display("Round 0:    %h", plaintext ^ key);
    
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

// Monitor round numbers
always @(posedge clk) begin
    if (round_num != 0 && round_num <= 10) begin
        $display("Round %0d complete", round_num);
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