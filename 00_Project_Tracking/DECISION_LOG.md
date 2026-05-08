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
