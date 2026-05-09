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

## Scan DEF Handoff Decision

```text
Date: 2026-05-08
Decision: add ICC2 scan DEF generation to the DFT handoff
Files:
  3_DFT/0_Script/run_insert_dft_10ns_topo.tcl
  3_DFT/0_Script/run_write_scan_def_from_post_dft.tcl
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def
Reason: ICC2 placement was previously allowed to continue without scan DEF. That bypass is acceptable only for early bring-up, not for scan-aware backend placement.
Result: ICC2 reads DEF SCANCHAINS. optimize_dft validates 1 scan chain and reduces scan wirelength in the scan_def_m8 trial.
Evidence:
  3_DFT/4_Report/topo/scan_path.existing.scan_def_source.rpt
  7_Backend_ICC2/3_Log/trials/scan_def_m8/scan_def_m8.log
```

## Advanced Legalizer Trial Decision

```text
Date: 2026-05-08
Decision: reject advanced legalizer / pin color alignment as current route-closure setting
Reason: scan_def_advleg_m8 and scan_def_advleg_color_m8 both finish with 0 open nets, legality 0, and PG clean, but route DRC is 605. This is worse than scan_def_m8 at 398.
Pin color result: place.legalize.enable_pin_color_alignment_check was enabled and pin_color_align legality violations are 0, but route DRC did not improve.
Current conclusion: route DRC is not caused simply by missing scan DEF or missing pin color alignment. The active root-cause focus remains lower-metal M1/M2/VIA1 access, stdcell pin/via/contact setup, and post-CTS density/clock-buffer interaction.
Evidence:
  docs/backend/scan_def_and_advanced_legalizer_trials.md
  7_Backend_ICC2/4_Report/trials/scan_def_m8/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/check_legality.rpt
```

## Route DRC Focus Decision

```text
Date: 2026-05-08
Decision: stop treating route DRC as a global density-only problem
Reason: marker context probe shows concentrated hotspots around x=220..260um and y=200..260um. Representative markers are tied to local stdcell pin/route context, including OR2X1_HVT, NOR2X0_HVT, SDFFARX1_RVT, and NBUFFX8_HVT examples. Some hotspot windows also include VDD/VSS PG shapes.
Next debug focus:
  local hotspot density
  PG strap/rail interaction
  lower-metal M1/M2/VIA1 route/access options
Rejected focus as standalone:
  global utilization reduction
  advanced legalizer/pin color alignment
  manual M1 track recreation
  blind detail-route looping
Evidence:
  docs/backend/drc_marker_context.md
  7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/representative_summary.rpt
  7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/marker_context.rpt
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

## Placement Spreading Trial Decision

```text
Date: 2026-05-08
Decision: reject pin-density/max-density spreading as a standalone route DRC fix
Trial: pin_access_spread
Options:
  place.coarse.pin_density_aware = true
  place.coarse.max_density = 0.70
  place.coarse.target_routing_density = 0.70, tool used 0.80
  place.coarse.increased_cell_expansion = true
Result: route open nets 0, legality 0 violations, PG clean, check_routes DRC 390
Blocked access result: official blocked pins worsened from 117 to 144; line-level blocked entries worsened from 125 to 150
Reason: route DRC improves only slightly, while the actual pin access metric gets worse.
Next: focus on scan DEF handoff, legalizer pin-track alignment, and lower-metal/via/contact setup instead of generic spreading.
Evidence:
  docs/backend/pin_access_drc_overlap_and_spread_trial.md
  7_Backend_ICC2/4_Report/trials/pin_access_spread/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/pin_access_spread_blocked_detail/99_pin_access/blocked_access.compact_summary.rpt
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

## Route DRC Root-Cause Focus Decision

```text
Date: 2026-05-08
Decision: pause blind DRC-reduction trials and focus on root-cause identification
Reason: multiple broad fix trials did not identify or close the problem. Overall utilization reduction, M8 signal layer bound, detail-route looping, scan DEF handoff, advanced legalizer/pin-color, generic placement spreading, and hotspot partial blockage alone all leave hundreds of route DRCs.
Hotspot evidence:
  scan_def_m8_restore fresh detail DRC = 398
  hotspot window {{215 195} {265 265}} contains 123 markers
  hotspot distribution: Off-grid VIA1 48, Off-grid M2 46, Diff net spacing M1 18, Needs fat contact 10, Off-grid M1 1
  representative off-grid markers are near NOR2X0_HVT signal pins and sometimes near VDD/VSS M2 PG stripes
  representative fat-contact markers are near OR2X1_HVT M1/M2 pin access
Rejected interpretation:
  do not treat this as simple global density or simple hotspot density issue.
Current leading hypotheses:
  1. stdcell pin access + M2/VIA1 off-grid interaction
  2. possible M2 PG mesh interference in the hotspot
  3. LEF-built NDM / pin-check quality issue
  4. route off-grid/via policy defaults
Next action:
  run cause probes that test one prediction at a time, starting with PG M2 stripe distance/offset evidence and then route off-grid/via option probes.
Evidence:
  docs/backend/route_drc_root_cause_investigation.md
  7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/drc_detail/drc.matrix.rpt
  7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/all_drc_markers.tsv
  7_Backend_ICC2/4_Report/trials/root_cause_probe/99_manual/route_common_app_options.rpt
  7_Backend_ICC2/4_Report/trials/root_cause_probe/99_manual/route_detail_app_options.rpt
```

## PG M2 Mesh Root-Cause Probe Decision

```text
Date: 2026-05-08
Decision: treat PG M2 mesh as a contributing route DRC cause, not as the only root cause
Reason: hotspot DRC-to-PG distance and M2 PG offset probe both show sensitivity to PG placement, but PG does not explain all hotspot markers and an offset-only change creates new PG DRC.
Distance evidence:
  hotspot window {{215 195} {265 265}} has 123 DRC markers
  M2 PG stripes inside hotspot are at x=219.8..220.2, x=239.8..240.2, and x=259.8..260.2
  23 markers are within 1um of M2 PG
  78 markers are within 5um of M2 PG
  45 markers are farther than 5um from M2 PG
Offset evidence:
  PG M2 offset 20um -> 30um changes signal route DRC 398 -> 377
  Diff net spacing changes 120 -> 82
  Needs fat contact changes 99 -> 127
  Off-grid changes 170 -> 163
  route open nets remain 0 and legality remains 0
  but PG DRC becomes invalid: 60 M1 insufficient-spacing errors after placement and 97 after route
Conclusion:
  PG M2 mesh location affects route DRC and is part of the cause.
  PG M2 offset 30um is rejected as a fix because PG DRC is not clean.
  The stronger root-cause model is PG mesh + stdcell pin access + M2/VIA1 route/via policy interaction.
Next action:
  keep the original PG-clean 20um/40um mesh as baseline for now.
  investigate route off-grid/via policy and stdcell pin access around NOR2X0_HVT/OR2X1_HVT before another PG structure change.
Evidence:
  docs/backend/route_drc_root_cause_investigation.md
  7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance/hotspot_drc_pg_distance_summary.rpt
  7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/03_power/pg_mesh_trial_settings.rpt
  7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/drc_detail/drc.matrix.rpt
  7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/pg_drc.rpt
```

## Route Off-Grid / Via Policy Probe Decision

```text
Date: 2026-05-08
Decision: treat route off-grid/via options as contributing knobs, not as the root-cause fix
Reason: two route option probes changed the DRC count only slightly and left the same lower-metal access classes open.
Probe 1:
  route.detail.generate_extra_off_grid_pin_tracks=true
  route DRC 398 -> 385
  Off-grid 170 -> 160
  Needs fat contact 99 -> 84
Probe 2:
  route.detail.drc_convergence_effort_level=high
  route.detail.optimize_wire_via_effort_level=high
  route DRC 398 -> 389
  Off-grid 170 -> 163
  Needs fat contact 99 -> 84
Common evidence:
  route open nets remain 0
  PG DRC remains clean
  ZRT-703 says force_end_on_preferred_grid is ignored because no layers have preferred grid
  ZRT-044 for MUX41X2_HVT/S0 no valid via regions appears in baseline and probes
Conclusion:
  simple router effort is not the main cause.
  extra off-grid pin tracks help slightly but do not solve the issue.
  next target should be stdcell valid via region / pin access data, especially MUX41X2_HVT/S0 and the lower-metal M2/VIA1 access model.
Evidence:
  docs/backend/route_drc_root_cause_investigation.md
  7_Backend_ICC2/4_Report/trials/route_offgrid_tracks_scan_def_m8/06_route/drc_detail/drc.matrix.rpt
  7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/drc_detail/drc.matrix.rpt
```

## MUX41X2_HVT/S0 Pin Access Decision

```text
Date: 2026-05-08
Decision: treat MUX41X2_HVT/S0 as a confirmed stdcell pin-access root-cause component
Reason:
  baseline and route-option trials all repeat ZRT-044 no valid via regions for MUX41X2_HVT/S0
  create_pin_check_lib/check_libcell_pin_access repeats the same issue as PDC-001 no via regions
  SAED32 HVT LEF shows MUX41X2_HVT/S0 has only one M1 stripe with height 0.050um
  SAED32 default VIA12SQ_C has 0.050um cut and needs M1 enclosure, so a valid VIA1 landing region is difficult on that stripe
Comparison:
  MUX41X1_HVT/S0 has the same stripe plus an extra M1 tab
  MUX41X2_HVT/S0 lacks that tab
Conclusion:
  this is not just router effort or one bad placement instance
  it is a real library pin-access weakness
  it does not alone explain all route DRCs, so keep the combined model: stdcell pin access + PG M2 mesh + M2/VIA1 routing policy
Next action:
  check whether MUX41X2_HVT usage can be avoided or swapped by library/cell-purpose constraints
  then continue with SDFFARX1_RVT blocked-access/hotspot overlap because official blocked access is still dominated by SDFFARX1_RVT
Evidence:
  docs/backend/mux41x2_pin_access_diagnosis.md
  7_Backend_ICC2/4_Report/trials/create_pin_check_lib_trial/99_pin_check_lib/check_libcell_pin_access.hvt.analyze_lib_cell.rpt
  7_Backend_ICC2/4_Report/trials/scan_def_m8_restore/06_route/check_routability.rpt
  /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef
  /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
```

## SDFFARX1_RVT Hotspot Overlap Decision

```text
Date: 2026-05-08
Decision: treat SDFFARX1_RVT blocked access as a hotspot contributor, not the sole root cause
Reason:
  current saved block has 352 SDFFARX1_RVT blocked access points
  hotspot contains 119 DRC markers but only 11 SDFFARX1_RVT blocked points
  all 11 hotspot SDFFARX1_RVT points have nearest DRC inside the hotspot
  10 of 11 are within 10um of the nearest DRC, 6 of 11 are within 5um
  all 11 nearest DRCs are Needs fat contact
  ICC2 context shows each hotspot SDFFARX1_RVT point has an M2 VSS PG stripe nearby at x=259.8..260.2
Conclusion:
  SDFFARX1_RVT pin access participates in the hotspot.
  SDFFARX1_RVT alone cannot explain the full hotspot because hotspot DRC count is much larger than SDFFARX1 hotspot blocked point count.
  Stronger model is now: x=260um M2 VSS PG stripe + SDFFARX1_RVT M2 pin access + lower-metal via/contact rules.
Next action:
  isolate all DRC markers near the x=259.8..260.2 M2 VSS stripe, then identify the full ref-cell distribution around that stripe.
Evidence:
  docs/backend/sdffarx1_hotspot_overlap.md
  7_Backend_ICC2/4_Report/trials/sdffarx1_current_hotspot_overlap/99_overlap/sdffarx1_overlap_summary.rpt
  7_Backend_ICC2/4_Report/trials/sdffarx1_hotspot_context/99_context/sdffarx1_hotspot_context.rpt
  7_Backend_ICC2/4_Report/trials/sdffarx1_hotspot_context/99_context/report_cell_pin_access.hotspot_sdffarx1.details.rpt
```

## Backend Fix Trial Decision

```text
Date: 2026-05-09
Decision: keep PG_M2_MESH_OFFSET at 20.0um and use route_combo_scan_def_m8 as the current best backend baseline candidate
Reason:
  PG M2 offset trials at 24/26/28um reduce or shift signal DRC slightly, but all create PG DRC
  hotspot 40% partial blockage is PG-clean and legal, but only reaches 391 route DRC
  route combo keeps open nets 0, legality 0, PG DRC clean, and improves route DRC to 381
Accepted route combo options:
  route.detail.generate_extra_off_grid_pin_tracks=true
  route.detail.drc_convergence_effort_level=high
  route.detail.optimize_wire_via_effort_level=high
Rejected as standalone fixes:
  PG_M2_MESH_OFFSET=24.0, 26.0, 28.0, 30.0
  hotspot 40% partial blockage
Conclusion:
  backend-only knobs improve 398 -> 381 but do not close route DRC
  next fix class should be front-end/library-driven cell selection or pin-access treatment, while keeping route_combo as the ICC2 route baseline
Evidence:
  docs/backend/backend_fix_trials_2026_05_09.md
  7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/pg_drc.rpt
```

## no_mux41x_hvt Decision

```text
Date: 2026-05-09
Decision: reject MUX41X*_HVT dont_use as a backend DRC fix
Reason:
  the front-end experiment is functionally valid
  DC replaced 67 MUX41X1_HVT cells with 67 MUX41X1_RVT cells
  R2N and N2N both pass with 2243 passing and 0 failing compare points
  DFT, ATPG, and PT SDF STA remain usable
  backend route_combo_no_mux41x_hvt has 399 route DRCs
  current best route_combo_scan_def_m8 has 381 route DRCs
Conclusion:
  MUX41X*_HVT pin access remains a confirmed library weakness
  but avoiding MUX41X*_HVT alone does not fix this backend route problem
  keep route_combo_scan_def_m8 as the current best backend candidate
Next action:
  continue root-cause work on PG M2 mesh + stdcell pin access + M2/VIA1 contact policy
Evidence:
  docs/backend/no_mux41x_hvt_experiment_2026_05_09.md
  2_Synthesis/4_Report/topo_no_mux41x_hvt/post_compile.references.rpt
  5_FM_N2N/4_Report/no_mux41x_hvt/n2n_topo_no_mux41x_hvt.failing_points.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_mux41x_hvt/06_route/check_routes.rpt
```

## Local PG M2 Cut Decision

```text
Date: 2026-05-09
Decision: treat x=259.8..260.2um VSS M2 PG stripe as a confirmed hotspot contributor, not a standalone fix
Reason:
  route_combo_pgcut_vss260 locally removed only the VSS M2 stripe segment inside {{258.0 195.0} {262.0 265.0}}
  the script recreated the stripe below and above the cut window
  PG connectivity remains clean for VDD and VSS
  check_pg_drc reports no errors
  route open nets remain 0
  placement legality remains 0
  route DRC improves from route_combo_scan_def_m8 381 to route_combo_pgcut_vss260 377
Conclusion:
  local M2 PG obstruction is a real contributor to the hotspot route DRC
  the 4-DRC improvement is too small to call PG M2 the sole root cause
  manual PG shape cutting is diagnosis evidence, not the preferred final implementation method
Next action:
  convert the learning from manual PG cut into proper PG planning options
  test cleaner PG strategy choices around the hotspot: regional M2 keepout/spacing, M2 stripe pitch/offset/width, or higher-metal-only PG in the local window
Evidence:
  docs/backend/local_pg_m2_cut_trial_2026_05_09.md
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/03_power/pg_m2_hotspot_cut.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/pg_drc.rpt
```

## All-M2 Hotspot PG Cut Decision

```text
Date: 2026-05-09
Decision: reject all-M2 hotspot PG cut as current best, but keep it as root-cause evidence
Reason:
  route_combo_pgcut_allm2_hotspot cuts VSS x=219.8..220.2, VDD x=239.8..240.2, and VSS x=259.8..260.2 inside {{215.0 195.0} {265.0 265.0}}
  route open nets remain 0
  placement legality remains 0
  PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC is 378, worse than route_combo_pgcut_vss260 at 377
  diff-net spacing improves strongly, 129/127 -> 96
  needs-fat-contact worsens, 79/91 -> 113
Conclusion:
  M2 PG obstruction is real but cannot be fixed by removing all local M2 PG access.
  Reducing local M2 PG obstruction changes signal routing and trades spacing failures for M1-M2 contact failures.
  The next useful experiment is individual stripe isolation, especially x=220 VSS and x=240 VDD.
Evidence:
  docs/backend/local_pg_m2_cut_trial_2026_05_09.md
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/03_power/pg_m2_hotspot_cut.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/pg_drc.rpt
```

## x=240 VDD PG Cut Decision

```text
Date: 2026-05-09
Decision: accept x=240 VDD M2 cut as the current best diagnosis candidate, but not as final PG signoff style
Reason:
  route_combo_pgcut_vdd240 cuts only VDD x=239.8..240.2 inside {{238.0 195.0} {242.0 265.0}}
  route open nets remain 0
  placement legality remains 0
  PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC is 376
  this improves route_combo_scan_def_m8 381 -> 376
  this improves route_combo_pgcut_vss260 377 -> 376
Conclusion:
  x=240 VDD M2 stripe is a stronger local obstruction contributor than x=260 VSS alone.
  The fix direction should convert this manual cut into a proper regional PG strategy.
  Route DRC is still open, so do not move to post-route signoff yet.
Next action:
  isolate x=220 VSS M2 stripe effect
  then decide whether the clean PG strategy should remove/avoid x=240 only or both x=220/x=240 in the hotspot window
Evidence:
  docs/backend/local_pg_m2_cut_trial_2026_05_09.md
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/03_power/pg_m2_hotspot_cut.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/pg_drc.rpt
```

## x=220 VSS PG Cut Decision

```text
Date: 2026-05-09
Decision: reject x=220 VSS M2 cut as current best
Reason:
  route_combo_pgcut_vss220 cuts only VSS x=219.8..220.2 inside {{218.0 195.0} {222.0 265.0}}
  route open nets remain 0
  placement legality remains 0
  PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC is 380
  this is worse than route_combo_pgcut_vdd240 at 376
Conclusion:
  x=220 VSS M2 stripe is not the preferred local removal target.
  It reduces diff-net spacing but worsens M1-M2 needs-fat-contact and short count.
  Keep x=220 VSS present in the next clean PG strategy.
Evidence:
  docs/backend/local_pg_m2_cut_trial_2026_05_09.md
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/03_power/pg_m2_hotspot_cut.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/pg_drc.rpt
```

## x=240 VDD Restore Decision

```text
Date: 2026-05-09
Decision: keep the saved ICC2 block at route_combo_pgcut_vdd240_restore for the next backend investigation step
Reason:
  x=220 VSS cut was rejected as best
  route_combo_pgcut_vdd240_restore reproduces the x=240 VDD result
  route open nets remain 0
  placement legality remains 0
  PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC is 376
Conclusion:
  continue from the x=240 VDD diagnosis candidate
  do not claim backend closure because route DRC remains open
  next work should replace the manual cut with a cleaner regional PG strategy or equivalent tool-supported PG construction
Evidence:
  7_Backend_ICC2/3_Log/trials/route_combo_pgcut_vdd240_restore/route_combo_pgcut_vdd240_restore.log
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240_restore/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240_restore/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240_restore/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240_restore/06_route/pg_drc.rpt
```

## Clean x=240 VDD PG Blockage Decision

```text
Date: 2026-05-09
Decision: accept route_combo_pgblock_vdd240 as the current best valid backend candidate
Reason:
  manual x=240 VDD cut was replaced by set_pg_strategy -blockage
  pg_strategies.rpt confirms blockage under core_mesh_strategy
  blockage target is VDD on M2 in pg_region hotspot_pg_m2_blockage
  route open nets remain 0
  placement legality remains 0
  route-stage PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC improves from route_combo_pgcut_vdd240 376 to route_combo_pgblock_vdd240 368
Conclusion:
  the cleaner PG strategy is better than the manual cut and should become the current backend baseline
  route DRC is still open, so do not move to post-route signoff yet
  remaining DRC is still lower-metal/access dominated: M1, M1-M2, M2, VIA1
Next action:
  analyze remaining hotspot markers in route_combo_pgblock_vdd240
  focus on M1-M2 needs-fat-contact and M2/VIA1 off-grid around x=220..260/y=200..260
Evidence:
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/03_power/pg_mesh_trial_settings.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/03_power/pg_strategies.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_drc.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.matrix.rpt
```

## Pin-Access Check Option Decision

```text
Date: 2026-05-09
Decision: reject route_pgblock_vdd240_pincheck as a new best candidate
Reason:
  trial adds only place.legalize.enable_multi_cell_pin_access_check=true
  VDD/M2 PG strategy blockage is unchanged from current best
  route open nets remain 0
  placement legality remains 0
  route-stage PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC remains 368
  detailed DRC matrix is identical to route_combo_pgblock_vdd240
Conclusion:
  the single multi-cell pin-access check option does not improve route closure
  current best remains route_combo_pgblock_vdd240
  next work should target route grid/via/contact policy or more specific cell/pin access treatment
Evidence:
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/04_place/place_legalize_app_options.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/pg_drc.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/drc_detail/drc.matrix.rpt
```

## Off-Track Via Region Option Decision

```text
Date: 2026-05-09
Decision: reject route_pgblock_vdd240_offtrackvia as a new best candidate
Reason:
  trial adds only place.legalize.support_off_track_via_region=true
  VDD/M2 PG strategy blockage is unchanged from current best
  route open nets remain 0
  placement legality remains 0
  route-stage PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC remains 368
  detailed DRC matrix is identical to route_combo_pgblock_vdd240
Conclusion:
  the single off-track via-region placement option does not improve route closure
  current best remains route_combo_pgblock_vdd240
  next work should target route grid/via/contact policy or specific lower-metal access geometry
Evidence:
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/04_place/place_legalize_app_options.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/pg_drc.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/drc_detail/drc.matrix.rpt
```

## Route Grid Option Value Decision

```text
Date: 2026-05-09
Decision: use single-brace Tcl list text for route grid/via list-pair env values
Reason:
  ICC2 man pages show list-pair values for route.common via/grid options
  shell env value '{{M2 0.5}}' becomes one brace level too deep for set_app_options
  ICC2 rejects that form with CMD-013 invalid value
  value probe confirms '{M2 0.5}' is accepted and reports back as {{M2 0.5}}
Conclusion:
  future env values should use forms like '{M2 0.5}' or '{VIA1 true}'
  do not use '{{M2 0.5}}' in shell commands
Evidence:
  7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/man_extra_via_off_grid_cost_multiplier_by_layer_name.rpt
  7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/route_grid_option_value_probe.rpt
```

## M2 Off-Grid Via Cost Decision

```text
Date: 2026-05-09
Decision: reject route_pgblock_vdd240_m2offgridcost05b as a new best candidate
Reason:
  trial adds route.common.extra_via_off_grid_cost_multiplier_by_layer_name={M2 0.5}
  route_common_app_options.rpt confirms the option was applied
  route open nets remain 0
  placement legality remains 0
  route-stage PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC remains 368
  detailed DRC matrix is identical to route_combo_pgblock_vdd240
Conclusion:
  small M2 off-grid via cost increase does not improve route closure
  current best remains route_combo_pgblock_vdd240
  next work should test explicit on-grid routing or targeted access geometry, one variable at a time
Evidence:
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/route_common_app_options.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/pg_drc.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/drc_detail/drc.matrix.rpt
```

## VIA1 On-Grid Route Option Decision

```text
Date: 2026-05-09
Decision: reject route_pgblock_vdd240_via1ongrid_b as a new best candidate
Reason:
  trial adds route.common.via_on_grid_by_layer_name={VIA1 true}
  route_common_app_options.rpt confirms the option was applied
  route open nets remain 0
  placement legality remains 0
  route-stage PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC remains 368
  DRC type counts remain Diff net spacing 91, Less than minimum area 5, Needs fat contact 120, Off-grid 152
  ZRT-044 for MUX41X2_HVT/S0 remains
Conclusion:
  explicit VIA1 on-grid routing does not improve route closure
  current best remains route_combo_pgblock_vdd240
  next work should test signal wire grid policy or targeted lower-metal access geometry, one variable at a time
Evidence:
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/route_common_app_options.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/pg_drc.rpt
```

## M2 Wire-On-Grid Route Option Decision

```text
Date: 2026-05-09
Decision: reject route_pgblock_vdd240_m2wireongrid as a new best candidate
Reason:
  trial adds route.common.wire_on_grid_by_layer_name={M2 true}
  route_common_app_options.rpt confirms the option was applied
  route open nets remain 0
  placement legality remains 0
  route-stage PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC worsens from 368 to 378
  diff-net spacing improves 91 -> 85
  needs-fat-contact worsens 120 -> 126
  off-grid worsens 152 -> 155
Conclusion:
  M2 wire grid policy affects the DRC mix, but it does not improve closure
  current best remains route_combo_pgblock_vdd240
  next work should inspect exact remaining lower-metal access geometry or test M1 wire grid separately
Evidence:
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/route_common_app_options.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/pg_drc.rpt
```

## M1 Wire-On-Grid Route Option Decision

```text
Date: 2026-05-09
Decision: reject route_pgblock_vdd240_m1wireongrid as a new best candidate
Reason:
  trial adds route.common.wire_on_grid_by_layer_name={M1 true}
  route_common_app_options.rpt confirms the option was applied
  route open nets remain 0
  placement legality remains 0
  route-stage PG connectivity remains clean
  check_pg_drc reports no errors
  total route DRC worsens from 368 to 380
  needs-fat-contact improves 120 -> 81
  diff-net spacing worsens 91 -> 130
  off-grid worsens 152 -> 158
Conclusion:
  M1 wire grid policy affects the DRC mix, but it does not improve closure
  current best remains route_combo_pgblock_vdd240
  exact lower-metal access/contact geometry should be inspected before more broad route-policy trials
Evidence:
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/route_common_app_options.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/pg_drc.rpt
```

## Current-Best Route DRC Root-Cause Direction

```text
Date: 2026-05-09
Decision: stop broad route-option/cell-ban trials and return to root-cause evidence on current-best 368 DRC route
Reason:
  current best route_combo_pgblock_vdd240 is valid as an open backend candidate:
    open nets 0
    legality 0
    PG connectivity clean
    PG DRC clean
    route DRC 368
  geometry residue analysis shows deterministic clustering:
    M1-M2 needs-fat-contact 120/120 at rx=0.064 ry=0.064 against 0.152um pitch
    M2 off-grid mostly at rx=0.061..0.066 ry=0.064
    VIA1 off-grid mostly at rx=0.061..0.066 ry=0.064
  PG blockage improves route DRC, so PG obstruction is real
  but 246 of 368 markers are more than 5um from the assumed hotspot M2 PG stripe centers
Conclusion:
  remaining DRC is not random congestion and not fixed by one broad route option
  strongest current root-cause model is:
    SAED32 stdcell M1 pin/contact geometry
    plus generated NDM routing grid / VIA1 legality mismatch
    plus local M2 PG obstruction in the hotspot
  next probe should map current-best DRC markers to nearby cells and pins before choosing a fix
Evidence:
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_drc.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.geometry_analysis.rpt
```

## Current-Best Marker Context Decision

```text
Date: 2026-05-09
Decision: make OR2X1_HVT and NOR2X*_HVT the next targeted root-cause candidates
Reason:
  ICC2 marker context was extracted on 35 representative markers from route_combo_pgblock_vdd240
  nearby pin ref-cell counts are:
    OR2X1_HVT 46
    NOR2X0_HVT 23
    NOR2X4_HVT 6
    SDFFARX1_RVT 5
    AO22X1_HVT 5
    FADDX2_HVT 3
    NAND2X0_HVT 2
  M1 diff-spacing representatives are OR2X1_HVT dominated
  M1-M2 needs-fat-contact representatives are OR2X1_HVT dominated
  M2/VIA1 off-grid representatives are NOR2X0_HVT/NOR2X4_HVT dominated
Conclusion:
  do not broadly ban random cells
  SDFFARX1_RVT remains a hotspot contributor, but it is not the main representative pattern
  next fix trial, if any, should be targeted:
    OR2X1_HVT sizing/dont_use trial for fat-contact/M1 spacing
    NOR2X0_HVT/NOR2X4_HVT sizing/dont_use trial for M2/VIA1 off-grid
    or NDM/tech/pin-access setup inspection for those ref-cell pins
Evidence:
  7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240_context/route_combo_pgblock_vdd240_context.log
  7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/99_marker_context/marker_context.rpt
```

## OR2X1_HVT Avoidance Decision

```text
Date: 2026-05-09
Decision: keep mixed-VT flow, but treat OR2X1_HVT as a confirmed avoid/replace candidate for the next MVT fix direction
Reason:
  OR2X1_HVT dont_use passed the front-end checks:
    DC topo synthesis passed
    R2N Formality passed
    DFT insertion passed
    N2N Formality passed
    PT post-DFT SDF STA passed at 10ns
  Backend route trial with the same current-best physical conditions improved:
    route DRC 368 -> 203
    open nets stayed 0
    legality stayed 0
    PG connectivity stayed clean
    PG DRC stayed clean
  final check_routes for no_or2x1_hvt has only:
    Off-grid 203
  ZRT-044 for MUX41X2_HVT/S0 still remains
Conclusion:
  OR2X1_HVT was a major contributor to M1 spacing and M1-M2 needs-fat-contact classes
  but OR2X1_HVT was not the only root cause
  remaining root-cause target is now the off-grid class, likely tied to other HVT pin-access/grid-sensitive cells such as MUX41X2_HVT and NOR2X*_HVT plus generated NDM/VIA1 behavior
  do not switch to RVT-only yet
  continue MVT repair with targeted HVT avoid/replace or NDM/pin-access investigation
Evidence:
  2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_hvt.log
  2.5_FM_R2N/4_Report/no_or2x1_hvt/r2n_topo_no_or2x1_hvt.passing_points.post_verify.rpt
  3_DFT/3_Log/insert_dft_10ns_topo_no_or2x1_hvt.log
  5_FM_N2N/4_Report/no_or2x1_hvt/n2n_topo_no_or2x1_hvt.passing_points.post_verify.rpt
  6_STA/3_Log/pt_post_dft_10ns_sdf_no_or2x1_hvt.log
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/check_routes.rpt
```

## NOR2X0_HVT/NOR2X2_HVT Follow-Up Probe Decision

```text
Date: 2026-05-09
Decision: do not stop at NOR2X0_HVT/NOR2X2_HVT avoidance; continue MVT repair toward remaining NOR2X1_HVT/MUX41X2_HVT pin-access/off-grid causes
Reason:
  no_or2x1_hvt remaining route DRC was all Off-grid 203
  representative markers from no_or2x1_hvt pointed to NOR2X0_HVT/NOR2X2_HVT
  targeted dont_use of OR2X1_HVT + NOR2X0_HVT + NOR2X2_HVT passed front-end validation:
    R2N 2243 pass / 0 fail
    N2N 2243 pass / 0 fail
    PT post-DFT SDF setup/hold clean
  backend route DRC improved only 203 -> 188
  remaining DRC is still dominated by lower-metal off-grid:
    Off-grid 186
    Diff net spacing 2
    M2 88
    VIA1 91
  marker context after this probe is dominated by NOR2X1_HVT:
    NOR2X1_HVT 47
    OR2X4_HVT 13
    FADDX2_HVT 12
    NOR2X4_HVT 8
    FADDX1_HVT 8
  ZRT-044 for MUX41X2_HVT/S0 still remains
Conclusion:
  NOR2X0_HVT/NOR2X2_HVT were contributors, not the remaining main root cause
  the root cause is now narrowed to lower-metal M2/VIA1 off-grid behavior around remaining HVT cells, especially NOR2X1_HVT, plus the persistent MUX41X2_HVT/S0 valid-via-region issue
  MVT should still be kept; fix by targeted cell avoidance or library/pin-access setup, not RVT-only
Evidence:
  2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_nor2x02_hvt.log
  2.5_FM_R2N/4_Report/no_or2x1_nor2x02_hvt/r2n_topo_no_or2x1_nor2x02_hvt.passing_points.post_verify.rpt
  5_FM_N2N/4_Report/no_or2x1_nor2x02_hvt/n2n_topo_no_or2x1_nor2x02_hvt.passing_points.post_verify.rpt
  6_STA/4_Report/post_dft_topo_sdf_no_or2x1_nor2x02_hvt/post_dft_no_or2x1_nor2x02_hvt.func_tt_10ns_sdf.global_timing.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/06_route/drc_detail/drc.matrix.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/99_marker_context/marker_context.rpt
```

## NOR2X1_HVT Follow-Up Probe Decision

```text
Date: 2026-05-09
Decision: treat NOR2X1_HVT as a confirmed major off-grid contributor; continue with NOR2X4_HVT as the next targeted MVT probe
Reason:
  no_or2x1_nor2x02_hvt route had 188 DRCs, dominated by Off-grid 186
  representative marker context was dominated by NOR2X1_HVT
  targeted dont_use of OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT passed front-end validation:
    DC topo timing met at 10ns
    R2N 2243 pass / 0 fail
    DFT inserted 1 scan chain / 2130 scan cells
    N2N 2243 pass / 0 fail
    PT post-DFT SDF setup/hold clean
  backend route DRC improved:
    188 -> 110
    open nets 0
    legality 0
    PG connectivity clean
    PG DRC clean
  remaining DRC matrix:
    M1 5
    M2 53
    VIA1 52
  remaining marker context:
    NOR2X4_HVT 72
    SDFFARX1_RVT 31
    OR2X4_HVT 7
  ZRT-044 for MUX41X2_HVT/S0 still remains
Conclusion:
  NOR2X1_HVT is confirmed as a large lower-metal off-grid contributor
  route DRC is not closed yet
  next narrow MVT repair trial should add NOR2X4_HVT avoidance
  SDFFARX1_RVT is now the main RVT sequential contributor but should be treated carefully because changing scan flops has broader DFT impact
Evidence:
  2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_nor2x012_hvt.log
  2.5_FM_R2N/4_Report/no_or2x1_nor2x012_hvt/r2n_topo_no_or2x1_nor2x012_hvt.passing_points.post_verify.rpt
  5_FM_N2N/4_Report/no_or2x1_nor2x012_hvt/n2n_topo_no_or2x1_nor2x012_hvt.passing_points.post_verify.rpt
  6_STA/4_Report/post_dft_topo_sdf_no_or2x1_nor2x012_hvt/post_dft_no_or2x1_nor2x012_hvt.func_tt_10ns_sdf.global_timing.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/06_route/drc_detail/drc.matrix.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/99_marker_context/marker_context.rpt
```

## NOR2X4_HVT Broad Avoidance Rejection

```text
Date: 2026-05-09
Decision: reject broad NOR2X4_HVT dont_use as a backend fix
Reason:
  no_or2x1_nor2x012_hvt marker context pointed to NOR2X4_HVT near many remaining markers
  the hypothesis was tested by adding NOR2X4_HVT to the existing avoid list:
    OR2X1_HVT
    NOR2X0_HVT
    NOR2X1_HVT
    NOR2X2_HVT
    NOR2X4_HVT
  front-end validation passed:
    DC topo timing met at 10ns
    R2N 2243 pass / 0 fail
    DFT inserted 1 scan chain / 2130 scan cells
    N2N 2243 pass / 0 fail
    PT post-DFT SDF setup/hold clean
  backend route worsened badly:
    110 -> 481 route DRC
    Off-grid 104 -> 477
    M2 53 -> 232
    VIA1 52 -> 245
  open nets stayed 0
  legality stayed 0
  PG connectivity stayed clean
  PG DRC stayed clean
  synthesis cell count increased:
    13880 -> 14302
Conclusion:
  NOR2X4_HVT appears near remaining markers, but broad removal is not a valid fix
  removing NOR2X4_HVT causes wider logic restructuring and creates much more M2/VIA1 off-grid routing
  keep current best cause-evidence baseline as no_or2x1_nor2x012_hvt at 110 DRC
  next investigation should not add more broad dont_use by marker context alone
  next target should be pin/access-level diagnosis around the 110-DRC design, especially SDFFARX1_RVT and persistent MUX41X2_HVT/S0 valid-via-region
Evidence:
  2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.references.rpt
  2.5_FM_R2N/4_Report/no_or2x1_nor2x0124_hvt/r2n_topo_no_or2x1_nor2x0124_hvt.passing_points.post_verify.rpt
  5_FM_N2N/4_Report/no_or2x1_nor2x0124_hvt/n2n_topo_no_or2x1_nor2x0124_hvt.passing_points.post_verify.rpt
  6_STA/4_Report/post_dft_topo_sdf_no_or2x1_nor2x0124_hvt/post_dft_no_or2x1_nor2x0124_hvt.func_tt_10ns_sdf.global_timing.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/drc_detail/drc.matrix.rpt
```

## Remaining Off-Grid Root Cause Direction

```text
Date: 2026-05-09
Decision: treat remaining 110-DRC baseline as HVT OR/NOR A2 access/grid mismatch, not broad cell-family removal
Reason:
  restored no_or2x1_nor2x012_hvt route has 110 DRC:
    Off-grid 104
    Diff net spacing 5
    Short 1
  full marker context shows repeated nearby ref cells:
    NOR2X4_HVT 85
    OR2X4_HVT 16
    SDFFARX1_RVT 7
    NOR2X0_HVT 2
  coordinate matching shows 103 / 110 markers align with report_cell_pin_access coordinates within 0.08um
  all 103 matched points are A2 routable access points:
    NOR2X4_HVT/A2: 43 VIA1 off-grid + 42 M2 off-grid
    OR2X4_HVT/A2: 8 VIA1 off-grid + 8 M2 off-grid
    NOR2X0_HVT/A2: 1 VIA1 off-grid + 1 M2 off-grid
  report_cell_pin_access calls these points Routable, but check_routes reports the same locations as Off-grid
Conclusion:
  remaining primary issue is route/check grid or contact/via generation mismatch around HVT OR/NOR A2 access
  NOR2X4_HVT broad dont_use remains rejected because it worsens route DRC to 481
  next fixes should be targeted:
    route/access option trial
    selected instance swap/resize around A2 off-grid markers
    pin-check-lib / NDM rule validation
Evidence:
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/06_route/drc_detail/drc.matrix.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_marker_context_all/marker_context.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/report_cell_pin_access.targets.details.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/drc_to_pin_access_coordinate_match.tsv
```

## Targeted A2 LVT ECO Rejection

```text
Date: 2026-05-09
Decision: reject targeted HVT OR/NOR A2 LVT swap as the current root fix
Reason:
  52 instances were selected only when DRC marker coordinates matched HVT OR/NOR A2 access coordinates:
    43 NOR2X4_HVT -> NOR2X4_LVT
    8 OR2X4_HVT -> OR2X4_LVT
    1 NOR2X0_HVT -> NOR2X0_LVT
  first ECO swap trial applied all 52 swaps at init, but final optimization changed every requested LVT ref away:
    41 NOR2X4_RVT
    8 OR2X4_RVT
    2 NOR2X0_HVT
    1 NOR2X4_HVT
  that trial reported only weak numeric movement:
    110 -> 109 route DRC
  second ECO swap trial added dont_touch to preserve requested LVT refs:
    43 NOR2X4_LVT
    8 OR2X4_LVT
    1 NOR2X0_LVT
  preserved-LVT trial still reports 110 route DRC:
    Off-grid 109
    Same net spacing 1
Conclusion:
  remaining A2 DRC is not solved by simply forcing matched HVT OR/NOR instances to LVT
  the cause remains route/check grid or via/contact generation around OR/NOR A2 access
  keep MVT flow
  do not broad-ban NOR2X4_HVT
  next probe should inspect NDM/LEF pin access/grid/via definitions or routing access options, not another blind VT swap
Evidence:
  configs/backend/a2_offgrid_hvt_to_lvt_swap.tsv
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/01_init_design/eco_swap.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/99_eco_swap_final_ref/eco_swap_final_ref.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/99_eco_swap_final_ref/eco_swap_final_ref.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/06_route/check_routes.rpt
```

## Via-Ladder Center-Track Probe Rejection

```text
Date: 2026-05-09
Decision: reject route.auto_via_ladder.generate_center_track_on_off_grid_pattern_must_join_pin_shapes=true as a fix
Reason:
  option was selected because route/check logs repeatedly report via ladder activation for pattern-must-join connection
  final check_routes remains 110 DRC:
    Off-grid 104
    Diff net spacing 5
    Short 1
  open nets remain 0
  legality remains 0
  PG connectivity and PG DRC remain clean
Conclusion:
  this option is not sufficient to fix the remaining route DRC
  because intermediate routing iterations moved Off-grid as low as 101, the route access / via-ladder / pattern-must-join mechanism is still likely related
  continue MVT flow
  current best root-cause model remains OR/NOR A2 pin access versus route/check grid or VIA1/contact generation mismatch
Evidence:
  7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/route_auto_via_ladder_app_options.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/pg_drc.rpt
```

## A2 Edge-of-Legal-Window Root Cause Model

```text
Date: 2026-05-09
Decision: treat remaining 110-route-DRC issue as A2 edge-of-legal-window access plus VIA1/contact snapping/grid mismatch
Reason:
  103 matched A2 marker/access rows reduce to 52 unique A2 access points
  unique points by ref:
    NOR2X4_HVT: 43
    OR2X4_HVT: 8
    NOR2X0_HVT: 1
  NOR2X4_HVT/A2 LEF M1 rectangle:
    x1=0.489 x2=0.663
  default VIA1 M1 enclosure requirement:
    cut_width/2 + enc_x = 0.050/2 + 0.030 = 0.055
  maximum legal VIA1 center X on that A2 M1 rectangle:
    0.663 - 0.055 = 0.608
  observed local access X:
    NOR2X4_HVT: 0.608 for all 43 unique access points
  33 of 43 NOR2X4_HVT access points are inside M1 but enclosure-tight
  NOR2 HVT drive variants share the same A2 M1 geometry
  NOR2X4_LVT/RVT share the same A2 M1 geometry as NOR2X4_HVT
Conclusion:
  the remaining issue is not solved by VT swap because pin geometry does not change
  report_cell_pin_access can call the point routable because it is just legal or near legal
  route/check can still produce Off-grid when generated via/contact snaps or checks at the edge
  do not broadly ban NOR2X4_HVT
  next candidates should be route access policy or controlled structural/cell-mapping alternatives, not broad VT replacement
Evidence:
  scripts/analyze_a2_lef_access_alignment.py
  7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/a2_lef_access_alignment.rpt
```

## M1 Pin-Contained Via Route Policy Rejection

```text
Date: 2026-05-09
Decision: reject route.common.connect_within_pins_by_layer_name={M1 via_standard_cell_pins} as a fix
Reason:
  option was selected because remaining A2 access points are at the edge of the legal VIA1-on-M1 window
  app option applied correctly:
    route.common.connect_within_pins_by_layer_name {M1 via_standard_cell_pins}
  final check_routes worsens from 110 to 148:
    Connection not within pin: 43
    Diff net spacing: 38
    Less than minimum area: 1
    Needs fat contact: 26
    Off-grid: 31
    Short: 9
  open nets remain 0
  legality remains 0
  PG connectivity and PG DRC remain clean
Conclusion:
  forcing M1 standard-cell pin-contained via connection is not a usable fix
  but the DRC class conversion is important:
    Off-grid drops 104 -> 31
    pin-containment and fat-contact errors appear
  this confirms the remaining issue is controlled by pin-contained VIA1/access geometry around A2
  next fix class should be controlled structural/cell-mapping changes or a more surgical access policy, not broad VT replacement
Evidence:
  7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/route_common_app_options.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/pg_drc.rpt
```

## Targeted A1/A2 Pin-Swap ECO Candidate

```text
Date: 2026-05-09
Decision: accept targeted commutative A1/A2 pin swap as current best backend candidate, not final closure
Reason:
  remaining A2 DRCs are edge-of-legal-window access issues on commutative OR/NOR gates
  selected 52 cells from matched A2 DRC/access coordinates:
    NOR2X4_HVT: 43
    OR2X4_HVT: 8
    NOR2X0_HVT: 1
  all 52 ECO pin swaps applied:
    A1 net and A2 net were swapped per selected cell
  final check_routes improves:
    previous baseline: 110 DRC
    pin-swap trial: 103 DRC
  final DRC mix:
    Off-grid: 101
    Diff net spacing: 2
  clean checks:
    open nets: 0
    legality: 0
    PG connectivity: clean
    PG DRC: no errors
Conclusion:
  targeted A1/A2 pin swap is better than broad NOR2X4_HVT dont_use and better than VT swap
  it confirms the physical pin choice matters
  it is still not backend closure because route DRC is not 0
  it is not signoff-ready because the post-DFT ECO needs an equivalence strategy before being treated as a final implementation change
Evidence:
  configs/backend/a2_edge_commutative_pin_swap.tsv
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/01_init_design/eco_pin_swap.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/check_routes.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/check_legality.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/pg_connectivity.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/pg_drc.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/drc_detail/drc.matrix.rpt
```

## A1/A2 Pin-Swap Follow-Up Diagnosis

```text
Date: 2026-05-09
Decision: do not continue pin-swap-only ECO as the main closure strategy
Reason:
  full marker context was extracted for all 103 remaining DRCs after the A1/A2 swap
  95 of 103 remaining markers are still near cells already touched by the pin-swap ECO
  ref distribution by marker count:
    NOR2X4_HVT: 81
    OR2X4_HVT : 16
    FADDX2_HVT: 2
    NOR2X2_HVT: 2
    SDFFARX1_RVT: 2
  broad marker-context pin overlap:
    A1: 99
    VSS: 87
    VDD: 82
    CI/B/A/RSTB: 2 each
  this broad overlap is not sufficient to identify the actual failing access point
  coordinate match against report_cell_pin_access gives stronger evidence:
    97 of 103 markers match a Routable A2 access point within 0.08um
    0 markers have blocked access as the nearest matched point
    matched classes are Off-grid VIA1 50 and Off-grid M2 47
  blocked access after pin swap is dominated by other refs:
    SDFFARX1_RVT: 136 line-level blocked entries
    MUX41X1_HVT : 14
    NOR2X4_HVT/A1: 2
  NOR2X4_HVT LEF confirms both input pins are small lower-metal access shapes:
    A2 M1 RECT 0.4890 0.5530 0.6630 0.7330
    A1 M1 RECT 0.2490 0.6310 0.4210 0.8150
Conclusion:
  pin choice matters numerically, but the trial mostly leaves DRC at A2 physical access points
  broad context overlap made A1 look dominant, but coordinate matching shows A2 remains dominant
  the remaining issue is not blocked pin access
  the remaining issue is Routable A2 access versus route/check grid or generated VIA1/M2 geometry mismatch
  the next fix should avoid creating these problematic OR/NOR pin-access situations structurally
  likely direction is synthesis/cell-mapping constraint or controlled decomposition for the affected OR/NOR population
  backend-only pin-swap remains useful evidence, not signoff-ready implementation
Evidence:
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context_all/marker_context.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context_all/marker_context_summary.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_pin_access_after_pin_swap/blocked_access.compact_summary.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_pin_access_after_pin_swap/drc_to_pin_access_coordinate_match.summary.rpt
  7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_pin_access_after_pin_swap/a2_access_grid_mismatch_after_pin_swap.rpt
  scripts/summarize_drc_marker_context.py
  scripts/match_drc_to_cell_pin_access.py
  /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef
```
