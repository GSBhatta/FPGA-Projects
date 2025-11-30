Here is your final polished, **ATS-ready, technically accurate, GitHub-understandable README** with badges, topics, and placeholders you can replace with PDF links in your repo or releases.

---

## 🔝 **ADC128S022 Interface using DE0-Nano (Cyclone IV E FPGA)**

![SPI](https://img.shields.io/badge/Protocol-SPI-blue)
![HDL](https://img.shields.io/badge/HDL-Verilog-orange)
![Clock](https://img.shields.io/badge/CLK-50MHz-green)
![SCLK](https://img.shields.io/badge/SCLK-3.125MHz-yellowgreen)

---

## 📌 Overview

A **single-file Verilog RTL module** implementing a **datasheet-accurate SPI Master interface** between the 12-bit, 8-channel ADC128S022 and the DE0‑Nano (powered by Intel Altera).
The design streams **12-bit MSB-first samples** into FPGA logic with runtime sampling-rate control and **5 ADC acquisition modes**.

---

## ⚙ Key Specifications

| Spec                  | Value                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------- |
| System Clock (`clk`)  | **50 MHz**                                                                            |
| SPI Clock (`sclk`)    | **3.125 MHz**                                                                         |
| PLL Usage             | ❌ Not used; **sclk not derived from PLL or external PLL/PLL phase-aligned clock**     |
| Clock Source          | Pure RTL divider, **No PLL, No PLL Phase alignment, No jitter compensation from PLL** |
| SPI Frame Size        | **16 sclk cycles per SPI frame**                                                      |
| Valid ADC Data Window | **Bits 4–15 (12-bit)**                                                                |
| Sample Capture        | **DOUT latched on sclk rising edge**                                                  |
| DIN Update            | **DIN driven on sclk falling edge**                                                   |
| ADC Command Sampling  | ADC samples DIN internally on **3rd sclk falling edge after CS goes LOW**             |
| Data Width            | **12 bits**                                                                           |
| Latency               | Command accepted from 3rd edge, data read in same 16-cycle frame                      |
| Modes Implemented     | `idle`, `single`, `continuous`, `single_continuous`, `continuous_oneshot`             |

---

## 🚀 Features

* ✅ Datasheet-accurate SPI Master timing for ADC128S022
* ✅ Controllable sampling rate via `sample_en` logic (no PLL dependency)
* ✅ 5 ADC modes for flexible acquisition control
* ✅ Multi-channel SCAN + ANY channel combination supported
* ✅ Behavioral + gate-level verified, with FPGA bring-up tested
* 📦 Next version supports **internal M9K memory writes** for sample storage

---

## ❗ FPGA Debug Limitation (Be honest & interview ready)

* **Continuous and Single-Continuous modes** validated in hardware using Signal Tap.
* **Single and One-Shot modes** could not be debug-triggered reliably in Signal Tap Logic Analyzer due to trigger constraints, but **both modes are fully verified in behavioral and gate simulation**.

---

## 📂 Actual Repository Structure

```
root/
├── adc_interface.v      # RTL: SPI Master + ADC control (ONLY file implemented)
├── adc_interface_tb.v   # Verilog testbench (stimulus + mode coverage)
├── constraints/
│   ├── pin_constraints.qsf  # Board pin mapping
│   └── adc_timing.sdc      # 50 MHz system timing constraints
├── synthesis/
│   └── resource_report.txt  # LE, register, and memory usage (to be added)
├── results/
│   ├── rtl_waveform.png    # Behavioral sim result
│   ├── gate_waveform.png   # Gate-level result
│   └── fpga_capture.png    # Signal Tap capture for streaming modes
└── README.md (this)
```

---

## 🧪 Verification Flow

| Stage                 | Status                               |
| --------------------- | ------------------------------------ |
| Behavioral Simulation | ✅ All 5 modes verified               |
| Gate-Level Simulation | ✅ Timing preserved after synthesis   |
| FPGA Validation       | ✅ Live data streaming proven         |
| Signal Tap Analysis   | ⚠ Single/One-Shot trigger limitation |

---

## 🕒 Timing Behavior Summary

1. `CS_n` asserted LOW → SPI frame begins
2. `DIN` updated on **every sclk falling edge**
3. ADC samples command at **3rd falling edge** (internal to ADC)
4. `DOUT` captured on sclk rising edge
5. 16 clocks total, **12-bit valid data at bits 4–15**
6. `CS_n` de-asserted HIGH → frame complete

---

## 🛠 Tools & Technology

* FPGA Bring-up → Using Quartus Prime Lite
* Simulation → Tested on ModelSim‑Intel FPGA Starter Edition
* RTL -> Bitstream flow → Quartus synthesis, place-and-route, timing closure @ 50 MHz
* Debug → Continuously monitored using Signal Tap logic triggers

---

## 📚 Reference PDFs (add them to GitHub Releases)

Once you upload manuals/datasheets to **GitHub Releases** or `/references/` folder in your repo, update these links:

* 📘 [DE0-Nano User Manual PDF](replace_with_your_pdf_link)
* 📘 [ADC128S022 Datasheet PDF](replace_with_your_pdf_link)

---

## 🏁 Outcome

A **robust, protocol-compliant FPGA acquisition system** demonstrating strong command of:

* ✅ Datasheet-driven RTL design
* ✅ SPI framing and edge-accurate sampling
* ✅ Multi-mode ADC control
* ✅ Clock-domain debugging **without PLL dependency**



