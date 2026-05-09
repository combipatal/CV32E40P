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
Command: icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pin_access_blocked_detail/pin_access_blocked_detail.log -f 7_Backend_ICC2/0_Script/99_util/run_pin_access_blocked_detail.tcl
Stage: ICC2 blocked pin access detail
Result: RECORDED
Notes: report_cell_pin_access -details ran on 2244 same-ref cells for SDFFARX1_RVT, INVX8_LVT, and MUX41X1_HVT. ICC2 summary reports 117 pins with blocked access. Parsed detail report has 125 line-level blocked entries: 116 SDFFARX1_RVT, 9 MUX41X1_HVT, and 0 INVX8_LVT. Main pins are RSTB 39, SE 23, Q 21, and CLK 20. Evidence: 7_Backend_ICC2/4_Report/trials/pin_access_blocked_detail/99_pin_access/{report_cell_pin_access.same_refs.details.rpt,blocked_access.compact_summary.rpt,blocked_access.by_ref_cell_pin.rpt}.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/create_pin_check_lib_trial/create_pin_check_lib_trial.log -f 7_Backend_ICC2/0_Script/99_util/run_create_pin_check_lib_trial.tcl
Stage: ICC2 create_pin_check_lib trial
Result: PASS_WITH_OPEN
Notes: create_pin_check_lib succeeded for RVT+LVT+HVT together and for each VT separately. check_libcell_pin_access -mode analyze_lib_cell succeeds after setting pin_check.place.preplace_option_file. Mixed-VT analyze_lib_cell reports 27 skipped cells and 855 cells meeting threshold; each VT reports 9 skipped and 285 meeting threshold. analyze_lib_pin still fails with LIB-001 current library context, so it remains open. Evidence: 7_Backend_ICC2/4_Report/trials/create_pin_check_lib_trial/99_pin_check_lib/{create_pin_check_lib_status.rpt,check_libcell_pin_access.all.analyze_lib_cell.rpt,check_libcell_pin_access.*.analyze_lib_pin.rpt}.
```

```text
Date: 2026-05-08
Command: python3 scripts/analyze_pin_access_drc_overlap.py
Stage: ICC2 pin access / route DRC overlap
Result: RECORDED
Notes: Parsed 305 blocked access points and 400 route DRC markers. Nearest DRC distance counts: 13 within 2um, 23 within 5um, 51 within 10um, 193 within 25um, and 289 within 50um. There are 21 shared 50um hotspot buckets. Evidence: 7_Backend_ICC2/4_Report/trials/pin_access_drc_overlap/99_overlap/{overlap_summary.rpt,hotspot_overlap_50um.rpt,nearest_drc_per_blocked_point.tsv}.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=hotspot_blk40_scan_def_m8 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def HOTSPOT_BLOCKAGE_ENABLE=true HOTSPOT_BLOCKAGE_PERCENT=40 HOTSPOT_BLOCKAGE_BOUNDARY="{{215.0 195.0} {265.0 265.0}}" icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/hotspot_blk40_scan_def_m8/hotspot_blk40_scan_def_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 hotspot partial blockage probe
Result: PASS_WITH_OPEN
Notes: Added one 40% partial placement blockage over hotspot {{215 195} {265 265}}. route_auto completed with open nets 0, legality 0 violations, PG connectivity floating counts 0, PG DRC no errors, and check_routes DRC 390. Compared with scan_def_m8_restore DRC 398, this is only 8 DRC improvement, so hotspot cell density alone is not the root cause. Evidence: 7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/04_place/hotspot_blockage.rpt and 7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/{check_routes.rpt,check_legality.rpt,pg_connectivity.rpt,pg_drc.rpt,drc_detail/drc.matrix.rpt}.
```

```text
Date: 2026-05-08
Command: root-cause investigation documentation update
Stage: ICC2 route DRC root-cause investigation
Result: RECORDED
Notes: Shifted active goal from immediate DRC reduction to root-cause identification. Hotspot {{215 195} {265 265}} contains 123 DRC markers; 94 are M2/VIA1 off-grid. Representative markers show NOR2X0_HVT/OR2X1_HVT stdcell pin access, paired M2/VIA1 off-grid markers, and some VDD/VSS M2 PG shape overlap. Leading hypotheses are stdcell pin access + M2/VIA1 off-grid interaction, possible M2 PG mesh interference, LEF-built NDM/pin-check quality, and route off-grid/via policy. Evidence: docs/backend/route_drc_root_cause_investigation.md and 7_Backend_ICC2/4_Report/trials/root_cause_probe/99_manual/{route_common_app_options.rpt,route_detail_app_options.rpt}.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/root_cause_probe/hotspot_pg_shape_probe.log -f 7_Backend_ICC2/0_Script/99_util/run_hotspot_pg_shape_probe.tcl; python3 scripts/analyze_hotspot_pg_distance.py
Stage: ICC2 hotspot DRC-to-PG distance probe
Result: RECORDED
Notes: Hotspot {{215 195} {265 265}} contains three M2 PG stripes at x=219.8..220.2, 239.8..240.2, and 259.8..260.2. Of 123 hotspot DRC markers, 23 are within 1um of an M2 PG shape, 78 are within 5um, and 45 are farther than 5um. PG is a real contributing axis but does not explain all hotspot markers alone. Evidence: 7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance/{hotspot_pg_shapes.tsv,hotspot_drc_pg_distance_summary.rpt,hotspot_drc_pg_distance.tsv}.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=pgm2off30_scan_def_m8 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_MESH_OFFSET=30.0 icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pgm2off30_scan_def_m8/pgm2off30_scan_def_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 PG M2 offset root-cause probe
Result: INVALID_FOR_CLOSURE_BUT_INFORMATIVE
Notes: Moving only the M2 PG mesh offset from 20um to 30um changed signal route DRC from 398 to 377 and reduced diff-net spacing 120 -> 82, but introduced PG DRC: 60 M1 insufficient-spacing errors after placement and 97 after route. Open nets stayed 0 and legality stayed 0. This proves PG M2 position affects route DRC, but the 30um offset is not a valid fix. Evidence: 7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/03_power/pg_mesh_trial_settings.rpt, 06_route/check_routes.rpt, 06_route/drc_detail/drc.matrix.rpt, 04_place/pg_drc.rpt, and 06_route/pg_drc.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=pin_access_spread CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 PLACE_PIN_DENSITY_AWARE=true PLACE_MAX_DENSITY=0.70 PLACE_TARGET_ROUTING_DENSITY=0.70 PLACE_INCREASED_CELL_EXPANSION=true icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pin_access_spread/pin_access_spread.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 placement spreading route trial
Result: REJECTED
Notes: Pin-density/max-density spreading trial completed with open nets 0, legality 0 violations, and PG clean, but check_routes reports 390 DRCs. This is only slightly better than 60util_m8 400 DRC and worse than the detail-route 1iter evidence at 383. Post-trial report_cell_pin_access worsened official blocked pins from 117 to 144, with line-level entries 150: SDFFARX1_RVT 126, MUX41X1_HVT 22, INVX8_LVT 2. Evidence: docs/backend/pin_access_drc_overlap_and_spread_trial.md and 7_Backend_ICC2/4_Report/trials/pin_access_spread*/.
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

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_mw_ref_open_trial.tcl | tee 7_Backend_ICC2/3_Log/trials/mw_ref_open_trial/mw_ref_open_trial.log
Stage: ICC2 Milkyway reference open trial
Result: BLOCKED
Notes: Tested whether original SAED32 Milkyway reference libraries can be used directly through create_lib -ref_libs. First failure required lib.configuration.icc_shell_exec or lib.setting.milkyway_exec. No IC Compiler 1 icc_shell exists in this install. Milkyway executable exists, and a wrapper translated -f/-output_log_file into Milkyway -file/-log. That removed the CLI argument failure, but Milkyway export still failed because Milkyway and MDataPrep license features are unavailable and no export tar.gz was created. Import then failed with FILE-002 and LM-010. Conclusion: direct Milkyway-reference ICC2 backend comparison is blocked by environment/tool/license. Continue with DB+LEF-built NDM and debug pin-access/track options there.
Evidence: docs/backend/mw_ref_open_trial.md, 7_Backend_ICC2/3_Log/trials/mw_ref_open_trial/mw_ref_open_trial.log, 7_Backend_ICC2/3_Log/trials/mw_ref_open_trial/icc_milkyway_exec_wrapper.args.log, and 7_Backend_ICC2/2_Output/trials/mw_ref_open_trial/local_cell_libs/log/*_{export_icc2_frame,import_icc_fram}.log.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pin_access_track_probe/pin_access_track_probe.log -f 7_Backend_ICC2/0_Script/99_util/run_pin_access_track_probe.tcl
Stage: ICC2 pin access / M1 track offset probe
Result: RECORDED
Notes: check_libcell_pin_access is not directly usable on the current design library and reports PAC-001 because the library was not created by create_pin_check_lib. report_cell_pin_access works: the 8 flagged cells have 46 pins with no access violations and 0 blocked access pins, while the same three ref cell types across the design show 15316 pins with no access violations and 117 blocked access pins. M1 track offset probe on an already routed block shows baseline has 8 ZRT-761 off-track warnings, M1 start 0.000 is worse, and M1 starts 0.012/0.050/0.076/0.088/0.126 remove visible ZRT-761 lines. This is only a probe, not a route fix.
Evidence: docs/backend/pin_access_track_probe.md, 7_Backend_ICC2/3_Log/trials/pin_access_track_probe/pin_access_track_probe.log, and 7_Backend_ICC2/4_Report/trials/pin_access_track_probe/99_pin_access_track/{pin_access_command_status,report_cell_pin_access.flagged_cells,report_cell_pin_access.same_refs,check_routability.*}.rpt.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/m1_retrack_route_088/m1_retrack_route_088.log -f 7_Backend_ICC2/0_Script/99_util/run_m1_retrack_route_trial.tcl
Stage: ICC2 M1 retrack full-route trial
Result: REJECTED
Notes: Started from the 400-DRC routed block. The trial copied the block, removed signal routes, recreated M1 tracks at start 0.088 with 0.152 pitch, and reran route_auto. Before route, check_routability still reported the same 8 ZRT-761 off-track M1 pin warnings. route_auto finished with 0 open nets but DRC exploded to 27260, dominated by 24981 illegal-track-route markers and 1104 off-grid markers. This rejects manual M1 track recreation as a route cleanup strategy. route_auto ended with a post-command internal hook error before follow-up reports; the script was updated to catch route_auto in future runs.
Evidence: docs/backend/pin_access_track_probe.md, 7_Backend_ICC2/3_Log/trials/m1_retrack_route_088/m1_retrack_route_088.log, and 7_Backend_ICC2/4_Report/trials/m1_retrack_route_088/06_route/{check_routes.before_remove,check_routability.after_recreate,tracks.m1.after_recreate}.rpt.
```

```text
Date: 2026-05-08
Command: dc_shell -topographical_mode -f 3_DFT/0_Script/run_write_scan_def_from_post_dft.tcl
Stage: DFT scan DEF handoff recovery
Result: PASS
Notes: Read existing post-DFT topo DDC and wrote ICC2 scan DEF without rerunning insert_dft. The scan report shows chain0 length 2130, scan_in -> scan_out, scan_en, and clk_i. This file is backend handoff evidence; SPF remains ATPG protocol evidence.
Evidence: 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def and 3_DFT/4_Report/topo/scan_path.existing.scan_def_source.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=scan_def_m8 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/scan_def_m8/scan_def_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 scan DEF + M8 route trial
Result: PASS_WITH_OPEN
Notes: ICC2 read DEF SCANCHAINS and optimize_dft validated 1 scan chain. DFT wirelength improved from 54278 to 14900 in the first scan optimization pass. Final route has 0 open nets, legality 0, PG clean, and 398 route DRCs. This slightly improves 60util_m8 400 DRC, but does not close route.
Evidence: 7_Backend_ICC2/3_Log/trials/scan_def_m8/scan_def_m8.log and 7_Backend_ICC2/4_Report/trials/scan_def_m8/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=scan_def_advleg_color_m8 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PLACE_ADVANCED_LEGALIZER=true PLACE_MULTI_CELL_PIN_ACCESS_CHECK=true PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS=true PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS=true PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING=true PLACE_SUPPORT_OFF_TRACK_VIA_REGION=true PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK=true icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/scan_def_advleg_color_m8/scan_def_advleg_color_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 scan DEF + advanced legalizer + pin color trial
Result: PASS_WITH_OPEN_REJECTED_FIX
Notes: pin_color_align legality rule was enabled and route-stage legality reports 0 violations. PG connectivity and PG DRC are clean. Final route has 0 open nets but 605 route DRCs, identical to the advanced-legalizer trial without pin color alignment and worse than scan_def_m8 398. Rejected as route-closure setting. Note: the 3_Log output path directory was not pre-created, so the main ICC2 transcript was not captured; official reports under 4_Report are the evidence for this run.
Evidence: docs/backend/scan_def_and_advanced_legalizer_trials.md, 7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/04_place/place_legalize_app_options.rpt, and 7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=scan_def_advleg_color_m8_blocked_detail icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/scan_def_advleg_color_m8_blocked_detail/scan_def_advleg_color_m8_blocked_detail.log -f 7_Backend_ICC2/0_Script/99_util/run_pin_access_blocked_detail.tcl; python3 scripts/summarize_cell_pin_access.py ...
Stage: ICC2 blocked access detail after pin color trial
Result: RECORDED
Notes: Parser found 254 line-level blocked access point entries, concentrated in SDFFARX1_RVT 233, MUX41X1_HVT 16, and INVX8_LVT 5. ICC2 official final summary for this routed context says Pins with blocked access 0, so the parsed count must be treated as blocked access points, not official blocked pins.
Evidence: 7_Backend_ICC2/3_Log/trials/scan_def_advleg_color_m8_blocked_detail/scan_def_advleg_color_m8_blocked_detail.log and 7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8_blocked_detail/99_pin_access/{report_cell_pin_access.same_refs.details,blocked_access.compact_summary}.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=scan_def_m8_restore CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/scan_def_m8_restore/scan_def_m8_restore.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 scan DEF + M8 routed block restore
Result: PASS_WITH_OPEN
Notes: Rebuilt current saved ICC2 block away from the rejected advanced-legalizer state and back to the simpler scan DEF + M8 route state. route_auto ended with 0 open nets and 397 DRCs; fresh detail extraction reports 398 DRCs. This is the intended diagnosis baseline.
Evidence: 7_Backend_ICC2/3_Log/trials/scan_def_m8_restore/scan_def_m8_restore.log and 7_Backend_ICC2/4_Report/trials/scan_def_m8_restore/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=route_offgrid_tracks_scan_def_m8 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_offgrid_tracks_scan_def_m8/route_offgrid_tracks_scan_def_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route off-grid pin-track probe
Result: PASS_WITH_OPEN
Notes: route.detail.generate_extra_off_grid_pin_tracks=true was applied. Final route has 0 open nets, PG DRC clean, and 385 route DRCs. Detail matrix: M1 diff spacing 130, M1-M2 needs-fat-contact 84, M2 off-grid 73, VIA1 off-grid 82. This improves baseline 398 only slightly, so extra off-grid pin tracks are a contributing axis, not the sole root cause.
Evidence: 7_Backend_ICC2/3_Log/trials/route_offgrid_tracks_scan_def_m8/route_offgrid_tracks_scan_def_m8.log, 7_Backend_ICC2/4_Report/trials/route_offgrid_tracks_scan_def_m8/06_route/{check_routes,route_detail_app_options,pg_drc}.rpt, and 7_Backend_ICC2/4_Report/trials/route_offgrid_tracks_scan_def_m8/06_route/drc_detail/drc.matrix.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=route_via_effort_scan_def_m8 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_via_effort_scan_def_m8/route_via_effort_scan_def_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route via/DRC effort probe
Result: PASS_WITH_OPEN
Notes: route.detail.drc_convergence_effort_level=high and route.detail.optimize_wire_via_effort_level=high were applied. Final route has 0 open nets, PG DRC clean, and 389 route DRCs. Detail matrix: M1 diff spacing 130, M1-M2 needs-fat-contact 84, M2 off-grid 73, VIA1 off-grid 81. This improves baseline 398 only slightly, so simple router effort is not the root cause.
Evidence: 7_Backend_ICC2/3_Log/trials/route_via_effort_scan_def_m8/route_via_effort_scan_def_m8.log, 7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/{check_routes,route_detail_app_options,pg_drc}.rpt, and 7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/drc_detail/drc.matrix.rpt.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/06_route/route_drc_detail.scan_def_m8_restore.log -f 7_Backend_ICC2/0_Script/06_route/run_route_drc_detail.tcl; python3 scripts/select_drc_representatives.py; icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/drc_marker_context/drc_marker_context.log -f 7_Backend_ICC2/0_Script/99_util/run_drc_marker_context.tcl
Stage: ICC2 DRC marker context probe
Result: RECORDED
Notes: Fresh marker extraction reports 398 DRCs: M1 diff-net spacing 116, M1-M2 needs-fat-contact 99, M2 off-grid 78, VIA1 off-grid 82, M2 min-area 8, M1 off-grid 10, M2 diff-net spacing 4, and M1 short 1. Hotspot buckets are concentrated around x=220..260um and y=200..260um. Representative marker context shows many failures near OR2X1_HVT/NOR2X0_HVT small combinational cells, with some SDFFARX1_RVT/NBUFFX8_HVT examples and some VDD/VSS PG shapes inside the same local search windows.
Evidence: docs/backend/drc_marker_context.md, 7_Backend_ICC2/4_Report/06_route/drc_detail/{drc.matrix,drc.by_layer,drc.detailed}.rpt, and 7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/{representative_summary,representative_drc_markers,marker_context}.rpt.
```

```text
Date: 2026-05-08
Command: icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/root_cause_probe/hotspot_pg_shape_probe.log -f 7_Backend_ICC2/0_Script/99_util/run_hotspot_pg_shape_probe.tcl; python3 scripts/analyze_hotspot_pg_distance.py
Stage: ICC2 hotspot DRC-to-PG distance probe
Result: RECORDED
Notes: Hotspot {{215 195} {265 265}} contains 123 route DRC markers and three M2 PG stripes at x=219.8..220.2, x=239.8..240.2, and x=259.8..260.2. Distance summary: 23 markers within 1um of M2 PG, 78 within 5um, and 45 farther than 5um. PG M2 is related to the hotspot, but not the only cause.
Evidence: 7_Backend_ICC2/3_Log/trials/root_cause_probe/hotspot_pg_shape_probe.log, 7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance/hotspot_pg_shapes.tsv, and 7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance/hotspot_drc_pg_distance_summary.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=pgm2off30_scan_def_m8 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_MESH_OFFSET=30.0 icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pgm2off30_scan_def_m8/pgm2off30_scan_def_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 PG M2 offset root-cause probe
Result: INVALID_FOR_CLOSURE_BUT_INFORMATIVE
Notes: Moving M2 PG offset from 20um to 30um changed signal route DRC from 398 to 377 and kept open nets at 0, proving PG M2 position affects signal routing. But the same trial created PG DRC errors: 60 M1 insufficient-spacing errors after placement and 97 after route. Rejected as a fix. Root-cause model becomes PG M2 mesh + stdcell pin access + M2/VIA1 route/via policy.
Evidence: 7_Backend_ICC2/3_Log/trials/pgm2off30_scan_def_m8/pgm2off30_scan_def_m8.log, 7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/03_power/pg_mesh_trial_settings.rpt, 7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/drc_detail/drc.matrix.rpt, and 7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-08
Command: env TRIAL_NAME=scan_def_m8_restore CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/scan_def_m8_restore/scan_def_m8_restore.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 PG-clean baseline restore after PG offset probe
Result: PASS_WITH_OPEN
Notes: Rebuilt and saved the PG-clean scan_def_m8_restore baseline after rejecting the PG_M2_MESH_OFFSET=30.0 probe. Final route has 0 open nets and check_routes reports 398 DRCs. The ICC2 log reports check_pg_drc No errors found at route stage, so the saved block is back to the PG-clean diagnosis baseline.
Evidence: 7_Backend_ICC2/3_Log/trials/scan_def_m8_restore/scan_def_m8_restore.log and 7_Backend_ICC2/4_Report/trials/scan_def_m8_restore/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-08
Command: rg/sed evidence review of ICC2 check_routability, create_pin_check_lib reports, SAED32 HVT LEF, and SAED32 tech ContactCode definitions.
Stage: ICC2 MUX41X2_HVT/S0 valid-via-region diagnosis
Result: ROOT_CAUSE_COMPONENT_CONFIRMED
Notes: ZRT-044 for MUX41X2_HVT/S0 repeats in baseline and route-option probes. create_pin_check_lib/check_libcell_pin_access reports PDC-001 for MUX41X2_HVT/S0 no via regions. LEF shows MUX41X2_HVT/S0 has only one M1 stripe, RECT 2.1620 1.4440 2.7080 1.4940, height 0.050um. The default VIA12SQ_C needs a 0.05um cut plus M1 lower-layer enclosure, so the M1 landing height is too small for a normal valid VIA1 region. This confirms a library pin-access weakness, but it does not alone explain all 398 route DRCs.
Evidence: docs/backend/mux41x2_pin_access_diagnosis.md, 7_Backend_ICC2/4_Report/trials/create_pin_check_lib_trial/99_pin_check_lib/check_libcell_pin_access.hvt.analyze_lib_cell.rpt, 7_Backend_ICC2/4_Report/trials/scan_def_m8_restore/06_route/check_routability.rpt, /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef, and /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf.
```

```text
Date: 2026-05-08
Command: python3 scripts/analyze_sdffarx1_hotspot_overlap.py; env TRIAL_NAME=sdffarx1_current_blocked_detail icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/sdffarx1_current_blocked_detail/sdffarx1_current_blocked_detail.log -f 7_Backend_ICC2/0_Script/99_util/run_pin_access_blocked_detail.tcl; python3 scripts/summarize_cell_pin_access.py ...; env BLOCKED_REPORT=... DRC_REPORT=... OUT_DIR=... python3 scripts/analyze_sdffarx1_hotspot_overlap.py; env TRIAL_NAME=sdffarx1_hotspot_context INPUT_FILE=... icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/sdffarx1_hotspot_context/sdffarx1_hotspot_context_current.log -f 7_Backend_ICC2/0_Script/99_util/run_sdffarx1_hotspot_context.tcl
Stage: ICC2 SDFFARX1_RVT hotspot overlap diagnosis
Result: ROOT_CAUSE_COMPONENT_CONFIRMED
Notes: Baseline report-only analysis found 17 SDFFARX1 blocked points inside the hotspot, 14 within 5um of a DRC marker. Because the saved ICC2 block had moved to the route_via_effort trial, current-block reports were regenerated for coordinate-consistent evidence. Current block has 352 SDFFARX1 blocked points and 389 DRC markers; hotspot has 119 DRC markers and 11 SDFFARX1 blocked points. All 11 hotspot SDFFARX1 points have nearest DRC inside the hotspot, 10 are within 10um, 6 are within 5um, and all nearest DRCs are Needs fat contact. ICC2 context shows the hotspot points sit around the x=259.8..260.2 M2 VSS stripe. SDFFARX1 is a contributing root-cause component, not the whole hotspot cause.
Evidence: docs/backend/sdffarx1_hotspot_overlap.md, 7_Backend_ICC2/4_Report/trials/sdffarx1_current_hotspot_overlap/99_overlap/sdffarx1_overlap_summary.rpt, 7_Backend_ICC2/4_Report/trials/sdffarx1_hotspot_context/99_context/sdffarx1_hotspot_context.rpt, and 7_Backend_ICC2/4_Report/trials/sdffarx1_hotspot_context/99_context/report_cell_pin_access.hotspot_sdffarx1.details.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=pgm2off24_scan_def_m8 ... PG_M2_MESH_OFFSET=24.0 icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pgm2off24_scan_def_m8/pgm2off24_scan_def_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl; repeated with PG_M2_MESH_OFFSET=26.0 and 28.0.
Stage: ICC2 PG M2 offset fix sweep
Result: REJECTED
Notes: 24um gives route DRC 377, 26um gives 384, and 28um gives 383, all with open nets 0. But all three create PG DRC: 102, 82, and 83 M1 insufficient-spacing errors respectively. PG offset remains a proven contributor, but offset-only is not a valid fix.
Evidence: docs/backend/backend_fix_trials_2026_05_09.md and 7_Backend_ICC2/4_Report/trials/pgm2off{24,26,28}_scan_def_m8/06_route/{check_routes,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=hotspot_blk40_scan_def_m8 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def HOTSPOT_BLOCKAGE_ENABLE=1 HOTSPOT_BLOCKAGE_PERCENT=40 icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/hotspot_blk40_scan_def_m8/hotspot_blk40_scan_def_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 hotspot local partial blockage fix trial
Result: PASS_WITH_OPEN
Notes: The hotspot {{215 195} {265 265}} 40% partial blockage keeps open nets 0, legality 0, and PG DRC clean, but final route DRC is 391. This is only a weak improvement over scan_def_m8_restore 398 and worse than route option probes, so hotspot density alone is not accepted as the fix.
Evidence: docs/backend/backend_fix_trials_2026_05_09.md and 7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/{check_routes,check_legality,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_scan_def_m8 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_scan_def_m8/route_combo_scan_def_m8.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route option combination fix trial
Result: BEST_CURRENT_PASS_WITH_OPEN
Notes: Combined route detail options keep open nets 0, legality 0, and PG DRC clean. check_routes reports 381 DRCs: diff-net spacing 127, min-area 3, needs-fat-contact 91, off-grid 157, same-net spacing 1, short 2. This is the best valid backend trial so far but still not route closure.
Evidence: docs/backend/backend_fix_trials_2026_05_09.md and 7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/{check_routes,check_legality,route_detail_app_options,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: dc_shell -topographical_mode -f 2_Synthesis/0_Script/run_compile_10ns_topo_no_mux41x_hvt.tcl -output_log_file 2_Synthesis/3_Log/compile_10ns_topo_no_mux41x_hvt.log; fm_shell -overwrite -file 2.5_FM_R2N/0_Script/run_fm_r2n_topo_no_mux41x_hvt.tcl; dc_shell -topographical_mode -f 3_DFT/0_Script/run_insert_dft_10ns_topo_no_mux41x_hvt.tcl -output_log_file 3_DFT/3_Log/insert_dft_10ns_topo_no_mux41x_hvt.log; fm_shell -overwrite -file 5_FM_N2N/0_Script/run_fm_n2n_topo_no_mux41x_hvt.tcl; tmax -shell 4_ATPG/0_Script/run_tmax_stuck_at_topo_no_mux41x_hvt.tcl; pt_shell -f 6_STA/0_Script/run_pt_post_dft_10ns_sdf_no_mux41x_hvt.tcl
Stage: no_mux41x_hvt front-end validation
Result: PASS_WITH_NOTE
Notes: MUX41X1_HVT usage changed from 67 to 0 and MUX41X1_RVT usage became 67. DC/R2N/DFT/N2N/ATPG/PT all completed. R2N and N2N each have 2243 passing compare points and 0 failing. DFT built chain0 length 2130. ATPG reached 98.61% test coverage and 98.51% fault coverage. PT post-DFT SDF annotation has 0 errors and no setup/hold violations. Existing DFT TEST-505, ATPG Z3, and PT max_cap notes remain.
Evidence: docs/backend/no_mux41x_hvt_experiment_2026_05_09.md, 2_Synthesis/4_Report/topo_no_mux41x_hvt/post_compile.qor.rpt, 2.5_FM_R2N/4_Report/no_mux41x_hvt/r2n_topo_no_mux41x_hvt.failing_points.rpt, 3_DFT/4_Report/topo_no_mux41x_hvt/post_dft.drc.rpt, 5_FM_N2N/4_Report/no_mux41x_hvt/n2n_topo_no_mux41x_hvt.failing_points.rpt, 4_ATPG/4_Report/stuck_at_topo_no_mux41x_hvt/summary.rpt, and 6_STA/4_Report/post_dft_topo_sdf_no_mux41x_hvt/post_dft_no_mux41x_hvt.func_tt_10ns_sdf.global_timing.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_mux41x_hvt CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_mux41x_hvt/cv32e40p_synth_wrap.post_dft_topo_no_mux41x_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_mux41x_hvt/cv32e40p_synth_wrap.post_dft_topo_no_mux41x_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_mux41x_hvt/cv32e40p_synth_wrap.post_dft_topo_no_mux41x_hvt.scan.def ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_no_mux41x_hvt/route_combo_no_mux41x_hvt.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 no_mux41x_hvt route combo trial
Result: REJECTED
Notes: The trial kept open nets 0, legality 0, and PG DRC clean, but check_routes reports 399 DRCs. This is worse than route_combo_scan_def_m8 at 381 DRCs. no_mux41x_hvt reduces diff-net spacing but worsens needs-fat-contact and off-grid classes, so it is not accepted as a backend fix.
Evidence: docs/backend/no_mux41x_hvt_experiment_2026_05_09.md and 7_Backend_ICC2/4_Report/trials/route_combo_no_mux41x_hvt/06_route/{check_routes,check_legality,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_pgcut_vss260 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_CUT_ENABLE=1 PG_M2_HOTSPOT_CUT_BOUNDARY='{{258.0 195.0} {262.0 265.0}}' PG_M2_HOTSPOT_CUT_NETS='VSS' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgcut_vss260/route_combo_pgcut_vss260.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 local M2 VSS PG cut root-cause trial
Result: BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Cut only the hotspot portion of the x=259.8..260.2um VSS M2 PG stripe from y=195..265um, then recreated the bottom/top stripe segments. The trial kept open nets 0, legality 0, PG connectivity clean, and PG DRC clean. check_routes reports 377 DRCs, improving the previous valid route_combo_scan_def_m8 baseline at 381 DRCs. This proves local M2 PG obstruction contributes to the route DRC, but the small 4-DRC improvement means it is not the only cause.
Evidence: docs/backend/local_pg_m2_cut_trial_2026_05_09.md, 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/03_power/pg_m2_hotspot_cut.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_pgcut_allm2_hotspot CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_CUT_ENABLE=1 PG_M2_HOTSPOT_CUT_BOUNDARY='{{215.0 195.0} {265.0 265.0}}' PG_M2_HOTSPOT_CUT_NETS='VDD VSS' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgcut_allm2_hotspot/route_combo_pgcut_allm2_hotspot.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 local hotspot all-M2 PG cut root-cause trial
Result: PASS_WITH_OPEN_REJECTED_AS_BEST
Notes: Cut hotspot portions of VSS x=219.8..220.2, VDD x=239.8..240.2, and VSS x=259.8..260.2 M2 PG stripes. The trial kept open nets 0, legality 0, PG connectivity clean, and PG DRC clean, but route DRC is 378, which is worse than vss260-only cut at 377. DRC class trade-off is important: diff-net spacing improves to 96, but needs-fat-contact worsens to 113. This confirms M2 PG obstruction and M1-M2 contact legality are coupled.
Evidence: docs/backend/local_pg_m2_cut_trial_2026_05_09.md, 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/03_power/pg_m2_hotspot_cut.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_pgcut_vdd240 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_CUT_ENABLE=1 PG_M2_HOTSPOT_CUT_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_CUT_NETS='VDD' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgcut_vdd240/route_combo_pgcut_vdd240.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 local x=240 VDD M2 PG cut root-cause trial
Result: BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Cut only the hotspot portion of the x=239.8..240.2um VDD M2 PG stripe from y=195..265um, then recreated the bottom/top stripe segments. The trial kept open nets 0, legality 0, PG connectivity clean, and PG DRC clean. check_routes reports 376 DRCs, improving route_combo_scan_def_m8 at 381 and route_combo_pgcut_vss260 at 377. This makes x=240 VDD the best PG-cut diagnosis candidate so far.
Evidence: docs/backend/local_pg_m2_cut_trial_2026_05_09.md, 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/03_power/pg_m2_hotspot_cut.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_pgcut_vss220 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_CUT_ENABLE=1 PG_M2_HOTSPOT_CUT_BOUNDARY='{{218.0 195.0} {222.0 265.0}}' PG_M2_HOTSPOT_CUT_NETS='VSS' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgcut_vss220/route_combo_pgcut_vss220.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 local x=220 VSS M2 PG cut root-cause trial
Result: PASS_WITH_OPEN_REJECTED_AS_BEST
Notes: Cut only the hotspot portion of the x=219.8..220.2um VSS M2 PG stripe. The trial kept open nets 0, legality 0, PG connectivity clean, and PG DRC clean, but route DRC is 380. This is only a weak improvement over route_combo_scan_def_m8 at 381 and worse than x=240 VDD cut at 376. x=220 VSS cut reduces diff-net spacing but worsens needs-fat-contact and short count.
Evidence: docs/backend/local_pg_m2_cut_trial_2026_05_09.md, 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/03_power/pg_m2_hotspot_cut.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_pgcut_vdd240_restore CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_CUT_ENABLE=1 PG_M2_HOTSPOT_CUT_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_CUT_NETS='VDD' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgcut_vdd240_restore/route_combo_pgcut_vdd240_restore.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 saved-block restore to x=240 VDD best candidate
Result: BEST_CURRENT_OPEN_RESTORED
Notes: Rebuilt and saved the current ICC2 block using the accepted x=240 VDD local M2 cut after rejecting x=220 VSS as best. check_routes reports 376 DRCs with open nets 0. check_legality reports 0 violations. check_pg_connectivity reports VDD/VSS floating wires, vias, std cells, hard macros, pads, terminals, and blocks all 0. check_pg_drc reports no errors. Route DRC remains open, so this is not backend closure.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_pgcut_vdd240_restore/route_combo_pgcut_vdd240_restore.log and 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240_restore/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_pgblock_vdd240 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240/route_combo_pgblock_vdd240.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 clean PG blockage trial
Result: BEST_CURRENT_OPEN
Notes: Replaced diagnosis-only manual x=240 VDD M2 cut with set_pg_strategy -blockage on VDD/M2 in pg_region hotspot_pg_m2_blockage. pg_strategies.rpt confirms the blockage under core_mesh_strategy. check_routes reports 368 DRCs with open nets 0. check_legality reports 0 violations. route-stage check_pg_connectivity reports VDD/VSS floating wires/vias/std cells/terminals all 0, and check_pg_drc reports no errors. DRC matrix is still lower-metal/access only: M1 92, M1-M2 120, M2 77, VIA1 79. This is the current best valid backend candidate, but route DRC remains open.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240/route_combo_pgblock_vdd240.log, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/03_power/pg_mesh_trial_settings.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/03_power/pg_strategies.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_drc.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.matrix.rpt.
```

```text
Date: 2026-05-09
Command: env DRC_DETAIL_DIR=7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240/route_combo_pgblock_vdd240.drc_detail.log -f 7_Backend_ICC2/0_Script/06_route/run_route_drc_detail.tcl; DRC_REPORT=7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.detailed.rpt OUT_DIR=7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail python3 scripts/select_drc_representatives.py
Stage: ICC2 clean PG blockage DRC detail extraction
Result: RECORDED
Notes: Detailed zroute.err matrix confirms 368 route DRCs: Diff net spacing 91, less-than-min-area 5, needs-fat-contact 120, off-grid 152. Top 20um buckets remain around x=220..260 and y=200..260, especially 220-240/220-240 with 30 markers. Representative markers were exported for GUI/debug follow-up.
Evidence: 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.matrix.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.by_layer.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.by_type.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.detailed.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/representative_summary.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/representative_drc_markers.tsv.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_pgblock_vdd240_vss260 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {262.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD VSS' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240_vss260/route_combo_pgblock_vdd240_vss260.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 clean PG blockage VDD+VSS expansion trial
Result: PASS_WITH_OPEN_REJECTED_AS_BEST
Notes: Expanded the PG strategy blockage to cover x=240 VDD and x=260 VSS M2 stripes in the hotspot. The trial kept open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but check_routes reports 376 DRCs. Matrix trade-off: needs-fat-contact improves 120 -> 104 compared with route_combo_pgblock_vdd240, but M1 diff-net spacing worsens 89 -> 101, M2 off-grid worsens 70 -> 79, VIA1 off-grid worsens 79 -> 81, and 2 shorts appear. Therefore route_combo_pgblock_vdd240 remains the best valid candidate at 368 DRC.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240_vss260/route_combo_pgblock_vdd240_vss260.log, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/03_power/pg_mesh_trial_settings.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/03_power/pg_strategies.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/pg_drc.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/drc_detail/drc.matrix.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_pgblock_vdd240_pincheck CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' PLACE_MULTI_CELL_PIN_ACCESS_CHECK=true ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_pincheck/route_pgblock_vdd240_pincheck.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 VDD/M2 PG blockage plus placement multi-cell pin-access check trial
Result: PASS_WITH_OPEN_REJECTED_AS_BEST
Notes: Added only place.legalize.enable_multi_cell_pin_access_check=true on top of the current best VDD/M2 PG blockage flow. The trial kept open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but check_routes reports 368 DRCs, identical to route_combo_pgblock_vdd240. The detailed matrix is also identical: M1 92, M1-M2 120, M2 77, VIA1 79. This single legalizer pin-access option does not improve closure.
Evidence: 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_pincheck/route_pgblock_vdd240_pincheck.log, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/04_place/place_legalize_app_options.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/pg_drc.rpt, and 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/drc_detail/drc.matrix.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_pgblock_vdd240_offtrackvia CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' PLACE_SUPPORT_OFF_TRACK_VIA_REGION=true ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_offtrackvia/route_pgblock_vdd240_offtrackvia.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 VDD/M2 PG blockage plus off-track via-region placement support trial
Result: PASS_WITH_OPEN_REJECTED_AS_BEST
Notes: Added only place.legalize.support_off_track_via_region=true on top of the current best VDD/M2 PG blockage flow. The trial kept open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but check_routes reports 368 DRCs. The detailed matrix is identical to the current best: M1 92, M1-M2 120, M2 77, VIA1 79. ICC2 also reports that pin-track alignment is disabled unless the advanced legalizer is enabled, so this single option is not a useful fix in the current flow.
Evidence: 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_offtrackvia/route_pgblock_vdd240_offtrackvia.log, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/04_place/place_legalize_app_options.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/pg_drc.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/drc_detail/drc.matrix.rpt, and 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/drc_detail/representative_summary.rpt.
```

```text
Date: 2026-05-09
Command: icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_grid_option_probe/probe_route_grid_options.log -f 7_Backend_ICC2/0_Script/99_util/probe_route_grid_options.tcl; icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_grid_option_probe/probe_route_grid_option_man.log -f 7_Backend_ICC2/0_Script/99_util/probe_route_grid_option_man.tcl; icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_grid_option_probe/probe_route_grid_option_values.log -f 7_Backend_ICC2/0_Script/99_util/probe_route_grid_option_values.tcl
Stage: ICC2 route grid/via option syntax probe
Result: RECORDED
Notes: report_app_options and man-page probes confirm route.common.via_on_grid_by_layer_name, route.common.wire_on_grid_by_layer_name, and route.common.extra_via_off_grid_cost_multiplier_by_layer_name are real block-scope options. The correct shell environment value form for one pair is single-brace Tcl list text such as '{M2 0.5}', not '{{M2 0.5}}'. The double-brace form causes CMD-013 invalid value errors when passed through an environment variable. The SAED32 tech file also reports TECH-025 because VIA1 has both onGrid and onWireTrack.
Evidence: 7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/route_common_all.rpt, 7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/route_detail_all.rpt, 7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/man_via_on_grid_by_layer_name.rpt, 7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/man_wire_on_grid_by_layer_name.rpt, 7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/man_extra_via_off_grid_cost_multiplier_by_layer_name.rpt, and 7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/route_grid_option_value_probe.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_pgblock_vdd240_m2offgridcost05b CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_COMMON_EXTRA_VIA_OFF_GRID_COST_BY_LAYER='{M2 0.5}' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_m2offgridcost05b/route_pgblock_vdd240_m2offgridcost05b.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 VDD/M2 PG blockage plus M2 off-grid via cost trial
Result: PASS_WITH_OPEN_REJECTED_AS_BEST
Notes: Added route.common.extra_via_off_grid_cost_multiplier_by_layer_name={M2 0.5}. route_common_app_options.rpt confirms the option was applied. The trial kept open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but check_routes reports 368 DRCs. The detailed matrix is identical to route_combo_pgblock_vdd240: M1 92, M1-M2 120, M2 77, VIA1 79. A small off-grid via cost increase on M2 does not move the remaining DRC.
Evidence: 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_m2offgridcost05b/route_pgblock_vdd240_m2offgridcost05b.log, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/route_common_app_options.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/pg_drc.rpt, and 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/drc_detail/drc.matrix.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_pgblock_vdd240_via1ongrid_b CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_COMMON_VIA_ON_GRID_BY_LAYER='{VIA1 true}' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_via1ongrid_b/route_pgblock_vdd240_via1ongrid_b.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 VDD/M2 PG blockage plus VIA1 on-grid route option trial
Result: PASS_WITH_OPEN_REJECTED_AS_BEST
Notes: Added route.common.via_on_grid_by_layer_name={VIA1 true}. route_common_app_options.rpt confirms the option was applied. The trial kept open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but check_routes reports 368 DRCs. DRC type counts remain Diff net spacing 91, Less than minimum area 5, Needs fat contact 120, and Off-grid 152. ZRT-044 for MUX41X2_HVT/S0 also remains. Therefore explicit VIA1 on-grid routing does not move the remaining DRC.
Evidence: 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_via1ongrid_b/route_pgblock_vdd240_via1ongrid_b.log, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/route_common_app_options.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_pgblock_vdd240_m2wireongrid CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER='{M2 true}' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_m2wireongrid/route_pgblock_vdd240_m2wireongrid.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 VDD/M2 PG blockage plus M2 wire-on-grid route option trial
Result: PASS_WITH_OPEN_REJECTED_AS_BEST
Notes: Added route.common.wire_on_grid_by_layer_name={M2 true}. The trial kept open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but check_routes reports 378 DRCs. Compared with route_combo_pgblock_vdd240, needs-fat-contact worsens 120 -> 126 and off-grid worsens 152 -> 155 while diff-net spacing improves 91 -> 85. This confirms M2 wire grid policy changes the DRC trade-off but does not close or improve the design.
Evidence: 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_m2wireongrid/route_pgblock_vdd240_m2wireongrid.log, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/route_common_app_options.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_pgblock_vdd240_restore2 CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240_restore2/route_combo_pgblock_vdd240_restore2.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 saved-block restore to current best VDD/M2 PG blockage candidate
Result: BEST_CURRENT_OPEN_RESTORED
Notes: Rebuilt and saved the ICC2 block using the accepted route_combo_pgblock_vdd240 condition after rejecting the M2 wire-on-grid trial. check_routes reports 368 DRCs with open nets 0. check_legality reports 0 violations. check_pg_connectivity reports VDD/VSS floating wires, vias, std cells, hard macros, pads, terminals, and blocks all 0. check_pg_drc reports no errors. Route DRC remains open, so this is not backend closure.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240_restore2/route_combo_pgblock_vdd240_restore2.log and 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_restore2/06_route/{check_routes,check_legality,pg_connectivity,pg_drc}.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_pgblock_vdd240_m1wireongrid CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER='{M1 true}' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_m1wireongrid/route_pgblock_vdd240_m1wireongrid.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 VDD/M2 PG blockage plus M1 wire-on-grid route option trial
Result: PASS_WITH_OPEN_REJECTED_AS_BEST
Notes: Added route.common.wire_on_grid_by_layer_name={M1 true}. The trial kept open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but check_routes reports 380 DRCs. Compared with route_combo_pgblock_vdd240, needs-fat-contact improves 120 -> 81, but diff-net spacing worsens 91 -> 130, off-grid worsens 152 -> 158, and total DRC worsens 368 -> 380. This confirms M1 wire grid policy also changes the DRC trade-off but is not a fix.
Evidence: 7_Backend_ICC2/3_Log/trials/route_pgblock_vdd240_m1wireongrid/route_pgblock_vdd240_m1wireongrid.log, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/route_common_app_options.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: python3 scripts/analyze_route_drc_geometry.py --markers 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/all_drc_markers.tsv --out 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.geometry_analysis.rpt
Stage: ICC2 current-best route DRC geometry residue analysis
Result: RECORDED
Notes: Analyzed the current best valid route candidate route_combo_pgblock_vdd240. The candidate remains open at 368 DRCs with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Geometry analysis shows a deterministic residue pattern: 120/120 M1-M2 needs-fat-contact markers have residue rx=0.064/ry=0.064 against 0.152um pitch; M2 and VIA1 off-grid markers cluster at rx=0.061..0.066/ry=0.064. This points to lower-metal stdcell pin/contact/grid mismatch plus local PG obstruction, not random global congestion.
Evidence: scripts/analyze_route_drc_geometry.py and 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.geometry_analysis.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_pgblock_vdd240_context MARKER_FILE=7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/representative_drc_markers.tsv REPORT_DIR=7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/99_marker_context icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240_context/route_combo_pgblock_vdd240_context.log -f 7_Backend_ICC2/0_Script/99_util/run_drc_marker_context.tcl
Stage: ICC2 current-best representative marker cell/pin context probe
Result: RECORDED
Notes: Reused the saved current-best route block and mapped 35 representative DRC markers to nearby pins, cells, and shapes. Nearby ref-cell counts are OR2X1_HVT 46, NOR2X0_HVT 23, NOR2X4_HVT 6, SDFFARX1_RVT 5, AO22X1_HVT 5, FADDX2_HVT 3, and NAND2X0_HVT 2. M1 spacing and needs-fat-contact representatives are dominated by OR2X1_HVT. M2/VIA1 off-grid representatives are dominated by NOR2X0_HVT/NOR2X4_HVT. This makes OR2X1_HVT and NOR2X*_HVT the next targeted root-cause candidates; SDFFARX1_RVT remains a contributor but not the main representative pattern.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240_context/route_combo_pgblock_vdd240_context.log and 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/99_marker_context/marker_context.rpt.
```

```text
Date: 2026-05-09
Command: dc_shell -topographical_mode -f 2_Synthesis/0_Script/run_compile_10ns_topo_no_or2x1_hvt.tcl -output_log_file 2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_hvt.log
Stage: DC topo synthesis OR2X1_HVT dont_use probe
Result: PASS
Notes: OR2X1_HVT was removed from the compiled reference list while mixed RVT/LVT/HVT remains enabled. DC timing is met at 10ns with worst setup slack about 1.87ns. Area is 45242.97 cell area. Existing max cap/transition constraint violations remain physical-cleanup items.
Evidence: 2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_hvt.log, 2_Synthesis/4_Report/topo_no_or2x1_hvt/post_compile.references.rpt, 2_Synthesis/4_Report/topo_no_or2x1_hvt/post_compile.timing.rpt, and 2_Synthesis/4_Report/topo_no_or2x1_hvt/post_compile.area.rpt.
```

```text
Date: 2026-05-09
Command: fm_shell -file 2.5_FM_R2N/0_Script/run_fm_r2n_topo_no_or2x1_hvt.tcl
Stage: Formality R2N OR2X1_HVT dont_use probe
Result: PASS
Notes: RTL reference vs no_or2x1_hvt pre-DFT topo implementation verification succeeded. 2243 compare points passed and 0 failed.
Evidence: 2.5_FM_R2N/4_Report/no_or2x1_hvt/r2n_topo_no_or2x1_hvt.failing_points.rpt, 2.5_FM_R2N/4_Report/no_or2x1_hvt/r2n_topo_no_or2x1_hvt.passing_points.post_verify.rpt, and 2.5_FM_R2N/2_Output/r2n_topo_no_or2x1_hvt_fm_session.fss.
```

```text
Date: 2026-05-09
Command: dc_shell -topographical_mode -f 3_DFT/0_Script/run_insert_dft_10ns_topo_no_or2x1_hvt.tcl -output_log_file 3_DFT/3_Log/insert_dft_10ns_topo_no_or2x1_hvt.log
Stage: DC/DFT Compiler OR2X1_HVT dont_use probe
Result: PASS
Notes: Post-DFT DDC/VG/SDC/SDF/SPF/scan DEF were generated for the no_or2x1_hvt handoff. This keeps the single muxed scan-chain flow.
Evidence: 3_DFT/3_Log/insert_dft_10ns_topo_no_or2x1_hvt.log, 3_DFT/2_Output/post_dft_topo_no_or2x1_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_hvt.vg, 3_DFT/2_Output/post_dft_topo_no_or2x1_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_hvt.scan.def, and 3_DFT/4_Report/topo_no_or2x1_hvt/post_dft.drc.rpt.
```

```text
Date: 2026-05-09
Command: fm_shell -file 5_FM_N2N/0_Script/run_fm_n2n_topo_no_or2x1_hvt.tcl
Stage: Formality N2N OR2X1_HVT dont_use probe
Result: PASS
Notes: no_or2x1_hvt pre-DFT vs post-DFT functional verification succeeded. 2243 compare points passed and 0 failed. Expected scan/clock-gate non-compare handling remains consistent with the main flow.
Evidence: 5_FM_N2N/4_Report/no_or2x1_hvt/n2n_topo_no_or2x1_hvt.failing_points.rpt, 5_FM_N2N/4_Report/no_or2x1_hvt/n2n_topo_no_or2x1_hvt.passing_points.post_verify.rpt, and 5_FM_N2N/2_Output/n2n_topo_no_or2x1_hvt_fm_session.fss.
```

```text
Date: 2026-05-09
Command: pt_shell -f 6_STA/0_Script/run_pt_post_dft_10ns_sdf_no_or2x1_hvt.tcl -output_log_file 6_STA/3_Log/pt_post_dft_10ns_sdf_no_or2x1_hvt.log
Stage: PrimeTime post-DFT SDF STA OR2X1_HVT dont_use probe
Result: PASS_WITH_PHYSICAL_DRC_OPEN
Notes: SDF read has 0 errors. Setup and hold are met at 10ns. Worst setup slack observed is about 1.82ns and worst hold slack about 0.05ns. Max cap/transition violations remain physical-cleanup items.
Evidence: 6_STA/3_Log/pt_post_dft_10ns_sdf_no_or2x1_hvt.log and 6_STA/4_Report/post_dft_topo_sdf_no_or2x1_hvt/.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_hvt POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_hvt.sdc CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_hvt.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_hvt/route_combo_no_or2x1_hvt.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route trial using OR2X1_HVT dont_use handoff
Result: BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Route completes with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. check_routes reports 203 DRCs, all Off-grid. This improves the current-best route DRC from 368 to 203, and removes the previous spacing/fat-contact classes from the final check_routes summary. ZRT-044 for MUX41X2_HVT/S0 remains, so OR2X1_HVT is confirmed as one major DRC contributor but not the sole root cause.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_hvt/route_combo_no_or2x1_hvt.log, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: DC topo -> FM R2N -> DFT -> FM N2N -> PT SDF STA for no_or2x1_nor2x02_hvt
Stage: Front-end validation for OR2X1_HVT + NOR2X0_HVT + NOR2X2_HVT dont_use probe
Result: PASS
Notes: Mixed-VT remains enabled. The three target HVT cells are absent from the synthesized reference list. R2N Formality passed with 2243 passing and 0 failing compare points. DFT generated post-DFT DDC/VG/SDC/SDF/SPF/scan DEF with 1 scan chain and 2130 scan cells. N2N Formality passed with 2243 passing and 0 failing compare points. PrimeTime post-DFT SDF read had 0 errors and global timing reports no setup or hold violations. DFT DRC keeps the existing TEST-505 constant-1 clock-gate note.
Evidence: 2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_nor2x02_hvt.log, 2_Synthesis/4_Report/topo_no_or2x1_nor2x02_hvt/post_compile.references.rpt, 2.5_FM_R2N/4_Report/no_or2x1_nor2x02_hvt/r2n_topo_no_or2x1_nor2x02_hvt.passing_points.post_verify.rpt, 3_DFT/4_Report/topo_no_or2x1_nor2x02_hvt/post_dft.drc.rpt, 5_FM_N2N/4_Report/no_or2x1_nor2x02_hvt/n2n_topo_no_or2x1_nor2x02_hvt.passing_points.post_verify.rpt, and 6_STA/4_Report/post_dft_topo_sdf_no_or2x1_nor2x02_hvt/post_dft_no_or2x1_nor2x02_hvt.func_tt_10ns_sdf.global_timing.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_nor2x02_hvt POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x02_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x02_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x02_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x02_hvt.sdc CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x02_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x02_hvt.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route trial using OR2X1_HVT + NOR2X0_HVT + NOR2X2_HVT dont_use handoff
Result: BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Route completes with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. check_routes reports 188 DRCs: Off-grid 186 and Diff net spacing 2. This improves no_or2x1_hvt route DRC from 203 to 188, but the improvement is small. Detailed matrix is M1 8, M2 88, M7 1, VIA1 91. ZRT-044 for MUX41X2_HVT/S0 remains. Representative marker context now points mostly to NOR2X1_HVT, then OR2X4_HVT/FADDX*_HVT/NOR2X4_HVT.
Evidence: 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/06_route/drc_detail/drc.matrix.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/06_route/pg_drc.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/99_marker_context/marker_context.rpt.
```

```text
Date: 2026-05-09
Command: DC topo -> FM R2N -> DFT -> FM N2N -> PT SDF STA for no_or2x1_nor2x012_hvt
Stage: Front-end validation for OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT dont_use probe
Result: PASS
Notes: Mixed-VT remains enabled. The target OR2X1/NOR2X0/NOR2X1/NOR2X2_HVT cells are absent from the synthesized reference list. DC timing is met at 10ns with worst visible slack about 1.69ns and pre-DFT cell area 45309.30. R2N Formality passed with 2243 passing and 0 failing compare points. DFT generated post-DFT DDC/VG/SDC/SDF/SPF/scan DEF with 1 scan chain and 2130 scan cells. N2N Formality passed with 2243 passing and 0 failing compare points. PrimeTime post-DFT SDF read had 0 errors and global timing reports no setup or hold violations.
Evidence: 2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_nor2x012_hvt.log, 2_Synthesis/4_Report/topo_no_or2x1_nor2x012_hvt/post_compile.references.rpt, 2.5_FM_R2N/4_Report/no_or2x1_nor2x012_hvt/r2n_topo_no_or2x1_nor2x012_hvt.passing_points.post_verify.rpt, 3_DFT/4_Report/topo_no_or2x1_nor2x012_hvt/post_dft.drc.rpt, 5_FM_N2N/4_Report/no_or2x1_nor2x012_hvt/n2n_topo_no_or2x1_nor2x012_hvt.passing_points.post_verify.rpt, and 6_STA/4_Report/post_dft_topo_sdf_no_or2x1_nor2x012_hvt/post_dft_no_or2x1_nor2x012_hvt.func_tt_10ns_sdf.global_timing.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_nor2x012_hvt POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt/route_combo_no_or2x1_nor2x012_hvt.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route trial using OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT dont_use handoff
Result: BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Route completes with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. check_routes reports 110 DRCs: Off-grid 104, Diff net spacing 5, and Short 1. Detailed matrix is M1 5, M2 53, VIA1 52. This improves no_or2x1_nor2x02_hvt route DRC from 188 to 110, confirming NOR2X1_HVT as a major remaining off-grid contributor. ZRT-044 for MUX41X2_HVT/S0 remains. Representative marker context after this trial is dominated by NOR2X4_HVT 72 and SDFFARX1_RVT 31.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt/route_combo_no_or2x1_nor2x012_hvt.log, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/06_route/drc_detail/drc.matrix.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/06_route/pg_drc.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/99_marker_context/marker_context.rpt.
```

```text
Date: 2026-05-09
Command: DC topo -> FM R2N -> DFT -> FM N2N -> PT SDF STA for no_or2x1_nor2x0124_hvt
Stage: Front-end validation for OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT + NOR2X4_HVT dont_use probe
Result: PASS
Notes: Mixed-VT remains enabled. The target OR2X1/NOR2X0/NOR2X1/NOR2X2/NOR2X4_HVT cells are absent from the synthesized reference list. DC timing is met at 10ns with worst visible slack about 1.82ns, pre-DFT cell area 45487.20, and 14302 cells. R2N Formality passed with 2243 passing and 0 failing compare points. DFT generated post-DFT DDC/VG/SDC/SDF/SPF/scan DEF with 1 scan chain and 2130 scan cells. N2N Formality passed with 2243 passing and 0 failing compare points. PrimeTime post-DFT SDF read had 0 errors and global timing reports no setup or hold violations.
Evidence: 2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_nor2x0124_hvt.log, 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.references.rpt, 2.5_FM_R2N/4_Report/no_or2x1_nor2x0124_hvt/r2n_topo_no_or2x1_nor2x0124_hvt.passing_points.post_verify.rpt, 3_DFT/4_Report/topo_no_or2x1_nor2x0124_hvt/post_dft.drc.rpt, 5_FM_N2N/4_Report/no_or2x1_nor2x0124_hvt/n2n_topo_no_or2x1_nor2x0124_hvt.passing_points.post_verify.rpt, and 6_STA/4_Report/post_dft_topo_sdf_no_or2x1_nor2x0124_hvt/post_dft_no_or2x1_nor2x0124_hvt.func_tt_10ns_sdf.global_timing.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_nor2x0124_hvt POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x0124_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x0124_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x0124_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x0124_hvt.sdc CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x0124_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x0124_hvt.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route trial using OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT + NOR2X4_HVT dont_use handoff
Result: REJECTED
Notes: Route completes with open nets 0, legality 0, PG connectivity clean, and PG DRC clean, but check_routes reports 481 DRCs. This is much worse than the no_or2x1_nor2x012_hvt route at 110 DRC. Detailed matrix is M1 3, M2 232, M7 1, VIA1 245; Off-grid alone is 477. Synthesis cell count increased 13880 -> 14302 and NOR2X4_HVT removal caused broader restructuring, including many more small/replacement cells. Therefore NOR2X4_HVT is context/correlation, not a valid broad dont_use fix.
Evidence: 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/drc_detail/drc.matrix.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_nor2x012_hvt_restore POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt_restore/route_combo_no_or2x1_nor2x012_hvt_restore.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route restore using OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT dont_use handoff
Result: RESTORED_BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Route completes with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. check_routes reports 110 DRCs: Off-grid 104, Diff net spacing 5, and Short 1. This restores the current best MVT repair baseline after the rejected NOR2X4_HVT broad dont_use trial.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt_restore/route_combo_no_or2x1_nor2x012_hvt_restore.log, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: ICC2 DRC detail + full marker context + report_cell_pin_access coordinate match for route_combo_no_or2x1_nor2x012_hvt_restore
Stage: ICC2 remaining DRC root-cause diagnosis
Result: ROOT_CAUSE_NARROWED
Notes: Full DRC detail confirms 110 DRCs: Off-grid 104, Diff net spacing 5, Short 1. Full marker context maps nearby ref cells to NOR2X4_HVT 85, OR2X4_HVT 16, SDFFARX1_RVT 7, and NOR2X0_HVT 2. Coordinate matching shows 103 of 110 markers align within 0.08um to report_cell_pin_access points, all on A2 routable access. The matched markers are NOR2X4_HVT/A2 85, OR2X4_HVT/A2 16, and NOR2X0_HVT/A2 2. This indicates a route/check grid or via/contact generation mismatch around HVT OR/NOR A2 access, not simple blocked pin access.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt_restore/route_combo_no_or2x1_nor2x012_hvt_restore_drc_detail.log, 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt_restore/route_combo_no_or2x1_nor2x012_hvt_restore_marker_context_all.log, 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt_restore/route_combo_no_or2x1_nor2x012_hvt_restore_pin_access.log, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/06_route/drc_detail/drc.matrix.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_marker_context_all/marker_context.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/report_cell_pin_access.targets.details.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/drc_to_pin_access_coordinate_match.tsv.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no012_no_extra_offgrid_tracks ... ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=false ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route option trial on no_or2x1_nor2x012_hvt handoff
Result: REJECTED
Notes: Disabling route.detail.generate_extra_off_grid_pin_tracks does not fix the HVT OR/NOR A2 off-grid issue. route_auto ended at 114 DRC and final check_routes reports 113 DRCs: Off-grid 107, Diff net spacing 4, Short 2. This is worse than the current best 110-DRC baseline. Open nets remain 0, legality remains 0, PG connectivity remains clean, and PG DRC has no errors.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no012_no_extra_offgrid_tracks/route_combo_no012_no_extra_offgrid_tracks.log, 7_Backend_ICC2/4_Report/trials/route_combo_no012_no_extra_offgrid_tracks/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_no_extra_offgrid_tracks/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_no_extra_offgrid_tracks/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no012_no_extra_offgrid_tracks/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_nor2x012_hvt_restore2 ... ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route restore after rejected no-extra-offgrid-tracks trial
Result: RESTORED_BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Saved ICC2 block was restored to the current best no_or2x1_nor2x012_hvt physical baseline. check_routes reports 110 DRCs: Off-grid 104, Diff net spacing 5, and Short 1. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt_restore2/route_combo_no_or2x1_nor2x012_hvt_restore2.log, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore2/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore2/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore2/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore2/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no012_a2_lvt_swap ... ECO_SWAP_FILE=configs/backend/a2_offgrid_hvt_to_lvt_swap.tsv ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 targeted ECO swap trial for HVT OR/NOR A2 off-grid markers
Result: WEAK_IMPROVEMENT_REJECTED_AS_ROOT_FIX
Notes: The 52 matched A2-marker instances were all size_cell PASS at init. Final check_routes reports 109 DRCs: Off-grid 108 and Same net spacing 1. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors. Final-ref audit shows optimizer did not keep any requested LVT swap: 41 NOR2X4_RVT, 8 OR2X4_RVT, 2 NOR2X0_HVT, and 1 NOR2X4_HVT. Therefore the 110 -> 109 change is not valid evidence that LVT geometry fixes the A2 issue.
Evidence: 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/01_init_design/eco_swap.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/06_route/pg_drc.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/06_route/drc_detail/drc.matrix.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/99_eco_swap_final_ref/eco_swap_final_ref.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no012_a2_lvt_swap_dt ... ECO_SWAP_FILE=configs/backend/a2_offgrid_hvt_to_lvt_swap.tsv ECO_SWAP_DONT_TOUCH=true ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 targeted ECO swap trial with requested LVT refs preserved
Result: REJECTED
Notes: The same 52 matched instances were swapped to LVT and marked dont_touch. Final-ref audit confirms all 52 kept the requested LVT refs: 43 NOR2X4_LVT, 8 OR2X4_LVT, and 1 NOR2X0_LVT. check_routes reports 110 DRCs: Off-grid 109 and Same net spacing 1. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors. This disproves "the remaining A2 DRC is fixed by forcing those matched HVT cells to LVT". The root cause remains route/check grid or via/contact generation around OR/NOR A2 access, not simply HVT-vs-LVT cell choice.
Evidence: 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/01_init_design/eco_swap.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/06_route/pg_drc.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/99_eco_swap_final_ref/eco_swap_final_ref.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_nor2x012_hvt_restore3 ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route restore after rejected A2 LVT ECO trials
Result: RESTORED_BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Saved ICC2 block was restored to the no_or2x1_nor2x012_hvt baseline. check_routes reports 110 DRCs: Off-grid 104, Diff net spacing 5, and Short 1. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt_restore3/route_combo_no_or2x1_nor2x012_hvt_restore3.log, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore3/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore3/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore3/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore3/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no012_vialadder_center_track ... ROUTE_AUTO_VIA_LADDER_CENTER_TRACK_OFF_GRID_PMJ=true ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route access policy probe for pattern-must-join off-grid pin shapes
Result: REJECTED_AS_FIX_BUT_USEFUL_CAUSE_EVIDENCE
Notes: The option route.auto_via_ladder.generate_center_track_on_off_grid_pattern_must_join_pin_shapes was enabled. During detail route the DRC count temporarily moved as low as 109 and Off-grid as low as 101, but final check_routes is again 110 DRC: Off-grid 104, Diff net spacing 5, and Short 1. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors. This does not close DRC, but it reinforces that via ladder / pattern-must-join / pin access grid behavior is connected to the remaining A2 off-grid class.
Evidence: 7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/route_auto_via_ladder_app_options.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_nor2x012_hvt_restore4 ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route restore after rejected via-ladder center-track probe
Result: RESTORED_BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Saved ICC2 block was restored to the no_or2x1_nor2x012_hvt baseline after rejecting the via-ladder center-track probe. check_routes reports 110 DRCs: Off-grid 104, Diff net spacing 5, and Short 1. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt_restore4/route_combo_no_or2x1_nor2x012_hvt_restore4.log, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore4/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore4/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore4/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore4/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: python3 scripts/analyze_a2_lef_access_alignment.py --lef /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef --match-tsv 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/drc_to_pin_access_coordinate_match.tsv --marker-context 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_marker_context_all/marker_context.rpt --out 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/a2_lef_access_alignment.rpt
Stage: Offline A2 LEF/access alignment root-cause probe
Result: STRONGER_ROOT_CAUSE_MODEL
Notes: The 103 matched A2 DRC/access markers reduce to 52 unique A2 access points: 43 NOR2X4_HVT, 8 OR2X4_HVT, and 1 NOR2X0_HVT. For NOR2X4_HVT/A2, all observed local access X values are 0.608, exactly the maximum legal X center for default VIA1 M1 enclosure on the A2 M1 rectangle. 33 of 43 NOR2X4_HVT access points are inside the A2 M1 pin shape but enclosure-tight. NOR2 HVT drive variants and NOR2X4 LVT/RVT share the same A2 M1 geometry, explaining why targeted LVT swap did not solve the issue.
Evidence: scripts/analyze_a2_lef_access_alignment.py and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/a2_lef_access_alignment.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no012_connect_within_m1_pins ... ROUTE_COMMON_CONNECT_WITHIN_PINS_BY_LAYER='{M1 via_standard_cell_pins}' ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route access policy trial for standard-cell M1 pin-contained via connection
Result: REJECTED_AS_FIX_BUT_STRONG_CAUSE_EVIDENCE
Notes: The option route.common.connect_within_pins_by_layer_name was applied as {M1 via_standard_cell_pins}. Final check_routes reports 148 DRCs: Connection not within pin 43, Diff net spacing 38, Less than minimum area 1, Needs fat contact 26, Off-grid 31, and Short 9. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors. This is worse than the 110 baseline, so it is not a fix. However, Off-grid drops from 104 to 31 while new pin-containment DRCs appear, confirming the remaining issue is controlled by pin-contained via/access behavior around A2.
Evidence: 7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/route_common_app_options.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_nor2x012_hvt_restore5 ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route restore after rejected M1 pin-contained via trial
Result: RESTORED_BEST_CURRENT_OPEN_CAUSE_EVIDENCE
Notes: Saved ICC2 block was restored to the no_or2x1_nor2x012_hvt baseline. check_routes reports 110 DRCs: Off-grid 104, Diff net spacing 5, and Short 1. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_hvt_restore5/route_combo_no_or2x1_nor2x012_hvt_restore5.log, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore5/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore5/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore5/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore5/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: python3 scripts/select_a2_commutative_pin_swaps.py --match-tsv 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/drc_to_pin_access_coordinate_match.tsv --marker-context 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_marker_context_all/marker_context.rpt --out configs/backend/a2_edge_commutative_pin_swap.tsv
Stage: Generate targeted commutative A1/A2 ECO pin-swap list
Result: PASS
Notes: Generated 52 targeted pin swaps from matched A2 DRC/access points: NOR2X4_HVT 43, OR2X4_HVT 8, and NOR2X0_HVT 1. These refs are commutative two-input OR/NOR gates, so A1/A2 net swapping is functionally equivalent in principle. Formal equivalence has not yet been run for the ECO netlist.
Evidence: scripts/select_a2_commutative_pin_swaps.py and configs/backend/a2_edge_commutative_pin_swap.tsv.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no012_a2_pin_swap ... ECO_PIN_SWAP_FILE=configs/backend/a2_edge_commutative_pin_swap.tsv ... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 targeted commutative A1/A2 pin-swap ECO route trial
Result: CURRENT_BEST_CAUSE_CANDIDATE_NOT_CLOSED
Notes: All 52 targeted A1/A2 pin swaps were applied. Final check_routes reports 103 DRCs: Off-grid 101 and Diff net spacing 2. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors. This improves the previous 110 DRC baseline to 103 and removes the Short class. It is not backend closure, and the post-DFT ECO still needs formal equivalence strategy before signoff use.
Evidence: 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/01_init_design/eco_pin_swap.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env DRC_DETAIL_DIR=7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/drc_detail icc2_shell -batch -f 7_Backend_ICC2/0_Script/06_route/run_route_drc_detail.tcl; env DRC_REPORT=... OUT_DIR=... python3 scripts/select_drc_representatives.py; env REPORT_DIR=... MARKER_FILE=... icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_drc_marker_context.tcl
Stage: Detailed DRC decomposition for targeted A1/A2 pin-swap ECO trial
Result: PASS
Notes: Detailed matrix confirms 103 DRCs: M1 3, M2 49, VIA1 51; Off-grid 101 and Diff net spacing 2. Representative marker context still points mostly to NOR2X4_HVT, with OR2X4_HVT, FADDX2_HVT, and SDFFARX1_RVT also visible in the representative context.
Evidence: 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/drc_detail/drc.matrix.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context/representative_summary.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context/marker_context.rpt.
```

```text
Date: 2026-05-09
Command: env REPORT_DIR=7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context_all MARKER_FILE=7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context/all_drc_markers.tsv icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_drc_marker_context.tcl; python3 scripts/summarize_drc_marker_context.py --context .../marker_context.rpt --swap-file configs/backend/a2_edge_commutative_pin_swap.tsv --out .../marker_context_summary.rpt
Stage: Full remaining-marker context extraction after targeted A1/A2 pin-swap ECO
Result: PASS
Notes: The marker context utility now supports both representative TSVs with a tag column and all-marker TSVs without one. Full context for all 103 remaining markers was extracted and summarized. 95 of 103 markers are still near cells already touched by the A1/A2 pin-swap ECO. Ref distribution by marker count is NOR2X4_HVT 81, OR2X4_HVT 16, FADDX2_HVT 2, NOR2X2_HVT 2, and SDFFARX1_RVT 2. The broad marker search window often intersects A1/VDD/VSS pins, but a stricter coordinate match against report_cell_pin_access shows 97 of 103 DRC markers match Routable A2 access points within 0.08um. This corrects the first visual interpretation: the pin-swap trial mostly leaves the deterministic A2 physical access/grid issue in place, so commutative pin swap alone is not a closure fix.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no012_a2_pin_swap/marker_context_all.log, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context_all/marker_context.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context_all/marker_context_summary.rpt, and scripts/summarize_drc_marker_context.py.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no012_a2_pin_swap REPORT_DIR=7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_pin_access_after_pin_swap icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_remaining_drc_pin_access_detail.tcl; python3 scripts/match_drc_to_cell_pin_access.py --drc-markers .../all_drc_markers.tsv --marker-context .../marker_context.rpt --pin-access .../report_cell_pin_access.targets.details.rpt --out .../drc_to_pin_access_coordinate_match.tsv --summary .../drc_to_pin_access_coordinate_match.summary.rpt
Stage: Coordinate match of post-pin-swap DRC markers to report_cell_pin_access points
Result: PASS
Notes: report_cell_pin_access on 2240 target cells completed. Compact blocked summary shows 152 line-level blocked entries, dominated by SDFFARX1_RVT 136 and MUX41X1_HVT 14; NOR2X4_HVT/A1 has only 2 blocked entries. Coordinate matching is stronger than broad marker-context overlap: 97 of 103 DRC markers match a Routable A2 access point within 0.08um, and 0 match blocked access as nearest point. Matched DRCs are Off-grid VIA1 50 and Off-grid M2 47. The marker center delta clusters at X=-0.027 or -0.002 from track, while reported access X is on-track. This confirms the remaining issue is not blocked pin access and not A1 movement; it is still A2 routable-access versus route/check grid or generated VIA1/M2 geometry mismatch.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no012_a2_pin_swap/pin_access_after_pin_swap.log, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_pin_access_after_pin_swap/blocked_access.compact_summary.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_pin_access_after_pin_swap/drc_to_pin_access_coordinate_match.summary.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_pin_access_after_pin_swap/a2_access_grid_mismatch_after_pin_swap.rpt, and scripts/match_drc_to_cell_pin_access.py.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_pin_access_place_opt POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def SIGNAL_MAX_ROUTING_LAYER=M8 ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high PG_M2_HOTSPOT_BLOCKAGE_ENABLE=true PLACE_MULTI_CELL_PIN_ACCESS_CHECK=true PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS=true PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS=true PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING=true icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 no012 placement pin-access optimization probe
Result: REJECTED_AS_FIX
Notes: The pin-access placement options were applied, but ICC2 warned that pin track alignment requires place.legalize.enable_advanced_legalizer. The log reports "Pin access optimization did not move any cells." Final check_routes is unchanged from the no012 baseline at 110 DRCs: Off-grid 104, Diff net spacing 5, and Short 1. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors. This rejects ordinary placement pin-access optimization as a standalone fix.
Evidence: 7_Backend_ICC2/3_Log/trials/route_no012_pin_access_place_opt.log, 7_Backend_ICC2/4_Report/trials/route_no012_pin_access_place_opt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_pin_access_place_opt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_pin_access_place_opt/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_pin_access_place_opt/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_advlegalizer_pin_access_place_opt POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def SIGNAL_MAX_ROUTING_LAYER=M8 ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high PG_M2_HOTSPOT_BLOCKAGE_ENABLE=true PLACE_ADVANCED_LEGALIZER=true PLACE_MULTI_CELL_PIN_ACCESS_CHECK=true PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS=true PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS=true PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING=true icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 no012 advanced legalizer plus placement pin-access optimization probe
Result: REJECTED_AS_FIX
Notes: Advanced legalizer was enabled. ICC2 still warned that pin track alignment requires place.legalize.enable_pin_color_alignment_check=true. The pin access cell spreader moved 1048 cells during placement and 561 cells during a later legalizer pass, but pin access optimization moved 0 cells. Final check_routes reports 111 DRCs, all Off-grid, which is worse than the no012 110-DRC baseline and worse than the A1/A2 pin-swap 103-DRC trial. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors.
Evidence: 7_Backend_ICC2/3_Log/trials/route_no012_advlegalizer_pin_access_place_opt.log, 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_access_place_opt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_access_place_opt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_access_place_opt/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_access_place_opt/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_advlegalizer_pin_color_pin_access_place_opt POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def SIGNAL_MAX_ROUTING_LAYER=M8 ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high PG_M2_HOTSPOT_BLOCKAGE_ENABLE=true PLACE_ADVANCED_LEGALIZER=true PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK=true PLACE_MULTI_CELL_PIN_ACCESS_CHECK=true PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS=true PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS=true PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING=true icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 no012 advanced legalizer plus pin-color placement pin-access probe
Result: REJECTED_AS_FIX_BUT_INCOMPLETE_PIN_TRACK_ALIGNMENT_PROBE
Notes: place.legalize.enable_pin_color_alignment_check was enabled and check_legality reports pin_color_align 0 violations. However, ICC2 warned that place.legalize.pin_color_alignment_layers had no valid layer and disabled pin track alignment in this run. Pin access cell spreader moved 1048 cells during placement and 561 cells later, but pin access optimization moved 0 cells. Final check_routes reports 111 DRCs, all Off-grid. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors. This rejects pin-color check alone as a fix and requires one precise follow-up with PLACE_PIN_COLOR_ALIGNMENT_LAYERS such as {M1 M2}.
Evidence: 7_Backend_ICC2/3_Log/trials/route_no012_advlegalizer_pin_color_pin_access_place_opt.log, 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_color_pin_access_place_opt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_color_pin_access_place_opt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_color_pin_access_place_opt/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_color_pin_access_place_opt/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_advlegalizer_pin_color_m1m2_pin_access_place_opt POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def SIGNAL_MAX_ROUTING_LAYER=M8 ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high PG_M2_HOTSPOT_BLOCKAGE_ENABLE=true PLACE_ADVANCED_LEGALIZER=true PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK=true PLACE_PIN_COLOR_ALIGNMENT_LAYERS='{M1 M2}' PLACE_MULTI_CELL_PIN_ACCESS_CHECK=true PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS=true PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS=true PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING=true icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 no012 advanced legalizer explicit M1/M2 pin-track alignment probe
Result: REJECTED_AS_FIX_BUT_CONFIRMS_PLACEMENT_PIN_TRACK_ALIGNMENT_IS_NOT_CLOSURE
Notes: place.legalize.pin_color_alignment_layers was applied as M1 M2, and check_legality reports pin_color_align 0 violations. Pin access cell spreader moved 1100 cells during placement and 541 cells later, but pin access optimization moved 0 cells. Final check_routes reports 110 DRCs, all Off-grid. Open nets are 0, legality is 0, PG connectivity is clean, and PG DRC has no errors. This matches the no012 baseline DRC count and is worse than the 103-DRC A1/A2 pin-swap trial, so placement pin-track alignment is not the standalone closure path.
Evidence: 7_Backend_ICC2/3_Log/trials/route_no012_advlegalizer_pin_color_m1m2_pin_access_place_opt.log, 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_color_m1m2_pin_access_place_opt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_color_m1m2_pin_access_place_opt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_color_m1m2_pin_access_place_opt/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_advlegalizer_pin_color_m1m2_pin_access_place_opt/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: python3 scripts/analyze_a2_marker_shape_geometry.py --match-tsv 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/drc_to_pin_access_coordinate_match.tsv --drc-markers 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/06_route/drc_detail/all_drc_markers.tsv --out 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/a2_marker_shape_geometry.rpt
Stage: Offline A2 marker-shape geometry probe
Result: STRONGER_ROOT_CAUSE_MODEL
Notes: Joined matched A2 report_cell_pin_access points with actual check_routes marker bboxes. All 103 matched rows had marker rows. The access points are on track in X, but marker centers repeat deterministic shifts from the access point: dx=-0.027/dy=0.000 for 32 rows, dx=-0.002/dy=0.035 for 22, dx=-0.027/dy=0.035 for 20, and dx=-0.002/dy=0.000 for 17. VIA1 markers all have bbox 0.050x0.202. M2 markers split into bbox 0.110x0.212 for 31 and 0.060x0.262 for 20. This confirms the remaining A2 problem is not blocked access or missing pin-track alignment; it is generated M2/VIA1 shape snapping or route/check grid behavior from a valid A2 access point.
Evidence: scripts/analyze_a2_marker_shape_geometry.py and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/a2_marker_shape_geometry.rpt.
```

```text
Date: 2026-05-09
Command: python3 scripts/analyze_via12_contact_marker_fit.py --tech-file /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf --marker-geometry 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/a2_marker_shape_geometry.rpt --out 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/via12_contact_marker_fit.rpt
Stage: Offline VIA12 contact-code to A2 marker-geometry fit probe
Result: STRONGER_ROOT_CAUSE_MODEL
Notes: Parsed SAED32 Milkyway tech file VIA12 contact codes and fit them against the observed A2 marker bbox dimensions. The M2 marker 0.110x0.212 count 31 exactly matches VIA12SQ lower metal dimensions plus one 0.152um routing pitch. The M2 marker 0.060x0.262 count 20 exactly matches default VIA12SQ_C upper M2 dimensions plus one 0.152um routing pitch. VIA12SQ_C is default and asymmetric: upper M2 0.060x0.110, lower M1 0.110x0.060. This confirms the off-grid marker geometry is contact-code derived, strengthening the generated VIA1/M2 patch snapping or route/check grid cause model.
Evidence: scripts/analyze_via12_contact_marker_fit.py, /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/via12_contact_marker_fit.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_rotate_default_vias_false POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def SIGNAL_MAX_ROUTING_LAYER=M8 ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high PG_M2_HOTSPOT_BLOCKAGE_ENABLE=true ROUTE_COMMON_ROTATE_DEFAULT_VIAS=false icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 no012 default-via rotation policy probe
Result: REJECTED_AS_FIX_BUT_USEFUL_CAUSE_EVIDENCE
Notes: route.common.rotate_default_vias=false was applied. Clock route reached 0 DRC, but final signal route worsened to 310 DRCs versus the no012 110-DRC baseline and the A1/A2 pin-swap 103-DRC candidate. Final check_routes reports open nets 0 and DRC mix: Off-grid 242, Short 57, Diff net spacing 7, Less than minimum width 2, Same net spacing 2. Legality is 0, PG connectivity is clean, and PG DRC has no errors. This rejects simply disabling default-via rotation. It also shows the issue is not just rotated VIA12 usage; via/contact generation policy strongly affects the failure mode.
Evidence: 7_Backend_ICC2/3_Log/trials/route_no012_rotate_default_vias_false.log, 7_Backend_ICC2/4_Report/trials/route_no012_rotate_default_vias_false/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_rotate_default_vias_false/06_route/route_common_app_options.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_rotate_default_vias_false/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_rotate_default_vias_false/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_rotate_default_vias_false/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: dc_shell -topographical_mode -f 2_Synthesis/0_Script/run_compile_10ns_topo_no_or2x1_nor2x012_or2x4_hvt.tcl; fm_shell -file 2.5_FM_R2N/0_Script/run_fm_r2n_topo_no_or2x1_nor2x012_or2x4_hvt.tcl; dc_shell -topographical_mode -f 3_DFT/0_Script/run_insert_dft_10ns_topo_no_or2x1_nor2x012_or2x4_hvt.tcl; fm_shell -file 5_FM_N2N/0_Script/run_fm_n2n_topo_no_or2x1_nor2x012_or2x4_hvt.tcl; pt_shell -f 6_STA/0_Script/run_pt_post_dft_10ns_sdf_no_or2x1_nor2x012_or2x4_hvt.tcl
Stage: Front-end validation for narrow OR2X4_HVT add-on dont_use probe
Result: PASS_FE_ONLY
Notes: This trial keeps the accepted no012 avoidance list and adds only OR2X4_HVT. The purpose is narrower than the rejected broad NOR2X4_HVT ban: test whether removing the smaller repeated OR2X4_HVT/A2 contributor helps without forcing large NOR2 restructuring. DC topo generated pre-DFT DDC/VG/SDC/SDF. R2N Formality passed with 2243 passing and 0 failing compare points. DFT generated post-DFT DDC/VG/SDC/SDF/SPF/scan DEF. N2N Formality passed with 2243 passing and 0 failing compare points. PrimeTime read the post-DFT SDF with 0 errors, and global timing reports no setup or hold violations. PT constraint report still has physical max-cap/max-transition style violations, consistent with existing backend-deferred cleanup policy.
Evidence: 2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_nor2x012_or2x4_hvt.log, 2.5_FM_R2N/4_Report/no_or2x1_nor2x012_or2x4_hvt/r2n_topo_no_or2x1_nor2x012_or2x4_hvt.passing_points.post_verify.rpt, 5_FM_N2N/4_Report/no_or2x1_nor2x012_or2x4_hvt/n2n_topo_no_or2x1_nor2x012_or2x4_hvt.passing_points.post_verify.rpt, and 6_STA/4_Report/post_dft_topo_sdf_no_or2x1_nor2x012_or2x4_hvt/post_dft_no_or2x1_nor2x012_or2x4_hvt.func_tt_10ns_sdf.global_timing.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_combo_no_or2x1_nor2x012_or2x4_hvt POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_or2x4_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_or2x4_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_or2x4_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_or2x4_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_or2x4_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_or2x4_hvt.scan.def CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 route trial for narrow OR2X4_HVT add-on dont_use handoff
Result: REJECTED_AS_FIX
Notes: Route completes with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Final check_routes reports 111 DRCs: Off-grid 104, Diff net spacing 5, Same net spacing 1, and Short 1. This is slightly worse than the no_or2x1_nor2x012_hvt baseline at 110 DRC and worse than the A1/A2 pin-swap candidate at 103 DRC. OR2X4_HVT-only add-on avoidance is therefore not a backend closure fix. ZRT-044 for MUX41X2_HVT/S0 remains.
Evidence: 7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_nor2x012_or2x4_hvt.log, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_or2x4_hvt/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_or2x4_hvt/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_or2x4_hvt/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_or2x4_hvt/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: python3 scripts/analyze_lef_pin_via_windows.py --tech-file /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf --lef hvt=/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef --lef rvt=/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef --lef lvt=/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/lef/saed32nm_lvt_1p9m.lef --target hvt:NOR2X4_HVT/A2 --target hvt:OR2X4_HVT/A2 --target hvt:NOR2X0_HVT/A2 --target hvt:NOR2X1_HVT/A2 --target hvt:NOR2X2_HVT/A2 --target hvt:OR2X1_HVT/A1 --target hvt:MUX41X2_HVT/S0 --target hvt:RDFFNSRX1_HVT/CLK --target rvt:NOR2X4_RVT/A2 --target lvt:NOR2X4_LVT/A2 --out 7_Backend_ICC2/4_Report/trials/ndm_pin_via_setup_probe/99_static/lef_pin_via_windows.rpt
Stage: Offline LEF pin via-window probe
Result: STRONGER_ROOT_CAUSE_MODEL
Notes: Parsed SAED32 Milkyway tech VIA12SQ_C and selected HVT/LVT LEF pins. MUX41X2_HVT/S0 and RDFFNSRX1_HVT/CLK have no legal M1 center window for the default VIA12SQ_C lower M1 enclosure, matching the create_pin_check_lib PDC-001 blocked-access class. NOR2X0/1/2/4_HVT A2 pins do have legal VIA1 track centers, so the remaining A2 off-grid issue is not pure pin-metal insufficiency. NOR2X4_HVT/A2 has legal X max 0.608, matching the previous observed local access X=0.608 edge condition. OR2X4_HVT/A2 and OR2X1_HVT/A1 have legal geometry windows but no default M1 track center inside those windows, supporting a track/access snapping mismatch class.
Evidence: scripts/analyze_lef_pin_via_windows.py and 7_Backend_ICC2/4_Report/trials/ndm_pin_via_setup_probe/99_static/lef_pin_via_windows.rpt.
```

```text
Date: 2026-05-09
Command: python3 scripts/classify_drc_by_lef_via_window.py --match-tsv 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/drc_to_pin_access_coordinate_match.tsv --marker-context 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_marker_context_all/marker_context.rpt --tech-file /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf --hvt-lef /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef --out 7_Backend_ICC2/4_Report/trials/ndm_pin_via_setup_probe/99_static/no012_drc_via_window_classification.rpt --detail-out 7_Backend_ICC2/4_Report/trials/ndm_pin_via_setup_probe/99_static/no012_drc_via_window_classification.tsv
Stage: Offline no012 DRC via-window class quantification
Result: STRONGER_ROOT_CAUSE_MODEL
Notes: Joined the 103 matched no012 DRC-to-pin-access rows with marker context ref names and LEF via-window classification. There are 52 unique access points and no missing inputs. 87/103 marker rows are or_nor_a2_legal_track_edge_snapping, mainly NOR2X4_HVT/A2 85 rows plus NOR2X0_HVT/A2 2 rows. 16/103 marker rows are legal_window_no_default_track_center, all OR2X4_HVT/A2. No matched no012 row belongs to the true no-window blocked-access class. This explains why OR2X4_HVT-only dont_use did not close route DRC: it targeted the 16-row minority class and left the dominant NOR2X4_HVT/A2 edge-snapping class.
Evidence: scripts/classify_drc_by_lef_via_window.py, 7_Backend_ICC2/4_Report/trials/ndm_pin_via_setup_probe/99_static/no012_drc_via_window_classification.rpt, and 7_Backend_ICC2/4_Report/trials/ndm_pin_via_setup_probe/99_static/no012_drc_via_window_classification.tsv.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_nor2x4_to_nor2x2_eco POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high ECO_SWAP_FILE=configs/backend/a2_edge_nor2x4_to_nor2x2_hvt_resize.tsv ECO_SWAP_DONT_TOUCH=true icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 targeted NOR2X4_HVT/A2 edge resize ECO route trial
Result: BEST_BACKEND_ECO_CANDIDATE_BUT_NOT_CLOSED
Notes: The trial resized 43 targeted NOR2X4_HVT instances to NOR2X2_HVT and marked them dont_touch. All 43 size_cell operations passed. Official check_routes reports open nets 0 and 67 total DRCs: Off-grid 59, Diff net spacing 4, and Short 4. Legality is 0, PG connectivity is clean, and PG DRC has no errors. This improves the no012 baseline from 110 DRC and the A1/A2 pin-swap candidate from 103 DRC, making NOR2X4_HVT/A2 edge access the strongest current root-cause/fix lever. This is backend ECO evidence only; it is not yet FE/FM-signed closure.
Evidence: configs/backend/a2_edge_nor2x4_to_nor2x2_hvt_resize.tsv, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/01_init_design/eco_swap.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env DRC_DETAIL_DIR=7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/drc_detail icc2_shell -batch -f 7_Backend_ICC2/0_Script/06_route/run_route_drc_detail.tcl
Stage: ICC2 DRC detail extraction for targeted NOR2X4_HVT/A2 edge resize ECO
Result: PASS_EXTRACTION
Notes: Detailed DRC matrix confirms 67 route DRCs. By type/layer: Diff net spacing M1 3 and M2 1; Off-grid M1 4, M2 1, and VIA1 54; Short M1 4. Totals by layer are M1 11, M2 2, and VIA1 54. Remaining DRC is still dominated by VIA1 off-grid, so backend is not closed.
Evidence: 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/drc_detail/drc.matrix.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/drc_detail/drc.by_type.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/drc_detail/drc.by_layer.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/drc_detail/check_routes.detail_source.rpt.
```

```text
Date: 2026-05-09
Command: DRC_REPORT=7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/06_route/drc_detail/drc.detailed.rpt OUT_DIR=7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_marker_context python3 scripts/select_drc_representatives.py; env TRIAL_NAME=route_no012_nor2x4_to_nor2x2_eco REPORT_DIR=7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_marker_context_all MARKER_FILE=7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_marker_context/all_drc_markers.tsv icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_drc_marker_context.tcl; env TRIAL_NAME=route_no012_nor2x4_to_nor2x2_eco REPORT_DIR=7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_remaining_drc_pin_access_detail.tcl; python3 scripts/match_drc_to_cell_pin_access.py ...; python3 scripts/classify_drc_by_lef_via_window.py ...
Stage: Remaining DRC classification after targeted NOR2X4_HVT/A2 resize ECO
Result: ROOT_CAUSE_REFINED
Notes: The 67 remaining DRC markers were converted to marker TSV, all-marker ICC2 context was extracted, and pin-access coordinate matching was rerun. Marker context sees 43 markers near resized NOR2X2_HVT cells, but coordinate matching is sharper: 55/67 markers match Routable A2 access points within 0.08um and 12 remain unmatched. LEF via-window classification of the 55 matched rows gives 45 OR/NOR A2 legal-track edge-snapping rows and 10 legal-window/no-default-track-center rows. By ref/pin, the remaining matched rows are 43 NOR2X2_HVT/A2, 10 OR2X4_HVT/A2, and 2 NOR2X4_HVT/A2. The resize ECO reduced DRC but did not remove the underlying A2 route/check-grid class.
Evidence: 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_marker_context/representative_summary.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_marker_context_all/marker_context_summary.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access/drc_to_pin_access_coordinate_match.summary.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access/remaining_drc_via_window_classification.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_nor2x4_to_nor2x2_plus_or2x4_to_or2x2_eco POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high ECO_SWAP_FILE=configs/backend/a2_edge_nor2x4_nor2x2_plus_or2x4_or2x2_hvt_resize.tsv ECO_SWAP_DONT_TOUCH=true icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 targeted NOR2X4 plus OR2X4 A2 resize ECO route trial
Result: REJECTED_AS_FIX
Notes: The trial combined the current 43-cell NOR2X4_HVT->NOR2X2_HVT resize with 9 targeted OR2X4_HVT->OR2X2_HVT resizes. All 52 size_cell operations passed and were kept dont_touch. Official check_routes reports open nets 0 and 97 total DRCs: Off-grid 89, Diff net spacing 4, Needs fat contact 1, and Short 3. Legality is 0, PG connectivity is clean, and PG DRC has no errors. This is worse than the NOR2-only resize candidate at 67 DRC. Therefore the OR2X4_HVT/A2 track-center mismatch is not solved by simple targeted OR2X4->OR2X2 downsizing.
Evidence: configs/backend/a2_edge_nor2x4_nor2x2_plus_or2x4_or2x2_hvt_resize.tsv, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_plus_or2x4_to_or2x2_eco/01_init_design/eco_swap.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_plus_or2x4_to_or2x2_eco/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_plus_or2x4_to_or2x2_eco/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_plus_or2x4_to_or2x2_eco/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_plus_or2x4_to_or2x2_eco/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_nor2x4_to_nor2x1_eco POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high ECO_SWAP_FILE=configs/backend/a2_edge_nor2x4_to_nor2x1_hvt_resize.tsv ECO_SWAP_DONT_TOUCH=true icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 targeted NOR2X4_HVT/A2 resize-to-X1 ECO route trial
Result: REJECTED_AS_FIX
Notes: The trial resized the same 43 matched NOR2X4_HVT/A2 cells directly to NOR2X1_HVT and marked them dont_touch. All 43 size_cell operations passed. Official check_routes reports open nets 0 and 109 total DRCs: Off-grid 106, Diff net spacing 2, and Short 1. Legality is 0, PG connectivity is clean, and PG DRC has no errors. This is much worse than the NOR2X4->NOR2X2 candidate at 67 DRC and similar to the no012 baseline at 110 DRC. Therefore smaller NOR2 drive is not monotonically better; X2 remains the best tested targeted NOR2 resize.
Evidence: configs/backend/a2_edge_nor2x4_to_nor2x1_hvt_resize.tsv, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x1_eco/01_init_design/eco_swap.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x1_eco/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x1_eco/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x1_eco/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x1_eco/06_route/pg_drc.rpt.
```

```text
Date: 2026-05-09
Command: python3 scripts/summarize_unmatched_drc_markers.py --drc-markers 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_marker_context/all_drc_markers.tsv --matched 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access/drc_to_pin_access_coordinate_match.tsv --marker-context 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_marker_context_all/marker_context.rpt --out 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access/unmatched_drc_marker_summary.rpt --tsv 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access/unmatched_drc_marker_summary.tsv
Stage: Post-ECO unmatched DRC marker classification
Result: ROOT_CAUSE_REFINED
Notes: In the 67-DRC best ECO candidate, 55 markers match nearby A2 pin-access points and 12 markers remain unmatched. The unmatched set is 4 Short, 4 Diff net spacing, and 4 Off-grid; 11 are on M1 and 1 is on M2. Marker context shows mostly SDFFARX1_RVT/SDFFASX1_RVT RSTB/VSS/Q/QN local interactions. This separates the residual issue into dominant A2 grid/contact markers plus a smaller flop/local-M1 class.
Evidence: scripts/summarize_unmatched_drc_markers.py, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access/unmatched_drc_marker_summary.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco/99_pin_access/unmatched_drc_marker_summary.tsv.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_nor2x4_to_nor2x2_connect_m1pin POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high ROUTE_COMMON_CONNECT_WITHIN_PINS_BY_LAYER='{M1 via_standard_cell_pins}' ECO_SWAP_FILE=configs/backend/a2_edge_nor2x4_to_nor2x2_hvt_resize.tsv ECO_SWAP_DONT_TOUCH=true icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 NOR2 resize ECO plus M1 connect-within-pin route trial
Result: REJECTED_AS_FIX
Notes: The trial kept the current 43-cell NOR2X4_HVT->NOR2X2_HVT ECO and added route.common.connect_within_pins_by_layer_name={M1 via_standard_cell_pins}. Official check_routes reports open nets 0 and 109 total DRCs. Legality is 0, PG connectivity is clean, and PG DRC has no errors. The option reduces Off-grid from 59 to 15 but introduces 45 Needs-fat-contact and 21 Connection-not-within-pin markers, so total DRC worsens from 67 to 109. This is useful cause evidence but not a closure fix.
Evidence: 7_Backend_ICC2/3_Log/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin.log, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/pg_connectivity.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/pg_drc.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_connect_m1pin/06_route/drc_detail/drc.matrix.rpt.
```

```text
Date: 2026-05-09
Command: env TRIAL_NAME=route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin POST_DFT_NETLIST=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg POST_DFT_SDC=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.sdc SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.scan.def CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high ECO_SWAP_FILE=configs/backend/a2_edge_nor2x4_to_nor2x2_hvt_resize.tsv ECO_SWAP_DONT_TOUCH=true icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
Stage: ICC2 restore to NOR2 resize ECO current-best state after rejected connect-within-pin trial
Result: RESTORED_CURRENT_BEST
Notes: The saved ICC2 block was restored by rerunning the NOR2X4_HVT->NOR2X2_HVT ECO without the rejected M1 connect-within-pin option. Official check_routes reports open nets 0 and 67 route DRCs: Off-grid 59, Diff net spacing 4, and Short 4. Legality is 0, PG connectivity is clean, and PG DRC has no errors. The detail-route log reached 66 DRC internally, but the official final check_routes result is 67, so 66 is not the accepted count. Current best remains the NOR2 resize ECO at official 67 DRC.
Evidence: 7_Backend_ICC2/3_Log/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin.log, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin/06_route/check_routes.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin/06_route/check_legality.rpt, 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin/06_route/pg_connectivity.rpt, and 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_restore_after_connect_m1pin/06_route/pg_drc.rpt.
```
