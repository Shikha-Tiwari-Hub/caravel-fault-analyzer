`timescale 1ns/1ps
// SPDX-License-Identifier: Apache-2.0
// Organization: VIPS-TC
// Engineer: Shikha Tiwari
// Description: Testbench for Smart Power Fault Signature Analyzer SoC
//
// Fault Detection Thresholds (from fault_detect.v):
//   HIGH_TH  = 3500  → Overcurrent fault
//   LOW_TH   = 500   → Undervoltage fault
//   SPIKE_TH = 800   → Spike fault

module tb_top_soc;

    reg         wb_clk_i, wb_rst_i;
    reg         wbs_cyc_i, wbs_stb_i, wbs_we_i;
    reg  [3:0]  wbs_sel_i;
    reg  [31:0] wbs_adr_i, wbs_dat_i;
    wire [31:0] wbs_dat_o;
    wire        wbs_ack_o;
    reg  [11:0] adc_data_in;
    wire [2:0]  user_irq;

    // DUT
    top_soc dut (
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

    // Clock 10ns period
    initial wb_clk_i = 0;
    always #5 wb_clk_i = ~wb_clk_i;

    integer pass_count = 0;
    integer fail_count = 0;

    // Wishbone WRITE
    task wb_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge wb_clk_i);
            wbs_adr_i = addr;
            wbs_dat_i = data;
            wbs_we_i  = 1;
            wbs_cyc_i = 1;
            wbs_stb_i = 1;
            wbs_sel_i = 4'hF;
            while (!wbs_ack_o) @(posedge wb_clk_i);
            @(posedge wb_clk_i);
            wbs_cyc_i = 0;
            wbs_stb_i = 0;
            wbs_we_i  = 0;
        end
    endtask

    // Wishbone READ
    task wb_read;
        input [31:0] addr;
        begin
            @(posedge wb_clk_i);
            wbs_adr_i = addr;
            wbs_we_i  = 0;
            wbs_cyc_i = 1;
            wbs_stb_i = 1;
            wbs_sel_i = 4'hF;
            while (!wbs_ack_o) @(posedge wb_clk_i);
            @(posedge wb_clk_i);
            $display("    READ [0x%h] = 0x%h", addr, wbs_dat_o);
            wbs_cyc_i = 0;
            wbs_stb_i = 0;
        end
    endtask

    initial begin
        // Init
        wb_rst_i    = 1;
        wbs_cyc_i   = 0;
        wbs_stb_i   = 0;
        wbs_we_i    = 0;
        wbs_sel_i   = 0;
        wbs_adr_i   = 0;
        wbs_dat_i   = 0;
        adc_data_in = 0;

        $display("");
        $display("=====================================================");
        $display(" Smart Power Fault Signature Analyzer - Testbench   ");
        $display("=====================================================");



        // TEST 1: Normal operation
        $display("\n[TEST 2] Normal Operation (ADC=1000, No Fault)");
	repeat(5) @(posedge wb_clk_i);
	wb_rst_i = 0;
	repeat(2) @(posedge wb_clk_i);

        adc_data_in = 12'd1000;
        repeat(10) @(posedge wb_clk_i);
        if (user_irq[0] == 0) begin
            $display("    PASS: No IRQ for normal ADC=1000");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: Unexpected IRQ for ADC=1000");
            fail_count = fail_count + 1;
        end


        // TEST 2: Enable fault detection engine
        $display("\n[TEST 1] Enable Fault Detection Engine");
        wb_write(32'h00, 32'd1);
        repeat(2) @(posedge wb_clk_i);
        wb_read(32'h00);
        if (wbs_dat_o[0] == 1) begin
            $display("    PASS: Enable register set correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: Enable register not set");
            fail_count = fail_count + 1;
        end

        // TEST 3: Overcurrent fault
        $display("\n[TEST 3] Overcurrent Fault (ADC=4000 > HIGH_TH=3500)");
        adc_data_in = 12'd4000;
        repeat(10) @(posedge wb_clk_i);
        if (user_irq[0] == 1) begin
            $display("    PASS: IRQ triggered for overcurrent");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: No IRQ for overcurrent");
            fail_count = fail_count + 1;
        end
        wb_read(32'h0C);
        wb_write(32'h14, 32'hFF);
        repeat(3) @(posedge wb_clk_i);

        // TEST 4: Undervoltage fault
        $display("\n[TEST 4] Undervoltage Fault (ADC=200 < LOW_TH=500)");
        adc_data_in = 12'd200;
        repeat(10) @(posedge wb_clk_i);
        if (user_irq[0] == 1) begin
            $display("    PASS: IRQ triggered for undervoltage");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: No IRQ for undervoltage");
            fail_count = fail_count + 1;
        end
        wb_write(32'h14, 32'hFF);
        repeat(3) @(posedge wb_clk_i);

        // TEST 5: Spike detection
        $display("\n[TEST 5] Spike Detection (1000 to 2000, delta > SPIKE_TH=800)");
        adc_data_in = 12'd1000;
        repeat(5) @(posedge wb_clk_i);
        adc_data_in = 12'd2000;
        repeat(10) @(posedge wb_clk_i);
        if (user_irq[0] == 1) begin
            $display("    PASS: IRQ triggered for spike");
            pass_count = pass_count + 1;
        end else begin
            $display("    FAIL: No IRQ for spike");
            fail_count = fail_count + 1;
        end

        // Summary
        $display("");
        $display("=====================================================");
        $display(" PASSED : %0d / 5", pass_count);
        $display(" FAILED : %0d / 5", fail_count);
        if (fail_count == 0)
            $display(" RESULT : ALL TESTS PASSED");
        else
            $display(" RESULT : SOME TESTS FAILED");
        $display("=====================================================");

        $finish;
    end

    initial begin
        $dumpfile("tb_top_soc.vcd");
        $dumpvars(0, tb_top_soc);
    end

    initial begin
        #100000;
        $display("TIMEOUT");
        $finish;
    end

endmodule
