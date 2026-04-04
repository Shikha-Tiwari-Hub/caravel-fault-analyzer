/////////////////////////////////////////////////////////////////////////////////
// Organization: Vivekananda Institute of Professional Studies- Technical Campus (VIPS-TC)
// Engineer: Shikha Tiwari
//
// Create Date: 28.02.2026 20:28:16
// Design Name: Top Soc
// Module Name: top_soc
// Project Name: Smart Power Fault Signature Analyzer System-on-Chip
// Description: Integrates all core modules (ADC interface, fault detection engine,
//              buffer, and FSM) into a Caravel-compatible user project top level.
//
/////////////////////////////////////////////////////////////////////////////////

module top_soc (
`ifdef USE_POWER_PINS
    inout vccd1,    // User area 1 1.8V supply
    inout vssd1,    // User area 1 digital ground
`endif
    // Wishbone Slave ports (WB MI A)
    input         wb_clk_i,
    input         wb_rst_i,
    input         wbs_cyc_i,
    input         wbs_stb_i,
    input         wbs_we_i,
    input  [3:0]  wbs_sel_i,
    input  [31:0] wbs_adr_i,
    input  [31:0] wbs_dat_i,
    output        wbs_ack_o,
    output [31:0] wbs_dat_o,
 
    // ADC input from GPIO pads
    input  [11:0] adc_data_in,
 
    // User maskable interrupt signals
    output [2:0]  user_irq
);
 
    // Internal wires
    wire clk = wb_clk_i;
    wire rst = wb_rst_i;
 
    wire        wb_wr = wbs_we_i & wbs_stb_i & wbs_cyc_i;
    wire        wb_rd = ~wbs_we_i & wbs_stb_i & wbs_cyc_i;
 
    wire [11:0] sample_data;
    wire        fault_flag;
    wire [1:0]  fault_type;
    wire [7:0]  fault_flags_bus;
    wire [15:0] threshold;
    wire        enable;
    wire [7:0]  fault_mask;
    wire        irq;
 
    // ADC sample interface
    adc u_adc (
        .clk           (clk),
        .rst           (rst),
        .adc_sample_in (adc_data_in),
        .sample_out    (sample_data)
    );
 
    // Fault detection engine
    fault_detect u_fault (
        .clk        (clk),
        .rst        (rst),
        .sample     (sample_data),
        .fault_flag (fault_flag),
        .fault_type (fault_type)
    );
 
    // Pack fault flags bus
    assign fault_flags_bus = {5'b0, fault_type, fault_flag};
 
    // Extend ADC value to 16 bits for register
    wire [15:0] adc_value_ext = {4'b0, sample_data};
 
    // Wishbone register file
    fault_analyzer_regs u_regs (
        .clk         (clk),
        .rst_n       (~rst),
        .wb_addr     (wbs_adr_i[7:0]),
        .wb_wdata    (wbs_dat_i),
        .wb_rdata    (wbs_dat_o),
        .wb_wr       (wb_wr),
        .wb_rd       (wb_rd),
        .wb_ack      (wbs_ack_o),
        .fault_flags (fault_flags_bus),
        .adc_value   (adc_value_ext),
        .threshold   (threshold),
        .enable      (enable),
        .fault_mask  (fault_mask),
        .irq         (irq)
    );
 
    // Route IRQ to Caravel user_irq
    assign user_irq = {2'b0, irq};
 
endmodule
