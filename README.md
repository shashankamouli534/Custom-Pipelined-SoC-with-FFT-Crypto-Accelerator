# Custom SoC with FFT and Crypto Accelerators

This project implements a simple **System-on-Chip (SoC)** design using a custom CPU and two hardware accelerators: **FFT** and **Crypto**.  
The goal of the project is to understand how a CPU can interact with hardware accelerators using **memory-mapped registers** and shared memory.

The design is written in Verilog/SystemVerilog and simulated using **Icarus Verilog**.

---

## Project Overview

The SoC consists of:
- A basic pipelined CPU core
- An FFT accelerator
- A cryptographic accelerator
- Shared RAM
- A simple interconnect and memory arbiter

The CPU controls the accelerators by writing to and reading from their registers.  
The accelerators run for multiple cycles and signal completion using a status register.

---

## High-Level Architecture

CPU
│
│ CPU Bus
│
Interconnect
│
├── RAM
├── FFT Accelerator
└── Crypto Accelerator

yaml
Copy code

The FFT and Crypto accelerators share the same RAM as the CPU.  
An arbiter is used to handle memory access between the CPU and the accelerators.

---

## Address Map

| Address Range | Component |
|--------------|----------|
| `0x00000xxxxx` | RAM |
| `0x60000xxxxx` | Crypto Accelerator |
| `0x70000xxxxx` | FFT Accelerator |

Address decoding is based on the upper address bits.

---

## Accelerator Registers

Both FFT and Crypto accelerators use the same register layout.

| Offset | Register | Description |
|------|---------|-------------|
| `0` | CTRL | Bit 0 starts the accelerator |
| `1` | STATUS | Bit 0 indicates completion |
| `2` | IN_BASE | Input data base address |
| `3` | OUT_BASE | Output data base address |

---

## Accelerator Usage

The CPU interacts with the accelerators using the following steps:

1. Write the input buffer address
2. Write the output buffer address
3. Write `1` to the CTRL register
4. Poll the STATUS register until DONE is set

---

## Verification

The design is verified using a simple testbench that:
- Resets the SoC
- Writes to accelerator registers
- Starts FFT and Crypto operations
- Polls for completion
- Runs accelerators multiple times

Simulation waveforms are generated using GTKWave.

---
