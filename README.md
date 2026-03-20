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


## Table of Contents
- [Overview](#overview)
- [Documentation & Resources](#documentation--resources)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Starting Your Project](#starting-your-project)
- [Development Flow](#development-flow)
- [GPIO Configuration](#gpio-configuration)
- [Local Precheck](#local-precheck)
- [Checklist for Shuttle Submission](#checklist-for-shuttle-submission)

## 1. Problem Statement
Modern embedded and SoC-based systems require stable power supply for proper operation. However, issues such as over-voltage, under-voltage, and sudden current spikes can damage the system or reduce reliability.

Traditional fault detection systems have several limitations:
- They use fixed thresholds and cannot be changed during operation.
- They are not integrated with the processor, so decision-making is limited.
- They rely on external monitoring circuits, which increases response time.

Therefore, a configurable and fast fault detection system integrated within the SoC is required.

---
## 2. Proposed Solution
The Smart Power Fault Analyzer is a hardware IP block integrated into the SoC. It continuously monitors power signals and detects faults in real time.
Main capabilities:
- Continuous monitoring of power signals using ADC input
- Detection and classification of faults (over-voltage, under-voltage, spikes)
- Fast response using hardware logic
- Interrupt generation to notify the processor immediately

This makes the system reliable and suitable for real-time applications.

---
### Comparison with Traditional Methods

| Feature        | Proposed SoC Solution                  | Traditional External System          |
|---------------|--------------------------------------|------------------------------------|
| **Response Time** | **Nanoseconds** to Microseconds          | Milliseconds to Seconds            |
| **Thresholds**    | **Software-programmable** (via registers)| Fixed hardware-based               |
| **Footprint**     | **Integrated** (no extra PCB space)      | External (extra board area needed) |
| **Intelligence**  | **FSM-based classification**             | Simple "Trip / No Trip" logic      |

---
## 3. System Architecture
The design consists of four main subsystems:
**1. Signal Acquisition** – Receives and synchronizes ADC input samples  
**2. Fault Processing** – Compares inputs with thresholds and detects faults  
**3. Data Capture** – Circular buffer stores pre/post fault data (black box)  
**4. Control Logic (FSM)** – Manages detection, capture, and communication

### Block Architecture Diagram
<p align="center">
  <img src="verilog/rtl/smart_fault_analyzer/assets/fault_analyzer_block_diagram.png" height="400 width="600"/>
</p>

---

## 4. Control FSM Design
The system operates using a finite state machine with the following states:

- Monitor: Normal operation, continuously checking signals
- Fault: Fault condition detected
- Post Capture: Additional data is recorded
- Freeze: Buffer is stopped to preserve data
- Send: Data/interrupt is sent to the processor
This ensures controlled and predictable system behavior.

<p align="center">
  <img src="verilog/rtl/smart_fault_analyzer/assets/fault_analyzer_FSM_DIAGRAM.png" height= "600" width="400"/>
</p>

---

 ## 5. Verification Results
 <p align="center">
  <img src="verilog/rtl/smart_fault_analyzer/assets/fault_analyzer_WAVEFORM.png" width="900"/>
</p>

---
## 6. GDS Layout - Smart_fault_analyzer : top_soc 
<p align="center">
  <img src="verilog/rtl/smart_fault_analyzer/assets/top_soc_GDS.jpeg" width="900"/>
</p>

---
## 7. Implementation Status
- RTL modules implemented: ADC Interface, Fault Detection Engine, Fault Classification, Circular Buffer, Event FSM Controller  
- Functional verification performed for fault detection and FSM behavior  

### Future Work
- Design and implement memory-mapped register interface for configuration and status monitoring  
- Integrate interrupt (IRQ) interface for processor communication  
- Integrate with Caravel SoC platform

---
 ## 8. Scalability and Future Scope
The proposed Smart Power Fault Analyzer SoC is designed with a modular and scalable architecture, enabling future extensions without major redesign.
- Multi-channel monitoring support
- Extension to voltage, current, and temperature sensing
- On-chip ADC integration
- Advanced fault logging and analytics
- Potential evolution into full power management IP

---
## 9. Applications
### Industrial Systems
- Motor controllers  
- Power converters  
- PLC systems  

### Commercial Systems
- Server power management  
- Smart meters  
- Battery management systems  

### Edge / IoT Systems
- Smart gateways  
- Remote monitoring nodes  
- Solar inverters  
- EV charging systems  

---

## Documentation & Resources
For detailed hardware specifications and register maps, refer to the following official documents:

* **[Caravel Datasheet](https://github.com/chipfoundry/caravel/blob/main/docs/caravel_datasheet_2.pdf)**: Detailed electrical and physical specifications of the Caravel harness.
* **[ChipFoundry Marketplace](https://platform.chipfoundry.io/marketplace)**: Access additional IP blocks, EDA tools, and shuttle services.
  
### AI-Assisted Workflow
- Design understanding and architecture planning
- RTL debugging and refinement
- Documentation structuring
* **[Waveform Debug](https://chatgpt.com/c/69b9765c-bc60-8324-8daf-400bc8c293d0)**: Complete register maps and programming guides for the management SoC.
* **[How can I design a Smart Power Fault Analyzer SoC for real-time monitoring?](https://chatgpt.com/c/69b99075-96c0-8324-91ed-80040d785bbe)**: Complete register maps and programming guides for the management SoC.
* **[Waveform Debug](https://chatgpt.com/c/69b9765c-bc60-8324-8daf-400bc8c293d0)**: Complete register maps and programming guides for the management SoC.
---

## License
This project is licensed under the [Apache License 2.0](LICENSE).

## Contact
Shikha 
shikhatiwari2112@gmail.com

---


