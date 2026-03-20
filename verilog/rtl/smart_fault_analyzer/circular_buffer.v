/////////////////////////////////////////////////////////////////////////////////
// Organization: Vivekananda Institute of Professional Studies- Technical Campus (VIPS-TC) 
// Engineer: Shikha Tiwari
// 
// Create Date: 28.02.2026 20:28:16
// Design Name: Circular Buffer
// Module Name: circular_buffer
// Project Name: Smart Power Fault Signature Analyzer System-on-Chip
// Description: Continuously stores samples and freezes to preserve the fault signature.
// 
/////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module circular_buffer (
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif
    input  wire        clk,
    input  wire        rst,
    input  wire        write_en,
    input  wire [11:0] data_in,
    input  wire        freeze,       // Stops writing
    input  wire        read_en,      // Controlled reading
    output reg  [11:0] buffer_out
);

    parameter DEPTH = 1024;
    parameter ADDR_WIDTH = 10; // Log2(1024) = 10

    reg [11:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] write_ptr;
    reg [ADDR_WIDTH-1:0] read_ptr;

    always @(posedge clk) begin
        if (rst) begin
            write_ptr <= 0;
        end else if (write_en && !freeze) begin
            mem[write_ptr] <= data_in;
            write_ptr <= write_ptr + 1;
        end
    end

    // Read only when requested or scanning during send phase
    always @(posedge clk) begin
        if (rst) begin
            read_ptr <= 0;
            buffer_out <= 0;
        end else begin
            if (freeze) begin
                // If frozen, we might want to read out data sequentially
                if (read_en) begin
                    read_ptr <= read_ptr + 1;
                    buffer_out <= mem[read_ptr];
                end
            end else begin
                // Default behavior: could be a preview of latest data or 0
                buffer_out <= 12'd0; 
            end
        end
    end

endmodule
