// aes_top.v - Top-level AES-128 Encryption Module
module aes_top (
    input         clk,
    input         rst,
    input  [127:0] key,
    input  [127:0] plaintext,
    input         start,
    output [127:0] ciphertext,
    output        ready
);
    wire [1407:0] round_keys;
    wire key_ready;
    wire core_done;
    
    // Key expansion module
    key_expansion key_exp (
        .clk(clk),
        .rst(rst),
        .cipher_key(key),
        .key_valid(start),
        .round_keys(round_keys),
        .key_ready(key_ready)
    );
    
    // AES core
    aes_core aes_core_inst (
        .clk(clk),
        .rst(rst),
        .plaintext(plaintext),
        .round_keys(round_keys),
        .start(start && key_ready),
        .ciphertext(ciphertext),
        .done(core_done)
    );
    
    assign ready = core_done;
endmodule