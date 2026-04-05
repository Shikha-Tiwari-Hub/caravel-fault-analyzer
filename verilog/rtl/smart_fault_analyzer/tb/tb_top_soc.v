`timescale 1ns/1ps
// Organization: VIPS-TC
// Engineer: Shikha Tiwari
// Description: Testbench for Smart Power Fault Signature Analyzer SoC
//              Compatible with both RTL and GL simulation
//
// Run RTL:
//   iverilog -g2012 -o sim tb/tb_top_soc.v top_soc.v adc.v fault_detect.v fault_analyzer_regs.v && vvp sim
//
// Run GL:
//   iverilog -g2012 -DFUNCTIONAL -DUSE_POWER_PINS -DUNIT_DELAY=#1 -o sim_gl \
//     tb/tb_top_soc.v \
//     ~/caravel-fault-analyzer/verilog/gl/top_soc.v \
//     ~/caravel-fault-analyzer/dependencies/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v \
//     ~/caravel-fault-analyzer/dependencies/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v \
//     && vvp sim_gl
//
// Fault Detection Thresholds (from fault_detect.v):
//   HIGH_TH  = 3500  -> Overcurrent fault
//   LOW_TH   = 500   -> Undervoltage fault
//   SPIKE_TH = 800   -> Spike fault (delta between samples)

module tb_top_soc;

    // ------------------------------------------------------------
    // Signal declarations
    // ------------------------------------------------------------
    reg         wb_clk_i;
    reg         wb_rst_i;
    reg         wbs_cyc_i;
    reg         wbs_stb_i;
    reg         wbs_we_i;
    reg  [3:0]  wbs_sel_i;
    reg  [31:0] wbs_adr_i;
    reg  [31:0] wbs_dat_i;
    wire [31:0] wbs_dat_o;
    wire        wbs_ack_o;
    reg  [11:0] adc_data_in;
    wire [2:0]  user_irq;

    // Power supply wires for GL simulation
    supply1 vccd1_supply;
    supply0 vssd1_supply;

    // ------------------------------------------------------------
    // DUT instantiation
    // ------------------------------------------------------------
    top_soc dut (
`ifdef USE_POWER_PINS
        .vccd1       (vccd1_supply),
        .vssd1       (vssd1_supply),
`endif
        .wb_clk_i    (wb_clk_i),
        .wb_rst_i    (wb_rst_i),
        .wbs_cyc_i   (wbs_cyc_i),
        .wbs_stb_i   (wbs_stb_i),
        .wbs_we_i    (wbs_we_i),
        .wbs_sel_i   (wbs_sel_i),
        .wbs_adr_i   (wbs_adr_i),
        .wbs_dat_i   (wbs_dat_i),
        .wbs_dat_o   (wbs_dat_o),
        .wbs_ack_o   (wbs_ack_o),
        .adc_data_in (adc_data_in),
        .user_irq    (user_irq)
    );

    // ------------------------------------------------------------
    // Clock: 10ns period = 100MHz
    // ------------------------------------------------------------
    initial wb_clk_i = 0;
    always #5 wb_clk_i = ~wb_clk_i;

    integer pass_count = 0;
    integer fail_count = 0;

    // ------------------------------------------------------------
    // Wishbone WRITE task
    // ------------------------------------------------------------
    task wb_write;
        input [31:0] addr;
        input [31:0] data;
        integer timeout;
        begin
            @(posedge wb_clk_i); #1;
            wbs_adr_i = addr;
            wbs_dat_i = data;
            wbs_we_i  = 1;
            wbs_cyc_i = 1;
            wbs_stb_i = 1;
            wbs_sel_i = 4'hF;
            timeout = 0;
            while (!wbs_ack_o && timeout < 100) begin
                @(posedge wb_clk_i); #1;
                timeout = timeout + 1;
            end
            @(posedge wb_clk_i); #1;
            wbs_cyc_i = 0;
            wbs_stb_i = 0;
            wbs_we_i  = 0;
            wbs_dat_i = 0;
            repeat(2) @(posedge wb_clk_i);
        end
    endtask

    // ------------------------------------------------------------
    // Wishbone READ task
    // ------------------------------------------------------------
    task wb_read;
        input [31:0] addr;
        integer timeout;
        begin
            @(posedge wb_clk_i); #1;
            wbs_adr_i = addr;
            wbs_we_i  = 0;
            wbs_cyc_i = 1;
            wbs_stb_i = 1;
            wbs_sel_i = 4'hF;
            timeout = 0;
            while (!wbs_ack_o && timeout < 100) begin
                @(posedge wb_clk_i); #1;
                timeout = timeout + 1;
            end
            @(posedge wb_clk_i); #1;
            $display("    READ [0x%h] = 0x%h", addr, wbs_dat_o);
            wbs_cyc_i = 0;
            wbs_stb_i = 0;
            repeat(2) @(posedge wb_clk_i);
        end
    endtask

    // ------------------------------------------------------------
    // Main test sequence
    // ------------------------------------------------------------
    initial begin
        // Initialize all signals
        wb_rst_i    = 1;
        wbs_cyc_i   = 0;
        wbs_stb_i   = 0;
        wbs_we_i    = 0;
        wbs_sel_i   = 4'h0;
        wbs_adr_i   = 32'h0;
        wbs_dat_i   = 32'h0;
        adc_data_in = 12'd1000; // safe value during reset - no fault

        $display("");
        $display("=====================================================");
        $display(" Smart Power Fault Signature Analyzer - Testbench   ");
        $display(" VIPS-TC | Shikha Tiwari                            ");
        $display(" HIGH_TH=3500  LOW_TH=500  SPIKE_TH=800            ");
        $display("=====================================================");

        // Long reset for GL simulation to clear X states
        repeat(30) @(posedge wb_clk_i);
        wb_rst_i = 0;
        repeat(20) @(posedge wb_clk_i);

        // Set safe ADC value and clear any spurious IRQs from GL init
        adc_data_in = 12'd1000;
        repeat(10) @(posedge wb_clk_i);
        wb_write(32'h14, 32'hFF); // clear IRQ
        repeat(20) @(posedge wb_clk_i);

        // -----------------------------------------------------
        // TEST 1: Enable fault detection via WB register
        // -----------------------------------------------------
        $display("\n[TEST 1] Enable Fault Detection Engine");
        wb_write(32'h00, 32'd1);
        repeat(5) @(posedge wb_clk_i);
        wb_read(32'h00);
        if (wbs_dat_o[0] === 1'b1) begin
            $display("    PASS: Enable register set correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: Enable register not set (got %h)", wbs_dat_o);
            fail_count = fail_count + 1;
        end

        // -----------------------------------------------------
        // TEST 2: Normal operation - no fault expected
        // -----------------------------------------------------
        $display("\n[TEST 2] Normal Operation (ADC=1000, No Fault Expected)");
        adc_data_in = 12'd1000;
        repeat(20) @(posedge wb_clk_i);
        if (user_irq[0] === 1'b0) begin
            $display("    PASS: No IRQ for normal ADC=1000");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: Unexpected IRQ for ADC=1000");
            fail_count = fail_count + 1;
        end

        // -----------------------------------------------------
        // TEST 3: Overcurrent fault - ADC=4000 > HIGH_TH=3500
        // -----------------------------------------------------
        $display("\n[TEST 3] Overcurrent Fault (ADC=4000 > HIGH_TH=3500)");
        adc_data_in = 12'd4000;
        repeat(20) @(posedge wb_clk_i);
        if (user_irq[0] === 1'b1) begin
            $display("    PASS: IRQ triggered for overcurrent ADC=4000");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: No IRQ for overcurrent ADC=4000");
            fail_count = fail_count + 1;
        end
        wb_read(32'h0C);
        // Return to safe value first then clear IRQ
        adc_data_in = 12'd1000;
        repeat(10) @(posedge wb_clk_i);
        wb_write(32'h14, 32'hFF);
        repeat(20) @(posedge wb_clk_i);

        // -----------------------------------------------------
        // TEST 4: Undervoltage fault - ADC=200 < LOW_TH=500
        // -----------------------------------------------------
        $display("\n[TEST 4] Undervoltage Fault (ADC=200 < LOW_TH=500)");
        adc_data_in = 12'd200;
        repeat(20) @(posedge wb_clk_i);
        if (user_irq[0] === 1'b1) begin
            $display("    PASS: IRQ triggered for undervoltage ADC=200");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: No IRQ for undervoltage ADC=200");
            fail_count = fail_count + 1;
        end
        // Return to safe value first then clear IRQ
        adc_data_in = 12'd1000;
        repeat(10) @(posedge wb_clk_i);
        wb_write(32'h14, 32'hFF);
        repeat(20) @(posedge wb_clk_i);

        // -----------------------------------------------------
        // TEST 5: Spike - jump from 1000 to 2000 (delta=1000 > SPIKE_TH=800)
        // -----------------------------------------------------
        $display("\n[TEST 5] Spike Detection (1000 to 2000, delta=1000 > SPIKE_TH=800)");
        adc_data_in = 12'd1000;
        repeat(10) @(posedge wb_clk_i);
        adc_data_in = 12'd2000;
        repeat(20) @(posedge wb_clk_i);
        if (user_irq[0] === 1'b1) begin
            $display("    PASS: IRQ triggered for spike detection");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: No IRQ for spike detection");
            fail_count = fail_count + 1;
        end

        // -----------------------------------------------------
        // Summary
        // -----------------------------------------------------
        $display("");
        $display("=====================================================");
        $display(" PASSED : %0d / 5", pass_count);
        $display(" FAILED : %0d / 5", fail_count);
        if (fail_count == 0)
            $display(" RESULT : ALL TESTS PASSED");
        else
            $display(" RESULT : SOME TESTS FAILED");
        $display("=====================================================");
        $display("");

        $finish;
    end

	// Waveform dump
    initial begin
	`ifdef FUNCTIONAL
	$dumpfile("tb/tb_top_soc_gl.vcd");
	`else
	$dumpfile("tb/tb_top_soc_rtl.vcd");
	`endif
        $dumpvars(0, tb_top_soc);
    end

    // ------------------------------------------------------------
    // Timeout watchdog 500us
    // ------------------------------------------------------------
    initial begin
        #500000;
        $display("TIMEOUT: Simulation exceeded 500us");
        $finish;
    end

endmodule
