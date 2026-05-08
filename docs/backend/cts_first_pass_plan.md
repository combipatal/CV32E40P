# ICC2 First-Pass CTS Plan

## Scope

This plan covers the first-pass clock tree synthesis run for the placed
CV32E40P backend design.

## Starting Point

```text
Input block: cv32e40p_icc2_lib:cv32e40p_synth_wrap.design
State: post-placement, PG-clean
Clock: clk_i
Clock period: 10 ns
Corner: TT 1.05V 25C
Library set: SAED32 RVT/LVT/HVT mixed-VT
```

## Acceptance Criteria

```text
check_clock_trees completes and writes a report
clock_opt completes through route_clock
report_clock_qor writes summary, latency, and DRC reports
report_clock_timing writes summary/skew/latency reports
check_legality reports TOTAL 0 violations
check_pg_connectivity reports 0 floating wires, vias, and std cells for VDD/VSS
check_pg_drc reports no errors
report_timing reports non-negative listed setup slack, or any violation is recorded with next action
```

## Execution Plan

```text
1. Add CTS output/log/report variables to ICC2 common setup.
2. Create 05_cts/run_cts_initial.tcl.
3. Open the placed PG-clean block.
4. Check clock tree readiness.
5. Set first-pass target skew for clk_i.
6. Run clock_opt -from build_clock -to route_clock.
7. Generate CTS, timing, legality, PG, QoR, and physical reports.
8. Save block and library.
9. Record evidence in 00_Project_Tracking.
```

## Risk Notes

```text
This is first-pass CTS, not production signoff.
ICC2 scan DEF is still missing, so scan-aware placement/reorder is not active.
clock_opt final_opto is intentionally not run yet; first CTS stops at route_clock.
Post-route routing, extraction, post-route STA, IR/EM, and GDS signoff are not claimed.
```

## Result Snapshot

```text
Date: 2026-05-08
Result: PASS_WITH_OPEN
Script: 7_Backend_ICC2/0_Script/05_cts/run_cts_initial.tcl
Log: 7_Backend_ICC2/3_Log/05_cts/cts_initial.log

Completed:
  clock_opt -from build_clock -to route_clock
  clock tree compilation
  clock route
  CTS/timing/legality/PG reports

Main evidence:
  clock DRC count: 0 transition, 0 capacitance, 0 fanout, 0 netlength
  clock QoR: 2130 sinks, 6 levels, 11 repeaters, 0.37 ns max latency, 0.33 ns global skew
  timing: listed worst setup slack 1.98 ns MET, listed worst hold slack 0.02 ns MET
  legality: TOTAL 0 violations
  PG DRC: no errors

Open items:
  VSS floating boundary terminals = 2 in post-CTS PG connectivity
  no default max_transition constraint warning remains
  whole-design electrical DRC remains: 1 max_transition, 172 max_cap
  scan DEF is still missing/bypassed
  this is pre-signal-route and not post-route signoff
```
