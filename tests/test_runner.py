#!/usr/bin/env python3
"""
Parametric Enclosure Generator v14.0 — Test Runner
Reads test_configs.json, executes OpenSCAD with each parameter set,
collects results (exit code, console output, geometry metrics) and generates report.

Usage:
  python test_runner.py                           # run all suites
  python test_runner.py --suite smoke             # run specific suite
  python test_runner.py --suite smoke,presets
  python test_runner.py --list                    # list all suites
  python test_runner.py --parallel 4              # run 4 tests concurrently
  python test_runner.py --output report.json
  python test_runner.py --dry-run                 # print commands without executing
"""
import json, os, sys, subprocess, time, argparse
from pathlib import Path
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading


_print_lock = threading.Lock()


def safe_print(*args, **kwargs):
    with _print_lock:
        print(*args, **kwargs)


def load_config(config_path):
    with open(config_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def find_openscad(cfg):
    """Find OpenSCAD executable from config or PATH."""
    paths = [cfg.get("openscad_path", ""), cfg.get("openscad_fallback", "")]
    for p in paths:
        if p and os.path.isfile(p):
            return p
    for name in ["openscad-nightly", "openscad"]:
        try:
            result = subprocess.run(["where", name], capture_output=True, text=True, shell=True)
            if result.returncode == 0 and result.stdout.strip():
                return result.stdout.strip().split("\n")[0]
        except Exception:
            pass
    return None


def _looks_numeric(val):
    if not isinstance(val, str):
        return True
    stripped = val.strip()
    if not stripped:
        return False
    try:
        float(stripped)
        return True
    except ValueError:
        return False


def _is_boolean_val(val):
    if not isinstance(val, str):
        return isinstance(val, bool)
    return val.strip().lower() in ("true", "false")


def build_openscad_args(cfg, params_dict):
    """Build openscad command-line arguments from test params.
    Numeric/boolean values are passed unquoted; string values are quoted.
    """
    backend = cfg.get("backend", "manifold")
    args = ["--backend", backend]
    for key, value in params_dict.items():
        if _looks_numeric(value):
            args.extend(["-D", f"{key}={value}"])
        elif _is_boolean_val(value):
            args.extend(["-D", f"{key}={value}"])
        else:
            args.extend(["-D", f'{key}="{value}"'])
    return args


def run_test(cfg, test_entry, output_dir, openscad_bin):
    """Run a single OpenSCAD test and return result dict."""
    test_name = test_entry["name"]
    params = test_entry.get("params", {})
    out_stl = os.path.join(output_dir, f"{test_name}.stl")
    out_log = os.path.join(output_dir, f"{test_name}.txt")

    if not openscad_bin:
        return {"name": test_name, "status": "ERROR", "error": "OpenSCAD not found", "elapsed_sec": 0}

    project_dir = cfg["project_dir"]
    entry_file = cfg.get("entry_file", "enclosure.scad")
    scad_file = os.path.join(project_dir, entry_file)

    cmd = [openscad_bin] + build_openscad_args(cfg, params) + ["-o", out_stl, scad_file]
    timeout = cfg.get("timeout_seconds", 120)

    start = time.time()
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True,
            timeout=timeout, cwd=project_dir,
            encoding='utf-8', errors='replace'
        )
        elapsed = round(time.time() - start, 3)
    except subprocess.TimeoutExpired:
        return {"name": test_name, "status": "TIMEOUT", "elapsed_sec": timeout, "errors": ["Timed out"]}
    except FileNotFoundError:
        return {"name": test_name, "status": "ERROR", "elapsed_sec": 0,
                "error": f"OpenSCAD not found at {openscad_bin}", "errors": []}

    stderr = result.stderr or ""
    stdout = result.stdout or ""
    combined = stdout + "\n" + stderr

    with open(out_log, 'w', encoding='utf-8') as f:
        f.write(f"=== STDOUT ===\n{stdout}\n=== STDERR ===\n{stderr}\n=== EXIT CODE: {result.returncode} ===\n")

    status = "PASS"
    errors = []

    if result.returncode != 0:
        status = "FAIL"
        errors.append(f"Exit code {result.returncode}")

    has_warnings = "WARNING" in combined
    has_errors = "ERROR" in combined

    if has_errors and not test_entry.get("expect_error", True):
        errors.append("Unexpected ERROR in console output")

    # Check expected_console text
    expect_console = test_entry.get("expect_console")
    if expect_console and expect_console not in combined:
        errors.append(f"Expected console text not found: '{expect_console}'")
        status = "FAIL"

    # Check for BOM output (expect_bom: true requires "BILL OF MATERIALS" in console)
    expect_bom = test_entry.get("expect_bom")
    if expect_bom and "BILL OF MATERIALS" not in combined:
        errors.append("Expected BOM output ('BILL OF MATERIALS') not found in console")
        status = "FAIL"

    stl_exists = os.path.isfile(out_stl) and os.path.getsize(out_stl) > 0
    if not stl_exists and result.returncode == 0:
        errors.append("STL file not generated despite exit code 0")
        status = "FAIL"

    if errors and status == "PASS":
        status = "FAIL"

    res = {
        "name": test_name,
        "status": status,
        "elapsed_sec": elapsed,
        "exit_code": result.returncode,
        "has_warnings": has_warnings,
        "has_errors": has_errors,
        "stl_exists": stl_exists,
        "errors": errors,
    }

    # Geometry check
    if stl_exists:
        geo_script = os.path.join(os.path.dirname(os.path.abspath(__file__)), "geometry_check.py")
        if os.path.isfile(geo_script):
            try:
                geo_result = subprocess.run(
                    [sys.executable, geo_script, out_stl, "--watertight"],
                    capture_output=True, text=True, timeout=30,
                    cwd=os.path.dirname(out_stl)
                )
                if geo_result.returncode == 0:
                    geo = json.loads(geo_result.stdout)
                    res["geometry"] = {
                        "vertex_count": geo.get("vertex_count"),
                        "facet_count": geo.get("facet_count"),
                        "is_watertight": geo.get("is_watertight"),
                        "genus": geo.get("genus"),
                        "volume_mm3": geo.get("volume_mm3"),
                        "bbox": geo.get("bbox"),
                    }
                    # Fail if manifold expected but not achieved
                    if test_entry.get("expect_manifold") and not geo.get("is_watertight"):
                        res["errors"].append("Mesh is not watertight (expected manifold)")
                        res["status"] = "FAIL"
            except Exception as e:
                res["geometry"] = {"error": str(e)}

    return res


def print_summary(results):
    total = len(results)
    passed  = sum(1 for r in results if r["status"] == "PASS")
    failed  = sum(1 for r in results if r["status"] == "FAIL")
    errored = sum(1 for r in results if r["status"] == "ERROR")
    timeout = sum(1 for r in results if r["status"] == "TIMEOUT")

    print(f"\n{'='*60}")
    print(f"TEST RESULTS: {passed} passed, {failed} failed, {errored} errors, {timeout} timeouts — {total} total")
    print(f"{'='*60}")

    for r in results:
        if r["status"] != "PASS":
            marker = r["status"]
            print(f"  [{marker:7s}] {r['name']}")
            for e in r.get("errors", []):
                print(f"             -> {e}")

    watertight_count = sum(1 for r in results if r.get("geometry", {}).get("is_watertight"))
    geo_tested = sum(1 for r in results if "geometry" in r)
    if geo_tested:
        print(f"\n  Geometry: {watertight_count}/{geo_tested} watertight meshes (of {geo_tested} checked)")
    return passed, failed, errored, timeout


def generate_report(results, output_path):
    report = {
        "timestamp": datetime.now().isoformat(),
        "total": len(results),
        "passed": sum(1 for r in results if r["status"] == "PASS"),
        "failed": sum(1 for r in results if r["status"] == "FAIL"),
        "errors": sum(1 for r in results if r["status"] == "ERROR"),
        "timeouts": sum(1 for r in results if r["status"] == "TIMEOUT"),
        "results": results,
    }
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False, default=str)
    print(f"\nFull report saved to: {output_path}")


def run_suite_parallel(cfg, suite_tests, output_dir, openscad_bin, workers, total_offset, total_tests):
    """Run suite tests using a thread pool. Returns list of results in original order."""
    results = [None] * len(suite_tests)
    futures = {}

    with ThreadPoolExecutor(max_workers=workers) as executor:
        for i, test_entry in enumerate(suite_tests):
            future = executor.submit(run_test, cfg, test_entry, output_dir, openscad_bin)
            futures[future] = i

        for future in as_completed(futures):
            i = futures[future]
            r = future.result()
            results[i] = r
            idx = total_offset + i + 1
            marker = "OK" if r["status"] == "PASS" else r["status"]
            safe_print(f"  [{idx}/{total_tests}] {r['name']}... {marker} ({r.get('elapsed_sec', 0)}s)")

    return results


def main():
    parser = argparse.ArgumentParser(description="Parametric Enclosure Generator v14.0 Test Runner")
    parser.add_argument("--config",   default=None, help="Path to test_configs.json")
    parser.add_argument("--suite",    default=None, help="Suite name(s) to run, comma-separated")
    parser.add_argument("--list",     action="store_true", help="List available suites")
    parser.add_argument("--output",   default=None, help="Output report JSON path")
    parser.add_argument("--dry-run",  action="store_true", help="Print commands without executing")
    parser.add_argument("--parallel", type=int, default=1, metavar="N",
                        help="Number of parallel OpenSCAD workers (default: 1 = sequential)")
    args = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = args.config or os.path.join(script_dir, "test_configs.json")
    if not os.path.isfile(config_path):
        print(f"ERROR: Config not found at {config_path}")
        sys.exit(1)

    cfg = load_config(config_path)

    if args.list:
        print("Available test suites:")
        for name, suite in cfg.get("suites", {}).items():
            count = len(suite.get("tests", []))
            print(f"  {name:25s} — {count:3d} tests — {suite.get('description', '')}")
        sys.exit(0)

    output_dir = os.path.join(cfg["project_dir"], cfg.get("output_dir", "tests/output"))
    os.makedirs(output_dir, exist_ok=True)

    suites_to_run = cfg["suites"]
    if args.suite:
        requested = [s.strip() for s in args.suite.split(",")]
        suites_to_run = {k: v for k, v in cfg["suites"].items() if k in requested}
        if not suites_to_run:
            print(f"No suites matched: {args.suite}")
            sys.exit(1)

    total_tests = sum(len(s["tests"]) for s in suites_to_run.values())
    workers = max(1, args.parallel)
    mode_label = f"{workers} parallel workers" if workers > 1 else "sequential"
    print(f"Running {total_tests} tests from {len(suites_to_run)} suite(s) [{mode_label}]...\n")

    openscad_bin = find_openscad(cfg)
    if not openscad_bin and not args.dry_run:
        print("ERROR: OpenSCAD executable not found. Check openscad_path in test_configs.json.")
        sys.exit(1)

    all_results = []
    total_offset = 0

    for suite_name, suite in suites_to_run.items():
        tests = suite["tests"]
        print(f"--- Suite: {suite_name} ({len(tests)} tests) ---")

        if args.dry_run:
            for test_entry in tests:
                name = test_entry["name"]
                params = test_entry.get("params", {})
                bin_ = openscad_bin or "openscad"
                cmd_parts = [bin_] + build_openscad_args(cfg, params) + ["-o", f"output/{name}.stl", cfg["entry_file"]]
                print(f"  DRY-RUN: {' '.join(cmd_parts)}")
                all_results.append({"name": name, "status": "DRYRUN", "elapsed_sec": 0, "errors": []})
        elif workers > 1:
            suite_results = run_suite_parallel(cfg, tests, output_dir, openscad_bin, workers, total_offset, total_tests)
            all_results.extend(suite_results)
        else:
            for test_entry in tests:
                name = test_entry["name"]
                print(f"  [{len(all_results)+1}/{total_tests}] {name}...", end=" ", flush=True)
                r = run_test(cfg, test_entry, output_dir, openscad_bin)
                all_results.append(r)
                marker = "OK" if r["status"] == "PASS" else r["status"]
                print(f"{marker} ({r.get('elapsed_sec', 0)}s)")

        total_offset += len(tests)

    passed, failed, errored, timeout = print_summary(all_results)

    report_path = args.output or os.path.join(output_dir, "report.json")
    generate_report(all_results, report_path)

    sys.exit(0 if failed + errored + timeout == 0 else 1)


if __name__ == "__main__":
    main()
