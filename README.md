# Simple 9-bit Processor (FPGA, SystemVerilog)

This project implements a simple 9-bit processor in SystemVerilog, tested on Intel DE10 board.  
Project done as part of the Digital Electronics Lab, Hebrew University of Jerusalem.

---

## Part I – Base Processor
- Components: registers, multiplexer, ALU (add/sub), decoder, control FSM
- Instruction set:
  - `mv Rx,Ry` – copy
  - `mvi Rx,#D` – move immediate
  - `add Rx,Ry` – addition
  - `sub Rx,Ry` – subtraction
- Functional and timing simulation
- Implemented and tested on FPGA

---

## Part II – Extended Processor
- Added program ROM (`inst_mem.mif`) for instruction storage
- Additional modules: memory unit, extended top-level processor
- New instructions:
  - `ones Rx,Ry` – count 1-bits in Rx → Ry
  - `specialMult Rx,Ry` – Ry = Rx × 3.5 (for even inputs, no multiplier used)
- Comprehensive test plan (in `.mif`)
- Simulation and FPGA validation

---

## Repository Structure
- `part1/src` – base SystemVerilog modules  
- `part1/tb` – testbench  
- `part1/sim` – waveforms  

- `part2/src` – extended modules  
- `part2/mif` – memory initialization file  
- `part2/tb` – extended testbench  
- `part2/sim` – waveforms  

---

## How to Run
1. Open Quartus project, add `src/` files and constraints.  
2. Simulate with ModelSim using provided `wave.do`.  
3. Compile and program the DE10 FPGA.  
4. For Part II, load `inst_mem.mif` file and verify instruction execution.  

---

## License
MIT
