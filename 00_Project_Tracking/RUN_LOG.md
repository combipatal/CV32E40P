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
