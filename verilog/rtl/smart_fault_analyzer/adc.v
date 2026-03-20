/////////////////////////////////////////////////////////////////////////////////
// Organization: Vivekananda Institute of Professional Studies- Technical Campus (VIPS-TC)
// Engineer: Shikha Tiwari
//
// Create Date: 28.02.2026 20:28:16
// Design Name: ADC Interface
// Module Name: adc
// Project Name: Smart Power Fault Signature Analyzer System-on-Chip
// Description: Synchronizes external ADC samples to the internal system clock domain.
//
/////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module adc(
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif
    input  wire        clk,
    input  wire        rst,
    input  wire [11:0] adc_sample_in,
    output reg  [11:0] sample_out
);

always @(posedge clk or posedge rst) begin
    if (rst)
        sample_out <= 12'd0;
    else
        sample_out <= adc_sample_in;
end

endmodule
