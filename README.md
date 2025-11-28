
# Parametric Synchronous FIFO – SystemVerilog Project

This project implements a **fully parameterized synchronous FIFO** in SystemVerilog, along with a **self‑checking testbench** that verifies its correctness across multiple corner‑case scenarios.

---

##  Features

### **Parametric Synchronous FIFO (DUT)**
- Fully configurable:
  - `WIDTH` – data width  
  - `DEPTH` – number of entries  
- Circular buffer implementation using:
  - Write pointer (wptr)  
  - Read pointer (rptr)  
  - Count register  
- Synchronous write/read (posedge clock)
- Overflow‑write ignore behavior when FIFO is full
- Correct empty/full flag generation
- Wrap‑around pointer logic

---

## Self‑Checking Testbench

The testbench includes:

### **Reference Model (`ref_q`)**
A SystemVerilog queue that acts as the golden model for comparison with DUT outputs.

### **Test Scenarios Covered**
1. **Basic write/read functionality**  
2. **Full condition test (overflow write ignored)**  
3. **Empty condition test (read ignored)**  
4. **Wrap‑around pointer validation**  
5. **Automatic checking** using `$display` and `!==` comparisons  
6. **Flag correctness** throughout all operations  

---

## File Structure

```
/Synchronous FIFO
│
├── sync_fifo.sv     # FIFO RTL design (parameterized)
├── sync_fifo_tb.sv       # Self‑checking testbench with reference model
└── README.md   # Project description
```

---

## How to Run

This design is compatible with:
- **EDA Playground (Aldec Riviera Pro / ModelSim)**
- Any local SystemVerilog simulator (Riviera, Questa, VCS, Xcelium)
- Run the design online in EDA Playground: https://edaplayground.com/x/SzCt

### Steps:
1. Add both `sync_fifo.sv` and `sync_fifo_tb.sv` to the simulator.
2. Compile.
3. Run the simulation.
4. Check the console output for PASS/FAIL messages.

---

## Author
Ziv Sindury – 2025  
Synchronous FIFO Implementation & Verification in SystemVerilog  
