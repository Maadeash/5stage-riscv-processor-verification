#!/usr/bin/env python3
import csv
import os
import re
import subprocess
import sys

TESTS = [
    "smoke", "alu", "branch", "jump", "forwarding", "hazard",
    "loadstore", "csr", "trap", "irq", "reset", "misalign", "random",
    "covclose", "memcover",
]

FILELIST = "filelist.f"
CM_DIR = "simv.vdb"          
LOG_DIR = "logs"
COMPILE_LOG = "compile.log"
CM_METRICS = "line+cond+tgl+fsm+branch+assert"
REPORT_DIR = "cov_report"

def banner(msg: str) -> None:
    print()
    print("=" * 64)
    print(msg)
    print("=" * 64)

def die(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)

def run(cmd, logfile=None):
    """Run a command, streaming output live and optionally tee-ing to a log file."""
    print(f"\n$ {' '.join(cmd)}")
    if logfile:
        with open(logfile, "w") as lf:
            proc = subprocess.run(cmd, stdout=lf, stderr=subprocess.STDOUT)
    else:
        proc = subprocess.run(cmd)
    return proc.returncode

def read_file(path):
    try:
        with open(path, "r", errors="replace") as f:
            return f.read()
    except FileNotFoundError:
        return ""

def parse_dashboard_table(text):
    m = re.search(
        r"Total Coverage Summary\s*\n"
        r"\s*(SCORE\s+.*)\n"
        r"\s*(.*)\n",
        text,
    )
    if not m:
        return []
    headers = m.group(1).split()
    values = m.group(2).split()
    return list(zip(headers, values))

def sanity_checks():
    if not os.path.isfile(FILELIST):
        die(f"'{FILELIST}' not found in {os.getcwd()}. "
            f"Run this script from your VCS run directory.")
    os.makedirs(LOG_DIR, exist_ok=True)
    os.makedirs(REPORT_DIR, exist_ok=True)

def compile_with_coverage():
    banner(f"STEP 1/3: Compiling with coverage (-cm {CM_METRICS})")
    cmd = [
        "vcs", "-full64", "-sverilog", "-ntb_opts", "uvm-1.2", "-debug_access+all",
        "-cm", CM_METRICS, "-cm_name", "rv32i_cov", "-cm_dir", CM_DIR,
        "-f", FILELIST, "-l", COMPILE_LOG,
    ]
    rc = run(cmd)
    log_text = read_file(COMPILE_LOG)
    if rc != 0 or re.search(r"^Error", log_text, re.MULTILINE):
        print(f"\nCompile FAILED -- see {COMPILE_LOG}. Last errors:")
        for m in re.finditer(r"^Error.*(?:\n(?!\n).*){0,2}", log_text, re.MULTILINE):
            print(m.group(0))
        die("compilation did not succeed; fix the errors above before running the regression.")
    print(f"Compile OK -- see {COMPILE_LOG}")

def run_regression():
    banner(f"STEP 2/3: Running regression ({', '.join(TESTS)})")
    results = {}
    for t in TESTS:
        testname = f"rv32i_{t}_test"
        logfile = os.path.join(LOG_DIR, f"{t}.log")

        print(f"\n--- Running {testname} ---")
        cmd = [
            "./simv", f"+UVM_TESTNAME={testname}",
            "-cm", CM_METRICS, "-cm_name", t, "-cm_dir", CM_DIR,
            "-l", logfile,
        ]
        run(cmd)
        log_text = read_file(logfile)
        if "FAILURES DETECTED" in log_text:
            status = "FAIL"
        elif re.search(r"segmentation fault|core dumped", log_text, re.IGNORECASE) \
                or re.search(r"UVM_FATAL\s*:\s*[1-9]\d*", log_text):
            status = "CRASH"
        elif "ALL CHECKS PASSED" in log_text:
            status = "PASS"
        else:
            status = "UNKNOWN"
        if re.search(r"unable to write to hdl path", log_text, re.IGNORECASE):
            status += " (+ IMEM deposit errors)"

        results[t] = status
        print(f"    -> {status}   (log: {logfile})")
    banner("Per-test result summary")
    for t in TESTS:
        print(f"  {t:<14} {results[t]}")
    fail_count = sum(1 for s in results.values() if not s.startswith("PASS"))
    if fail_count:
        print(f"\nWARNING: {fail_count} test(s) did not complete cleanly. "
              f"Check the logs above before trusting the coverage numbers.")
    return results, fail_count

def generate_report():
    banner("STEP 3/3: Generating coverage report")
    cmd = ["urg", "-dir", CM_DIR, "-report", REPORT_DIR, "-format", "both"]
    rc = run(cmd)
    if rc != 0:
        die("urg report generation failed.")
    print()
    print("Done.")
    print(f"  Text summary : {REPORT_DIR}/dashboard.txt")
    print(f"  HTML report  : {REPORT_DIR}/dashboard.html")

def parse_overall_percentages():
    banner("Overall functional/code coverage percentages")
    dashboard = os.path.join(REPORT_DIR, "dashboard.txt")
    summary_csv = os.path.join(REPORT_DIR, "coverage_summary.csv")
    text = read_file(dashboard)
    if not text:
        print(f"dashboard.txt not found -- open {REPORT_DIR}/dashboard.html manually.")
        return
    num_tests = re.search(r"Number of tests:\s*(\d+)", text)
    if num_tests:
        n = int(num_tests.group(1))
        print(f"Number of tests in report: {n}")
        if n < len(TESTS):
            print(f"WARNING: expected {len(TESTS)} tests, report only shows {n}. "
                  f"Treat this report as incomplete/unreliable.")
    if "Limited design loaded" in text or "Limited Design Loaded" in text:
        print("WARNING: urg reported a LIMITED design load for this database "
              "(design info missing for at least one test run). Numbers below "
              "may be partial -- do not treat as final until this warning is gone.")
    rows = parse_dashboard_table(text)
    print(f"{'Metric':<10}{'Value':>12}")
    print(f"{'------':<10}{'-----':>12}")
    for metric, val in rows:
        suffix = "%" if val != "--" else ""
        print(f"{metric:<10}{val + suffix:>12}")
    with open(summary_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["Metric", "Value"])
        w.writerows(rows)
    print(f"\nCSV written to: {summary_csv}")
    if not rows:
        print()
        print("NOTE: couldn't auto-parse the summary table out of dashboard.txt.")
        print("Raw dashboard excerpt below:")
        print()
        print("\n".join(text.splitlines()[:60]))

def parse_per_test_functional_coverage():
    banner("Per-test functional coverage (from each test's own [COV] output)")
    per_test_csv = os.path.join(REPORT_DIR, "per_test_functional_coverage.csv")
    all_rows = []
    cov_line_re = re.compile(r"\[COV\]\s+([A-Za-z0-9\- ×x/]+?)\s*:\s*([\d.]+)%")
    for t in TESTS:
        logfile = os.path.join(LOG_DIR, f"{t}.log")
        text = read_file(logfile)
        matches = cov_line_re.findall(text)
        print(f"\n{t}:")
        if not matches:
            print("  (no [COV] lines found in this log)")
            continue
        seen = {}
        for category, pct in matches:
            seen[category.strip()] = pct
        for category, pct in seen.items():
            print(f"  {category:<16} {pct:>6}%")
            all_rows.append((t, category, pct))
    with open(per_test_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["Test", "Category", "Coverage%"])
        w.writerows(all_rows)
    print(f"\nCSV written to: {per_test_csv}")

def main():
    sanity_checks()
    compile_with_coverage()
    results, fail_count = run_regression()
    generate_report()
    parse_overall_percentages()
    parse_per_test_functional_coverage()
    print()
    print("Full dashboard (open in browser for the clickable breakdown):")
    print(f"  {REPORT_DIR}/dashboard.html")
    sys.exit(fail_count)

if __name__ == "__main__":
    main()
