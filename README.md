# RV32I 5-Stage Pipelined Processor Verification with UVM

A SystemVerilog/UVM verification environment for a 5-stage pipelined RV32I RISC-V processor.
This repository includes RTL, a structured UVM testbench, directed and regression tests, assertions, functional coverage, and Synopsys VCS/urg coverage reports.

---

## Architecture Overview

The DUT is the RV32I pipeline core implemented in `RTL/rv32i_pipeline_core.v`. The design follows the standard 5 pipeline stages:

* **IF**: instruction fetch
* **ID**: instruction decode / register read
* **EX**: execute / branch / compare / forwarding resolution
* **MEM**: data memory access
* **WB**: writeback to the register file

The RTL source set also includes the main supporting blocks used by the core:

* `Control_Unit_Top.v`
* `Main_Decoder.v`
* `ALU_Decoder.v`
* `ALU.v`
* `Register_File.v`
* `Sign_Extend.v`
* `Forwarding_Unit.v`
* `Instruction_Memory.v`
* `Data_Memory.v`
* `CSR_File.v`
* `PC_Module.v`
* `PC_Adder.v`
* `Mux.v`

The repository also contains `Pipeline_top.v` as a wrapper around the core and a standalone `Hazard_unit.v` source file.

### Architecture diagram

<img width="1029" height="610" alt="image" src="https://github.com/user-attachments/assets/c0db24a3-1b75-4e93-a22c-44beae634317" />


### Mermaid diagram

<img width="1061" height="703" alt="image" src="https://github.com/user-attachments/assets/e09adbc1-1c2b-4c1b-9103-818cb6e070c1" />


---

## Verification Architecture

The verification environment is packaged in `UVM_VIP/` and uses the following structure:

* `rv32i_pkg.sv` holds shared RV32I constants such as opcodes, ALU controls, writeback selects, CSR command encodings, trap causes, and CSR addresses.
* `rv32i_tb_pkg.sv` imports the verification components and includes the sequence, test, scoreboard, coverage, agent, and env files.
* `tb_top.sv` creates the clock, interface, DUT connection, timeout, waveform dump, and `run_test()` entry point.
* The driver uses a virtual interface and loads instruction words directly into instruction memory through `uvm_hdl_deposit`.
* The monitor publishes multiple analysis streams for writeback, memory, trap, and full-cycle observation.
* The scoreboard keeps a reference model for registers, CSR state, and data memory and reports pass/fail counts.
* The coverage subscriber contains the functional covergroups used in the reports.
* Assertions are provided in `rv32i_assertions.sv` and are used for pipeline/control checking.

The coverage model includes 15 named covergroups:

* opcode
* ALU control
* branch
* forwarding
* writeback source
* trap cause
* load width
* store width
* memory alignment
* register addresses
* CSR operations
* R-type funct3
* I-type funct3
* control flow
* pipeline valid

### Verification output

<img width="1675" height="906" alt="image" src="https://github.com/user-attachments/assets/01a60efe-111a-4a95-9413-58a2ad61a95c" />


---

## RTL Summary

The RTL source set in `RTL/` is centered around a 5-stage RV32I pipeline with CSR and trap handling.

### Main RTL files

* `rv32i_pipeline_core.v`: top-level datapath and control integration for the pipeline
* `Control_Unit_Top.v`: combines `Main_Decoder` and `ALU_Decoder`, and handles system/CSR decode plus illegal instruction detection
* `ALU.v`: arithmetic and logic execution
* `Register_File.v`: 32-register file with x0 hardwired to zero
* `Sign_Extend.v`: immediate generation for I/S/B/U/J formats
* `Forwarding_Unit.v`: EX/MEM and MEM/WB forwarding selection
* `Instruction_Memory.v`: instruction ROM with default initialization support
* `Data_Memory.v`: 256-word byte-writeable data memory
* `CSR_File.v`: machine CSRs, trap state, and timer interrupt pending logic
* `PC_Module.v`, `PC_Adder.v`, `Mux.v`: combinational and sequential helper blocks
* `Pipeline_top.v`: wrapper around the core
* `Hazard_unit.v`: standalone hazard helper source present in the RTL set

---

## UVM Environment Summary

The UVM testbench is built from these components:

* `rv32i_seq_item.sv`: transaction item carrying instruction, address, reset, IRQ, and expected outcome fields
* `rv32i_sequencer.sv`: sequencer for RV32I stimulus
* `rv32i_driver.sv`: drives reset/IRQ and loads instructions into IMEM
* `rv32i_monitor.sv`: captures pipeline and writeback activity into observation items
* `rv32i_scoreboard.sv`: reference checker for WB, memory, and trap behavior
* `rv32i_coverage.sv`: functional coverage subscriber
* `rv32i_agent.sv`: bundles sequencer, driver, and monitor
* `rv32i_env.sv`: connects agent, scoreboard, and coverage
* `rv32i_assertions.sv`: bindable assertion module for pipeline and control checks

The monitor observation item includes signals for:

* writeback state
* memory transactions
* trap detection and cause
* forwarding selections
* branch redirect activity
* CSR write activity

---

## Test Plan / Directed Tests

The repository contains both standalone tests and a regression-style composite test.

### Standalone tests in `rv32i_test_lib.sv`

* `rv32i_smoke_test`
* `rv32i_alu_test`
* `rv32i_branch_test`
* `rv32i_jump_test`
* `rv32i_forwarding_test`
* `rv32i_hazard_test`
* `rv32i_loadstore_test`
* `rv32i_memcover_test`
* `rv32i_csr_test`
* `rv32i_trap_test`
* `rv32i_irq_test`
* `rv32i_reset_test`
* `rv32i_misalign_test`
* `rv32i_random_test`
* `rv32i_covclose_test`
* `rv32i_regression_test`

### Directed sequences in `rv32i_sequence_lib.sv`

The sequence library includes:

* smoke
* ALU R-type
* ALU I-type
* LUI/AUIPC
* branch
* jump
* forwarding
* load-use
* load/store
* memory coverage
* CSR
* trap
* IRQ
* mid-reset
* misalignment
* random
* coverage closure

### Test summary 

<img width="1555" height="797" alt="image" src="https://github.com/user-attachments/assets/b7758ca8-559e-4c3f-a5bc-3f25e67dbe83" />


This is useful as a visual summary of the test matrix, but `run/cov_report/tests.txt` is often better kept as text because it lists the exact tests used to build the report.

---

## Regression Summary

The repository includes `run/regression.py`, which runs the following 13 tests:

* smoke
* alu
* branch
* jump
* forwarding
* hazard
* loadstore
* csr
* trap
* irq
* reset
* misalign
* random

The generated `run/regression_report.txt` shows:

* **Total tests:** 13
* **Passed:** 13
* **Failed:** 0
* **Pass rate:** 100.00%

### Regression test output

<img width="975" height="529" alt="image" src="https://github.com/user-attachments/assets/1a884ca1-4b87-4725-8645-242e2c68ebd0" />


---

## Functional Coverage Summary

<img width="1074" height="152" alt="image" src="https://github.com/user-attachments/assets/14cef1c7-cf28-4168-befa-7b01302ff9a2" />


The generated coverage dashboard is in `run/cov_report/`.

Key values from `coverage_summary.csv`:

* **SCORE:** 48.83
* **LINE:** 35.03
* **COND:** 44.19
* **TOGGLE:** 35.26
* **BRANCH:** 32.69
* **ASSERT:** 45.78
* **GROUP:** 100.00

Additional coverage facts from the report:

* The dashboard was generated from **15 tests**
* All **15 covergroups** show **100.00 group coverage**
* The report includes a per-test functional coverage CSV in `per_test_functional_coverage.csv`

Report files worth linking in the repository:

* `run/cov_report/dashboard.html`
* `run/cov_report/dashboard.txt`
* `run/cov_report/coverage_summary.csv`
* `run/cov_report/per_test_functional_coverage.csv`
* `run/cov_report/tests.txt`
* `run/cov_report/groups.txt`
* `run/cov_report/hierarchy.txt`
* `run/cov_report/asserts.txt`

---

## Assertions Summary

<img width="640" height="759" alt="image" src="https://github.com/user-attachments/assets/6b195841-8b6e-4995-9fce-3c91d8dda920" />


The assertion report in `run/cov_report/asserts.txt` shows:

* **Total assertions:** 83
* **Success:** 38
* **Uncovered:** 45
* **Failure:** 0
* **Incomplete:** 2

The assertion set focuses on:

* reset behavior
* x0 immutability
* IF/ID, ID/EX, and EX/MEM reset handling
* forwarding paths
* load-use stall behavior
* jump and branch redirect behavior
* JALR alignment
* trap entry and trap target behavior
* MRET behavior
* CSR writes and trap CSR state
* memory alignment and write strobes
* writeback protection for x0
* pipeline advancement and no-write NOP behavior

---

---

## Tools Used

* Synopsys VCS
* Synopsys urg
* Python 3 for regression automation

---

## How to Run Simulation and Regression

From the `run/` directory:

```bash
# Compile
vcs -full64 -sverilog -ntb_opts uvm-1.2 -debug_access+all \
    -cm line+cond+tgl+fsm+branch+assert \
    -cm_name rv32i_cov -cm_dir simv.vdb \
    -f filelist.f -l compile.log

# Run one test
./simv +UVM_NO_RELNOTES +UVM_TESTNAME=rv32i_smoke_test


# Run the coverage-oriented flow
python3 run_coverage.py
```

### Notes

* `regression.py` writes per-test logs into `run/logs/`
* `run_coverage.py` generates the shared coverage database and writes the HTML/text report into `run/cov_report/`
* `tb_top.sv` contains a simulation timeout and VCD dump (`tb_top.vcd`)

---

## Directory Structure

Current repository layout:

```text
RISC-V(Pipelined)/
├── RTL/
├── UVM_VIP/
├── run/
    ├── logs/
    ├── cov_report/
    ├── cov_report_detail/
    ├── csrc/
    ├── regression.py
    ├── run_coverage.py
    └── filelist.f

```

---

## Results / Achievements

* Built a reusable UVM verification environment around a 5-stage RV32I pipeline
* Added directed tests for ALU, branch, jump, forwarding, hazard, load/store, CSR, trap, IRQ, reset, misalign, random, and coverage closure scenarios
* Achieved a clean regression result in the current regression script: **13/13 PASS**
* Generated a coverage database from **15 tests**
* Reached **100.00 group coverage** across all 15 covergroups
* Added an assertion-based checking layer with **0 assertion failures** in the report

---

## Future Work

* Overall coverage is not yet closed; the current report still shows uncovered line, condition, toggle, branch, and assertion items
* The current regression script covers 13 tests, while the coverage flow includes 15 tests
* More negative tests, corner-case stimulus, and additional coverage-driven scenarios would help close the remaining gaps

---
