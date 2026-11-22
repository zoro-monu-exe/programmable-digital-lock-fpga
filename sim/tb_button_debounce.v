`timescale 1ns/1ps

module tb_button_debounce;
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg button_in = 1'b0;
    wire press_pulse;
    integer pulse_count = 0;
    integer cycle;

    button_debounce #(.FILTER_CYCLES(3)) dut (
        .clk(clk),
        .rst(rst),
        .button_in(button_in),
        .press_pulse(press_pulse)
    );

    always #5 clk = ~clk;

    initial begin
        rst = 1'b1;
        repeat (2) @(negedge clk);
        rst = 1'b0;

        button_in = 1'b1;
        for (cycle = 0; cycle < 8; cycle = cycle + 1) begin
            @(negedge clk);
            if (press_pulse)
                pulse_count = pulse_count + 1;
        end
        if (pulse_count != 1)
            $fatal(1, "held press should generate exactly one pulse");

        button_in = 1'b0;
        repeat (8) @(negedge clk);
        if (press_pulse)
            $fatal(1, "button release must not generate a press pulse");

        button_in = 1'b1;
        pulse_count = 0;
        for (cycle = 0; cycle < 8; cycle = cycle + 1) begin
            @(negedge clk);
            if (press_pulse)
                pulse_count = pulse_count + 1;
        end
        if (pulse_count != 1)
            $fatal(1, "a second press should generate one pulse");

        $display("PASS: button debounce checks passed");
        $finish;
    end
endmodule
