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

## Local PG M2 Cut Trial

Trial:

```text
route_combo_pgcut_vss260
PG_M2_HOTSPOT_CUT_BOUNDARY = {{258.0 195.0} {262.0 265.0}}
PG_M2_HOTSPOT_CUT_NETS = VSS
```

This cuts only the hotspot part of the x=259.8..260.2um VSS M2 stripe.
The script recreates the bottom and top stripe segments.

Result:

```text
Route DRC: 377
Open nets: 0
Placement legality: 0
PG connectivity: clean
PG DRC: clean
```

DRC classes:

```text
Diff net spacing: 129
Less than minimum area: 1
Needs fat contact: 79
Off-grid: 166
Same net spacing: 1
Short: 1
```

Evidence:

```text
docs/backend/local_pg_m2_cut_trial_2026_05_09.md
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/03_power/pg_m2_hotspot_cut.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/pg_drc.rpt
```

Conclusion:

```text
This is the best valid route DRC count so far.
It improves route_combo_scan_def_m8 from 381 to 377 DRCs while keeping PG clean.
The small improvement proves local PG M2 is a contributor, but not the only cause.
Manual PG shape cutting is a diagnosis method, not the final implementation style.
```

Follow-up trial:

```text
route_combo_pgcut_allm2_hotspot
PG_M2_HOTSPOT_CUT_BOUNDARY = {{215.0 195.0} {265.0 265.0}}
PG_M2_HOTSPOT_CUT_NETS = VDD VSS
```

Result:

```text
Route DRC: 378
Open nets: 0
Placement legality: 0
PG connectivity: clean
PG DRC: clean
```

DRC class shift:

```text
Class                  route_combo_scan_def_m8  vss260_cut  allm2_cut
Diff net spacing       127                      129         96
Needs fat contact      91                       79          113
Off-grid               157                      166         163
Total                  381                      377         378
```

Conclusion:

```text
Cutting all three hotspot M2 PG stripes is not better than the x=260 VSS-only cut.
It strongly reduces diff-net spacing but increases M1-M2 needs-fat-contact.
This confirms a trade-off: M2 PG obstruction vs lower-metal via/contact legality.
Next clean experiment should isolate x=220 VSS and x=240 VDD individually.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/03_power/pg_m2_hotspot_cut.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/drc_detail/drc.matrix.rpt
```

Individual stripe trial:

```text
route_combo_pgcut_vdd240
PG_M2_HOTSPOT_CUT_BOUNDARY = {{238.0 195.0} {242.0 265.0}}
PG_M2_HOTSPOT_CUT_NETS = VDD
```

Result:

```text
Route DRC: 376
Open nets: 0
Placement legality: 0
PG connectivity: clean
PG DRC: clean
```

Conclusion:

```text
x=240 VDD M2 stripe cut is the current best PG-cut diagnosis candidate.
It improves route_combo_scan_def_m8 381 -> 376.
It improves x=260 VSS-only cut 377 -> 376.
This confirms x=240 VDD is a better local PG obstruction target than removing all hotspot M2 PG stripes.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/03_power/pg_m2_hotspot_cut.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/drc_detail/drc.matrix.rpt
```

Individual stripe rejection:

```text
route_combo_pgcut_vss220
PG_M2_HOTSPOT_CUT_BOUNDARY = {{218.0 195.0} {222.0 265.0}}
PG_M2_HOTSPOT_CUT_NETS = VSS
```

Result:

```text
Route DRC: 380
Open nets: 0
Placement legality: 0
PG connectivity: clean
PG DRC: clean
```

Conclusion:

```text
x=220 VSS cut is not the best direction.
It improves route_combo_scan_def_m8 only 381 -> 380.
It is worse than x=240 VDD cut at 376.
It reduces diff-net spacing but increases needs-fat-contact and short count.
Keep x=220 VSS in the PG mesh for now.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/03_power/pg_m2_hotspot_cut.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/drc_detail/drc.matrix.rpt
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
PG_M2_HOTSPOT_CUT_ENABLE = 1 with x=240 VDD cut as diagnosis-only best current candidate
```

Not accepted:

```text
PG M2 offset 24/26/28/30um
hotspot partial blockage as standalone fix
```

Next fix class:

```text
Cleaner PG strategy plus pin-access-aware placement/routing.
Main candidates:
  replace manual M2 cut with a proper regional PG strategy
  reduce local M2 PG obstruction without creating PG DRC
  convert x=240 VDD cut into a proper regional PG strategy
  avoid broad all-M2 removal because it worsens contact DRC
  check SDFFARX1_RVT and nearby stdcell pin-access treatment
  keep route combo options as ICC2 baseline while testing those changes
```

## Clean PG Blockage Trial Prepared

Goal:

```text
Replace the diagnosis-only manual x=240 VDD M2 cut with a tool-supported PG strategy blockage.
The intended behavior is to prevent compile_pg from creating VDD M2 PG strap only inside the hotspot window.
```

Script change:

```text
7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
```

New env knobs:

```text
PG_M2_HOTSPOT_BLOCKAGE_ENABLE
PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY
PG_M2_HOTSPOT_BLOCKAGE_NETS
PG_M2_HOTSPOT_BLOCKAGE_LAYERS
```

Planned first run:

```text
route_combo_pgblock_vdd240
PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY = {{238.0 195.0} {242.0 265.0}}
PG_M2_HOTSPOT_BLOCKAGE_NETS = VDD
PG_M2_HOTSPOT_BLOCKAGE_LAYERS = M2
```

Local evidence used for syntax:

```text
/tools/synopsys/syn/W-2024.09-SP5-5/icc2/auxx/ICC2/tcl/dp/python/AI/pg_template/pg_script_template_5nm.tcl
/tools/synopsys/syn/W-2024.09-SP5-5/icc2/auxx/ICC2/tcl/dp/python/AI/pg_template/pg_script_template_3nm.tcl
/tools/synopsys/syn/W-2024.09-SP5-5/icc2/auxx/ICC2/tcl/dp/nwtn_dp.tcl
```

Status:

```text
Tcl file is syntactically complete by tclsh info complete.
route_combo_pgblock_vdd240 completed.
```

Result:

```text
Route DRC: 368
Open nets: 0
Placement legality: 0
Route-stage PG connectivity: clean
PG DRC: clean
```

PG strategy evidence:

```text
core_mesh_strategy blockage:
  Nets: VDD
  Layers: M2
  PG regions: hotspot_pg_m2_blockage
```

DRC matrix:

```text
M1:    92
M1-M2: 120
M2:    77
VIA1:  79
Total: 368
```

Conclusion:

```text
Clean PG blockage is better than manual x=240 VDD M2 cut.
Manual cut best was 376 DRC.
PG strategy blockage is 368 DRC.
This confirms x=240 VDD local M2 PG obstruction is real and can be handled through PG strategy instead of post-compile shape editing.
Remaining DRC is still lower-metal/access dominated, especially M1-M2 needs-fat-contact and M2/VIA1 off-grid.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/03_power/pg_mesh_trial_settings.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/03_power/pg_strategies.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.matrix.rpt
```

## Clean PG Blockage Expansion Trial: x=240 VDD + x=260 VSS

Goal:

```text
Test whether adding the nearby x=260 VSS M2 stripe to the same tool-supported hotspot PG blockage improves the remaining lower-metal route DRC.
```

Run:

```text
route_combo_pgblock_vdd240_vss260
PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY = {{238.0 195.0} {262.0 265.0}}
PG_M2_HOTSPOT_BLOCKAGE_NETS = VDD VSS
PG_M2_HOTSPOT_BLOCKAGE_LAYERS = M2
```

Result:

```text
Route DRC: 376
Open nets: 0
Placement legality: 0
Route-stage PG connectivity: clean
PG DRC: clean
```

DRC matrix:

```text
M1:    107
M1-M2: 104
M2:    84
VIA1:  81
Total: 376
```

Comparison against route_combo_pgblock_vdd240:

```text
Needs fat contact: 120 -> 104 improved
M1 diff spacing:   89 -> 101 worsened
M2 off-grid:       70 -> 79 worsened
VIA1 off-grid:     79 -> 81 worsened
Short:              0 -> 2 worsened
Total DRC:        368 -> 376 worsened
```

Conclusion:

```text
Do not broaden the PG blockage to include x=260 VSS in this form.
The VSS blockage helps M1-M2 fat-contact count but creates worse M1 spacing and off-grid side effects.
Current best remains route_combo_pgblock_vdd240.
Next probes should target lower-metal pin-access/contact/grid behavior, not broad PG removal.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/03_power/pg_mesh_trial_settings.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/03_power/pg_strategies.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/drc_detail/representative_summary.rpt
```

## VDD PG Blockage + Multi-Cell Pin-Access Check Trial

Goal:

```text
Test whether enabling one placement legalizer pin-access option improves the remaining lower-metal route DRC while keeping the accepted VDD/M2 PG blockage.
```

Run:

```text
route_pgblock_vdd240_pincheck
PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY = {{238.0 195.0} {242.0 265.0}}
PG_M2_HOTSPOT_BLOCKAGE_NETS = VDD
PG_M2_HOTSPOT_BLOCKAGE_LAYERS = M2
PLACE_MULTI_CELL_PIN_ACCESS_CHECK = true
```

Result:

```text
Route DRC: 368
Open nets: 0
Placement legality: 0
Route-stage PG connectivity: clean
PG DRC: clean
```

DRC matrix:

```text
M1:    92
M1-M2: 120
M2:    77
VIA1:  79
Total: 368
```

Comparison against route_combo_pgblock_vdd240:

```text
Total DRC:          368 -> 368 same
Diff net spacing:    91 -> 91 same
Needs fat contact:  120 -> 120 same
Off-grid:           152 -> 152 same
Layer matrix: identical
```

Conclusion:

```text
Do not keep this as a new best candidate.
The single multi-cell pin-access check option does not change the final route DRC.
Current best remains route_combo_pgblock_vdd240.
Next probes should focus on route grid/via/contact behavior or targeted cell/pin access, not this single legalizer option alone.
```

Evidence:

```text
7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_pincheck/route_pgblock_vdd240_pincheck.log
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/04_place/place_legalize_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/drc_detail/representative_summary.rpt
```

## VDD PG Blockage + Off-Track Via Region Support Trial

Goal:

```text
Test whether enabling one placement legalizer off-track via-region option improves the remaining lower-metal route DRC while keeping the accepted VDD/M2 PG blockage.
```

Run:

```text
route_pgblock_vdd240_offtrackvia
PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY = {{238.0 195.0} {242.0 265.0}}
PG_M2_HOTSPOT_BLOCKAGE_NETS = VDD
PG_M2_HOTSPOT_BLOCKAGE_LAYERS = M2
PLACE_SUPPORT_OFF_TRACK_VIA_REGION = true
```

Result:

```text
Route DRC: 368
Open nets: 0
Placement legality: 0
Route-stage PG connectivity: clean
PG DRC: clean
```

DRC matrix:

```text
M1:    92
M1-M2: 120
M2:    77
VIA1:  79
Total: 368
```

Comparison against route_combo_pgblock_vdd240:

```text
Total DRC:          368 -> 368 same
Diff net spacing:    91 -> 91 same
Needs fat contact:  120 -> 120 same
Off-grid:           152 -> 152 same
Layer matrix: identical
```

Conclusion:

```text
Do not keep this as a new best candidate.
The single off-track via-region placement option does not change the final route DRC.
Current best remains route_combo_pgblock_vdd240.
Next probes should focus on route grid/via/contact behavior or targeted lower-metal pin access.
```

Evidence:

```text
7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_offtrackvia/route_pgblock_vdd240_offtrackvia.log
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/04_place/place_legalize_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/drc_detail/representative_summary.rpt
```

## Route Grid/Via Option Probe

Goal:

```text
Confirm real ICC2 route grid/via option names and shell env value syntax before running more route trials.
```

Findings:

```text
route.common.via_on_grid_by_layer_name exists.
route.common.wire_on_grid_by_layer_name exists.
route.common.extra_via_off_grid_cost_multiplier_by_layer_name exists.
route.detail.generate_extra_off_grid_pin_tracks exists.

For env-driven Tcl variables, use single-brace list pair text:
  '{M2 0.5}'
  '{VIA1 true}'

Do not use double-brace shell text:
  '{{M2 0.5}}'
```

Reason:

```text
The Tcl script passes the env string as one -value argument.
Single-brace text becomes the list-pair ICC2 expects.
Double-brace text becomes one extra-nested list and ICC2 rejects it with CMD-013.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/route_common_all.rpt
7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/route_detail_all.rpt
7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/man_via_on_grid_by_layer_name.rpt
7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/man_wire_on_grid_by_layer_name.rpt
7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/man_extra_via_off_grid_cost_multiplier_by_layer_name.rpt
7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/route_grid_option_value_probe.rpt
```

## VDD PG Blockage + M2 Off-Grid Via Cost Trial

Goal:

```text
Test whether adding extra cost to off-grid vias adjacent to M2 changes the remaining M2/VIA1 off-grid DRC.
```

Run:

```text
route_pgblock_vdd240_m2offgridcost05b
PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY = {{238.0 195.0} {242.0 265.0}}
PG_M2_HOTSPOT_BLOCKAGE_NETS = VDD
PG_M2_HOTSPOT_BLOCKAGE_LAYERS = M2
ROUTE_COMMON_EXTRA_VIA_OFF_GRID_COST_BY_LAYER = {M2 0.5}
```

Result:

```text
Route DRC: 368
Open nets: 0
Placement legality: 0
Route-stage PG connectivity: clean
PG DRC: clean
```

DRC matrix:

```text
M1:    92
M1-M2: 120
M2:    77
VIA1:  79
Total: 368
```

Conclusion:

```text
Do not keep this as a new best candidate.
The M2 off-grid via cost option was applied, but the final route DRC and matrix are unchanged.
Current best remains route_combo_pgblock_vdd240.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/route_common_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/drc_detail/representative_summary.rpt
```

## VDD PG Blockage + VIA1 On-Grid Trial

Goal:

```text
Test whether forcing VIA1 to on-grid routing changes the remaining VIA1/M1-M2 off-grid and fat-contact DRC.
```

Run:

```text
route_pgblock_vdd240_via1ongrid_b
PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY = {{238.0 195.0} {242.0 265.0}}
PG_M2_HOTSPOT_BLOCKAGE_NETS = VDD
PG_M2_HOTSPOT_BLOCKAGE_LAYERS = M2
ROUTE_COMMON_VIA_ON_GRID_BY_LAYER = {VIA1 true}
```

Result:

```text
Route DRC: 368
Open nets: 0
Placement legality: 0
Route-stage PG connectivity: clean
PG DRC: clean
ZRT-044 MUX41X2_HVT/S0 warning: still present
```

DRC type counts:

```text
Diff net spacing:        91
Less than minimum area:   5
Needs fat contact:      120
Off-grid:               152
Total:                  368
```

Conclusion:

```text
Do not keep this as a new best candidate.
The VIA1 on-grid option was applied, but final route DRC is unchanged.
Current best remains route_combo_pgblock_vdd240.
Next sharper probe should target signal wire grid policy or exact lower-metal access geometry.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/route_common_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/pg_drc.rpt
```

## VDD PG Blockage + M2 Wire-On-Grid Trial

Goal:

```text
Test whether forcing signal wires on M2 to routing grid changes the remaining lower-metal DRC.
```

Run:

```text
route_pgblock_vdd240_m2wireongrid
PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY = {{238.0 195.0} {242.0 265.0}}
PG_M2_HOTSPOT_BLOCKAGE_NETS = VDD
PG_M2_HOTSPOT_BLOCKAGE_LAYERS = M2
ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER = {M2 true}
```

Result:

```text
Route DRC: 378
Open nets: 0
Placement legality: 0
Route-stage PG connectivity: clean
PG DRC: clean
```

DRC type counts:

```text
Diff net spacing:        85
Less than minimum area:  11
Needs fat contact:      126
Off-grid:               155
Same net spacing:         1
Total:                  378
```

Conclusion:

```text
Do not keep this as a new best candidate.
M2 wire-on-grid changes the DRC mix, but worsens total DRC from 368 to 378.
Current best remains route_combo_pgblock_vdd240.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/route_common_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/pg_drc.rpt
```

## VDD PG Blockage + M1 Wire-On-Grid Trial

Goal:

```text
Test whether forcing signal wires on M1 to routing grid changes the remaining M1 spacing and lower-metal contact DRC.
```

Run:

```text
route_pgblock_vdd240_m1wireongrid
PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY = {{238.0 195.0} {242.0 265.0}}
PG_M2_HOTSPOT_BLOCKAGE_NETS = VDD
PG_M2_HOTSPOT_BLOCKAGE_LAYERS = M2
ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER = {M1 true}
```

Result:

```text
Route DRC: 380
Open nets: 0
Placement legality: 0
Route-stage PG connectivity: clean
PG DRC: clean
```

DRC type counts:

```text
Diff net spacing:       130
Less than minimum area:  11
Needs fat contact:       81
Off-grid:               158
Total:                  380
```

Conclusion:

```text
Do not keep this as a new best candidate.
M1 wire-on-grid improves needs-fat-contact but worsens spacing and off-grid.
Current best remains route_combo_pgblock_vdd240.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/route_common_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/pg_drc.rpt
```

## Post-ECO Unmatched 12-Marker Classification

Purpose:

```text
The 67-DRC best ECO candidate has 55 markers that match nearby A2 pin-access
points. The remaining 12 markers need a separate cause class before another
fix trial.
```

Result:

```text
Total markers:      67
Matched markers:    55
Unmatched markers:  12

Unmatched by type:
  Short:             4
  Diff net spacing:  4
  Off-grid:          4

Unmatched by layer:
  M1:               11
  M2:                1
```

Refs touched by unmatched markers:

```text
SDFFARX1_RVT  9
SDFFASX1_RVT  2
NBUFFX4_HVT   2
NAND2X0_HVT   2
MUX41X2_HVT   1
NBUFFX8_HVT   1
AND2X1_HVT    1
```

Interpretation:

```text
The unmatched 12 markers are mostly M1 local DRC near flop RSTB/VSS/Q/QN pins,
not the dominant HVT OR/NOR A2 VIA1 off-grid class.

So the current best candidate has two remaining classes:
1. 55 matched A2 access/grid/contact markers.
2. 12 residual M1 local markers around scan flops/buffers/small logic.

The next fix should not treat all 67 markers as one cause.
```

Evidence:

```text
scripts/summarize_unmatched_drc_markers.py
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access/unmatched_drc_marker_summary.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access/unmatched_drc_marker_summary.tsv
```

## NOR2 Resize ECO + M1 Connect-Within-Pin Trial

Purpose:

```text
Test whether forcing M1 standard-cell pin connections inside pin shapes reduces
the remaining A2 off-grid/contact problem in the current 67-DRC best ECO.
```

Run:

```text
route_no012_nor2x4_to_nor2x2_connect_m1pin

Base ECO:
  43 NOR2X4_HVT -> NOR2X2_HVT

Additional route option:
  route.common.connect_within_pins_by_layer_name = {M1 via_standard_cell_pins}
```

Result:

```text
Route DRC: 109
Open nets: 0
Placement legality: 0
PG connectivity: clean
PG DRC: clean
```

DRC matrix:

```text
Connection not within pin   M1       21
Diff net spacing            M1/M2    17/2
Less than minimum area      M2        1
Needs fat contact           M1-M2    45
Off-grid                    M1/M2/VIA1 1/1/13
Short                       M1/M2     7/1
```

Comparison:

```text
NOR2 resize ECO:
  total DRC 67
  Off-grid 59
  Needs fat contact 0
  Connection not within pin 0

NOR2 resize ECO + connect-within-pin:
  total DRC 109
  Off-grid 15
  Needs fat contact 45
  Connection not within pin 21
```

Interpretation:

```text
This option confirms the cause model: the remaining problem is connected to
how the router creates M1/VIA1 access around stdcell pins.

But it is not a closure fix. It trades VIA1 off-grid markers for M1-M2
fat-contact and connection-not-within-pin markers, increasing total DRC.

Current best remains route_no012_nor2x4_to_nor2x2_eco at 67 DRC.
```

Evidence:

```text
7_Backend_ICC2/3_Log/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin.log
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/drc_detail/drc.matrix.rpt
```

## Restore After M1 Connect-Within-Pin Rejection

Purpose:

```text
Return the saved ICC2 block to the accepted NOR2 resize ECO state after the
connect-within-pin experiment saved a rejected route result.
```

Run:

```text
route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin

Base ECO:
  43 NOR2X4_HVT -> NOR2X2_HVT

Removed rejected option:
  route.common.connect_within_pins_by_layer_name
```

Official result:

```text
Route DRC: 67
Open nets: 0
Placement legality: 0
PG connectivity: clean
PG DRC: clean
```

DRC type split:

```text
Off-grid:          59
Diff net spacing:   4
Short:              4
```

Important note:

```text
The detail-route log temporarily reported 66 violations near the end of routing,
but the official final check_routes report is 67 DRC.

Use 67 as the accepted current-best count.
Do not report 66 as a closed or accepted result.
```

Evidence:

```text
7_Backend_ICC2/3_Log/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin.log
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin/06_route/pg_drc.rpt
```

## NOR2 Resize ECO + Force End On Preferred Grid Trial

Purpose:

```text
Test whether ending detail-route segments on preferred grid reduces the
remaining A2 off-grid/contact markers.
```

Run:

```text
route_no012_nor2x4_to_nor2x2_force_end_grid

Base ECO:
  43 NOR2X4_HVT -> NOR2X2_HVT

Additional route option:
  route.detail.force_end_on_preferred_grid = true
```

Result:

```text
Route DRC: 67
Open nets: 0
Placement legality: 0
PG connectivity: clean
PG DRC: clean
```

DRC split:

```text
Off-grid:          59
Diff net spacing:   4
Short:              4
```

Important log message:

```text
Information: Option route.detail.force_end_on_preferred_grid will be ignored
since none of the layers have preferred grid. (ZRT-703)
```

Interpretation:

```text
This is not a closure fix.

The app option is set in ICC2, but the router says it is ignored for the
current layer/grid setup. Official final check_routes stays at 67 DRC.

The route_auto log again temporarily reports 66 DRC near the end, but the
accepted count remains the official check_routes 67 DRC.

This points back to tech/NDM preferred-grid definition or VIA/contact generation
rather than route.detail.force_end_on_preferred_grid.
```

Tech-file observation:

```text
SAED32 Milkyway tech has layer pitch and onWireTrack entries:
  M1 pitch = 0.152, onWireTrack = 1
  M2 pitch = 0.152, onWireTrack = 1
  VIA1 onWireTrack = 1, onGrid = 1

But ICC2 still reports that route.detail.force_end_on_preferred_grid is ignored
because no layer has preferred grid. Therefore ICC2's preferred-grid concept is
not satisfied by these pitch/onWireTrack entries alone.
```

Evidence:

```text
7_Backend_ICC2/3_Log/trials/route_no012_nor2x4_to_nor2x2_force_end_grid.log
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_force_end_grid/06_route/route_detail_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_force_end_grid/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_force_end_grid/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_force_end_grid/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_force_end_grid/06_route/pg_drc.rpt
/DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
```

## Preferred Grid / Track Probe

Purpose:

```text
Check whether the rejected force-end-on-preferred-grid route trial failed because
basic routing tracks were missing, or because ICC2 does not see the current NDM
as having preferred-grid technology semantics.
```

Result:

```text
The current block has routing_direction set correctly:
  M1/M3/M5/M7/M9  horizontal
  M2/M4/M6/M8/MRDL vertical

M1 and M2 tracks exist:
  start = 0.088um
  pitch = 0.152um
  attribute = default

But ICC2 W-2024.09 does not provide the old ICC command:
  set_preferred_routing_direction

And these are not layer attributes in this block:
  preferred_direction
  on_wire_track
  on_grid
```

Interpretation:

```text
This is not a reason to edit the SAED32 tech file.

The tech file is process/library collateral. Changing it would make the result
hard to defend. The safer project direction is to keep the PDK/tech read-only
and solve through:
  library usage policy
  controlled ECO
  placement/routing setup
  NDM-generation/setup investigation

The failed force-end trial is now explained:
  pitch/routing_direction/tracks exist,
  but ICC2 preferred-grid semantics required by route.detail.force_end_on_preferred_grids
  are not satisfied by this setup.
```

Evidence:

```text
7_Backend_ICC2/0_Script/99_util/run_preferred_grid_probe.tcl
7_Backend_ICC2/4_Report/trials/preferred_grid_probe/99_preferred_grid/preferred_grid_probe_summary.rpt
7_Backend_ICC2/4_Report/trials/preferred_grid_probe/99_preferred_grid/tracks.m1.rpt
7_Backend_ICC2/4_Report/trials/preferred_grid_probe/99_preferred_grid/tracks.m2.rpt
7_Backend_ICC2/4_Report/trials/preferred_grid_probe/99_preferred_grid/man_force_end_on_preferred_grid.rpt
/DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
```
