module fault_analyzer_regs (
    input         clk,
    input         rst_n,
 
    // Wishbone interface
    input  [7:0]  wb_addr,
    input  [31:0] wb_wdata,
    output reg [31:0] wb_rdata,
    input         wb_wr,
    input         wb_rd,
    output reg    wb_ack,
 
    // Fault interface
    input  [7:0]  fault_flags,
    input  [15:0] adc_value,
 
    // Control outputs
    output reg [15:0] threshold,
    output reg        enable,
    output reg [7:0]  fault_mask,
 
    // IRQ output
    output wire       irq
);
 
    reg [7:0] irq_latched;
 
    wire [7:0] prev_fault_flags_reg;
    reg  [7:0] prev_fault_flags;
 
    wire [7:0] irq_set   = (fault_flags & ~prev_fault_flags) & fault_mask;
    wire [7:0] irq_clear = (wb_wr && (wb_addr == 8'h14)) ? wb_wdata[7:0] : 8'd0;
    wire [7:0] irq_next  = (irq_latched | (enable ? irq_set : 8'd0)) & ~irq_clear;
 
    assign irq = |irq_latched;
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_ack        <= 1'b0;
            wb_rdata      <= 32'b0;
            threshold     <= 16'd2000;
            enable        <= 1'b0;
            fault_mask    <= 8'hFF;
            irq_latched   <= 8'b0;
            prev_fault_flags <= 8'b0;
        end else begin
            prev_fault_flags <= fault_flags;
            irq_latched      <= irq_next;
            wb_ack           <= 1'b0;
 
            if (wb_wr) begin
                wb_ack <= 1'b1;
                case (wb_addr)
                    8'h00: enable        <= wb_wdata[0];
                    8'h04: threshold     <= wb_wdata[15:0];
                    8'h08: fault_mask    <= wb_wdata[7:0];
                    8'h14: ; // IRQ clear handled by irq_clear wire
                    default: ;
                endcase
            end else if (wb_rd) begin
                wb_ack <= 1'b1;
                case (wb_addr)
                    8'h00: wb_rdata <= {31'b0, enable};
                    8'h04: wb_rdata <= {16'b0, threshold};
                    8'h08: wb_rdata <= {24'b0, fault_mask};
                    8'h0C: wb_rdata <= {24'b0, irq_latched};
                    8'h10: wb_rdata <= {16'b0, adc_value};
                    default: wb_rdata <= 32'b0;
                endcase
            end
        end
    end
 
endmodule
 
`default_nettype wire
