`timescale 1ns/1ps

module tb_digital_lock_core;
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg [3:0] code_switches = 4'b0000;
    reg set_code_pulse = 1'b0;
    reg submit_pulse = 1'b0;
    reg relock_pulse = 1'b0;

    wire code_programmed;
    wire unlocked;
    wire locked;
    wire wrong_code;
    wire lockout;

    digital_lock_core dut (
        .clk(clk),
        .rst(rst),
        .code_switches(code_switches),
        .set_code_pulse(set_code_pulse),
        .submit_pulse(submit_pulse),
        .relock_pulse(relock_pulse),
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
            set_code_pulse = 1'b1;
            @(negedge clk);
            set_code_pulse = 1'b0;
        end
    endtask

    task press_submit;
        begin
            @(negedge clk);
            submit_pulse = 1'b1;
            @(negedge clk);
            submit_pulse = 1'b0;
        end
    endtask

    task press_relock;
        begin
            @(negedge clk);
            relock_pulse = 1'b1;
            @(negedge clk);
            relock_pulse = 1'b0;
        end
    endtask

    task check;
        input condition;
        input [8*100-1:0] message;
        begin
            if (!condition) begin
                $display("FAIL: %0s", message);
                $fatal(1);
            end
        end
    endtask

    initial begin
        $dumpfile("build/digital_lock.vcd");
        $dumpvars(0, tb_digital_lock_core);

        rst = 1'b1;
        repeat (2) @(negedge clk);
        rst = 1'b0;
        @(negedge clk);
        check(!code_programmed && !unlocked, "reset enters setup");

        code_switches = 4'b1010;
        press_set();
        check(code_programmed && locked, "set first code");

        code_switches = 4'b0110;
        press_submit();
        check(wrong_code && locked && !lockout, "first wrong attempt");
        code_switches = 4'b0000;
        press_submit();
        check(wrong_code && locked && !lockout, "second wrong attempt");
        code_switches = 4'b1111;
        press_submit();
        check(wrong_code && lockout, "third wrong attempt locks out");

        rst = 1'b1;
        repeat (2) @(negedge clk);
        rst = 1'b0;
        @(negedge clk);
        code_switches = 4'b1010;
        press_set();
        code_switches = 4'b1010;
        press_submit();
        check(unlocked && !wrong_code, "correct code unlocks");

        press_relock();
        check(locked && !unlocked, "relock button locks again");

        code_switches = 4'b1010;
        press_submit();
        check(unlocked, "correct code unlocks after relock");
        code_switches = 4'b0110;
        press_set();
        check(locked && code_programmed, "set button changes code and relocks");

        code_switches = 4'b1010;
        press_submit();
        check(locked && wrong_code, "old code no longer works");
        code_switches = 4'b0110;
        press_submit();
        check(unlocked && !wrong_code, "new code unlocks");

        $display("PASS: all digital-lock checks passed");
        $finish;
    end
endmodule
