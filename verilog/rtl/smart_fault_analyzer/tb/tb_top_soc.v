`timescale 1ns / 1ps
module tb_top_soc;

    // Inputs
    reg clk;
    reg rst;
    reg [11:0] adc_in;
    reg tx_done;  // External signal simulation

    // Outputs
    wire fault_flag;
    wire [1:0] fault_type;
    wire freeze_buffer;
    wire send_data;

    // Instantiate Top Module
    top_soc dut (
        .clk(clk),
        .rst(rst),
        .adc_in(adc_in),
        .tx_done(tx_done),
        .fault_flag(fault_flag),
        .fault_type(fault_type),
        .freeze_buffer(freeze_buffer),
        .send_data(send_data)
    );

    // Clock Generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
initial begin
    $display("TESTBENCH STARTED");
end

    // Test Process
    initial begin
        // 1. Dump Waveform
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top_soc);

	// 2. Initialize
        rst = 1;
        adc_in = 12'd1000;
        tx_done = 0;
        
        // 3. Release Reset
        repeat(5) @(posedge clk);
        rst = 0;
        $display("Time %0t: System Reset Released", $time);

        // 4. Normal Operation
        repeat(20) @(posedge clk);
        
        // 5. Inject Fault
        $display("Time %0t: Injecting Over-Voltage Fault", $time);
        adc_in = 12'd4000; // Value > 3500 threshold
        
        // Wait for detection
        wait(fault_flag == 1);
        $display("Time %0t: Fault Detected!", $time);

        // 6. Wait for Freeze
        wait(freeze_buffer == 1);
        $display("Time %0t: Buffer Frozen. System in SEND mode.", $time);

        // 7. Simulate Data Transmission Done
        repeat(10) @(posedge clk);
        $display("Time %0t: Asserting TX_DONE", $time);
        tx_done = 1;
        @(posedge clk);
        tx_done = 0;

        // 8. Check Return to Normal
        wait(freeze_buffer == 0);
        $display("Time %0t: System returned to MONITOR mode.", $time);

        repeat(10) @(posedge clk);
        $display("Time %0t: Simulation Passed.", $time);
#1000; 
    $finish;
end

endmodule

