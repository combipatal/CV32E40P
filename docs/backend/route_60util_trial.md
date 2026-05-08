# Route 60% Utilization Trial

## Goal

```text
Check whether first-pass route DRC is mainly caused by high placement/routing density.
```

Baseline route used 65% target floorplan utilization.
After CTS/route the reported utilization was 0.7717 and check_routes reported 408 DRCs.

This trial changed only the floorplan target:

```text
CORE_UTILIZATION = 0.60
```

PG, placement, CTS, and route settings stayed the same.

The generated ICC2 library is rebuilt by this script.
After running it, the current local ICC2 block reflects the 60% trial state.
Rerun the main `01_init_design` through `06_route` scripts if the 65% baseline state is needed again.

## Command

```text
icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl | tee 7_Backend_ICC2/3_Log/trials/60util/trial_60util_to_route.log
```

## Result

```text
Floorplan utilization: 0.6027
Route-stage utilization: 0.7324
Route open nets: 0
route_auto final DRC: 406
check_routes final DRC: 407
Worst listed setup slack: 2.10 ns MET
Worst listed hold slack: 0.02 ns MET
Legality: 0 violations
PG connectivity: VDD/VSS floating counts all 0
PG DRC: no errors
```

check_routes DRC classes:

```text
Diff-net spacing: 102
Less than minimum area: 8
Needs fat contact: 128
Off-grid: 166
Same-net spacing: 1
Short: 2
```

## Interpretation

```text
65% baseline check_routes DRC: 408
60% trial check_routes DRC: 407
```

Lowering utilization from 65% target to 60% target did not materially improve route DRC.
Density is still a contributor, but not the dominant root cause by itself.

Next cleanup should focus on:

```text
explicit signal routing layer bounds
route/via/contact/grid setup
top VDD/VSS port cleanup
scan DEF handoff instead of missing-scan-DEF bypass
default electrical constraints for max_transition/max_cap
```

## Evidence

```text
7_Backend_ICC2/3_Log/trials/60util/trial_60util_to_route.log
7_Backend_ICC2/4_Report/trials/60util/02_floorplan/utilization.rpt
7_Backend_ICC2/4_Report/trials/60util/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/60util/06_route/utilization.rpt
7_Backend_ICC2/4_Report/trials/60util/06_route/timing.max.rpt
7_Backend_ICC2/4_Report/trials/60util/06_route/timing.min.rpt
7_Backend_ICC2/4_Report/trials/60util/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/60util/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/60util/06_route/pg_drc.rpt
```
