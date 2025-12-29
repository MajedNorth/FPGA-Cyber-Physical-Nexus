\# \[Project Name]: Heterogeneous FPGA Signal Processing Platform



\## 🚀 Overview

This project is a multi-stage system architecture design using the \*\*Xilinx Artix-7 (Basys 3)\*\* as a central processing hub. The system integrates external microcontrollers (ESP32, STM32) to perform real-time signal analysis across both digital (Wi-Fi) and physical (Vibration) domains.



\*\*Core Architecture:\*\*

\* \*\*Hub:\*\* Basys 3 FPGA (Data Aggregation, Filtering, Visualization)

\* \*\*Cyber Agent:\*\* ESP32 (Wi-Fi Packet Sniffing \& Injection)

\* \*\*Physical Agent:\*\* STM32 (High-Speed Accelerometer DSP)



---



\## 🗺️ Project Roadmap



\### Phase 1: The Foundation (Reliable Communication)

\*Goal: Establish a robust UART Physical Layer verified by Oscilloscope.\*

\- \[x] \*\*Milestone 1:\*\* RTL Design of UART Receiver (State Machine).

\- \[x] \*\*Milestone 2:\*\* Formal Verification using SymbiYosys (Mathematically Proven).

\- \[x] \*\*Milestone 3:\*\* UVM-style Simulation \& Random Testing.

\- \[x] \*\*Milestone 4:\*\* Hardware Integration (Verified 9600 Baud Timing on Rigol Scope).

\- \[ ] \*\*Milestone 4.5:\*\* 7-Segment Display Driver (Hex Visualization).



\### Phase 2: The "Hacker" Dashboard (Cyber-Security)

\*Goal: Packet inspection and traffic visualization.\*

\- \[ ] \*\*Milestone 5:\*\* ESP32 Raw Packet Streaming.

\- \[ ] \*\*Milestone 6:\*\* FPGA Custom Packet Parser.

\- \[ ] \*\*Milestone 7:\*\* Traffic Density Visualization (Breathing LEDs).



\### Phase 3: The DSP Monitor (Signal Processing)

\*Goal: Real-time vibration analysis and filtering.\*

\- \[ ] \*\*Milestone 8:\*\* STM32 High-Speed Sensor Streaming (1kHz).

\- \[ ] \*\*Milestone 9:\*\* Verilog Moving Average Filter (Noise Reduction).

\- \[ ] \*\*Milestone 10:\*\* Zero-Crossing Frequency Detector.



---



\## 📸 Proof of Concept

\### Phase 1: Physical Layer Verification

\*Below: Oscilloscope capture of the character 'p' (0x70) traversing the FPGA spy-pin. Verified 104µs bit width consistent with 9600 baud.\*





---



\## 🛠️ Tech Stack

\* \*\*Hardware:\*\* Xilinx Basys 3, Rigol DS1054Z, ESP32-C3, STM32F4.

\* \*\*Languages:\*\* SystemVerilog, Tcl, C++.

\* \*\*Tools:\*\* Vivado 2023.2, Tera Term, SymbiYosys.

