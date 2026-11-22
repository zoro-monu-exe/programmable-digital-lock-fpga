`timescale 1ns/1ps

module tb_tang_nano_1k_top;
    reg xtal_27m = 1'b0;
    reg sys_rst_n = 1'b1;
    reg [3:0] code_sw_n = 4'b1111;
    reg set_button_n = 1'b1;
    reg submit_button_n = 1'b1;
    reg relock_button_n = 1'b1;
    wire led_r_n;
    wire led_g_n;
    wire led_b_n;

    tang_nano_1k_top #(.FILTER_CYCLES(3)) dut (
        .xtal_27m(xtal_27m),
        .sys_rst_n(sys_rst_n),
        .code_sw_n(code_sw_n),
        .set_button_n(set_button_n),
        .submit_button_n(submit_button_n),
        .relock_button_n(relock_button_n),
        .led_r_n(led_r_n),
        .led_g_n(led_g_n),
        .led_b_n(led_b_n)
    );

    always #5 xtal_27m = ~xtal_27m;

    task press_set;
        begin
            @(negedge xtal_27m);
            set_button_n = 1'b0;
            repeat (12) @(negedge xtal_27m);
            set_button_n = 1'b1;
            repeat (8) @(negedge xtal_27m);
        end
    endtask

    task press_submit;
        begin
            @(negedge xtal_27m);
            submit_button_n = 1'b0;
            repeat (12) @(negedge xtal_27m);
            submit_button_n = 1'b1;
            repeat (8) @(negedge xtal_27m);
        end
    endtask

    task press_relock;
        begin
            @(negedge xtal_27m);
            relock_button_n = 1'b0;
            repeat (12) @(negedge xtal_27m);
            relock_button_n = 1'b1;
            repeat (8) @(negedge xtal_27m);
        end
    endtask

    initial begin
        $dumpfile("build/tang_nano_1k_top.vcd");
        $dumpvars(0, tb_tang_nano_1k_top);

        sys_rst_n = 1'b0;
        repeat (3) @(negedge xtal_27m);
        sys_rst_n = 1'b1;
        repeat (3) @(negedge xtal_27m);
        if ({led_r_n, led_g_n, led_b_n} != 3'b001)
            $fatal(1, "setup should show yellow on the active-low RGB LED");

        code_sw_n = 4'b0101;
        press_set();
        if ({led_r_n, led_g_n, led_b_n} != 3'b011)
            $fatal(1, "programmed lock should show red");

        press_submit();
        if ({led_r_n, led_g_n, led_b_n} != 3'b101)
            $fatal(1, "correct code should show green");

        press_relock();
        code_sw_n = 4'b1001;
        press_submit();
        if ({led_r_n, led_g_n, led_b_n} != 3'b110)
            $fatal(1, "wrong code should show blue");

        press_submit();
        press_submit();
        if ({led_r_n, led_g_n, led_b_n} != 3'b010)
            $fatal(1, "third wrong code should show magenta lockout");

        $display("PASS: Tang Nano 1K wrapper checks passed");
        $finish;
    end
endmodule
