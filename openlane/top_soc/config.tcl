set ::env(DESIGN_NAME) top_soc

set ::env(VERILOG_FILES) "\
$::env(DESIGN_DIR)/../../verilog/rtl/smart_fault_analyzer/top_soc.v \
$::env(DESIGN_DIR)/../../verilog/rtl/smart_fault_analyzer/adc.v \
$::env(DESIGN_DIR)/../../verilog/rtl/smart_fault_analyzer/circular_buffer.v \
$::env(DESIGN_DIR)/../../verilog/rtl/smart_fault_analyzer/fault_detect.v \
$::env(DESIGN_DIR)/../../verilog/rtl/smart_fault_analyzer/event_fsm.v"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "10"

set ::env(FP_CORE_UTIL) 40
set ::env(FP_ASPECT_RATIO) 1.0

set ::env(PNR_SDC_FILE) "$::env(DESIGN_DIR)/base.sdc"
set ::env(SIGNOFF_SDC_FILE) "$::env(DESIGN_DIR)/base.sdc"

