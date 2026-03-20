/////////////////////////////////////////////////////////////////////////////////
// Organization: Vivekananda Institute of Professional Studies- Technical Campus (VIPS-TC)
// Engineer: Shikha Tiwari
//
// Create Date: 28.02.2026 20:28:16
// Design Name: Top Soc
// Module Name:  top_soc
// Project Name: Smart Power Fault Signature Analyzer System-on-Chip
// Description: Integrates all core modules (ADC interface, fault detection engine, buffer, and FSM)
//
/////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module top_soc (
`ifdef USE_POWER_PINS
    inout VPWR,  
    inout VGND,  
`endif

    input  wire clk,
    input  wire rst,
    input  wire [11:0] adc_in,
    input  wire tx_done,        
    output wire fault_flag,
    output wire [1:0] fault_type,
    output wire freeze_buffer,
    output wire send_data
);

    wire [11:0] sample_data;
    wire read_en_fsm;
    wire buf_rst_fsm;
    wire [11:0] buffer_data;

    wire buffer_reset = rst | buf_rst_fsm;

    // 1. ADC Interface
    adc u_adc (
        .clk(clk),
        .rst(rst),
        .adc_sample_in(adc_in),
        .sample_out(sample_data)
    );

    // 2. Fault Detection
    fault_detect u_fault (
        .clk(clk),
        .rst(rst),
        .sample(sample_data),
        .fault_flag(fault_flag),
        .fault_type(fault_type)
    );

    // 3. Circular Buffer
    circular_buffer u_buffer (
        .clk(clk),
        .rst(buffer_reset),      
        .write_en(1'b1),         
        .data_in(sample_data),
        .freeze(freeze_buffer),  
        .read_en(read_en_fsm),   
        .buffer_out(buffer_data)            
    );

    // 4. Event FSM
    event_fsm u_fsm (
        .clk(clk),
        .rst(rst),
        .fault_flag(fault_flag),
        .tx_done(tx_done),       
        .freeze_buffer(freeze_buffer),
        .send_data(send_data),
        .read_enable(read_en_fsm),
        .buf_rst(buf_rst_fsm)
    );

// Use it in a dummy assignment
wire [11:0] _unused_buffer = buffer_data; 
endmodule
