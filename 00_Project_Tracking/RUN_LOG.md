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
