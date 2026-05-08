# Backend Fix Trials - 2026-05-09

## Goal

Reduce the remaining ICC2 route DRCs without breaking these already-clean checks:

```text
route open nets = 0
placement legality = 0 violations
PG DRC = clean
PG connectivity = clean
```

Baseline for comparison:

```text
Trial: scan_def_m8_restore
Route DRC: 398
Open nets: 0
PG DRC: clean
```

## PG M2 Offset Sweep

PG M2 position affects the hotspot, but the tested offsets create PG DRC.

| Trial | PG M2 offset | Route DRC | Open nets | PG DRC | Verdict |
| --- | ---: | ---: | ---: | --- | --- |
| pgm2off24_scan_def_m8 | 24.0 | 377 | 0 | 102 M1 insufficient spacing | Rejected |
| pgm2off26_scan_def_m8 | 26.0 | 384 | 0 | 82 M1 insufficient spacing | Rejected |
| pgm2off28_scan_def_m8 | 28.0 | 383 | 0 | 83 M1 insufficient spacing | Rejected |

Evidence:

```text
7_Backend_ICC2/4_Report/trials/pgm2off24_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/pgm2off24_scan_def_m8/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/pgm2off26_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/pgm2off26_scan_def_m8/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/pgm2off28_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/pgm2off28_scan_def_m8/06_route/pg_drc.rpt
```

Conclusion:

```text
M2 PG stripe position is a real contributor.
But offset-only fix is not valid because it damages PG DRC.
Keep PG_M2_MESH_OFFSET at the PG-clean 20.0um setting for now.
```

## Hotspot Partial Blockage

Trial:

```text
hotspot_blk40_scan_def_m8
HOTSPOT_BLOCKAGE_BOUNDARY = {{215.0 195.0} {265.0 265.0}}
HOTSPOT_BLOCKAGE_PERCENT = 40
```

Result:

```text
Route DRC: 391
Open nets: 0
Placement legality: 0
PG DRC: clean
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/pg_drc.rpt
```

Conclusion:

```text
Local spreading helps only slightly.
It is worse than the route option trials.
Hotspot density is not the primary fix by itself.
```

## Route Option Combination

Trial:

```text
route_combo_scan_def_m8
route.detail.generate_extra_off_grid_pin_tracks = true
route.detail.drc_convergence_effort_level = high
route.detail.optimize_wire_via_effort_level = high
```

Result:

```text
Route DRC: 381
Open nets: 0
Placement legality: 0
PG DRC: clean
```

DRC classes:

```text
Diff net spacing: 127
Less than minimum area: 3
Needs fat contact: 91
Off-grid: 157
Same net spacing: 1
Short: 2
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/route_detail_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/pg_drc.rpt
7_Backend_ICC2/3_Log/trials/route_combo_scan_def_m8/route_combo_scan_def_m8.log
```

Conclusion:

```text
This is the best valid backend route trial so far.
It improves scan_def_m8_restore from 398 to 381 DRCs.
It does not close route DRC.
The remaining issue is still lower-metal pin/via access, not a simple effort knob.
```

## Current Fix Direction

Accepted for next backend baseline candidate:

```text
PG_M2_MESH_OFFSET = 20.0
SIGNAL_MAX_ROUTING_LAYER = M8
SCAN_DEF_FILE = 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def
route.detail.generate_extra_off_grid_pin_tracks = true
route.detail.drc_convergence_effort_level = high
route.detail.optimize_wire_via_effort_level = high
```

Not accepted:

```text
PG M2 offset 24/26/28/30um
hotspot partial blockage as standalone fix
```

Next fix class:

```text
Front-end or library-driven cell selection cleanup.
Main candidates:
  avoid MUX41X2_HVT if possible
  check SDFFARX1_RVT alternatives or placement/pin-access treatment
  keep route combo as ICC2 baseline while testing those changes
```
