`timescale 1ns/1ps

module tb_digital_lock_top;
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg [3:0] code_switches = 4'b0000;
    reg set_code_button = 1'b0;
    reg submit_button = 1'b0;
    reg relock_button = 1'b0;

    wire code_programmed;
    wire unlocked;
    wire locked;
    wire wrong_code;
    wire lockout;

    digital_lock_top #(.FILTER_CYCLES(3)) dut (
        .clk(clk),
        .rst(rst),
        .code_switches(code_switches),
        .set_code_button(set_code_button),
        .submit_button(submit_button),
        .relock_button(relock_button),
        .code_programmed(code_programmed),
        .unlocked(unlocked),
        .locked(locked),
        .wrong_code(wrong_code),
        .lockout(lockout)
    );

    always #5 clk = ~clk;

    task press_set;
        begin
            @(negedge clk);
            set_code_button = 1'b1;
            repeat (12) @(negedge clk);
            set_code_button = 1'b0;
            repeat (8) @(negedge clk);
        end
    endtask

    task press_submit;
        begin
            @(negedge clk);
            submit_button = 1'b1;
            repeat (12) @(negedge clk);
            submit_button = 1'b0;
            repeat (8) @(negedge clk);
        end
    endtask

    task press_relock;
        begin
            @(negedge clk);
            relock_button = 1'b1;
            repeat (12) @(negedge clk);
            relock_button = 1'b0;
            repeat (8) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("build/digital_lock_top.vcd");
        $dumpvars(0, tb_digital_lock_top);

        rst = 1'b1;
        repeat (3) @(negedge clk);
        rst = 1'b0;
        repeat (3) @(negedge clk);
        if (code_programmed || unlocked || locked || lockout)
            $fatal(1, "reset should leave the design in setup");

        code_switches = 4'b1010;
        press_set();
        if (!code_programmed || !locked)
            $fatal(1, "top-level Set button should program the code");

        code_switches = 4'b0110;
        press_submit();
        if (!wrong_code || !locked || lockout)
            $fatal(1, "top-level should flag one wrong entry");

        code_switches = 4'b1010;
        press_submit();
        if (!unlocked || wrong_code)
            $fatal(1, "top-level should unlock on the programmed code");

        press_relock();
        if (!locked || unlocked)
            $fatal(1, "top-level Relock button should relock");

        code_switches = 4'b1010;
        press_submit();
        code_switches = 4'b0011;
        press_set();
        if (!locked || !code_programmed)
            $fatal(1, "top-level Set should change code and relock");

        code_switches = 4'b1010;
        press_submit();
        if (!wrong_code || !locked)
            $fatal(1, "old code should fail after a code change");
        code_switches = 4'b0011;
        press_submit();
        if (!unlocked || wrong_code)
            $fatal(1, "new code should unlock");

        press_relock();
        code_switches = 4'b0000;
        press_submit();
        if (!locked || !wrong_code || lockout)
            $fatal(1, "first failed attempt should not yet lock out");
        press_submit();
        if (!locked || lockout || !wrong_code)
            $fatal(1, "second failed attempt should remain in normal lock");
        press_submit();
        if (locked || !lockout)
            $fatal(1, "third failed attempt should enter lockout");

        $display("PASS: end-to-end top-level checks passed");
        $finish;
    end
endmodule
