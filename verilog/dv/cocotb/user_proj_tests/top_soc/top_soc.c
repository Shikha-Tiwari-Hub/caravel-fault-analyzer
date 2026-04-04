// SPDX-License-Identifier: Apache-2.0
// Organization: VIPS-TC
// Engineer: Shikha Tiwari
// Description: Firmware test for Smart Power Fault Signature Analyzer SoC
//              Tests fault detection via Wishbone register interface

#include <stdint.h>
#include <stdio.h>

// Memory Map (Derived from fault_analyzer_regs case statement)
#define USER_PROJECT_BASE  0x30000000
#define REG_ENABLE         (USER_PROJECT_BASE + 0x00)
#define REG_THRESHOLD      (USER_PROJECT_BASE + 0x04)
#define REG_FAULT_MASK     (USER_PROJECT_BASE + 0x08)
#define REG_IRQ_STATUS     (USER_PROJECT_BASE + 0x0C)
#define REG_ADC_VALUE      (USER_PROJECT_BASE + 0x10)
#define REG_IRQ_CLEAR      (USER_PROJECT_BASE + 0x14)

// Volatile pointers for memory-mapped I/O
volatile uint32_t *enable_reg     = (volatile uint32_t *)REG_ENABLE;
volatile uint32_t *threshold_reg  = (volatile uint32_t *)REG_THRESHOLD;
volatile uint32_t *fault_mask_reg = (volatile uint32_t *)REG_FAULT_MASK;
volatile uint32_t *irq_status_reg = (volatile uint32_t *)REG_IRQ_STATUS;
volatile uint32_t *adc_value_reg  = (volatile uint32_t *)REG_ADC_VALUE;
volatile uint32_t *irq_clear_reg  = (volatile uint32_t *)REG_IRQ_CLEAR;

// Debug register (visible in simulation waveforms)
volatile uint32_t *debug_reg = (volatile uint32_t *)0x300FFFFC;

// Simple loop delay
void delay(int count) {
    for (volatile int i = 0; i < count; i++);
}

void main() {
    // 1. Enable fault detection system
    *enable_reg = 0x01;

    // 2. Set fault threshold (e.g., 2000 ADC counts)
    *threshold_reg = 2000;

    // 3. Enable all fault masks
    *fault_mask_reg = 0xFF;

    // 4. Poll until fault is detected (IRQ status bit 0 goes high)
    uint32_t status = 0;
    while ((status & 0x01) == 0) {
        status = *irq_status_reg;
    }

    // 5. Read ADC value that caused the fault
    //    Store in debug register so it appears in simulation waveforms
    *debug_reg = *adc_value_reg;

    // 6. Clear the IRQ
    *irq_clear_reg = 0xFF;

    delay(100);

    // End test - loop forever
    while (1);
}
