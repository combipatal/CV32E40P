# Route DRC Detail Diagnosis

## Goal

```text
Break remaining route DRCs down by type and layer before trying route repair.
```

The previous reports showed:

```text
65% baseline route: 408 DRC, 0 open nets
60% utilization trial: 407 DRC, 0 open nets
60% utilization + M8 route-layer trial: 400 DRC, 0 open nets
```

This means density and upper route-layer bound alone are not enough.
The next question is where the remaining DRC markers are located.

## Command

```text
icc2_shell -batch -f 7_Backend_ICC2/0_Script/06_route/run_route_drc_detail.tcl | tee 7_Backend_ICC2/3_Log/06_route/route_drc_detail.log
```

## Reports

```text
7_Backend_ICC2/4_Report/06_route/drc_detail/check_routes.detail_source.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/drc.by_layer.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/drc.by_type.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/drc.detailed.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/drc.hotspot_50um.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/zroute.err
```

## First Result

Current generated ICC2 block was the `60util_m8` trial state when this diagnosis ran.

Matrix:

```text
                       | M1    M1-M2   M2   VIA1  | TOTALS BY TYPE
---------------------------------------------------------------------
Diff net spacing       | 119   -       3    -     | 122
Less than minimum area | -     -       7    -     | 7
Needs fat contact      | -     108     -    -     | 108
Off-grid               | 5     -       76   79    | 160
Short                  | 1     -       2    -     | 3
---------------------------------------------------------------------
                       | M1    M1-M2   M2   VIA1  | 400
TOTALS BY LAYER        | 125   108     88   79    |
```

Top 50um hotspot buckets:

```text
26 200-250,250-300 | Diff net spacing         | M1 (11)
23 100-150,050-100 | Needs fat contact        | M1 (11)-M2 (13)
20 200-250,200-250 | Off-grid                 | VIA1 (12)
20 200-250,200-250 | Off-grid                 | M2 (13)
15 200-250,250-300 | Needs fat contact        | M1 (11)-M2 (13)
14 150-200,200-250 | Off-grid                 | VIA1 (12)
13 150-200,200-250 | Off-grid                 | M2 (13)
12 150-200,250-300 | Needs fat contact        | M1 (11)-M2 (13)
```

## Interpretation

```text
All 400 route DRCs are on M1, M2, M1-M2, or VIA1.
No remaining route DRC is on upper routing layers.
```

This points away from M8/M9/MRDL routing capacity as the main issue.
The stronger suspect is lower-metal access:

```text
stdcell pin access
VIA1/contact rule selection
M1/M2 off-grid behavior
fat-contact requirement
top VDD/VSS no-pin cleanup
```

Next repair trial should focus on lower-metal/via/contact behavior before changing global floorplan size again.

## Next Repair Candidates

```text
1. Inspect detailed Bbox hotspots in ICC2 GUI, starting near x=200-250/y=250-300 and x=100-150/y=50-100.
2. Test lower-metal route/detail options and via/contact rule settings.
3. Clean top VDD/VSS no-pin/unplaced warning so router has fewer ambiguous top-level PG objects.
4. Keep M1-M8 signal route bound in the main route script.
```

## Detail Route Repair Trial

The first repair check was intentionally narrow:

```text
Use the same routed 60% + M8 state.
Run incremental route_detail only.
Do not change floorplan, PG, placement, CTS, or constraints.
```

Script:

```text
7_Backend_ICC2/0_Script/99_util/run_trial_detail_route_repair.tcl
```

### 200 Iteration Trial

Command:

```text
icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_detail_route_repair.tcl | tee 7_Backend_ICC2/3_Log/trials/detail_repair_200iter/detail_route_repair.log
```

Result:

```text
Before check_routes DRC: 400
After check_routes DRC: 398
Open nets: 0
Worst listed setup slack: 2.11 ns MET
Worst listed hold slack: 0.02 ns MET
Legality: 0 violations
PG connectivity: floating counts 0
PG DRC: no errors
```

After matrix:

```text
                       | M1   M1-M2   M2   M4  VIA1  | TOTALS BY TYPE
------------------------------------------------------------------------
Diff net spacing       | 90   -       3    1   -     | 94
Less than minimum area | -    -       6    -   -     | 6
Needs fat contact      | -    137     -    -   -     | 137
Off-grid               | 3    -       78   -   79    | 160
Short                  | 1    -       -    -   -     | 1
------------------------------------------------------------------------
                       | M1   M1-M2   M2   M4  VIA1  | 398
TOTALS BY LAYER        | 94   137     87   1   79    |
```

Interpretation:

```text
Long incremental detail routing does not converge.
It reduces total DRC only by 2 markers.
Needs-fat-contact grows from 108 to 137.
```

### 1 Iteration Trial

The 200-iteration log showed the first detail-route iteration could reduce the count to 383 before later iterations drifted. A separate 1-iteration run was used to capture that state.

Command:

```text
env TRIAL_NAME=detail_repair_1iter DETAIL_ROUTE_ITERATIONS=1 icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_detail_route_repair.tcl | tee 7_Backend_ICC2/3_Log/trials/detail_repair_1iter/detail_route_repair_1iter.log
```

Result:

```text
Before check_routes DRC: 400
After check_routes DRC: 383
Open nets: 0
Worst listed setup slack: 2.11 ns MET
Worst listed hold slack: 0.02 ns MET
Legality: 0 violations
PG connectivity: floating counts 0
PG DRC: no errors
```

Before matrix:

```text
                       | M1    M1-M2   M2   VIA1  | TOTALS BY TYPE
---------------------------------------------------------------------
Diff net spacing       | 119   -       3    -     | 122
Less than minimum area | -     -       7    -     | 7
Needs fat contact      | -     108     -    -     | 108
Off-grid               | 5     -       76   79    | 160
Short                  | 1     -       2    -     | 3
---------------------------------------------------------------------
                       | M1    M1-M2   M2   VIA1  | 400
TOTALS BY LAYER        | 125   108     88   79    |
```

After matrix:

```text
                 | M1    M2   VIA1  | TOTALS BY TYPE
-------------------------------------------------------
Diff net spacing | 224   -    -     | 224
Off-grid         | 3     73   79    | 155
Short            | 4     -    -     | 4
-------------------------------------------------------
                 | M1    M2   VIA1  | 383
TOTALS BY LAYER  | 231   73   79    |
```

Interpretation:

```text
1 iteration gives the best total count seen so far: 383.
But it trades away fat-contact/min-area markers by increasing M1 spacing markers.
This is not route closure.
Next work should target root setup issues, not more blind route_detail looping.
```

## Current Backend Direction

```text
Keep the 1-iteration result as evidence only.
Do not treat it as final route.
Next fixes:
  1. clean top VDD/VSS no-pin/unplaced port handling
  2. inspect lower-metal pin access / off-grid pins
  3. review SAED32 routing/via/contact setup for ICC2
  4. add scan DEF handoff before placement
  5. rerun route and compare matrix
```
