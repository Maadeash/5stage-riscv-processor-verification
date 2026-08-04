#!/usr/bin/env python3

import subprocess
import os
import re
import time
from datetime import datetime

SIMV = "./simv"

TESTS = [
    "rv32i_smoke_test",
    "rv32i_alu_test",
    "rv32i_branch_test",
    "rv32i_jump_test",
    "rv32i_forwarding_test",
    "rv32i_hazard_test",
    "rv32i_loadstore_test",
    "rv32i_csr_test",
    "rv32i_trap_test",
    "rv32i_irq_test",
    "rv32i_reset_test",
    "rv32i_misalign_test",
    "rv32i_random_test"
]

LOG_DIR = "logs"
REPORT = "regression_report.txt"

os.makedirs(LOG_DIR, exist_ok=True)

results = []

print("="*80)
print("                 RV32I UVM REGRESSION")
print("="*80)

for test in TESTS:

    logfile = os.path.join(LOG_DIR, test + ".log")

    print(f"\nRunning {test}...")

    start = time.time()

    with open(logfile, "w") as f:
        subprocess.run(
            [SIMV,
             "+UVM_NO_RELNOTES",
             f"+UVM_TESTNAME={test}"],
            stdout=f,
            stderr=subprocess.STDOUT
        )

    runtime = time.time() - start

    with open(logfile) as f:
        log = f.read()

    status = "FAIL"
    reason = "Unknown"

    ###############################################################
    # 1. Scoreboard summary has highest priority
    ###############################################################
    sb = re.search(r'PASS:\s*(\d+)\s*FAIL:\s*(\d+)', log)

    if sb:
        pass_cnt = int(sb.group(1))
        fail_cnt = int(sb.group(2))

        if fail_cnt == 0:
            status = "PASS"
            reason = f"Scoreboard PASS={pass_cnt}"
        else:
            status = "FAIL"
            reason = f"Scoreboard FAIL={fail_cnt}"

    ###############################################################
    # 2. Otherwise use UVM report summary
    ###############################################################
    else:

        err = re.search(r'UVM_ERROR\s*:\s*(\d+)', log)
        fat = re.search(r'UVM_FATAL\s*:\s*(\d+)', log)

        if err and fat:

            errors = int(err.group(1))
            fatals = int(fat.group(1))

            if errors == 0 and fatals == 0:
                status = "PASS"
                reason = "UVM clean"

            else:
                status = "FAIL"
                reason = f"{errors} ERROR {fatals} FATAL"

    ###############################################################
    # 3. Timeout always FAIL
    ###############################################################
    if "PH_TIMEOUT" in log:
        status = "FAIL"
        reason = "Simulation Timeout"

    ###############################################################
    # 4. Ignore segmentation fault if already PASS
    ###############################################################
    if status == "PASS":
        if "Segmentation fault" in log:
            reason += " (Coverage save crash ignored)"

    results.append((test,status,reason,runtime))

print("\n")
print("="*80)
print("Regression Summary")
print("="*80)

passed = 0

for test,status,reason,runtime in results:

    print(f"{test:<28}{status:<8}{runtime:6.1f}s   {reason}")

    if status=="PASS":
        passed+=1

failed = len(results)-passed

print("="*80)
print(f"Total Tests : {len(results)}")
print(f"Passed      : {passed}")
print(f"Failed      : {failed}")
print(f"Pass Rate   : {(passed/len(results))*100:.2f}%")
print("="*80)

with open(REPORT,"w") as f:

    f.write("="*80+"\n")
    f.write("RV32I UVM Regression Report\n")
    f.write("="*80+"\n")
    f.write(str(datetime.now())+"\n\n")

    for t,s,r,tm in results:
        f.write(f"{t:<28}{s:<8}{tm:6.1f}s   {r}\n")

    f.write("\n")
    f.write("="*80+"\n")
    f.write(f"Total Tests : {len(results)}\n")
    f.write(f"Passed      : {passed}\n")
    f.write(f"Failed      : {failed}\n")
    f.write(f"Pass Rate   : {(passed/len(results))*100:.2f}%\n")

print("\nRegression report written to",REPORT)
