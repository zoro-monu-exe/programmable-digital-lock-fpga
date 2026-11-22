`timescale 1ns/1ps

module digital_lock_top #(
    parameter integer FILTER_CYCLES = 500_000
) (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] code_switches,
    input  wire       set_code_button,
    input  wire       submit_button,
    input  wire       relock_button,
    output wire       code_programmed,
    output wire       unlocked,
    output wire       locked,
    output wire       wrong_code,
    output wire       lockout
);
    wire set_code_pulse;
    wire submit_pulse;
    wire relock_pulse;
    reg [3:0] switch_sync_1;
    reg [3:0] switch_sync_2;

    always @(posedge clk) begin
        if (rst) begin
            switch_sync_1 <= 4'b0000;
            switch_sync_2 <= 4'b0000;
        end else begin
            switch_sync_1 <= code_switches;
            switch_sync_2 <= switch_sync_1;
        end
    end

    button_debounce #(.FILTER_CYCLES(FILTER_CYCLES)) set_debounce (
        .clk(clk),
        .rst(rst),
        .button_in(set_code_button),
        .press_pulse(set_code_pulse)
    );

    button_debounce #(.FILTER_CYCLES(FILTER_CYCLES)) submit_debounce (
        .clk(clk),
        .rst(rst),
        .button_in(submit_button),
        .press_pulse(submit_pulse)
    );

    button_debounce #(.FILTER_CYCLES(FILTER_CYCLES)) relock_debounce (
        .clk(clk),
        .rst(rst),
        .button_in(relock_button),
        .press_pulse(relock_pulse)
    );

    digital_lock_core core (
        .clk(clk),
        .rst(rst),
        .code_switches(switch_sync_2),
        .set_code_pulse(set_code_pulse),
        .submit_pulse(submit_pulse),
        .relock_pulse(relock_pulse),
        .code_programmed(code_programmed),
        .unlocked(unlocked),
        .locked(locked),
        .wrong_code(wrong_code),
        .lockout(lockout)
    );
endmodule
