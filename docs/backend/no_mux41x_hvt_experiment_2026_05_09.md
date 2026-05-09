# no_mux41x_hvt Experiment - 2026-05-09

## Goal

Test whether avoiding MUX41X*_HVT cells improves ICC2 route DRC caused by lower-metal pin access.

The experiment blocks:

```text
MUX41X1_HVT
MUX41X2_HVT
```

RVT/LVT alternatives remain available.

## Front-End Result

```text
Stage | Result | Evidence
DC topo synthesis | PASS_WITH_NOTE | 2_Synthesis/4_Report/topo_no_mux41x_hvt/post_compile.qor.rpt
Formality R2N | PASS | 2.5_FM_R2N/4_Report/no_mux41x_hvt/r2n_topo_no_mux41x_hvt.failing_points.rpt
DFT topo | PASS_WITH_NOTE | 3_DFT/4_Report/topo_no_mux41x_hvt/post_dft.drc.rpt
Formality N2N | PASS | 5_FM_N2N/4_Report/no_mux41x_hvt/n2n_topo_no_mux41x_hvt.failing_points.rpt
TetraMAX stuck-at | PASS_WITH_NOTE | 4_ATPG/4_Report/stuck_at_topo_no_mux41x_hvt/summary.rpt
PrimeTime post-DFT SDF STA | PASS_WITH_NOTE | 6_STA/4_Report/post_dft_topo_sdf_no_mux41x_hvt/post_dft_no_mux41x_hvt.func_tt_10ns_sdf.global_timing.rpt
```

Key front-end numbers:

```text
Pre-DFT DC slack: 1.82 ns
Post-DFT DC slack: 1.84 ns
R2N: 2243 passing, 0 failing
N2N: 2243 passing, 0 failing
Scan chain: chain0 length 2130
ATPG test coverage: 98.61%
ATPG fault coverage: 98.51%
PT SDF annotation errors: 0
PT setup/hold violations: 0
```

Cell-selection effect:

```text
Baseline pre-DFT MUX41X1_HVT: 67
Experiment pre-DFT MUX41X1_HVT: 0
Experiment pre-DFT MUX41X1_RVT: 67
Experiment post-DFT MUX41X1_RVT: 67
Experiment post-DFT MUX41X1_HVT: 0
```

So the structure change is localized. DC replaced the actual used MUX41X1_HVT cells with MUX41X1_RVT, and Formality confirmed functional equivalence.

## Backend Result

The backend trial used the current best route options:

```text
TRIAL_NAME=route_combo_no_mux41x_hvt
CORE_UTILIZATION=0.60
SIGNAL_MAX_ROUTING_LAYER=M8
SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_mux41x_hvt/cv32e40p_synth_wrap.post_dft_topo_no_mux41x_hvt.scan.def
ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true
ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high
ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high
```

Result:

```text
Trial | Route DRC | Open nets | Legality | PG DRC
route_combo_scan_def_m8 | 381 | 0 | 0 | clean
route_combo_no_mux41x_hvt | 399 | 0 | 0 | clean
```

DRC class comparison:

```text
Class | route_combo_scan_def_m8 | route_combo_no_mux41x_hvt
Diff net spacing | 127 | 95
Less than minimum area | 3 | 8
Needs fat contact | 91 | 126
Off-grid | 157 | 165
Same net spacing | 1 | 0
Short | 2 | 5
```

## Decision

Reject `no_mux41x_hvt` as a backend DRC fix.

Reason:

```text
Front-end remains valid.
But route DRC worsens from 381 to 399.
Needs-fat-contact and off-grid classes increase.
Open nets, legality, and PG remain clean, so the rejection is based on route DRC quality.
```

Interpretation:

```text
MUX41X*_HVT pin access is a real library weakness.
But avoiding these cells alone does not solve the current route DRC.
The stronger root-cause model remains PG M2 mesh + stdcell pin access + M2/VIA1 contact policy.
```
