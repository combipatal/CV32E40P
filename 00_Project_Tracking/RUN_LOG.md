# Run Log

## tt_mvt_10ns_scan1

Use this file to record command invocations, dates, pass/fail status, and important report paths.

```text
Date:
Command:
Stage:
Result:
Notes:
```

```text
Date: 2026-05-08
Command: repository edit
Stage: Front-End script cleanup
Result: PASS
Notes: Active synthesis flow was reduced to DC Graphical topo only. Removed non-topo/stale active scripts run_analyze_elab_link.tcl, run_compile_10ns.tcl, and run_pt_pre_dft_10ns.tcl. Added Korean study comments to active Front-End Tcl/SDC scripts.
```

```text
Date: 2026-05-08
Command: /tools/synopsys/syn/W-2024.09-SP5-5/icc2/bin/lm_shell -batch -file 7_Backend_ICC2/0_Script/00_setup/build_saed32_ndm.tcl -output_log_file 7_Backend_ICC2/3_Log/00_setup/build_saed32_ndm.log
Stage: ICC2 reference library setup
Result: PASS_WITH_NOTE
Notes: Built saed32rvt_tt.ndm, saed32lvt_tt.ndm, and saed32hvt_tt.ndm from SAED32 TT DB+LEF. Workspace checks succeeded. Warnings include LEF bus-bit character defaulting, duplicate timing arcs, PG pin direction mismatch auto-fixes, and large M1 frame blockage warnings in some cells.
```

```text
Date: 2026-05-08
Command: /tools/synopsys/syn/W-2024.09-SP5-5/icc2/bin/icc2_shell -batch -file 7_Backend_ICC2/0_Script/01_init_design/run_init_design_check.tcl -output_log_file 7_Backend_ICC2/3_Log/01_init_design/init_design_check.log
Stage: ICC2 init_design check
Result: PASS_WITH_NOTE
Notes: ICC2 created cv32e40p_icc2_lib, read post-DFT topo netlist, linked cv32e40p_synth_wrap successfully against RVT/LVT/HVT NDM libraries, read post-DFT SDC, generated reports, saved block and library. check_design netlist/design_mismatch/timing reported 0 errors and 14004 warnings; main warning classes are unconnected/unloaded/direct-connected nets and unconstrained endpoints. report_timing uses zero interconnect delay because no floorplan/parasitics exist yet.
```

```text
Date: 2026-05-08
Command: /tools/synopsys/syn/W-2024.09-SP5-5/icc2/bin/icc2_shell -batch -file 7_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.tcl -output_log_file 7_Backend_ICC2/3_Log/02_floorplan/floorplan_initial.log
Stage: ICC2 floorplan initial
Result: PASS_WITH_NOTE
Notes: Opened cv32e40p_icc2_lib:cv32e40p_synth_wrap, initialized rectangular floorplan with target utilization 0.65, core offset 20um, and 1:1 aspect ratio. ICC2 reported core utilization ratio 65.40%, core area coordinates {20 20} {295.728 294.208}, utilization 0.6540, and 382 created pins. check_design reported 0 errors and 14004 warnings. Routing directions were auto-derived for M1-MRDL; power plan/placement/routing are not done yet.
```

```text
Date: 2026-05-07
Command: source ~/.bashrc; dc_shell -f 2_Synthesis/0_Script/run_analyze_elab_link.tcl
Stage: DC analyze/elaborate/link
Result: FAIL
Notes: Script used invalid DC syntax, analyze -format sverilog -f filelists/cv32e40p_dc.f. DC interpreted -f as -format. Fixed by adding filelists/cv32e40p_dc.tcl and analyzing explicit RTL_FILES list.
```

```text
Date: 2026-05-07
Command: source ~/.bashrc; dc_shell -f 2_Synthesis/0_Script/run_analyze_elab_link.tcl
Stage: DC analyze/elaborate/link
Result: PASS
Notes: RTL analyzed, cv32e40p_synth_wrap elaborated, link completed. Generated 2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.elab.ddc. check_design has many LINT warnings from disabled FPU/PULP/PMP/APU paths and constants; no unresolved design blocker seen.
```

```text
Date: 2026-05-07
Command: source ~/.bashrc; dc_shell -f 2_Synthesis/0_Script/run_compile_10ns.tcl
Stage: DC compile
Result: INVALID
Notes: compile_ultra completed and wrote pre_dft DDC/VG/SVF, but read_sdc reported unknown command remove_from_collection. Timing numbers from this run are not used. Fixed constraints/cv32e40p_func_10ns.sdc by listing input/output ports explicitly.
```

```text
Date: 2026-05-07
Command: source ~/.bashrc; dc_shell -f 2_Synthesis/0_Script/run_compile_10ns.tcl
Stage: DC compile
Result: PASS_WITH_NOTE
Notes: Final 10 ns mixed-VT TT compile completed. Outputs: 2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.ddc, .vg, .sdc, and 2_Synthesis/2_Output/svf/cv32e40p_synth_wrap.pre_dft.svf. DC QoR: setup WNS 0.02 ns, TNS 0.00, no setup/hold violating paths, cell area 44899.37. DC reports one max_cap violation at rounded 16.00/16.00, treated as residual DRC item.
```

```text
Date: 2026-05-07
Command: source ~/.bashrc; pt_shell -f 6_STA/0_Script/run_pt_pre_dft_10ns.tcl
Stage: PrimeTime pre-DFT STA
Result: PASS_WITH_NOTE
Notes: PT linked synthesized netlist and read functional 10 ns SDC. check_timing succeeded. No setup or hold violations. Worst setup slack is 0.02 ns on path u_core/core_i/id_stage_i/prepost_useincr_ex_o_reg -> data_addr_o[31]. PT reports 476 max_cap violations; keep as next investigation before calling full front-end closure.
```

```text
Date: 2026-05-07
Command: source ~/.bashrc; dc_shell -topographical_mode -f 2_Synthesis/0_Script/run_compile_10ns_topo.tcl
Stage: DC Graphical topographical compile
Result: PASS_WITH_NOTE
Notes: Topographical mode entered successfully. Milkyway design lib, RVT/LVT/HVT MW reference libs, SAED32 tech file, and TLU+ RC files were used. Outputs: 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.{ddc,vg,sdc,sdf} and 2_Synthesis/2_Output/svf/cv32e40p_synth_wrap.pre_dft_topo.svf. DC QoR: setup WNS 1.61 ns, TNS 0.00, no setup/hold violating paths, cell area 45313.37. DC still reports max_cap/max_transition DRC violations, so this is timing-clean but DRC-not-clean.
```

```text
Date: 2026-05-07
Command: source ~/.bashrc; pt_shell -f 6_STA/0_Script/run_pt_pre_dft_10ns_sdf.tcl
Stage: PrimeTime pre-DFT SDF STA
Result: PASS_WITH_NOTE
Notes: PT linked the topographical netlist, read functional 10 ns SDC, and annotated DC-generated SDF with 0 read_sdf errors. Annotated arcs: 106265 cell delay arcs, 43148 net delay arcs, 13076 timing checks, 6390 constraints. check_timing succeeded. No setup or hold violations. Worst setup slack is 1.61 ns; worst hold slack is 0.06 ns. PT still reports max_cap violations, so this is SDF timing-clean but DRC-not-clean.
```

```text
Date: 2026-05-07
Command: fm_shell -work_path 2.5_FM_R2N/FM_WORK -file 2.5_FM_R2N/0_Script/run_fm_r2n_topo.tcl -overwrite
Stage: Formality R2N topo
Result: PASS
Notes: RTL reference cv32e40p_synth_wrap matched against DC Graphical pre-DFT topo netlist using the topo SVF. Functional constants were applied to scan_cg_en_i, scan_en, and scan_in. Formality reverse clock-gating was enabled for DC-inserted LATCG cells. scan_out is an undriven pre-DFT wrapper output and was marked don't-verify. Final result: Verification SUCCEEDED, 2243 passing compare points, 0 failing compare points. Reports are under 2.5_FM_R2N/4_Report/.
```

```text
Date: 2026-05-07
Command: dc_shell -topographical_mode -f 3_DFT/0_Script/run_insert_dft_10ns_topo.tcl
Stage: DC/DFT Compiler topographical DFT insertion
Result: PASS_WITH_NOTE
Notes: Inserted one muxed scan chain. Outputs: 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.{ddc,vg,sdc,sdf,spf}. SPF is written after insert_dft so ScanStructures contains chain0 length 2130. DFT DRC reports 1 TEST-505 constant-1 clock-gate note; 2130 cells are valid scan cells. DC post-DFT critical path slack is 1.48 ns, TNS 0.00, cell area 49449.82.
```

```text
Date: 2026-05-07
Command: fm_shell -work_path 5_FM_N2N/FM_WORK -file 5_FM_N2N/0_Script/run_fm_n2n_topo.tcl -overwrite
Stage: Formality N2N topo
Result: PASS
Notes: Verified DC Graphical pre-DFT topo netlist against DC/DFT Compiler post-DFT topo netlist using post-DFT SVF. Functional constants were applied to scan_cg_en_i, scan_en, and scan_in. Final result: Verification SUCCEEDED, 2243 passing compare points, 0 failing compare points. Reports are under 5_FM_N2N/4_Report/.
```

```text
Date: 2026-05-07
Command: pt_shell -f 6_STA/0_Script/run_pt_post_dft_10ns_sdf.tcl
Stage: PrimeTime post-DFT SDF STA
Result: PASS_WITH_NOTE
Notes: PT linked the post-DFT topo netlist, read functional 10 ns SDC, and annotated post-DFT SDF with 0 read_sdf errors. Annotated arcs: 106265 cell delay arcs, 47481 net delay arcs, 13076 timing checks, 6390 constraints. No setup or hold violations. Worst setup slack is 1.48 ns; worst hold slack is 0.03 ns. Max_cap/max_transition cleanup remains deferred to physical/backend work.
```

```text
Date: 2026-05-07
Command: tmax -shell 4_ATPG/0_Script/run_tmax_stuck_at_topo.tcl
Stage: TetraMAX stuck-at ATPG
Result: PASS_WITH_NOTE
Notes: TetraMAX read RVT/LVT/HVT SAED32 test models, post-DFT topo netlist, and post-DFT SPF. chain0 was traced successfully with 2130 scan cells. DRC succeeded with 6 Z3 wire-contention warnings downgraded to warning for first-pass ATPG. Stuck-at ATPG reached 98.64% test coverage and 98.55% fault coverage with 448 basic_scan patterns. Pattern output: 4_ATPG/2_Output/patterns/cv32e40p_synth_wrap.stuck_at.serial.stil.
```

```text
Date: 2026-05-07
Command: documentation update only
Stage: Baseline freeze and Fmax estimate
Result: RECORDED
Notes: Froze tt_mvt_10ns_scan1 as the first complete Front-End baseline at commit 5473b61. Fmax estimate uses post-DFT topo/SDF worst setup slack: 10.00 ns - 1.48 ns = 8.52 ns critical delay, ideal Fmax about 117.4 MHz. Next trial candidate is 8.5 ns first, then 8.0 ns if clean enough.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/01_init_design/run_init_design_check.tcl
Stage: ICC2 init_design with TLU+
Result: PASS_WITH_NOTE
Notes: Rebuilt cv32e40p_icc2_lib from post-DFT topo netlist. Added TLU+ parasitic models saed32_cmin/saed32_cmax and set default corner early/late parasitic parameters. Evidence: 7_Backend_ICC2/4_Report/01_init_design/parasitic_parameters.rpt. check_design remains 0 errors, 14004 warnings.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.tcl
Stage: ICC2 floorplan refresh
Result: PASS_WITH_NOTE
Notes: Recreated rectangular floorplan after TLU+ setup. Core utilization remains 65.40%, 382 pins created. Evidence: 7_Backend_ICC2/4_Report/02_floorplan/utilization.rpt and 7_Backend_ICC2/3_Log/02_floorplan/floorplan_initial.log.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/04_place/run_place_initial.tcl
Stage: ICC2 initial placement
Result: PASS_WITH_NOTE
Notes: Placement required set_app_options place.coarse.continue_on_missing_scandef true because no ICC2 scan DEF exists in DFT handoff. TLU+ setup fixed the earlier RC/parasitic abort. create_placement and legalize_placement completed; 14083 cells legalized with 0 placement legality violations. Worst reported placement timing slack is 0.76 ns. Evidence: 7_Backend_ICC2/4_Report/04_place/check_legality.rpt and timing.rpt.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/03_power/run_power_initial.tcl
Stage: ICC2 post-placement power rebuild
Result: PASS_WITH_OPEN
Notes: Rebuilt VDD/VSS PG after placement using M1 stdcell rails, M2/M7/M8 mesh, M7/M8 core ring, and generated 16 design-boundary PG pins. PG DRC is clean. VSS connectivity is clean. VDD still has 3 floating wires and 499 floating std cells, so PG connectivity is not closed. A denser M2 20um trial reduced floating risk but caused 1225 M1 spacing errors, so it was rejected and M2 pitch restored to 40um. Evidence: 7_Backend_ICC2/4_Report/03_power/pg_connectivity.rpt, pg_drc.rpt, and 7_Backend_ICC2/3_Log/03_power/power_initial.log.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/03_power/run_power_initial.tcl
Stage: ICC2 VDD PG bridge trial
Result: REJECTED_THEN_RESTORED
Notes: Queried the three remaining floating VDD M1 rail shapes: PATH_11_12 at y=40.034, PATH_11_36 at y=80.162, and PATH_11_60 at y=120.290. Tried adding a narrow VDD-only M2 bridge mesh, but check_pg_drc reported 146 M1 insufficient-spacing errors. Removed the bridge and reran power script to restore the DRC-clean baseline. Fresh restored evidence: pg_drc reports no errors; pg_connectivity still reports VDD 3 floating wires / 499 floating std cells and VSS 0 floating std cells.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/03_power/run_power_initial.tcl
Stage: ICC2 PG connectivity closure
Result: PASS
Notes: Root cause was M7 horizontal mesh alignment with some stdcell M1 rails, which prevented clean M1-M2 via creation at those rail/mesh crossings. Rejected targeted create_pg_vias repair because normal DRC blocked the vias and -drc no_check created 42 PG DRC errors. Rejected M7 offset 22um/25um because VSS remained floating. Chose M7 horizontal mesh offset 28um. Final power reports show VDD floating wires/vias/std cells = 0/0/0 and VSS floating wires/vias/std cells = 0/0/0. PG DRC reports no errors. Evidence: 7_Backend_ICC2/4_Report/03_power/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/03_power/pg_drc.rpt, and 7_Backend_ICC2/3_Log/03_power/power_initial.log.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/04_place/run_place_initial.tcl
Stage: ICC2 placement refresh after PG closure
Result: PASS_WITH_NOTE
Notes: Re-ran placement/legalization after PG mesh offset update. legalize_placement succeeded and check_legality reports TOTAL 0 violations. Placement-stage PG connectivity remains closed: VDD floating wires/vias/std cells = 0/0/0 and VSS floating wires/vias/std cells = 0/0/0. Placement-stage PG DRC reports no errors. Worst listed placement timing slack is 0.57 ns. Missing scan DEF is still bypassed with place.coarse.continue_on_missing_scandef true, so scan-aware placement remains a later cleanup item. Evidence: 7_Backend_ICC2/4_Report/04_place/check_legality.rpt, pg_connectivity.rpt, pg_drc.rpt, timing.rpt, and 7_Backend_ICC2/3_Log/04_place/place_initial.log.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/05_cts/run_cts_initial.tcl
Stage: ICC2 CTS script syntax trial
Result: FAIL_THEN_FIXED
Notes: First CTS attempt stopped at set_clock_routing_rules because the command required -rules or -default_rule. Fixed the learning script by adding -default_rule while keeping the explicit M4-M6 clock routing layer limit.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/05_cts/run_cts_initial.tcl | tee 7_Backend_ICC2/3_Log/05_cts/cts_initial.log
Stage: ICC2 first-pass CTS
Result: PASS_WITH_OPEN
Notes: clock_opt completed through route_clock, clock tree compilation finished successfully, and clock route finished with 0 DRC violations/open nets. Clock QoR reports clk_i has 2130 sinks, 6 levels, 11 repeaters, max latency 0.37 ns, global skew 0.33 ns, 0 transition DRC, and 0 capacitance DRC. Listed setup/hold timing paths are MET: worst setup slack 1.98 ns and worst hold slack 0.02 ns. check_legality reports TOTAL 0 violations. PG DRC reports no errors. PG connectivity has VDD floating wires/vias/std cells/terminals = 0/0/0/0 and VSS floating wires/vias/std cells = 0/0/0, but VSS floating terminals = 2 after CTS. report_qor still shows whole-design electrical DRC open: 1 max transition violation and 172 max capacitance violations. Open items: no default max_transition constraint warning, scan DEF still bypassed from placement, whole-design electrical DRC, and VSS boundary terminal count. Evidence: 7_Backend_ICC2/3_Log/05_cts/cts_initial.log and 7_Backend_ICC2/4_Report/05_cts/{clock_qor.summary.rpt,clock_qor.drc_violators.rpt,clock_timing.summary.rpt,timing.max.rpt,timing.min.rpt,qor.rpt,check_legality.rpt,pg_connectivity.rpt,pg_drc.rpt}.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/06_route/run_route_initial.tcl | tee 7_Backend_ICC2/3_Log/06_route/route_initial.log
Stage: ICC2 first-pass signal route
Result: PASS_WITH_OPEN
Notes: route_auto ran to completion and saved the block. Detail route did not converge cleanly: route_auto ended with 407 DRCs and check_routes reports 408 DRCs. Open nets are 0. check_routes DRC classes are diff-net spacing 131, less-than-min-area 8, needs-fat-contact 106, and off-grid 163. Timing listed paths are still MET: worst listed setup slack 2.00 ns and worst listed hold slack 0.02 ns. Placement legality remains TOTAL 0 violations. PG connectivity improved versus CTS: VDD/VSS floating wires/vias/std cells/terminals are all 0, and PG DRC reports no errors. Open items: route DRC cleanup, explicit route layer setup, check_routability pre-check, and unplaced/no-pin top VDD/VSS port warnings. Evidence: 7_Backend_ICC2/3_Log/06_route/route_initial.log and 7_Backend_ICC2/4_Report/06_route/{check_routes.rpt,qor.rpt,timing.max.rpt,timing.min.rpt,check_legality.rpt,pg_connectivity.rpt,pg_drc.rpt}.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/06_route/run_route_drc_diagnose.tcl | tee 7_Backend_ICC2/3_Log/06_route/route_drc_diagnose.log
Stage: ICC2 route DRC diagnosis
Result: RECORDED
Notes: Fresh check_routability confirms no PG net open, no standard-cell overlap, no min-grid violations, no blocked ports, and no blocked nets. It reports 2 unplaced top PG ports, 3 off-track M1 pins, and one long VSS PG shape with shape_use detail_route. Fresh check_routes reproduces 408 DRCs and 0 open nets. Fresh utilization remains 77.17%. This supports a combined root cause: routing congestion plus PG/top-port cleanup plus tech/via/contact/grid setup, not connectivity failure.
Evidence: 7_Backend_ICC2/4_Report/06_route/check_routability.post_route.rpt, check_routes.fresh.rpt, utilization.fresh.rpt, qor.fresh.rpt, and 7_Backend_ICC2/3_Log/06_route/route_drc_diagnose.log.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl | tee 7_Backend_ICC2/3_Log/trials/60util/trial_60util_to_route.log
Stage: ICC2 route DRC 60% utilization trial
Result: PASS_WITH_OPEN
Notes: Rebuilt ICC2 lib from post-DFT netlist and reran init, 60% floorplan, PG, placement, CTS, and route in one trial script. The current generated ICC2 lib now reflects this 60% trial state; rerun main 01-06 scripts to recreate the 65% baseline state. Floorplan utilization report is 0.6027; route-stage utilization is 0.7324. Signal route still does not converge: route_auto log ends with 406 DRCs and check_routes reports 407 DRCs. Open nets are 0. check_routes DRC classes are diff-net spacing 102, less-than-min-area 8, needs-fat-contact 128, off-grid 166, same-net spacing 1, and short 2. Timing listed paths are MET: worst setup slack 2.10 ns and worst hold slack 0.02 ns. Legality remains TOTAL 0 and PG connectivity/DRC are clean. Compared to baseline 65% route check_routes 408 DRCs, this trial changes almost nothing, so lower utilization alone is not the route DRC root cause.
Evidence: 7_Backend_ICC2/3_Log/trials/60util/trial_60util_to_route.log and 7_Backend_ICC2/4_Report/trials/60util/06_route/{check_routes.rpt,utilization.rpt,timing.max.rpt,timing.min.rpt,check_legality.rpt,pg_connectivity.rpt,pg_drc.rpt}.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=60util_m8 SIGNAL_MIN_ROUTING_LAYER=M1 SIGNAL_MAX_ROUTING_LAYER=M8 icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl | tee 7_Backend_ICC2/3_Log/trials/60util_m8/trial_60util_m8_route.log
Stage: ICC2 60% utilization + M8 route-layer trial
Result: PASS_WITH_OPEN
Notes: Trial rebuilt the ICC2 lib, reran init/floorplan/PG/place/CTS/route, and applied signal route layer bounds M1-M8. The current generated ICC2 lib now reflects this 60util_m8 trial state; rerun main 01-06 scripts to recreate the 65% baseline state. route_auto completed with 399 DRCs; check_routes reports 400 DRCs and 0 open nets. DRC classes are diff-net spacing 122, less-than-min-area 7, needs-fat-contact 108, off-grid 160, and short 3. Worst listed setup slack is 2.11 ns MET; worst listed hold slack is 0.02 ns MET. Legality is 0 violations. PG connectivity and PG DRC are clean. M8 bound slightly improves 60% trial DRC from 407 to 400, but route convergence is still open.
Evidence: 7_Backend_ICC2/3_Log/trials/60util_m8/trial_60util_m8_route.log and 7_Backend_ICC2/4_Report/trials/60util_m8/06_route/{check_routes,check_routability,ignored_layers,utilization,timing.max,timing.min,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/06_route/run_route_drc_detail.tcl | tee 7_Backend_ICC2/3_Log/06_route/route_drc_detail.log
Stage: ICC2 route DRC detail diagnosis
Result: PASS_WITH_OPEN
Notes: Opened current generated ICC2 block, which is the 60util_m8 trial state. check_routes regenerated zroute.err marker data. report_drc_error matrix/by-layer/by-type/detailed reports were written. Matrix shows all 400 remaining DRCs are lower-metal/access issues: M1 125, M1-M2 108, M2 88, VIA1 79. Type split is diff-net spacing 122, less-than-min-area 7, needs-fat-contact 108, off-grid 160, short 3. Hotspot report was also created from detailed Bbox coordinates using 50um buckets.
Evidence: 7_Backend_ICC2/3_Log/06_route/route_drc_detail.log and 7_Backend_ICC2/4_Report/06_route/drc_detail/{check_routes.detail_source,drc.matrix,drc.by_layer,drc.by_type,drc.detailed,drc.hotspot_50um,zroute.err}.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_detail_route_repair.tcl | tee 7_Backend_ICC2/3_Log/trials/detail_repair_200iter/detail_route_repair.log
Stage: ICC2 incremental detail route repair trial, 200 max iterations
Result: PASS_WITH_OPEN
Notes: Started from the 60util_m8 routed state. route_detail ran incrementally and stopped without DRC convergence. check_routes improved only from 400 to 398 DRCs, with 0 open nets. After matrix shows diff-net spacing 94, less-than-min-area 6, needs-fat-contact 137, off-grid 160, short 1. Timing listed paths remain MET: setup slack 2.11 ns and hold slack 0.02 ns. Legality remains 0 and PG connectivity/DRC remain clean. Conclusion: long blind detail-route looping is not enough for route closure.
Evidence: 7_Backend_ICC2/3_Log/trials/detail_repair_200iter/detail_route_repair.log and 7_Backend_ICC2/4_Report/trials/detail_repair_200iter/06_route/{check_routes.before,check_routes.after,drc.before.matrix,drc.after.matrix,timing.max.after,timing.min.after,check_legality.after,pg_connectivity.after,pg_drc.after}.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=60util_m8_restore SIGNAL_MIN_ROUTING_LAYER=M1 SIGNAL_MAX_ROUTING_LAYER=M8 icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl | tee 7_Backend_ICC2/3_Log/trials/60util_m8_restore/trial_60util_m8_restore.log
Stage: ICC2 60% utilization + M8 route-layer restore
Result: PASS_WITH_OPEN
Notes: Rebuilt the generated ICC2 lib back to a clean 60util_m8-equivalent routed state before the 1-iteration repair comparison. check_routes reports 400 DRCs and 0 open nets. Legality remains 0 and PG connectivity/DRC remain clean. Timing listed paths remain MET.
Evidence: 7_Backend_ICC2/3_Log/trials/60util_m8_restore/trial_60util_m8_restore.log and 7_Backend_ICC2/4_Report/trials/60util_m8_restore/06_route/{check_routes,timing.max,timing.min,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=detail_repair_1iter DETAIL_ROUTE_ITERATIONS=1 icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_detail_route_repair.tcl | tee 7_Backend_ICC2/3_Log/trials/detail_repair_1iter/detail_route_repair_1iter.log
Stage: ICC2 incremental detail route repair trial, 1 max iteration
Result: PASS_WITH_OPEN
Notes: Started from the restored 60util_m8 routed state. Before DRC was 400. After one detail-route iteration, check_routes reports 383 DRCs and 0 open nets. DRC type split becomes diff-net spacing 224, off-grid 155, and short 4; needs-fat-contact and min-area markers disappear, but M1 diff-net spacing grows. Timing listed paths remain MET: setup slack 2.11 ns and hold slack 0.02 ns. Legality remains 0 and PG connectivity/DRC remain clean. Conclusion: this is the best count so far, but not route closure and not a root-cause fix.
Evidence: 7_Backend_ICC2/3_Log/trials/detail_repair_1iter/detail_route_repair_1iter.log and 7_Backend_ICC2/4_Report/trials/detail_repair_1iter/06_route/{check_routes.before,check_routes.after,drc.before.matrix,drc.after.matrix,timing.max.after,timing.min.after,check_legality.after,pg_connectivity.after,pg_drc.after}.rpt.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_pg_port_diagnose.tcl | tee 7_Backend_ICC2/3_Log/trials/pg_port_diagnose/pg_port_diagnose.log
Stage: ICC2 PG top port diagnosis
Result: RECORDED
Notes: VDD/VSS ports exist but have 0 terminals. compile_pg-generated VDD_1/VSS_1 ports are placed and have 8 terminals each. This explains route-time VDD/VSS no-pin/unplaced warnings.
Evidence: 7_Backend_ICC2/4_Report/trials/pg_port_diagnose/99_pg_port/{pg_port_summary,report_ports.vdd_vss,pg_connectivity}.rpt.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_pg_port_cleanup_trial.tcl | tee 7_Backend_ICC2/3_Log/trials/pg_port_cleanup/pg_port_cleanup.log
Stage: ICC2 PG stale port removal trial
Result: REJECTED
Notes: Removing terminal-less VDD/VSS ports kept PG connectivity/DRC clean and check_routes stayed at 383 on the current routed block, but the VDD/VSS ports reappeared after later save/reopen flow. Not robust enough for the main script.
Evidence: 7_Backend_ICC2/4_Report/trials/pg_port_cleanup/99_pg_port/{cleanup_summary,pg_connectivity.after,pg_drc.after,check_routes.after_cleanup}.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=60util_m8_pgport_cleanup SIGNAL_MIN_ROUTING_LAYER=M1 SIGNAL_MAX_ROUTING_LAYER=M8 icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl | tee 7_Backend_ICC2/3_Log/trials/60util_m8_pgport_cleanup/trial_60util_m8_pgport_cleanup.log
Stage: ICC2 60% + M8 + stale port removal full-route trial
Result: PASS_WITH_OPEN_REJECTED_FIX
Notes: Full route still reports check_routes 400 DRCs and 0 open nets. Timing listed paths remain MET: setup slack 2.11 ns and hold slack 0.02 ns. Legality and PG remain clean. However check_routability still reports VDD/VSS no-pin/unplaced warnings, proving stale port removal is not persistent enough.
Evidence: 7_Backend_ICC2/3_Log/trials/60util_m8_pgport_cleanup/trial_60util_m8_pgport_cleanup.log and 7_Backend_ICC2/4_Report/trials/60util_m8_pgport_cleanup/06_route/{check_routes,check_routability,timing.max,timing.min,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=pg_terminal_attach_offset icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_pg_terminal_attach_trial.tcl | tee 7_Backend_ICC2/3_Log/trials/pg_terminal_attach_offset/pg_terminal_attach_offset.log
Stage: ICC2 PG top terminal attach trial
Result: PASS_WITH_OPEN
Notes: Added one non-overlapping M8 terminal to each VDD and VSS port at y=3..5um on the existing PG ring. VDD/VSS terminal_count becomes 1, while VDD_1/VSS_1 remain at 8 terminals. check_routability no longer reports VDD/VSS no-pin/unplaced warnings and does not report duplicate pin-shape warnings. PG connectivity/DRC remain clean. check_routes remains 400 DRCs and 0 open nets, so this is warning cleanup, not route DRC closure.
Evidence: 7_Backend_ICC2/3_Log/trials/pg_terminal_attach_offset/pg_terminal_attach_offset.log and 7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/{terminal_attach_summary,check_routability.after,check_routes.after,pg_connectivity.after,pg_drc.after}.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=pg_port_diagnose_after_offset icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_pg_port_diagnose.tcl | tee 7_Backend_ICC2/3_Log/trials/pg_port_diagnose/pg_port_diagnose_after_offset.log
Stage: ICC2 PG top terminal save/reopen check
Result: PASS
Notes: Reopened the saved ICC2 block after offset terminal attach. VDD terminal_count is 1 and VSS terminal_count is 1, so the accepted fix persists across save/reopen.
Evidence: 7_Backend_ICC2/4_Report/trials/pg_port_diagnose_after_offset/99_pg_port/pg_port_summary.rpt.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_offtrack_pin_diagnose.tcl | tee 7_Backend_ICC2/3_Log/trials/offtrack_pin_diagnose/offtrack_pin_diagnose.log
Stage: ICC2 off-track M1 pin diagnosis
Result: FAIL_THEN_FIXED
First fatal error: Cannot specify '-intersect' with '-physical_context'. (CMD-001)
Log path: 7_Backend_ICC2/3_Log/trials/offtrack_pin_diagnose/offtrack_pin_diagnose.log
Suspected root cause: script used an invalid get_pins option combination for region search.
Next action taken: replaced get_pins -physical_context -intersect with hierarchical region pin query and reran.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_offtrack_pin_diagnose.tcl | tee 7_Backend_ICC2/3_Log/trials/offtrack_pin_diagnose/offtrack_pin_diagnose.log
Stage: ICC2 off-track M1 pin diagnosis
Result: RECORDED
Notes: check_routability still reports 8 M1 off-track pin warnings, but the object names are now identified. The warnings map to real stdcell pins, mainly SDFFARX1_RVT/QN plus INVX8_LVT/A and MUX41X1_HVT/S1. check_routability confirms No PG net open, no standard-cell overlap, no min-grid violation, no blocked ports, and no blocked nets. Verbose mode also names the 6 non-physical clock-gate ENL internal ports. Current conclusion: this is not a top-level PG port issue; next root-cause work should focus on SAED32 stdcell pin access versus ICC2 M1 routing track/contact setup and ZRT-022 default CO contact warning.
Evidence: docs/backend/offtrack_pin_diagnosis.md, 7_Backend_ICC2/4_Report/trials/offtrack_pin_diagnose/99_route_access/check_routability.verbose.rpt, 7_Backend_ICC2/4_Report/trials/offtrack_pin_diagnose/99_route_access/offtrack_pin_objects.rpt, and 7_Backend_ICC2/3_Log/trials/offtrack_pin_diagnose/offtrack_pin_diagnose.log.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_contact_code_diagnose.tcl | tee 7_Backend_ICC2/3_Log/trials/contact_code_diagnose/contact_code_diagnose.log
Stage: ICC2 CO/VIA contact code diagnosis
Result: RECORDED
Notes: ZRT-022 is reproduced. ICC2 sees CO layer number 28, mask polyCont, width 0.042um, but no CO via_def/default contact exists in the current library tech. VIA1 does have six M1-M2 via_defs and one signal-usable default, VIA12SQ_C. Therefore ZRT-022 is a real CO default-contact warning from stdcell pin CO geometry, but it is not evidence that M1-M2 VIA1 routing setup is missing. M1/M2 tracks start at 0.088um with 0.152um pitch, matching the SAED32 unit site width, while several off-track pin coordinates are 0.02-0.055um away from the nearest track. Current best root-cause candidate remains stdcell M1 pin access versus track/via legality, not PG connectivity.
Evidence: docs/backend/contact_code_diagnosis.md, 7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/{contact_code_summary,check_routability.contact,via_defs.cv32e40p_icc2_lib,tracks.m1,tracks.m2}.rpt, and 7_Backend_ICC2/3_Log/trials/contact_code_diagnose/contact_code_diagnose.log.
```
