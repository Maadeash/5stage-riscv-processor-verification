# RV32I 5-Stage Pipelined Processor — Design and UVM Verification

Designed a 5-Stage Pipelined RISC-V Processor using Verilog HDL and built a SystemVerilog/UVM verification environment for it, with directed tests, functional coverage, assertion-based checking, and Synopsys VCS/URG coverage reports.

`RTL` — synthesizable core &nbsp;|&nbsp; `UVM_VIP` — testbench &nbsp;|&nbsp; `run` — regression, coverage flow, reports

---

## Contents

- [Architecture](#architecture)
- [Verification Environment](#verification-environment)
- [Test Plan](#test-plan)
- [Results](#results)
- [How to Run](#how-to-run)
- [Repository Layout](#repository-layout)
- [Known Gaps / Future Work](#known-gaps--future-work)

---


## Architecture

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/ca560969-f6a5-4f00-80bd-83377aa54f0e" />


The DUT (`RTL/rv32i_pipeline_core.v`) is a classic 5-stage RV32I pipeline, wrapped by `Pipeline_top.v`:

| Stage | Function |
|---|---|
| **IF** | Instruction fetch |
| **ID** | Decode / register read |
| **EX** | ALU execute, branch resolution, forwarding mux |
| **MEM** | Data memory access |
| **WB** | Register file writeback |

**Supporting blocks:**

| Module | Role |
|---|---|
| `Control_Unit_Top.v` | Combines `Main_Decoder` + `ALU_Decoder`; system/CSR decode and illegal-instruction detection |
| `ALU.v` / `ALU_Decoder.v` | Arithmetic/logic execution and control decode |
| `Register_File.v` | 32×32 register file, `x0` hardwired to zero |
| `Sign_Extend.v` | Immediate generation for I/S/B/U/J formats |
| `Forwarding_Unit.v` | EX/MEM and MEM/WB forwarding select |
| `Hazard_unit.v` | Load-use hazard detection / stall |
| `Instruction_Memory.v` | Instruction ROM |
| `Data_Memory.v` | 256-word byte-writeable data memory |
| `CSR_File.v` | Machine-mode CSRs, trap state, timer-interrupt pending |
| `PC_Module.v`, `PC_Adder.v`, `Mux.v` | PC sequencing / combinational helpers |

## RTL-Based Architecture:

<img width="1774" height="887" alt="RISC-V pipeline architecture" src="https://github.com/user-attachments/assets/99e98f70-c87a-4ef0-8992-63c895de418a" />

---


## Verification Environment

Standard UVM agent/env structure under `UVM_VIP/`:

| Component | File | Role |
|---|---|---|
| Package | `rv32i_pkg.sv` | Opcodes, ALU controls, writeback selects, CSR encodings, trap causes |
| TB package | `rv32i_tb_pkg.sv` | Compiles the env (sequences, tests, scoreboard, coverage, agent) |
| Top | `tb_top.sv` | Clock/reset gen, interface binding, timeout, waveform dump, `run_test()` |
| Transaction | `rv32i_seq_item.sv` | Instruction, address, reset, IRQ, expected-outcome fields |
| Sequencer | `rv32i_sequencer.sv` | Arbitrates stimulus |
| Driver | `rv32i_driver.sv` | Drives reset/IRQ; loads instruction words into IMEM via `uvm_hdl_deposit` |
| Monitor | `rv32i_monitor.sv` | Publishes writeback, memory, trap, and full-cycle analysis streams |
| Scoreboard | `rv32i_scoreboard.sv` | Reference model for register file, CSR state, and data memory |
| Coverage | `rv32i_coverage.sv` | Functional covergroup subscriber |
| Agent / Env | `rv32i_agent.sv`, `rv32i_env.sv` | Wires sequencer + driver + monitor, then scoreboard + coverage |
| Assertions | `rv32i_assertions.sv` | Bind-based SVA checks on pipeline/control behavior |

**Monitor observation item** carries: writeback state, memory transactions, trap detection/cause, forwarding selects, branch-redirect activity, CSR writes.

**Functional coverage — 15 covergroups:** `cg_opcode`, `cg_alu_ctrl`, `cg_branch`, `cg_forwarding`, `cg_wb_src`, `cg_trap_cause`, `cg_load_width`, `cg_store_width`, `cg_mem_alignment`, `cg_reg_addresses`, `cg_csr_ops`, `cg_rtype_funct3`, `cg_itype_funct3`, `cg_control_flow`, `cg_pipeline_valid`.

## Block Diagram:

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/6989e992-d11e-4250-88bc-a9320ffbf5ee" />


---


## Test Plan

Each test in `rv32i_test_lib.sv` (extends `rv32i_base_test`) pairs with a driving sequence in `rv32i_sequence_lib.sv` (extends `rv32i_base_seq`):

| Test | Sequence | Target |
|---|---|---|
| `rv32i_smoke_test` | `rv32i_smoke_seq` | Basic bring-up |
| `rv32i_alu_test` | `rv32i_alu_r_seq`, `rv32i_alu_i_seq`, `rv32i_lui_auipc_seq` | R-type/I-type ALU ops, LUI/AUIPC |
| `rv32i_branch_test` | `rv32i_branch_seq` | Branch resolution |
| `rv32i_jump_test` | `rv32i_jump_seq` | JAL/JALR redirect |
| `rv32i_forwarding_test` | `rv32i_forwarding_seq` | EX/MEM, MEM/WB forwarding paths |
| `rv32i_hazard_test` | `rv32i_loaduse_seq` | Load-use stall |
| `rv32i_loadstore_test` | `rv32i_loadstore_seq` | Load/store width & data path |
| `rv32i_memcover_test` | `rv32i_memcover_seq` | Memory alignment/coverage closure |
| `rv32i_csr_test` | `rv32i_csr_seq` | CSR read/write |
| `rv32i_trap_test` | `rv32i_trap_seq` | Trap entry, `mcause`/`mepc`, MRET |
| `rv32i_irq_test` | `rv32i_irq_seq` | Timer interrupt |
| `rv32i_reset_test` | `rv32i_reset_seq`, `rv32i_reset_mid_seq` | Reset behavior, including mid-stream reset |
| `rv32i_misalign_test` | `rv32i_misalign_seq` | Misaligned access handling |
| `rv32i_random_test` | `rv32i_random_seq` | Constrained-random instruction streams |
| `rv32i_covclose_test` | `rv32i_covclose_seq` | Targeted coverage closure |
| `rv32i_regression_test` | — | Composite/regression entry point |

<img width="1555" height="797" alt="Test summary" src="https://github.com/user-attachments/assets/b7758ca8-559e-4c3f-a5bc-3f25e67dbe83" />

`run/cov_report/tests.txt` is the source of truth for which tests fed a given coverage report.

---


## Results

### Regression — `run/regression_report.txt`

| Total | Passed | Failed | Pass rate |
|---|---|---|---|
| 13 | 13 | 0 | **100.00%** |

<img width="975" height="529" alt="Regression output" src="https://github.com/user-attachments/assets/1a884ca1-4b87-4725-8645-242e2c68ebd0" />

### Functional / code coverage — `run/cov_report/`

Generated from **15 tests** (`run/cov_report/tests.txt` — includes `memcover` and `covclose` on top of the 13 regression tests):

| Metric | Score |
|---|---|
| SCORE | 48.83% |
| LINE | 35.03% |
| COND | 44.19% |
| TOGGLE | 35.26% |
| BRANCH | 32.69% |
| ASSERT | 45.78% |
| **GROUP (functional)** | **100.00%** |

All 15 covergroups close at 100%. Code coverage (line/cond/toggle/branch) is not yet closed — see [Future Work](#known-gaps--future-work).

<img width="1074" height="152" alt="Coverage summary" src="https://github.com/user-attachments/assets/14cef1c7-cf28-4168-befa-7b01302ff9a2" />

Key artifacts: [`dashboard.html`](run/cov_report/dashboard.html) · [`dashboard.txt`](run/cov_report/dashboard.txt) · [`coverage_summary.csv`](run/cov_report/coverage_summary.csv) · [`per_test_functional_coverage.csv`](run/cov_report/per_test_functional_coverage.csv) · [`tests.txt`](run/cov_report/tests.txt) · [`groups.txt`](run/cov_report/groups.txt) · [`hierarchy.txt`](run/cov_report/hierarchy.txt)

### Assertions — `run/cov_report/asserts.txt`

| Total | Success | Uncovered | Failure | Incomplete |
|---|---|---|---|---|
| 83 | 38 | 45 | **0** | 2 |

<img width="640" height="759" alt="Assertion report" src="https://github.com/user-attachments/assets/6b195841-8b6e-4995-9fce-3c91d8dda920" />

Assertion set covers: reset behavior and `x0` immutability, IF/ID·ID/EX·EX/MEM reset propagation, forwarding paths (EX/EX, MEM/EX, no-forward-from-`x0`), load-use stall, jump/branch redirect, JALR LSB alignment, trap entry/target and MRET, CSR write/trap-CSR state, memory alignment and byte-write strobes, writeback protection for `x0`, and pipeline advance/no-write-on-NOP.

**Zero assertion failures across the full run.**

---


## How to Run

Tools: **Synopsys VCS** + **Python 3**.

```bash
# 1. Set up the tool environment
source /path/to/synopsys_setup.sh

# 2. From run/, compile + simulate all 15 tests + generate the coverage report
cd run
python3 run_coverage.py
```

`run_coverage.py` compiles with `-cm line+cond+tgl+fsm+branch+assert`, runs each test in `TESTS`, invokes `urg` on the merged `simv.vdb`, and writes the HTML/text report plus `coverage_summary.csv` and `per_test_functional_coverage.csv` into `cov_report/`.

To compile only (e.g. for a manual `simv` run against a single test):

```bash
vcs -full64 -sverilog -ntb_opts uvm -debug_access+all -kdb -f filelist.f -l compile.log
./simv +UVM_TESTNAME=rv32i_smoke_test
```

---


## Repository Layout

```text
5stage-riscv-processor-verification/
├── RTL/                     # Synthesizable RV32I pipeline core
├── UVM_VIP/                 # UVM testbench (agent, env, scoreboard, coverage, assertions)
├── coverage_report/         # Snapshot coverage report (repo root)
└── run/
    ├── filelist.f           # VCS compile file list
    ├── run_coverage.py      # Compile + regress + coverage report driver
    ├── regression_report.txt
    └── cov_report/          # URG-generated dashboard, per-test coverage, assertion report
```

---


## Known Gaps / Future Work

- Code coverage (line/cond/toggle/branch) is well below closure; functional coverage is closed but structural coverage needs more directed and random stimulus.
- `run/regression_report.txt` reflects 13 tests; the coverage flow (`run_coverage.py`) runs 15 (adds `memcover` and `covclose`) — worth reconciling into a single entry point.
- 45 of 83 assertions are still uncovered (never triggered) and 2 are incomplete — additional corner-case and negative stimulus would close these out.



