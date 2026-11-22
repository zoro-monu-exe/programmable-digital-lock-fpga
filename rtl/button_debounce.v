`timescale 1ns/1ps

module button_debounce #(
    parameter [31:0] FILTER_CYCLES = 32'd500_000
) (
    input  wire clk,
    input  wire rst,
    input  wire button_in,
    output reg  press_pulse
);
    localparam integer COUNT_WIDTH =
        (FILTER_CYCLES <= 1) ? 1 : $clog2(FILTER_CYCLES);
    localparam [COUNT_WIDTH-1:0] ONE =
        {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
    localparam [COUNT_WIDTH-1:0] LAST_COUNT =
        FILTER_CYCLES[COUNT_WIDTH-1:0] - ONE;

    reg sync_1;
    reg sync_2;
    reg stable_level;
    reg [COUNT_WIDTH-1:0] count;

    always @(posedge clk) begin
        if (rst) begin
            sync_1 <= 1'b0;
            sync_2 <= 1'b0;
        end else begin
            sync_1 <= button_in;
            sync_2 <= sync_1;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            stable_level <= 1'b0;
            count <= {COUNT_WIDTH{1'b0}};
            press_pulse <= 1'b0;
        end else begin
            press_pulse <= 1'b0;

            if (sync_2 == stable_level) begin
                count <= {COUNT_WIDTH{1'b0}};
            end else if (count == LAST_COUNT) begin
                stable_level <= sync_2;
                count <= {COUNT_WIDTH{1'b0}};
                if (sync_2)
                    press_pulse <= 1'b1;
            end else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule
