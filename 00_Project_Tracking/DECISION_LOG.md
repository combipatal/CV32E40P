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

## Pin-Check Lib And Blocked Access Decision

```text
Date: 2026-05-08
Decision: use create_pin_check_lib + check_libcell_pin_access -mode analyze_lib_cell as the valid ICC2 lib-cell pin-access flow for this environment
Reason: check_libcell_pin_access cannot run on the normal design library, and create_pin_check_lib requires a non-empty pin_check.place.preplace_option_file in this install.
Result: create_pin_check_lib succeeded for RVT/LVT/HVT together and separately; analyze_lib_cell succeeded; analyze_lib_pin is still blocked by LIB-001 current library context.
Blocked access finding: same-ref design-context report still has 117 pins with blocked access. Parsed detail entries are concentrated in SDFFARX1_RVT and MUX41X1_HVT, not INVX8_LVT.
Conclusion: route DRC root cause is more likely placed-context lower-metal pin access around scan flops/muxes than pure M1 track recreation or globally unusable library cells.
Evidence:
  docs/backend/pin_check_lib_blocked_access.md
  7_Backend_ICC2/4_Report/trials/create_pin_check_lib_trial/99_pin_check_lib/create_pin_check_lib_status.rpt
  7_Backend_ICC2/4_Report/trials/create_pin_check_lib_trial/99_pin_check_lib/check_libcell_pin_access.all.analyze_lib_cell.rpt
  7_Backend_ICC2/4_Report/trials/pin_access_blocked_detail/99_pin_access/blocked_access.compact_summary.rpt
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

## Route Layer Bound And DRC Detail Decision

```text
Date: 2026-05-08
Decision: fix main signal route layer bound to M1-M8 and add route DRC detail reporting
Reason: 60% + M8 trial reduced check_routes DRC from 407 to 400 and removed the signal route max-routing-layer warning, but did not close DRC.
Detailed finding: all 400 remaining DRCs in the current 60util_m8 block are on M1, M2, M1-M2, or VIA1.
Matrix:
  Diff net spacing: 119 on M1, 3 on M2
  Less than minimum area: 7 on M2
  Needs fat contact: 108 on M1-M2
  Off-grid: 5 on M1, 76 on M2, 79 on VIA1
  Short: 1 on M1, 2 on M2
Conclusion: upper-layer routing capacity is not the dominant remaining issue. Next repair should focus on lower-metal/VIA1/contact/grid behavior and top PG port cleanup.
Evidence:
  7_Backend_ICC2/3_Log/06_route/route_drc_detail.log
  7_Backend_ICC2/4_Report/06_route/drc_detail/drc.matrix.rpt
  7_Backend_ICC2/4_Report/06_route/drc_detail/drc.by_layer.rpt
  7_Backend_ICC2/4_Report/06_route/drc_detail/drc.detailed.rpt
  docs/backend/route_drc_detail_diagnosis.md
```

## Detail Route Repair Decision

```text
Date: 2026-05-08
Decision: do not continue blind incremental detail_route looping as the main route-closure method
Reason: direct repair trials did not solve the lower-metal/VIA1 DRC cluster.
Trial 1: 200 max iterations
  before DRC: 400
  after DRC: 398
  open nets: 0
  note: needs-fat-contact grew from 108 to 137
Trial 2: 1 max iteration
  before DRC: 400
  after DRC: 383
  open nets: 0
  note: best total count so far, but diff-net spacing grew to 224 on M1
Conclusion: router can reshuffle the violations, but the root problem remains lower-metal access/grid/contact setup.
Next decision path: clean top VDD/VSS no-pin/unplaced port handling, inspect lower-metal pin access/off-grid pins, review SAED32 via/contact setup, and add scan DEF handoff before another full route comparison.
Evidence:
  7_Backend_ICC2/3_Log/trials/detail_repair_200iter/detail_route_repair.log
  7_Backend_ICC2/4_Report/trials/detail_repair_200iter/06_route/check_routes.after.rpt
  7_Backend_ICC2/4_Report/trials/detail_repair_200iter/06_route/drc.after.matrix.rpt
  7_Backend_ICC2/3_Log/trials/detail_repair_1iter/detail_route_repair_1iter.log
  7_Backend_ICC2/4_Report/trials/detail_repair_1iter/06_route/check_routes.after.rpt
  7_Backend_ICC2/4_Report/trials/detail_repair_1iter/06_route/drc.after.matrix.rpt
  docs/backend/route_drc_detail_diagnosis.md
```

## PG Top Port Cleanup Decision

```text
Date: 2026-05-08
Decision: attach non-overlapping M8 terminals to VDD/VSS top ports after compile_pg
Reason: VDD/VSS ports exist after PG creation but have 0 terminals, causing route no-pin/unplaced warnings. The actual compile_pg boundary ports are VDD_1/VSS_1.
Rejected option 1: remove_ports VDD/VSS
  reason: PG stayed clean, but VDD/VSS reappeared after save/reopen or later flow.
Rejected option 2: set VDD_1_0/VSS_1_0 terminal port owner to VDD/VSS
  reason: ICC2 rejects non-bond-pad terminal port attribute updates.
Rejected option 3: create VDD/VSS terminal exactly on existing VDD_1/VSS_1 terminal bboxes
  reason: check_routability reports duplicate redundant pin-shape warnings.
Accepted option:
  VDD terminal bbox: {{13.0000 3.0000} {15.0000 5.0000}} on M8
  VSS terminal bbox: {{10.0000 3.0000} {12.0000 5.0000}} on M8
Result: VDD/VSS terminal_count becomes 1, VDD_1/VSS_1 remain at 8, PG connectivity remains clean, PG DRC has no errors, check_routability no longer reports VDD/VSS no-pin/unplaced or duplicate pin-shape warnings.
Persistence check: save/reopen keeps VDD/VSS terminal_count at 1.
Limit: route DRC remains open at 400 in the current routed trial block.
Evidence:
  docs/backend/pg_top_port_cleanup.md
  7_Backend_ICC2/3_Log/trials/pg_terminal_attach_offset/pg_terminal_attach_offset.log
  7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/terminal_attach_summary.rpt
  7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/check_routability.after.rpt
  7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/pg_connectivity.after.rpt
  7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/pg_drc.after.rpt
  7_Backend_ICC2/4_Report/trials/pg_port_diagnose_after_offset/99_pg_port/pg_port_summary.rpt
```

## Off-Track M1 Pin Diagnosis Decision

```text
Date: 2026-05-08
Decision: treat remaining 8 off-track M1 pin warnings as stdcell pin-access/track/contact setup issues, not PG top-port issues
Reason: after PG terminal attach, check_routability reports No PG net open, no blocked ports/nets, no standard-cell overlap, and no min-grid violations. Region query maps all 8 warning coordinates to real stdcell M1 pins.
Observed cells:
  SDFFARX1_RVT/QN: 5 warnings
  INVX8_LVT/A: 2 warnings
  MUX41X1_HVT/S1: 1 warning
Related warning:
  ZRT-022 Cannot find a default contact code for layer CO.
Conclusion: next route cleanup should inspect SAED32 NDM/LEF pin access, M1 track definition, CO/VIA1 contact setup, and Milkyway-vs-LEF-built NDM behavior before more route_detail loops.
Rejected action: manual stdcell LEF/NDM pin geometry edits.
Evidence:
  docs/backend/offtrack_pin_diagnosis.md
  7_Backend_ICC2/4_Report/trials/offtrack_pin_diagnose/99_route_access/check_routability.verbose.rpt
  7_Backend_ICC2/4_Report/trials/offtrack_pin_diagnose/99_route_access/offtrack_pin_objects.rpt
```

## CO Contact Code Diagnosis Decision

```text
Date: 2026-05-08
Decision: do not patch or create a CO ContactCode as the next fix
Reason: ZRT-022 is real because CO layer exists but CO via_def/default contact is absent. However CO is stdcell internal contact/pin geometry, while signal route M1-M2 access uses VIA1.
Evidence from ICC2:
  CO via_def_count = 0, default_count = 0
  VIA1 via_def_count = 6, default_count = 1
  default VIA1 = VIA12SQ_C lower=M1 upper=M2 excluded_for_signal=false
Track evidence:
  M1 start = 0.0880, pitch = 0.1520
  M2 start = 0.0880, pitch = 0.1520
  SAED32 unit site width = 0.152
  flagged pin coordinates are often 0.02-0.055um away from nearest track
Conclusion: ZRT-022 explains the CO warning, but current route DRC root cause is more likely stdcell M1 pin access versus routing track/VIA1 legality or LEF-built NDM access quality.
Next decision path: compare Milkyway reference vs LEF-built NDM behavior, then test pin-access/track options with check_routability before another full route run.
Evidence:
  docs/backend/contact_code_diagnosis.md
  7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/contact_code_summary.rpt
  7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/check_routability.contact.rpt
  7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/via_defs.cv32e40p_icc2_lib.rpt
```

## Milkyway Reference Path Decision

```text
Date: 2026-05-08
Decision: keep current ICC2 backend on DB+LEF-built NDM libraries
Reason: original SAED32 Milkyway reference libraries cannot be converted/used directly in this environment.
Trial: create_lib -technology $TECH_FILE -ref_libs {$MW_RVT $MW_LVT $MW_HVT}
Observed blockers:
  IC Compiler 1 icc_shell is not installed or not discoverable.
  lib.setting.milkyway_exec alone did not satisfy create_lib.
  Milkyway executable required wrapper translation from -f/-output_log_file to -file/-log.
  After wrapper translation, Milkyway export still failed due missing Milkyway and MDataPrep license features.
  Import failed because export tar.gz was never created.
Conclusion: Milkyway-reference vs LEF-built-NDM route behavior cannot be compared directly in current environment.
Next decision path: debug within DB+LEF-built NDM path by testing pin-access/report commands, M1 track offset trials, and lower-metal/VIA1 route options before full route rerun.
Evidence:
  docs/backend/mw_ref_open_trial.md
  7_Backend_ICC2/3_Log/trials/mw_ref_open_trial/mw_ref_open_trial.log
  7_Backend_ICC2/2_Output/trials/mw_ref_open_trial/local_cell_libs/log/cv32e40p_icc2_lib_mwref_saed32nm_rvt_1p9m_export_icc2_frame.log
  7_Backend_ICC2/2_Output/trials/mw_ref_open_trial/local_cell_libs/log/cv32e40p_icc2_lib_mwref_saed32nm_rvt_1p9m_import_icc_fram.log
```

## M1 Track Recreate Decision

```text
Date: 2026-05-08
Decision: reject manual M1 track recreation as the next route-closure fix
Reason: check_routability on an already routed block was misleading. Recreated M1 tracks removed visible ZRT-761 lines in that narrow probe, but a real reroute after signal route removal still had the 8 off-track warnings before route and then exploded route DRC.
Probe evidence:
  baseline routed block: 8 ZRT-761 off-track warnings
  recreated M1 start 0.012/0.050/0.076/0.088/0.126 on routed block: no ZRT-761 lines
Full-route evidence:
  before trial route: 400 DRCs
  after signal route removal + M1 start 0.088 recreate + route_auto: 27260 DRCs
  open nets: 0
  dominant DRC: illegal track route 24981
Conclusion: simple M1 offset/recreate is not the root-cause fix. Continue with proper pin-access library checking, blocked-access pin identification, NDM/LEF setup review, and scan/placement handoff work.
Evidence:
  docs/backend/pin_access_track_probe.md
  7_Backend_ICC2/3_Log/trials/pin_access_track_probe/pin_access_track_probe.log
  7_Backend_ICC2/3_Log/trials/m1_retrack_route_088/m1_retrack_route_088.log
  7_Backend_ICC2/4_Report/trials/m1_retrack_route_088/06_route/check_routes.before_remove.rpt
  7_Backend_ICC2/4_Report/trials/m1_retrack_route_088/06_route/check_routability.after_recreate.rpt
```
