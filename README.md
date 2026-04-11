<div align="center">

<img src="https://umsousercontent.com/lib_lnlnuhLgkYnZdkSC/hj0vk05j0kemus1i.png" alt="ChipFoundry Logo" height="140" />

<h1>Smart Power Fault Analyzer SoC</h1>

<p><b>Real-Time Power Monitoring and Fault Classification IP for SoC Systems</b></p>

<p>
ASIC-Ready | OpenLane | Sky130
</p>

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![ChipFoundry Marketplace](https://img.shields.io/badge/ChipFoundry-Marketplace-6E40C9.svg)](https://platform.chipfoundry.io/marketplace)

</div>

### Project Information
**Project:** Smart Power Fault Analyzer (SPFA)  
**Target Application:** Electric Vehicle Battery Management System (EV-BMS) Safety Monitoring  
**Technology Platform:** Efabless Caravel SoC Harness 
**Target Frequency:** 40 MHz
**PDK:** SkyWater 130nm (Sky130A) Open-Source PDK  
**Design Flow:** OpenLane chipIgnite flow  
**Language:** Verilog HDL  
**Verification:** Cocotb / Icarus Verilog  

## Table of Contents
- [Problem Statement](#1-problem-statement)
- [Proposed Solution](#2-proposed-solution)
- [Application: EV Battery Management System (BMS)](#3-application-ev-battery-management-system-bms)
- [Feasibility & Cost Analysis](#4-feasibility--cost-analysis)
- [Caravel SoC Integration](#5-caravel-soc-integration)
- [GPIO Configurations](#6-gpio-configurations)
- [Verification Results](#7-verification-results)
- [Static Timing Analysis (STA)](#8-static-timing-analysis-sta)
- [Local Precheck](#9-local-precheck)
- [Quick Start](#10-quick-start)
- [Documentation & Resources](#documentation--resources)
- [Project Structure](#project-structure)
- [License](#license)
- [Contact](#contact)

---
## 1. Problem Statement
Modern **SoC-based embedded systems** rely on a **stable power supply** for correct operation. Unexpected events such as **over-voltage**, **under-voltage**, or **sudden current spikes** can cause:
- Component damage 
-	System crashes 
-	Reduced reliability and lifetime

**Limitations of traditional fault detection:**
- Fixed thresholds that cannot adapt during operation 
-	Separate monitoring circuits not integrated with the processor - slow decision-making 
-	Software-based detection suffers from latency, risking catastrophic failures

**Need:** A **fast**, **configurable**, **SoC-integrated fault detection** system that reacts in real time to **protect the system**.

---
## 2. Proposed Solution
The **Smart Power Fault Analyzer** SoC is a hardware IP block that performs real-time **power fault detection** and **classification** integrated into the **Caravel harness**.\
It continuously monitors a **12-bit ADC input**, compares sampled values against a **programmable threshold**, classifies **fault types**, and **raises maskable interrupt requests (IRQs)** to the Caravel management **RISC-V core** via the **Wishbone bus**.
### Key Features
| Feature | Description |
|--------|-------------|
| **12-bit ADC Interface** | Samples power signal via `io_in[11:0]` GPIO pads |
| **Fault Detection Engine** | Classifies overvoltage, undervoltage, and anomaly faults |
| **Wishbone Slave Interface** | Full 32-bit WB MI A compatible register interface |
| **Maskable IRQ** | `user_irq[0]` raised on fault detection |
| **Programmable Threshold** | 16-bit threshold register via WB address `0x04` |
| **Fault Mask Register** | 8-bit mask for selective fault enabling |
| **IRQ Latch & Clear** | Edge-triggered IRQ with software-clearable status |

### Fault Detection Logic
The Smart Power Fault Analyzer implements a comparator-based detection
mechanism to classify voltage anomalies in real time.

| Condition | Fault Type |
|-----------|-----------|
| ADC_value > threshold_high | Over-voltage |
| ADC_value < threshold_low | Under-voltage |
| ADC_value - previous_sample > spike_limit | Voltage spike |

The detection logic operates within a single clock cycle and generates
a fault classification signal that triggers an interrupt to the
Caravel management processor.

---
## 3. Application: EV Battery Management System (BMS)
This chip is designed as a **hardware-based voltage fault monitoring IP** for Electric Vehicle Battery Management Systems (EV-BMS).  
It enables real-time detection of **over-voltage and under-voltage conditions** with deterministic, low-latency response, overcoming the limitations of traditional software-based monitoring approaches.

### 1️⃣ Architectural Gap: Why This IP is Needed
EV Battery Management Systems require fast and reliable voltage monitoring under highly dynamic operating conditions:
- **Electrical Variations:** Voltage fluctuations during battery charging and discharging cycles  
- **Safety Requirements:** Deterministic detection of abnormal voltage conditions  
- **Dynamic Limits:** Configurable thresholds required for different operating states  

Traditional solutions rely on **software polling and external analog protection circuits**, which introduce:
- Non-deterministic response latency  
- Limited configurability and scalability  
- Increased system complexity and hardware cost  

### 2️⃣ System Integration: How the IP Operates
The **Smart Power Fault Analyzer (SPFA)** is integrated within the BMS SoC as a dedicated hardware monitoring IP block:
1. **Voltage Sampling** – Receives digitized voltage inputs from an external ADC  
2. **Threshold Configuration** – System processor configures voltage limits via control registers  
3. **Fault Detection** – Comparator logic evaluates thresholds and detects faults in a single clock cycle  
4. **Fault Signaling** – Generates an interrupt or status flag to the system controller  
5. **System Response** – Controller executes protective actions (e.g., disconnect battery, limit charging current)

### 3️⃣ Deployment Scenario: EV Battery Protection
In an EV Battery Management System, the SPFA module continuously monitors
battery voltage levels through digitized ADC inputs.

**When abnormal voltage conditions are detected**:
- **Over-voltage:** Charging current is reduced or disconnected  
- **Under-voltage:** Load isolation or system shutdown is triggered  
- **Voltage spike:** Controller performs immediate protection action  

The hardware interrupt generated by **SPFA** enables the system controller
to respond instantly, improving safety and system reliability.

### EV-BMS System Architecture
**Future EV BMS** architecture showing SPFA IP integrated on SoC for real-time fault detection and hardware safety interlocks (Caravel integration in progress).

<img src="https://github.com/user-attachments/assets/59ac80ba-045f-4b89-8c5d-ff6c5000dfda" alt="Future EV BMS Architecture" width="600" height="500">

---
## 4. Feasibility & Cost Analysis
### Bill of Materials (BOM) Comparison – EV BMS
This comparison illustrates a typical EV Battery Management System (BMS) implementation using discrete components versus a system integrating the **Smart Power Fault Analyzer (SPFA)** as an on-chip hardware IP.

| Component Category | Conventional Design (Discrete/COTS) | SPFA-Based SoC Approach | Impact |
|-------------------|--------------------------------------|------------------------|--------|
| Main Controller | Automotive-grade MCU | Integrated processor within SoC platform | Reduced external components |
| Fault Monitoring | Dedicated analog front-end / protection IC | On-chip SPFA hardware IP | Eliminates separate monitoring IC |
| Signal Conditioning | External analog circuitry | Simplified digital interface from ADC | Reduced analog circuitry |
| External Memory | Optional EEPROM / Flash | Integrated or system-level memory | Potential component reduction |
| PCB Complexity | Higher routing density | Simplified interconnect | Reduced PCB complexity |

### 💎 Estimated System Impact
- **Reduced external component count** due to integration of monitoring logic within the SoC
- **Lower PCB routing complexity** by minimizing external analog protection circuitry  
- **Improved system reliability** due to fewer discrete components and interconnects  
- **Better scalability** since voltage thresholds and monitoring logic are configurable in hardware

### 💰 Estimated Cost Impact
**By integrating SPFA** into the SoC, the design can eliminate a standalone voltage monitoring IC **(~$1–$3 per system)** and reduce PCB routing complexity.

---
## 5. Caravel SOC Integration
The **Smart Power Fault Analyzer (SPFA)** is integrated as a user IP inside the
Caravel SoC harness.
The module interfaces with the **Wishbone bus** for configuration
and receives **digitized voltage inputs** through the **GPIO interface**.

<img src="verilog/rtl/smart_fault_analyzer/docs/Caravel_harness_block_diagram.png" width="800"/>

### Integration Overview
The SPFA module connects to the Caravel system through three primary interfaces:

| Interface | Signal | Description |
|----------|--------|-------------|
| Wishbone | wb_* | Configuration and status register access |
| GPIO Input | io_in[11:0] | Digitized voltage from external ADC |
| Interrupt | user_irq[0] | Fault detection notification to CPU |
| Clock | wb_clk_i | System clock |
| Reset | wb_rst_i | Global reset |

The hardware performs voltage monitoring and fault detection in a single clock
cycle, enabling deterministic fault response for safety-critical systems.

---
## GDS Layout - user_project_wrapper
<img src="verilog/rtl/smart_fault_analyzer/docs/user_project_wrapper_gds.jpeg" width="700"/>

### 👉 Integration Details
- **Bus Interface:** Wishbone slave connected to Caravel management SoC  
- **Control Path:** CPU configures thresholds via memory-mapped registers  
- **Data Path:** ADC input (`io_in[11:0]`) processed in real-time  
- **Interrupt Handling:** Fault events trigger `user_irq[0]`  
<img src="verilog/rtl/smart_fault_analyzer/docs/user_project_wrapper_gds1.jpeg" width="500"/>

---
## 6. GPIO Configurations
The SPFA module interfaces with the Caravel SoC using GPIO pins
for receiving digitized voltage samples and generating fault interrupts.
- [IO & Pin Description](verilog/rtl/smart_fault_analyzer/README.md)

---
 ## 7. Verification Results
 The **Smart Power Fault Analyzer** (SPFA) was **verified** at multiple levels to ensure
correct **functionality** and **system** integration.

Verification includes:
- **RTL & GL simulation** using Icarus Verilog testbench
- **Firmware-level verification** using cocotb with C firmware

 ### 👉 RTL Simulation (iverilog)
- [RTL-Level Verification](verilog/rtl/smart_fault_analyzer/README.md)
### 👉 Gate-Level (GL) Simulation (iverilog)
- [Gate-Level (GL) Verfication](verilog/rtl/smart_fault_analyzer/README.md)

 ### 👉 Firmware Simulation (cocotb)
**Tool:** cocotb v1.9.2 + Icarus Verilog 12.0
| Test | Simulation | Result | Duration |
|---|---|---|---|
| `top_soc` | Firmware |  **PASSED** | 30,000 ns |

**Test Log Evidence:**\
<img src="verilog/rtl/smart_fault_analyzer/docs/firmware_verification.png " width="600"/>

| Firmware Files | [`verilog/dv/cocotb/user_proj_tests/top_soc`](verilog/dv/cocotb/user_proj_tests/top_soc) 
### Run Simulation
```bash
# Configure GPIO first
cf gpio-config
```
This command will:
- Configure GPIO pins **5–37 interactively**
- Show available GPIO modes
- Save configuration to `.cf/project.json`
- Update `verilog/rtl/user_defines.v`
- Generate GPIO defaults for simulation

### GPIO Pin Information
| GPIO Range | Description |
|-------------|-------------|
| GPIO[0–4] | Fixed system pins |
| GPIO[5–37] | User configurable |

```bash
# Run test
cf verify top_soc
```
### Verification Coverage Summary
| Feature Tested | Test Method |
|----------------|------------|
| Threshold configuration | Wishbone register write |
| Overvoltage detection | ADC test stimulus |
| Undervoltage detection | ADC test stimulus |
| Interrupt generation | Firmware test |
| Fault clearing | Register reset |

---
## 8. Static Timing Analysis (STA)
**Source:** OpenROAD post-route Static Timing Analysis generated by the OpenLane hardening flow
**PDK:** Sky130A
**Clock Frequency:** 40 MHz (25 ns clock period)

### 👉 top_soc Macro
| Metric | Value | Status |
|---|---|---|
| Setup WNS | 0 ns | PASS |
| Setup TNS | 0 ns | PASS |
| Setup Violations | 0 | PASS |
| Hold WNS | 0 ns | PASS |
| Hold TNS | 0 ns | PASS |
| Hold Violations | 0 | PASS |
| Setup Slack (r2r) | 20.27 ns | PASS |
| Hold Slack (r2r) | 0.78 ns | PASS |

<img width="700" height="500" alt="sta top_soc" src="https://github.com/user-attachments/assets/98b846b8-037d-45aa-8eac-a7810760cdd3" />

The timing results confirm that the **top_soc macro meets all setup and hold timing constraints** for the target clock frequency.

### 👉 user_project_wrapper
| Metric | Value | Status |
|---|---|---|
| Setup WNS | 0 ns | PASS |
| Setup TNS | 0 ns | PASS |
| Setup Violations | 0 | PASS |
| Hold WNS | -0.46 ns | WARNING |
| Hold TNS | -9.72 ns | WARNING |
| Hold Violations | 30 | WARNING |
| Setup Slack (r2r) | 20.27 ns | PASS |
| Hold Slack (r2r) | 0.82 ns | PASS |

<img width="700" height="500" alt="sta wrapper" src="https://github.com/user-attachments/assets/4c7872d5-b4bb-42a1-9840-9c0cac03d6bf" />

The hold violations appear at the wrapper integration level due to routing delays between the `top_soc` macro and the Caravel harness.
The internal `top_soc` macro itself is timing-clean with **zero setup and hold violations**.

### ⌛ STA Report
The following OpenLane **timing summary** shows the timing analysis results across multiple process corners.
Key observations:
- No setup violations across all corners
- No hold violations inside the top_soc macro
- Positive slack observed for setup and hold paths
  Design meets timing constraints for 40 MHz operation

---
## 9. Local Precheck
Before submitting, the local precheck was run to verify compliance with all **shuttle requirements**.
**Note:** GPIO configuration was completed before running precheck using `cf gpio-config`.

### Command
```bash
cf precheck --disable-lvs
```
### Results
<img width="600" height="777" alt="precheck passed" src="https://github.com/user-attachments/assets/f3911767-38d2-48e1-b5e9-c2d4fca8d9ec" />

_**LVS Note: `cf precheck LVS` reports top_soc as a black box due to a known tool
limitation where the precheck internally references user_proj_example.v
regardless of the actual project macro name.**_
```bash
cf precheck
```

<img width="500" height="500" alt="precheck" src="https://github.com/user-attachments/assets/51e9ffa1-7d48-4ffa-8958-4d1faa1d59fa" />

---
## 10. Quick Start
### 1. Repository Setup
Create a new repository based on the **caravel_fault_analyzer template** and clone it to your local machine:
```bash
git clone https://github.com/Shikha-Tiwari-Hub/caravel-fault-analyzer.git
pip install chipfoundry-cli
cd caravel_fault_analyzer
```
### 2. Platform Login
Log in to the ChipFoundry platform (required before `cf init`, `cf push`, `cf pull`, etc.):
```bash
cf login
```
### 3. Project Initialization
> ⚠️ **Important:** Run this first.
Initialize your project configuration:

```bash
cf init
```
This creates `.cf/project.json` with project metadata.  
This must be run before any other commands (`cf setup`, `cf gpio-config`, `cf harden`, `cf precheck`, `cf verify`).

### 4. Environment Setup

Install the ChipFoundry CLI tool and set up the local environment (PDKs, OpenLane, and Caravel Lite):

```bash
cf setup
```

The `cf setup` command installs:
- **Caravel Lite** – Caravel SoC template  
- **Management Core** – RISC-V management area required for simulation  
- **OpenLane** – RTL-to-GDS hardening flow  
- **PDK** – SkyWater 130nm process design kit  
- **Timing Scripts** – For Static Timing Analysis (STA)
  
---
## Development Flow
### Hardening the Design
Hardening is the process of synthesizing your RTL and performing **Place & Route (P&R)** to create a **GDSII layout**.
#### Macro Hardening
Create a subdirectory for each custom macro under `openlane/` containing your `config.json`.
```bash
cf harden --list
cf harden top_soc
```
### Wrapper Hardening
Finalize the top-level user project:
```bash
cf harden user_project_wrapper
```

---
## Known Warnings
During synthesis, place-and-route, and verification, a few warnings were observed.
These warnings are documented here for transparency.

### Hold Violations in `user_project_wrapper`
- **WNS:** -0.46 ns
- **Violations:** 30

**Root Cause:**
Hold violations occur at the integration boundary between the `top_soc` macro and the Caravel harness routing.

**Impact:**
The internal `top_soc` macro has **no setup or hold violations**, and the system operates correctly at the target **40 MHz clock frequency**.

**Status:**
Under investigation. These violations occur in fast process corners and do not affect functional verification results.

### Antenna Violations
- **Count:** 6 (wrapper level)

**Root Cause:**
Long routing nets on some GPIO input paths without antenna diode insertion.

**Impact:**
These violations are minor and are common in wrapper-level routing during OpenLane integration.

**Status:**
Within acceptable limits for experimental MPW submissions.

### Gate-Level (GL) Simulation with `cf verify --sim gl`
**Observation:**
`caravel-lite` installations may not include the `caravel_core.mag` file required by the `gen_gpio_defaults.py` script.

**Workaround:**
Gate-level verification was performed independently using:
- Icarus Verilog
- Generated gate-level netlists
- Sky130A standard cell models

**Result:**
All verification tests passed successfully.

---
## Documentation & Resources
For detailed background research and related methodologies, the following academic references were consulted during the design and architecture planning of the Smart Power Fault Analyzer (SPFA).

### Research References
- **[SoC-Based Early Fault Detector](https://link.springer.com/chapter/10.1007/978-981-97-8476-9_26)**  
  Development of a System-on-Chip based early fault detection system for industrial motor monitoring and protection.
- **[Fault Detection and Diagnosis of Electric Vehicles](https://www.mdpi.com/2075-1702/11/7/713)**  
  Research on fault detection strategies and diagnostic techniques for electric vehicle power systems.
  
---

## AI-Assisted Workflow & Queries
AI tools were used to assist in design exploration, debugging, and documentation structuring during the development of this project.

### AI Contributions
**Architecture Exploration**  
*Tool used: ChatGPT*
- Assisted in conceptualizing the Smart Power Fault Analyzer architecture
- Explored ADC interfacing strategies
- Evaluated threshold-based voltage monitoring techniques
- Discussed FSM-based control logic and interrupt signaling for SoC integration

**RTL Debugging and Verification Support**  
*Tool used: ChatGPT*
- Assisted with debugging RTL modules and simulation setup
- Supported firmware-level verification for:
  - `top_soc.c`
  - `top_soc.py`
  - `top_soc.yaml`

**System Architecture Visualization**  
*Tool used: Google Gemini*
- Generated conceptual diagrams for the **Future EV Battery Management System (BMS) architecture** used in the project documentation.
---
## Project Structure

| Directory / File | Description |
|------------------|-------------|
| [`verilog/rtl/smart_fault_analyzer`](verilog/rtl/smart_fault_analyzer) | RTL source code for Smart Power Fault Analyzer modules (ADC interface, fault detection, FSM, buffer) |
| [`verilog/rtl/smart_fault_analyzer/tb`](verilog/rtl/smart_fault_analyzer/tb) | Testbench files for functional verification |
| [`openlane/top_soc/final/gds`](openlane/top_soc/gds) | GDSII layout file (`top_soc.gds`) |
| [`openlane/user_project_wrapper/final/gds`](openlane/user_project_wrapper/gds) | GDSII layout file (`user_project_wrapper.gds`)|
| [`verilog/dv/cocotb/user_proj_tests/top_soc`](verilog/dv/cocotb/user_proj_tests/top_soc) | Firmware Verification |
| [`verilog/rtl/smart_fault_analyzer/docs`](verilog/rtl/smart_fault_analyzer/docs) | Architecture diagrams, waveform images, and GDS images |
| [`README.md`](README.md) | Project overview and documentation |

---
## License
This project is licensed under the [Apache License 2.0](http://www.apache.org/licenses/).

## Contact
Questions and collaboration: shikhatiwari2112@gmail.com

---


