/////////////////////////////////////////////////////////////////////////////////
// Organization: Vivekananda Institute of Professional Studies- Technical Campus (VIPS-TC)
// Engineer: Shikha Tiwari
//
// Create Date: 28.02.2026 20:28:16
// Design Name: Event FSM
// Module Name:  event_fsm
// Project Name: Smart Power Fault Signature Analyzer System-on-Chip
// Description: Controls system flow from monitoring to fault capture and data transmission.
//
/////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module event_fsm (
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif
    input  wire clk,
    input  wire rst,
    input  wire fault_flag,
    input  wire tx_done,      // Input signal indicating data transmission is finished
    
    output reg  freeze_buffer,
    output reg  send_data,
    output reg  read_enable,  // Control for buffer reading
    output reg  buf_rst       // To reset buffer pointers for next capture
);
 
    localparam [3:0] 
        MONITOR     = 4'b0001,
        FAULT       = 4'b0010,
        POST_WAIT   = 4'b0100,
        SEND        = 4'b1000;

    reg [3:0] state;
    reg [15:0] post_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= MONITOR;
            freeze_buffer<= 1'b0;
            send_data    <= 1'b0;
            read_enable  <= 1'b0;
            buf_rst      <= 1'b1;
            post_counter <= 16'd0;
        end else begin
            // Defaults
            buf_rst      <= 1'b0; 
            read_enable  <= 1'b0;

            case(state)
                MONITOR: begin
                    freeze_buffer <= 1'b0;
                    send_data     <= 1'b0;
                    
                    if (fault_flag)
                        state <= FAULT;
                end

                FAULT: begin
                    // We entered fault state. Wait to capture post-fault data
                    post_counter <= 16'd0;
                    state <= POST_WAIT;
                end

                POST_WAIT: begin
                    post_counter <= post_counter + 1;
                    
                    if (post_counter == 16'd5) begin
                        freeze_buffer <= 1'b1; // Stop buffer, hold data
                        state <= SEND;
                    end
                end

                SEND: begin
                    send_data    <= 1'b1; // Assert 'Data Ready' to external transmitter
                    read_enable  <= 1'b1; // Step through buffer memory
                    
                    // Wait for external system to say transmission is done
                    if (tx_done) begin
                        send_data <= 1'b0;
                        state     <= MONITOR;
                        buf_rst   <= 1'b1; // Reset buffer for next round
                    end
                end
                
                default: state <= MONITOR;
            endcase
        end
    end
endmodule
