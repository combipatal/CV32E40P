# Decision Log

## Fixed Decisions

```text
Primary goal: Front-End closure
Conditional Phase 2: ICC2 backend after Front-End closure
Run name: tt_mvt_10ns_scan1
Source intake: plain clone into rtl/cv32e40p
Top: cv32e40p_synth_wrap
Wrapper policy: pass through all functional ports
Initial config: FPU=0, COREV_PULP=0, COREV_CLUSTER=0, NUM_MHPMCOUNTERS=1
Initial corner: TT 1.05V 25C
Initial libraries: RVT + LVT + HVT mixed-VT
Clock period: 10 ns
Clock gate cell: CGLPPRX2_RVT
DFT insertion: DC/DFT Compiler
Scan chain count: 1
ATPG: TetraMAX stuck-at
Required equivalence: R2N and N2N Formality
Baseline freeze: tt_mvt_10ns_scan1 front-end baseline fixed at commit 5473b61
Next timing exploration: estimate from post-DFT topo/SDF slack before changing clock
```

See:

```text
docs/tt_mvt_10ns_scan1_execution_spec.md
```

## Baseline Freeze

```text
Date: 2026-05-07
Baseline: tt_mvt_10ns_scan1
Commit: 5473b61
Status: Front-End baseline completed, not signoff-clean
Evidence: DC topo, R2N, DFT topo, N2N, post-DFT SDF STA, TetraMAX stuck-at ATPG
Reason: Freeze the first complete reproducible 10 ns run before Fmax experiments.
```

## Fmax Estimate Decision

```text
Basis: post-DFT topo/SDF PrimeTime STA
Clock period: 10.00 ns
Worst setup slack: 1.48 ns
Estimated critical path delay: 8.52 ns
Ideal Fmax estimate: 117.4 MHz
Next trial candidates: 8.5 ns first, 8.0 ns if 8.5 ns is clean enough
Constraint: this is pre-layout/topographical estimate, not post-route signoff Fmax
```

## Active Script Cleanup

```text
Date: 2026-05-08
Decision: keep topographical synthesis flow only for active scripts
Removed active scripts:
  2_Synthesis/0_Script/run_analyze_elab_link.tcl
  2_Synthesis/0_Script/run_compile_10ns.tcl
  6_STA/0_Script/run_pt_pre_dft_10ns.tcl
Reason: current baseline and backend handoff use DC Graphical topo outputs and SDF-based STA.
Historical non-topo run evidence remains in RUN_LOG as history, but is not the active flow.
```

## Backend Library Format Decision

```text
Date: 2026-05-08
Decision: build ICC2 NDM reference libraries from SAED32 DB+LEF using lm_shell
Reason: direct Milkyway auto-conversion in ICC2/lm_shell failed because export_icc2_frame was unavailable in this install.
Result: RVT/LVT/HVT NDM libraries were generated and ICC2 linked the post-DFT netlist successfully.
```

## Initial Floorplan Decision

```text
Date: 2026-05-08
Decision: first ICC2 floorplan uses rectangular core, 1:1 aspect ratio, 65% target utilization, and 20um core offset
Reason: CV32E40P baseline has no macros, so a simple square-ish standard-cell floorplan is easiest to debug before power planning.
Result: ICC2 created a floorplan with reported utilization 65.40% and 382 top-level pins.
Next: create power plan before placement.
```

## Backend RC Tech Decision

```text
Date: 2026-05-08
Decision: read SAED32 TLU+ Cmin/Cmax into ICC2 init_design and bind them to the default corner
Reason: timing-driven placement aborted without valid parasitic data.
Files:
  max RC = saed32nm_1p9m_Cmax.tluplus
  min RC = saed32nm_1p9m_Cmin.tluplus
  map    = saed32nm_tf_itf_tluplus.map
Result: create_placement no longer aborts on missing RC values.
Evidence: 7_Backend_ICC2/4_Report/01_init_design/parasitic_parameters.rpt
```

## Placement Scan DEF Decision

```text
Date: 2026-05-08
Decision: allow first-pass placement to continue without scan DEF
ICC2 option: place.coarse.continue_on_missing_scandef = true
Reason: DFT handoff currently has SPF for ATPG but no ICC2 scan DEF. ICC2 otherwise stops placement on PLACE-042.
Risk: scan-chain-aware placement/reorder is not active. Placement QoR is acceptable only as first-pass learning evidence.
Next: add proper scan DEF generation/import before calling backend placement production-clean.
Evidence: 7_Backend_ICC2/3_Log/04_place/place_initial.log
```

## Power Plan Decision

```text
Date: 2026-05-08
Decision: keep PG plan with M1 rails, M2/M7/M8 mesh, M7/M8 ring, and boundary PG pins
Reason: M1 rails alone did not connect well to upper mesh. Adding M2 vertical straps greatly improved VSS and most VDD rail connectivity.
Rejected trial: M2 pitch 20um
Reject reason: created 1225 M1 spacing errors.
Chosen value: M2/M7/M8 pitch 40um and M7 horizontal offset 28um for first-pass DRC-clean PG connectivity.
Resolved issue: old M7 offset 20um left VDD with 3 floating wires and 499 floating std cells.
Evidence: 7_Backend_ICC2/4_Report/03_power/pg_connectivity.rpt and pg_drc.rpt
```

## VDD PG Bridge Trial Decision

```text
Date: 2026-05-08
Decision: reject narrow VDD-only M2 bridge strap trial
Reason: adding VDD-only M2 bridge straps produced PG DRC errors even though the goal was to reduce remaining VDD floating rails.
Observed floating VDD rails:
  PATH_11_12 y ~= 40.034
  PATH_11_36 y ~= 80.162
  PATH_11_60 y ~= 120.290
Rejected trial result:
  check_pg_drc reported 146 M1 insufficient-spacing errors.
Restored result:
  PG DRC clean again.
  VDD still has 3 floating wires and 499 floating std cells.
  VSS has 0 floating std cells.
Follow-up: resolved later by moving M7 horizontal mesh offset to 28um.
```

## M7 Mesh Offset Decision

```text
Date: 2026-05-08
Decision: set M7 horizontal mesh offset to 28um
Reason: M7 offset 20um aligned with three VDD stdcell M1 rails, preventing DRC-clean M1-M2 rail vias. Offset 22um and 25um moved the issue to VSS. Offset 28um avoids the observed rail collision for both supplies.
Rejected trial: targeted create_pg_vias repair
Reject reason: default DRC inserted 0 vias; forcing -drc no_check inserted vias but created 42 PG DRC errors.
Result: VDD and VSS both have 0 floating wires, 0 floating vias, and 0 floating std cells. PG DRC reports no errors.
Evidence:
  7_Backend_ICC2/4_Report/03_power/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/03_power/pg_drc.rpt
  7_Backend_ICC2/4_Report/04_place/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/04_place/pg_drc.rpt
```

## First-Pass CTS Decision

```text
Date: 2026-05-08
Decision: run first-pass CTS with clock_opt -from build_clock -to route_clock
Clock: clk_i
Target skew set in script/report_clock_tree_options: 0.20 ns
Clock routing rule: default rule, min layer M4, max layer M6
Reason: build and route the clock tree from the PG-clean placed design before wider route/final optimization.
Rejected script syntax: set_clock_routing_rules without -rules/-default_rule
Fix: added -default_rule with explicit M4-M6 layer limits.
Result: CTS completed, clock DRC count is 0, legality is 0 violations, listed setup/hold paths are MET.
Open items: CTS log also reports auto target skew as 1.500000 during build, no default max_transition constraint warning, missing scan DEF remains, report_qor has whole-design electrical DRC violations, and VSS has 2 floating boundary terminals in post-CTS PG connectivity.
Evidence:
  7_Backend_ICC2/3_Log/05_cts/cts_initial.log
  7_Backend_ICC2/4_Report/05_cts/clock_tree_options.rpt
  7_Backend_ICC2/4_Report/05_cts/clock_qor.summary.rpt
  7_Backend_ICC2/4_Report/05_cts/clock_qor.drc_violators.rpt
  7_Backend_ICC2/4_Report/05_cts/qor.rpt
  7_Backend_ICC2/4_Report/05_cts/check_legality.rpt
  7_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt
```

## First-Pass Route Decision

```text
Date: 2026-05-08
Decision: add a simple first-pass signal route script using route_auto
Reason: verify whether the post-CTS design can enter signal routing and produce route/timing/PG evidence.
Result: route_auto completed with 0 open nets, but detail route did not converge to DRC clean.
Route DRC: check_routes reports 408 total violations.
Main DRC classes: diff-net spacing 131, less-than-min-area 8, needs-fat-contact 106, off-grid 163.
Positive evidence: timing listed setup/hold paths are MET, legality is 0 violations, PG DRC is clean, and PG connectivity is fully connected.
Open items: improve route setup before extraction/STA, run check_routability before route, set explicit routing layer bounds, and investigate VDD/VSS top port no-pin/unplaced warnings.
Evidence:
  7_Backend_ICC2/3_Log/06_route/route_initial.log
  7_Backend_ICC2/4_Report/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/06_route/qor.rpt
  7_Backend_ICC2/4_Report/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/06_route/pg_connectivity.rpt
```

## Route Utilization Trial Decision

```text
Date: 2026-05-08
Decision: test lower floorplan density before changing route technology/setup assumptions
Trial: 60% target core utilization, same PG/place/CTS/route settings as baseline
Reason: baseline first-pass route had actual route utilization 77.17% and 408 check_routes DRCs.
Expected if density was dominant root cause: much lower route DRC count.
Observed:
  floorplan utilization report: 0.6027
  route utilization report: 0.7324
  route_auto final DRC: 406
  check_routes final DRC: 407
  open nets: 0
Conclusion: lowering target utilization from 65% to 60% does not materially improve DRC.
Decision: do not treat core utilization alone as the root cause. Next cleanup should focus on explicit route setup, via/contact/grid behavior, top PG port cleanup, and scan DEF handoff.
Evidence:
  7_Backend_ICC2/3_Log/trials/60util/trial_60util_to_route.log
  7_Backend_ICC2/4_Report/trials/60util/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/60util/06_route/utilization.rpt
```
