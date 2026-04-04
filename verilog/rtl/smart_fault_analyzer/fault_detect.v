/////////////////////////////////////////////////////////////////////////////////
// Organization: Vivekananda Institute of Professional Studies- Technical Campus (VIPS-TC)
// Engineer: Shikha Tiwari
//
// Create Date: 28.02.2026 20:28:16
// Design Name: Fault Detection Engine
// Module Name: fault_detect
// Project Name: Smart Power Fault Signature Analyzer System-on-Chip
// Description: Detects overvoltage, undervoltage, and spike faults using predefined thresholds.
//
/////////////////////////////////////////////////////////////////////////////////

module fault_detect(
    input  wire        clk,
    input  wire        rst,
    input  wire [11:0] sample,
    output reg         fault_flag,
    output reg  [1:0]  fault_type
);
 
    // Thresholds
    parameter HIGH_TH  = 12'd3500;
    parameter LOW_TH   = 12'd500;
    parameter SPIKE_TH = 12'd800;
 
    reg [11:0] prev_sample;
 
    // Combinational fault detection signals
    reg is_overcurrent;
    reg is_undervoltage;
    reg is_spike_pos;
    reg is_spike_neg;
    reg fault_detected_comb;
 
    always @(*) begin
        // Overcurrent / Undervoltage
        is_overcurrent  = (sample > HIGH_TH);
        is_undervoltage = (sample < LOW_TH);
 
        // Detect spikes
        is_spike_pos = (sample > prev_sample) && ((sample - prev_sample) > SPIKE_TH);
        is_spike_neg = (prev_sample > sample) && ((prev_sample - sample) > SPIKE_TH);
 
        // Priority Encoder: Overcurrent > Undervoltage > Spike
        fault_detected_comb = is_overcurrent | is_undervoltage | is_spike_pos | is_spike_neg;
    end
 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fault_flag  <= 1'b0;
            fault_type  <= 2'b0;
            prev_sample <= 12'd0;
        end else begin
            prev_sample <= sample;
 
            // Fault detection pulse
            fault_flag <= fault_detected_comb ? 1'b1 : 1'b0;
 
            // Priority encoding for fault_type
            fault_type <= 2'b0; // default
            if (fault_detected_comb) begin
                if (is_overcurrent)
                    fault_type <= 2'b01;
                else if (is_undervoltage)
                    fault_type <= 2'b10;
                else
                    fault_type <= 2'b11; // spike
            end
        end
    end
 
endmodule
