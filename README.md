# Asynchronous FIFO with UVM Verification

## Overview
This project implements an **Asynchronous FIFO** in SystemVerilog and verifies the design using a **UVM (Universal Verification Methodology) based verification environment**.

The FIFO enables safe data transfer between two independent clock domains, addressing common **Clock Domain Crossing (CDC)** challenges.

## Design Features
- Dual clock domains (write clock and read clock)
- Parameterizable data width and FIFO depth
- Full and Empty flag generation
- Gray code pointer synchronization for CDC safety
- Synthesizable RTL implementation

## Verification Environment
The design is verified using a **UVM testbench architecture** including:

- UVM agents for read and write interfaces
- Drivers and monitors for stimulus and observation
- Sequencers and sequences for transaction generation
- Scoreboard for functional checking
- Interface-based DUT communication

## Repository Structure

```
rtl/   -> RTL implementation of asynchronous FIFO
tb/    -> Top-level testbench and interface
uvm/   -> UVM verification components
```

## Tools Used
- SystemVerilog
- UVM
- ModelSim / QuestaSim simulation

## Learning Outcomes
- Clock Domain Crossing (CDC) design
- FIFO architecture and pointer synchronization
- UVM verification environment development
- Testbench architecture and functional checking
