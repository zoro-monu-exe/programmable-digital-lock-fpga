`timescale 1ns/1ps

module digital_lock_core (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] code_switches,
    input  wire       set_code_pulse,
    input  wire       submit_pulse,
    input  wire       relock_pulse,
    output wire       code_programmed,
    output wire       unlocked,
    output wire       locked,
    output wire       wrong_code,
    output wire       lockout
);
    localparam [1:0] SETUP   = 2'b00;
    localparam [1:0] LOCKED  = 2'b01;
    localparam [1:0] OPEN    = 2'b10;
    localparam [1:0] LOCKOUT = 2'b11;

    reg [1:0] state;
    reg [3:0] saved_code;
    reg [1:0] failed_attempts;
    reg error_latched;

    assign code_programmed = (state != SETUP);
    assign unlocked = (state == OPEN);
    assign locked = (state == LOCKED);
    assign wrong_code = error_latched;
    assign lockout = (state == LOCKOUT);

    always @(posedge clk) begin
        if (rst) begin
            state <= SETUP;
            saved_code <= 4'b0000;
            failed_attempts <= 2'b00;
            error_latched <= 1'b0;
        end else begin
            case (state)
                SETUP: begin
                    if (set_code_pulse) begin
                        saved_code <= code_switches;
                        failed_attempts <= 2'b00;
                        error_latched <= 1'b0;
                        state <= LOCKED;
                    end
                end

                LOCKED: begin
                    if (submit_pulse) begin
                        if (code_switches == saved_code) begin
                            failed_attempts <= 2'b00;
                            error_latched <= 1'b0;
                            state <= OPEN;
                        end else begin
                            error_latched <= 1'b1;
                            if (failed_attempts == 2'd2) begin
                                state <= LOCKOUT;
                            end else begin
                                failed_attempts <= failed_attempts + 1'b1;
                            end
                        end
                    end
                end

                OPEN: begin
                    if (set_code_pulse) begin
                        saved_code <= code_switches;
                        failed_attempts <= 2'b00;
                        error_latched <= 1'b0;
                        state <= LOCKED;
                    end else if (relock_pulse) begin
                        error_latched <= 1'b0;
                        state <= LOCKED;
                    end
                end

                LOCKOUT: begin
                    state <= LOCKOUT;
                end

                default: begin
                    state <= SETUP;
                    saved_code <= 4'b0000;
                    failed_attempts <= 2'b00;
                    error_latched <= 1'b0;
                end
            endcase
        end
    end
endmodule
