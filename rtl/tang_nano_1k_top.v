`timescale 1ns/1ps

module tang_nano_1k_top #(
    parameter [31:0] FILTER_CYCLES = 32'd135_000
) (
    input  wire       xtal_27m,
    input  wire       sys_rst_n,
    input  wire [3:0] code_sw_n,
    input  wire       set_button_n,
    input  wire       submit_button_n,
    input  wire       relock_button_n,
    output reg        led_r_n,
    output reg        led_g_n,
    output reg        led_b_n
);
    wire code_programmed;
    wire unlocked;
    wire locked;
    wire wrong_code;
    wire lockout;

    digital_lock_top #(.FILTER_CYCLES(FILTER_CYCLES)) lock (
        .clk(xtal_27m),
        .rst(~sys_rst_n),
        .code_switches(~code_sw_n),
        .set_code_button(~set_button_n),
        .submit_button(~submit_button_n),
        .relock_button(~relock_button_n),
        .code_programmed(code_programmed),
        .unlocked(unlocked),
        .locked(locked),
        .wrong_code(wrong_code),
        .lockout(lockout)
    );

    always @* begin
        led_r_n = 1'b1;
        led_g_n = 1'b1;
        led_b_n = 1'b1;

        if (!code_programmed) begin
            led_r_n = 1'b0;
            led_g_n = 1'b0;
        end else if (lockout) begin
            led_r_n = 1'b0;
            led_b_n = 1'b0;
        end else if (unlocked) begin
            led_g_n = 1'b0;
        end else if (wrong_code) begin
            led_b_n = 1'b0;
        end else if (locked) begin
            led_r_n = 1'b0;
        end
    end
endmodule
