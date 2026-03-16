`timescale 1ns/1ps
// AES-128 Testbench
// NIST FIPS-197 Appendix B test vector
//   Plaintext : 00112233445566778899aabbccddeeff
//   Key       : 000102030405060708090a0b0c0d0e0f
//   Ciphertext: 69c4e0d86a7b0430d8cdb78070b4c55a
module aes_tb;
    // ── DUT signals ────────────────────────────────────────────────
    reg         clk, rst_n, start;
    reg  [127:0] plaintext, key;
    wire [127:0] ciphertext;
    wire         done;

    // ── DUT instantiation ──────────────────────────────────────────
    aes_top dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .plaintext  (plaintext),
        .key        (key),
        .ciphertext (ciphertext),
        .done       (done)
    );

    // ── Clock generation: 10 ns period ─────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Waveform dump (optional – comment out if not needed) ────────
    initial begin
        $dumpfile("aes_tb.vcd");
        $dumpvars(0, aes_tb);
    end

    // ── Stimulus ───────────────────────────────────────────────────
    integer cycle_count;

    initial begin
        // NIST test vector
        plaintext = 128'h00112233445566778899aabbccddeeff;
        key       = 128'h000102030405060708090a0b0c0d0e0f;
        rst_n     = 1'b0;
        start     = 1'b0;
        cycle_count = 0;

        // Assert reset for 2 cycles
        @(negedge clk); @(negedge clk);
        rst_n = 1'b1;

        // Print inputs
        $display("==============================================");
        $display("AES-128 Iterative Core – NIST FIPS-197 Vector");
        $display("==============================================");
        $display("Plaintext  : %032h", plaintext);
        $display("Key        : %032h", key);
        $display("Expected CT: 69c4e0d86a7b0430d8cdb78070b4c55a");
        $display("----------------------------------------------");

        // Assert start for one cycle
        @(negedge clk);
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;

        // Wait for done, track cycles and round_num
        while (!done) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;
            // Print intermediate state each round (round_num is registered)
            if (dut.u_ctrl.state_we && !dut.u_ctrl.load_init)
                $display("After Round %0d : state = %032h",
                         dut.u_ctrl.round_num - 1,
                         dut.state);
        end

        // One more clock edge to latch final state
        @(posedge clk); #1;

        $display("----------------------------------------------");
        $display("Ciphertext : %032h", ciphertext);
        $display("----------------------------------------------");

        if (ciphertext === 128'h69c4e0d86a7b0430d8cdb78070b4c55a)
            $display("RESULT: PASS  – Ciphertext matches NIST vector!");
        else begin
            $display("RESULT: FAIL  – Mismatch!");
            $display("  Got     : %032h", ciphertext);
            $display("  Expected: 69c4e0d86a7b0430d8cdb78070b4c55a");
        end

        $display("Total clock cycles: %0d", cycle_count);
        $display("==============================================");
        $finish;
    end

    // ── Timeout watchdog ────────────────────────────────────────────
    initial begin
        #2000;
        $display("TIMEOUT: simulation exceeded 2000 ns");
        $finish;
    end
endmodule
