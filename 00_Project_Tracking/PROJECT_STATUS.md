# Project Status

## Current Phase

```text
Front-End baseline completed; 8.5 ns front-end closure trial completed; ICC2 backend init/floorplan/place/power/CTS/route first pass completed
Route DRC diagnosis, 60%/M8 trials, lower-metal DRC detail breakdown, detail-route repair trials, PG top-port cleanup, off-track pin object diagnosis, CO/VIA contact diagnosis, Milkyway reference open trial, pin-access/M1-track probe, M1 retrack route trial, create_pin_check_lib trial, blocked-access detail extraction, pin-access/DRC overlap parse, placement spreading trial, scan DEF handoff trial, advanced legalizer/pin-color trial, DRC marker context probe, hotspot partial blockage probe, route DRC root-cause hypothesis write-up, hotspot DRC-to-PG distance probe, PG M2 offset probe, PG blockage trials, route grid option probes, and current-best DRC geometry residue analysis completed; root cause narrowed but route DRC not closed
```

## Next Milestone

```text
Use 8.5 ns front-end closure as the time-limited portfolio finish point unless the user explicitly asks for an 8.0 ns stretch run or backend continuation.
```

## Frozen Baseline

```text
Run: tt_mvt_10ns_scan1
Commit: 5473b61
Status: Front-End baseline complete
Meaning: 10 ns topo synthesis, R2N, DFT topo, N2N, post-DFT SDF STA, and stuck-at ATPG are reproducible from scripts.
Not included: production signoff, post-route STA, IR/EM, GDS signoff.
```

## Current Front-End Best

```text
Run: tt_mvt_8p5ns_scan1
Status: Front-End timing closure trial complete
Meaning: clean baseline mixed-VT 8.5 ns topo synthesis, R2N, DFT topo, N2N, post-DFT SDF STA, and stuck-at ATPG completed.
PT post-DFT SDF STA: setup/hold clean, WNS 0.44 ns, hold slack 0.04 ns, SDF read errors 0.
ATPG: 98.40% test coverage, 98.31% fault coverage, 416 patterns.
Not included: production signoff, post-route STA, IR/EM, GDS signoff.
```

## Milestone Checklist

```text
[x] Clone CV32E40P
[x] Record source revision
[x] Create wrapper RTL
[x] Create technology clock gate RTL
[x] Create DC/FM filelists
[x] Create 10 ns SDC
[x] DC Graphical topo analyze/elaborate/link/compile
[x] Formality R2N
[x] DFT insertion
[x] Formality N2N
[x] TetraMAX stuck-at ATPG
[x] PrimeTime STA
[x] Portfolio summary tables
[x] 8.5 ns front-end closure trial
```

## Current Notes

```text
DFT is topographical and writes post-DFT DDC/VG/SDC/SDF/SPF.
SPF is written after insert_dft so TetraMAX sees chain0 length 2130.
TetraMAX stuck-at ATPG reached 98.64% test coverage and 98.55% fault coverage.
Remaining notes: DC DFT TEST-505 constant-1 clock gate, TetraMAX Z3 wire contention warnings, and physical max_cap/max_transition cleanup deferred to backend.
Active synthesis script is only 2_Synthesis/0_Script/run_compile_10ns_topo.tcl.
8.5 ns clean baseline scripts now exist under *_8p5ns_topo.tcl and constraints/cv32e40p_func_8p5ns.sdc. They do not use backend DRC workaround dont_use lists.
8.5 ns front-end closure trial passed with notes: DC pre-DFT WNS 0.41 ns, DFT post-DFT WNS 0.44 ns, PT post-DFT SDF setup slack 0.44 ns, PT hold slack 0.04 ns, R2N/N2N 2243 passing and 0 failing, ATPG 98.40% test coverage and 98.31% fault coverage.
Backend DRC workaround dont_use variant scripts are retained as experiment evidence only. They are not the active front-end finish path.
ICC2 can open/link/save the post-DFT netlist as a physical design library.
Initial ICC2 floorplan exists: rectangular core, 65.40% utilization, 382 pins created.
ICC2 placement exists: 14083 cells legalized with 0 legality violations after PG closure refresh.
ICC2 power plan exists: PG DRC clean, VDD connectivity clean, and VSS connectivity clean.
ICC2 CTS first pass exists: clock_opt completed through route_clock, clock DRC count 0, legality 0 violations, listed setup/hold timing paths MET.
Scan DEF handoff is now available from DFT and was imported by ICC2 in the scan_def_m8 trial.
CTS open items: no default max_transition constraint warning, whole-design electrical DRC remains in post-CTS qor.rpt (1 max_transition and 172 max_cap), and CTS log auto-reported target skew 1.500000 while script option report shows 0.20 ns.
ICC2 route first pass exists: route_auto completed, open nets 0, timing listed paths MET, legality 0 violations, PG DRC clean, and PG connectivity all floating counts 0.
Route open item: check_routes reports 408 DRCs, so extraction/STA should wait until route DRC cleanup.
60% utilization route trial was run. It reports route-stage utilization 0.7324 and check_routes 407 DRCs, almost identical to the 65% baseline 408 DRCs.
60% utilization plus explicit M1-M8 signal route layer trial was run. It reports route-stage utilization 0.7324, check_routes 400 DRCs, and 0 open nets.
Detailed DRC matrix shows all 400 remaining route DRCs are on M1, M2, M1-M2, or VIA1.
Detail route repair was tested. 200 max iterations ended at 398 DRCs. 1 max iteration ended at 383 DRCs, the best count so far, but M1 diff-net spacing grew to 224.
PG top-port cleanup was tested. Accepted fix adds non-overlapping M8 terminals to VDD/VSS at y=3..5um on the PG ring. VDD/VSS no-pin/unplaced warnings are removed and PG remains clean.
Off-track M1 pin object diagnosis was run. The 8 remaining off-track warnings map to stdcell pins: SDFFARX1_RVT/QN, INVX8_LVT/A, and MUX41X1_HVT/S1.
CO/VIA contact diagnosis was run. CO has no default contact, which explains ZRT-022, but VIA1 has default M1-M2 via VIA12SQ_C, so M1-M2 via setup is present.
Milkyway reference open trial was run. Direct Milkyway reference conversion is blocked in this environment because IC Compiler 1 icc_shell is unavailable and Milkyway/MDataPrep license features are unavailable.
Pin access / M1 track probe was run. check_libcell_pin_access needs a create_pin_check_lib-style library and cannot run directly on the current design library. report_cell_pin_access shows the 8 flagged cells have 0 blocked access pins, but the same ref-cell population has 117 blocked access pins.
Manual M1 track recreation was rejected. It can remove visible off-track warnings in an already routed block probe, but after signal-route removal the warning returns and full route explodes to 27260 DRCs, dominated by 24981 illegal-track-route markers.
Formal create_pin_check_lib flow was tested. create_pin_check_lib succeeds for mixed RVT/LVT/HVT and each VT library. check_libcell_pin_access analyze_lib_cell succeeds after setting pin_check.place.preplace_option_file. analyze_lib_pin remains blocked by LIB-001.
Blocked access detail extraction was run. ICC2 official summary remains 117 pins with blocked access. Parsed detail has 125 line-level blocked entries: 116 SDFFARX1_RVT, 9 MUX41X1_HVT, and 0 INVX8_LVT.
Pin access / route DRC overlap was parsed. 289 of 305 blocked access points have a route DRC marker within 50um, and 193 are within 25um. They are related by physical region, but not always exact same-coordinate failures.
Placement spreading trial was run and rejected. It reduced route DRC only from 400 to 390 while blocked access worsened from 117 to 144 official blocked pins.
Scan DEF handoff trial was run. ICC2 read SCANCHAINS and scan-aware DFT optimization validated 1 scan chain; route DRC improved only from 400 to 398.
Advanced legalizer and pin color alignment trials were run and rejected. They keep open nets 0, legality 0, and PG clean, but final route DRC is 605.
DRC marker context probe was run after restoring the simpler scan_def_m8 route state. Hotspots are concentrated around x=220..260um and y=200..260um, and representative markers show OR2X1_HVT/NOR2X0_HVT/SDFFARX1_RVT/NBUFFX8_HVT local pin/route interactions plus some nearby VDD/VSS PG shapes.
Hotspot partial blockage probe was run. It changed only the hotspot placement density and reduced route DRC from 398 to 390, so hotspot density alone is not the root cause.
Root-cause investigation is now the active mode. Hotspot window {{215 195} {265 265}} contains 123 DRC markers, dominated by M2/VIA1 off-grid markers. Current leading hypotheses are stdcell pin access + M2/VIA1 off-grid interaction, possible M2 PG mesh interference, LEF-built NDM/pin-check quality, and route off-grid/via policy.
Hotspot DRC-to-PG distance probe shows 78 of 123 hotspot markers are within 5um of M2 PG shapes, but 45 are farther than 5um. PG M2 offset 30um changes signal DRC from 398 to 377, proving PG position affects routing, but it creates 97 PG DRC errors and is invalid as a fix.
After the invalid PG M2 offset probe, the saved ICC2 block was restored to the PG-clean scan_def_m8_restore baseline: route open nets 0, check_routes 398 DRCs, and route-stage check_pg_drc No errors found.
Route option probes were run. generate_extra_off_grid_pin_tracks=true gives 385 DRCs; high drc_convergence/optimize_wire_via effort gives 389 DRCs. Both keep open nets 0 and PG clean, but neither removes the M2/VIA1 off-grid class.
Baseline and route option probe logs all repeat ZRT-044 for MUX41X2_HVT/S0 no valid via regions, so stdcell valid-via-region / pin-access data is now the strongest next cause target.
MUX41X2_HVT/S0 pin-access cause was confirmed. SAED32 HVT LEF gives S0 only one M1 stripe of height 0.050um, while default VIA12SQ_C needs cut plus M1 enclosure. create_pin_check_lib reports PDC-001 no via regions for the same pin. This is a confirmed library pin-access weakness, but not the only cause of all 398 route DRCs.
SDFFARX1_RVT hotspot overlap was checked with coordinate-consistent current-block evidence. SDFFARX1_RVT has many blocked access points overall, but only 11 inside the hotspot. Those 11 all map to hotspot Needs-fat-contact DRCs, and ICC2 context shows each is near the x=259.8..260.2 M2 VSS PG stripe. SDFFARX1_RVT is therefore a hotspot contributor, not the sole root cause.
Conclusion: lower floorplan utilization, M8 bound, blind detail-route looping, M1 track recreation, generic placement spreading, scan DEF handoff alone, hotspot partial blockage alone, and advanced legalizer/pin-color alignment do not identify or close the root cause. Do not continue manual cell moves or blind repair trials before the next cause probe.
Updated root-cause view: PG M2 mesh is a contributing obstruction, and the strongest local model is x=260um M2 VSS PG stripe + stdcell pin access + M2/VIA1 contact legality. Next cause probe should isolate all DRC markers near the x=259.8..260.2 PG stripe and list the nearby ref-cell distribution.
Backend fix trials were run. PG M2 offset 24/26/28um was rejected because each creates PG M1 spacing DRC. Hotspot 40% partial blockage is legal and PG-clean but only reaches 391 route DRC. The current best valid route is route_combo_scan_def_m8: open nets 0, legality 0, PG DRC clean, and check_routes 381 DRCs. Backend-only knobs still do not close route DRC.
Next accepted baseline candidate: keep PG_M2_MESH_OFFSET=20.0, scan DEF input, M8 signal max layer, and route detail options generate_extra_off_grid_pin_tracks=true, drc_convergence_effort_level=high, optimize_wire_via_effort_level=high.
Next fix class: front-end/library-driven cell selection cleanup, starting with MUX41X2_HVT avoidance feasibility and SDFFARX1_RVT alternative/pin-access treatment.
MUX41X*_HVT avoidance feasibility was tested. Front-end passed, but backend route DRC worsened from the current best 381 to 399, so no_mux41x_hvt is rejected as a backend fix.
Local PG M2 cut trial was run. Cutting only the hotspot portion of the x=259.8..260.2um VSS M2 stripe keeps open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Route DRC improves from 381 to 377.
Current best valid backend candidate is route_combo_pgcut_vss260: open nets 0, legality 0, PG DRC clean, route DRC 377. Treat this as cause evidence, not final PG signoff style.
All-M2 hotspot cut trial was run. Cutting x=220 VSS, x=240 VDD, and x=260 VSS hotspot M2 segments keeps open nets 0, legality 0, PG connectivity clean, and PG DRC clean, but route DRC is 378. It improves diff-net spacing but worsens M1-M2 needs-fat-contact, confirming a PG obstruction vs via/contact trade-off.
x=240 VDD individual PG cut trial was run. It keeps open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Route DRC improves to 376, so the current best valid backend candidate is route_combo_pgcut_vdd240.
x=220 VSS individual PG cut trial was run and rejected as best. It keeps open nets 0, legality 0, PG connectivity clean, and PG DRC clean, but route DRC is 380. It reduces spacing DRC while increasing fat-contact and short DRC.
Saved ICC2 block was restored to the x=240 VDD best candidate as route_combo_pgcut_vdd240_restore. Evidence remains route DRC 376, open nets 0, legality 0, PG connectivity clean, and PG DRC clean.
Clean PG blockage trial support was added to the route trial script. The first intended trial is route_combo_pgblock_vdd240, replacing manual cut with set_pg_strategy -blockage for VDD/M2 in the hotspot.
route_combo_pgblock_vdd240 completed. It replaces the manual x=240 VDD cut with set_pg_strategy -blockage on VDD/M2 in hotspot_pg_m2_blockage. It keeps open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean. Route DRC improves to 368, making it the current best valid backend candidate.
route_combo_pgblock_vdd240 DRC detail was extracted. The remaining DRC matrix is M1 92, M1-M2 120, M2 77, VIA1 79. Top 20um buckets remain around x=220..260/y=200..260.
route_combo_pgblock_vdd240_vss260 was tested and rejected as best. It keeps open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but route DRC is 376. Blocking x=260 VSS as well reduces needs-fat-contact 120 -> 104 but worsens M1 diff spacing, M2/VIA1 off-grid, and creates 2 shorts. Current best remains route_combo_pgblock_vdd240 at 368 DRC.
route_pgblock_vdd240_pincheck was tested and rejected as best. It adds only place.legalize.enable_multi_cell_pin_access_check=true on top of the VDD/M2 PG blockage flow. It keeps open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but route DRC remains 368 with the same lower-metal matrix as route_combo_pgblock_vdd240.
route_pgblock_vdd240_offtrackvia was tested and rejected as best. It adds only place.legalize.support_off_track_via_region=true on top of the VDD/M2 PG blockage flow. It keeps open nets 0, legality 0, route-stage PG connectivity clean, and PG DRC clean, but route DRC remains 368 with the same lower-metal matrix as route_combo_pgblock_vdd240.
Route grid/via option probes were run. The correct shell environment value form for list pair options is single-brace Tcl list text such as '{M2 0.5}'. Double-brace text from the shell is invalid. The M2 off-grid via cost 0.5 trial applied correctly but route DRC remained 368 with the same lower-metal matrix.
Explicit VIA1 on-grid routing was tested and rejected. It applied correctly but route DRC remained 368 and ZRT-044 for MUX41X2_HVT/S0 stayed present.
Explicit M2 wire-on-grid routing was tested and rejected. It applied correctly and kept open nets 0, legality 0, and PG clean, but route DRC worsened to 378. The DRC mix changed, so grid policy affects the problem but is not a direct fix.
Explicit M1 wire-on-grid routing was tested and rejected. It applied correctly and kept open nets 0, legality 0, and PG clean, but route DRC worsened to 380. Needs-fat-contact improved, but diff-net spacing and off-grid worsened.
The saved ICC2 block was restored to the current best VDD/M2 PG strategy blockage candidate: route DRC 368, open nets 0, legality 0, PG connectivity clean, and PG DRC clean.
Current-best geometry residue analysis was run on route_combo_pgblock_vdd240. M1-M2 needs-fat-contact is 120/120 at the same 0.152um residue rx=0.064/ry=0.064. M2 and VIA1 off-grid markers also cluster around rx=0.061..0.066/ry=0.064. This is strong evidence for a deterministic lower-metal pin/contact/grid mismatch, not random congestion.
Current-best representative marker context was extracted in ICC2. OR2X1_HVT dominates M1 spacing and M1-M2 needs-fat-contact representative markers. NOR2X0_HVT/NOR2X4_HVT dominate M2/VIA1 off-grid representative markers. SDFFARX1_RVT remains a contributor but is not the main representative pattern.
PG remains a contributing obstruction, but not the only root cause: 246 of 368 markers are more than 5um from the assumed hotspot M2 PG stripe centers, while the x=240 VDD/M2 blockage still improves DRC to 368 and remains the best valid candidate.
Next backend investigation should not blindly ban more cells or broaden PG blockages. It should target OR2X1_HVT and NOR2X*_HVT pin/contact/grid behavior first, then decide whether the next fix is NDM/tech/pin-access setup, targeted cell avoidance, or a controlled PG/routing-grid adjustment.
Extraction and post-route STA are still pending.
OR2X1_HVT targeted avoidance was tested through FE and backend. DC topo, R2N, DFT, N2N, and PT post-DFT SDF STA passed. ICC2 route with the same current-best physical options improved route DRC from 368 to 203, with open nets 0, legality 0, PG connectivity clean, and PG DRC clean.
The remaining 203 route DRCs are all Off-grid. ZRT-044 for MUX41X2_HVT/S0 remains. Current cause view: OR2X1_HVT was a major spacing/fat-contact contributor, but the remaining root cause is now narrowed to off-grid pin/via/grid behavior in the remaining HVT-sensitive cell set, likely MUX41X2_HVT and NOR2X*_HVT plus generated NDM/VIA1 behavior.
Current best valid backend candidate is route_combo_no_or2x1_hvt for cause evidence only: route DRC 203, open nets 0, legality 0, PG clean. Backend is still not closed.
OR2X1_HVT + NOR2X0_HVT + NOR2X2_HVT targeted avoidance was tested through FE and backend. DC topo, R2N, DFT, N2N, and PT post-DFT SDF STA passed. ICC2 route improved route DRC from 203 to 188, with open nets 0, legality 0, PG connectivity clean, and PG DRC clean.
The remaining 188 route DRCs are dominated by Off-grid 186, mainly M2 88 and VIA1 91. Representative marker context then pointed mostly to NOR2X1_HVT, while ZRT-044 for MUX41X2_HVT/S0 remained.
OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT targeted avoidance was tested through FE and backend. DC topo, R2N, DFT, N2N, and PT post-DFT SDF STA passed. ICC2 route improved route DRC from 188 to 110, with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. NOR2X1_HVT is confirmed as a major lower-metal off-grid contributor.
The 110-DRC matrix is M1 5, M2 53, VIA1 52. Remaining representative context is dominated by NOR2X4_HVT and SDFFARX1_RVT, and ZRT-044 for MUX41X2_HVT/S0 remains.
Adding NOR2X4_HVT to the avoid list was tested and rejected. FE passed, but ICC2 route DRC worsened from 110 to 481. Off-grid rose to 477, with M2 232 and VIA1 245. NOR2X4_HVT is therefore context/correlation, not a valid broad dont_use fix. Backend is still not closed.
Remaining 110-DRC root cause is now narrowed further. Full marker context plus coordinate matching shows 103 of 110 markers align with HVT OR/NOR A2 routable access points within 0.08um: NOR2X4_HVT/A2 85, OR2X4_HVT/A2 16, and NOR2X0_HVT/A2 2. This points to HVT OR/NOR A2 route/check grid or contact/via generation mismatch, not simple blocked pin access and not a reason to abandon MVT.
The no012 route trial with route.detail.generate_extra_off_grid_pin_tracks=false was rejected. Final check_routes is 113 DRC, worse than the 110 baseline. The option changes the mix only slightly and does not remove the A2 off-grid class.
Targeted A2 LVT ECO swap was tested. Without dont_touch, all 52 requested LVT swaps were changed by optimization and check_routes was 109 DRC, so the result is weak and not a root fix. With dont_touch, all 52 requested LVT refs were preserved, but check_routes returned to 110 DRC. Therefore the remaining A2 issue is not solved by forcing matched HVT OR/NOR cells to LVT.
Saved ICC2 block was restored to the no_or2x1_nor2x012_hvt baseline as route_combo_no_or2x1_nor2x012_hvt_restore3: route DRC 110, open nets 0, legality 0, PG connectivity clean, and PG DRC clean.
Via-ladder center-track probe was tested with route.auto_via_ladder.generate_center_track_on_off_grid_pattern_must_join_pin_shapes=true. It did not improve final check_routes: route DRC remains 110, open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Intermediate routing moved Off-grid as low as 101, so via-ladder / pattern-must-join / pin-access grid behavior remains related but this option is not the fix.
Saved ICC2 block was restored again to the no_or2x1_nor2x012_hvt baseline as route_combo_no_or2x1_nor2x012_hvt_restore4: route DRC 110, open nets 0, legality 0, PG connectivity clean, and PG DRC clean.
A2 LEF access alignment analysis found a sharper cause model. Of 52 unique matched A2 access points, 43 are NOR2X4_HVT. For NOR2X4_HVT/A2, the observed local access X is 0.608 for all 43 points, exactly the maximum legal X center for default VIA1 M1 enclosure on the A2 M1 rectangle. 33 of 43 NOR2X4_HVT points are inside M1 but enclosure-tight. NOR2 HVT drive variants and NOR2X4 LVT/RVT share the same A2 M1 geometry, explaining why targeted LVT swap did not fix the issue.
The M1 pin-contained via route policy trial was tested with route.common.connect_within_pins_by_layer_name={M1 via_standard_cell_pins}. It was rejected as a fix because route DRC worsened to 148, but it is strong cause evidence: Off-grid drops from 104 to 31 while Connection-not-within-pin and Needs-fat-contact classes appear. The saved ICC2 block was restored again as route_combo_no_or2x1_nor2x012_hvt_restore5: route DRC 110, open nets 0, legality 0, PG connectivity clean, and PG DRC clean.
Targeted commutative A1/A2 pin-swap ECO was tested on 52 matched A2 DRC/access cells: 43 NOR2X4_HVT, 8 OR2X4_HVT, and 1 NOR2X0_HVT. All 52 swaps applied. ICC2 route improved from 110 DRC to 103 DRC, with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Detailed matrix is M1 3, M2 49, VIA1 51; Off-grid 101 and Diff net spacing 2. This is the current best route candidate, but backend is still not closed and the post-DFT ECO equivalence strategy has not been signed off.
Full remaining-marker context after the A1/A2 pin-swap ECO was extracted. 95 of 103 remaining DRCs are still near already-swapped cells. A broad marker-context search often intersects A1/VDD/VSS pins, but stricter coordinate matching against report_cell_pin_access shows 97 of 103 markers still match Routable A2 access points within 0.08um. The pin-swap trial mostly leaves the A2 OR/NOR lower-metal access/grid problem in place. Pin-swap-only ECO is no longer the main closure strategy.
The no012 placement pin-access optimization probe was tested and rejected. ICC2 reported that pin access optimization did not move any cells, and final route DRC remained 110: Off-grid 104, Diff net spacing 5, and Short 1. The log also says pin track alignment requires place.legalize.enable_advanced_legalizer.
The no012 advanced legalizer plus pin-access placement probe was tested and rejected. It moved cells through the pin access cell spreader, but final route DRC was 111 all-Off-grid, worse than the 110 baseline. The log says true pin-track alignment still requires place.legalize.enable_pin_color_alignment_check=true.
The no012 advanced legalizer plus pin-color placement probe was tested and rejected as a fix. It enabled pin_color_align legality checking and kept pin_color_align violations at 0, but route DRC stayed 111 all-Off-grid. ICC2 disabled true pin-track alignment because no valid place.legalize.pin_color_alignment_layers value was set.
The no012 explicit M1/M2 pin-track alignment probe was tested and rejected as a fix. ICC2 applied place.legalize.pin_color_alignment_layers M1 M2, kept pin_color_align legality at 0, and moved cells through the pin access cell spreader, but final route DRC was still 110 all-Off-grid. Placement pin-access/pin-color/pin-track knobs are not the standalone closure path.
A2 marker-shape geometry was analyzed. Matched A2 access points are on-track in X, but check_routes markers have deterministic shifts from the access point and repeated M2/VIA1 bbox dimensions. This strengthens the cause model: generated M2/VIA1 shape snapping or route/check grid behavior from A2, not blocked pin access or missing placement pin-track alignment.
VIA12 contact-code fit was analyzed. Observed A2 M2 marker bboxes exactly match VIA12/VIA12SQ_C metal dimensions plus one 0.152um routing pitch. This makes the remaining off-grid marker geometry contact-code-derived rather than random congestion residue.
Default-via rotation was tested with route.common.rotate_default_vias=false and rejected. It worsened route DRC to 310 while keeping open nets 0, legality 0, PG connectivity clean, and PG DRC clean. This means rotated VIA12 usage alone is not the root cause, although via/contact generation policy clearly changes the failure mode.
Narrow OR2X4_HVT add-on avoidance was tested through FE and backend. FE passed, but ICC2 route reports 111 DRC with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. This is worse than the no012 110-DRC baseline and the A1/A2 pin-swap 103-DRC candidate, so OR2X4_HVT-only add-on avoidance is rejected as a fix.
LEF pin via-window analysis was run. MUX41X2_HVT/S0 and RDFFNSRX1_HVT/CLK have no legal default VIA12SQ_C M1 center window, confirming a blocked-access library class. NOR2X*_HVT/A2 pins do have legal VIA1 track centers, so the remaining A2 off-grid problem is access/contact/check-grid snapping at the legal-window edge, not simple pin-metal absence. OR2X4_HVT/A2 and OR2X1_HVT/A1 have legal windows but no default M1 track center inside the window, confirming a separate track-center mismatch class.
The no012 matched DRC rows were classified by LEF via-window class. 87/103 matched marker rows are OR/NOR A2 legal-track edge-snapping, mainly NOR2X4_HVT/A2. 16/103 are legal-window/no-default-track-center, all OR2X4_HVT/A2. No matched no012 row is a true no-window blocked-access class. Next backend action should focus first on the dominant NOR2X4_HVT/A2 edge-snapping class, then OR2X4_HVT/A2 track-center mismatch. MUX41X2_HVT/S0 remains a ZRT-044 cleanup issue, but it is not the matched no012 DRC majority.
Targeted backend ECO resizing the 43 matched NOR2X4_HVT/A2 edge instances to NOR2X2_HVT was tested. All 43 swaps passed and were kept dont_touch. ICC2 route improved to 67 DRC with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. DRC detail is still dominated by VIA1 off-grid: M1 11, M2 2, VIA1 54. This is the current best backend ECO candidate, but it is not backend closure and not yet FE/FM-signed.
Post-ECO remaining DRC classification was run. Of 67 remaining DRC markers, 55 match Routable A2 access points within 0.08um. The matched class split is 43 NOR2X2_HVT/A2 edge-snapping, 10 OR2X4_HVT/A2 track-center mismatch, and 2 NOR2X4_HVT/A2 edge-snapping. Therefore the resize helped but did not eliminate the A2 route/check-grid issue; the next probe should target remaining NOR2X2/NOR2X4 A2 edge behavior or OR2X4 A2 track-center behavior, not broad cell bans.
Targeted OR2X4_HVT/A2 downsizing was tested as an add-on to the current NOR2 resize ECO. The combined 52-cell ECO completed with open nets 0, legality 0, PG connectivity clean, and PG DRC clean, but route DRC worsened to 97. Current best remains the NOR2-only resize ECO at 67 DRC.
Targeted NOR2X4_HVT/A2 resize-to-X1 was also tested. It completed with open nets 0, legality 0, PG connectivity clean, and PG DRC clean, but route DRC worsened to 109. X2 remains the best tested targeted NOR2 resize point; smaller drive is not a monotonic fix.
Post-ECO unmatched marker classification was added. In the 67-DRC best ECO candidate, 55 markers match A2 access points and 12 do not. The 12 unmatched markers are mostly M1 local DRC around SDFFARX1_RVT/SDFFASX1_RVT RSTB/VSS/Q/QN pins, with 4 Short, 4 Diff net spacing, and 4 Off-grid. Treat this as a separate residual class from the dominant HVT OR/NOR A2 VIA1 off-grid issue.
The NOR2 resize ECO plus M1 connect-within-pin route option was tested and rejected as a fix. It reduced Off-grid from 59 to 15 but increased total DRC from 67 to 109 by introducing 45 Needs-fat-contact and 21 Connection-not-within-pin markers. This confirms the lower-metal pin/via access cause model but shows the option is the wrong closure knob.
After the rejected connect-within-pin trial, the saved ICC2 block was restored to the NOR2 resize ECO current-best state. Official final check_routes is still 67 DRC with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. The route log observed 66 DRC internally before final checking, but the accepted evidence remains the official 67-DRC check_routes result.
The NOR2 resize ECO plus route.detail.force_end_on_preferred_grid=true trial was tested and rejected. ICC2 says the option is ignored because the current layers have no preferred grid. Official check_routes remains 67 DRC with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. This points back to tech/NDM grid definition or contact generation rather than this route knob.
SAED32 Milkyway tech defines M1/M2 pitch and onWireTrack, and VIA1 onWireTrack/onGrid, but that is still not enough for ICC2 to treat layers as having preferred grid for route.detail.force_end_on_preferred_grid. Next cause work should inspect ICC2/NDM route track or preferred-grid setup before adding more route knobs.
Preferred-grid / routing-track probe was run. ICC2 W-2024.09 does not provide the old ICC set_preferred_routing_direction command. The block has routing_direction set correctly and M1/M2 tracks exist at start 0.088um, pitch 0.152um, but ICC2 layer attributes preferred_direction/on_wire_track/on_grid are absent in this block. The route.detail.force_end_on_preferred_grids man page requires preferred-grid technology semantics and specific end-rule support, so the rejected force-end route knob is explained by ICC2 tech/NDM semantics, not by a missing basic track pitch. Do not edit the SAED32 tech file; fix attempts should stay in library usage, controlled ECO, placement/routing setup, or NDM-generation/setup investigation.
The NOR2 resize ECO plus A1/A2 pin-swap ECO combination was tested and rejected. All 43 resize operations and all 52 pin swaps applied, but official check_routes worsened to 112 DRC with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Detailed matrix is M1 4, M2 54, VIA1 54. Current best remains the NOR2X4_HVT->NOR2X2_HVT targeted ECO at official 67 DRC.
After the rejected resize+pin-swap trial, the saved ICC2 block was restored to the NOR2 resize ECO current-best state. Official check_routes is 67 DRC with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Fresh marker/pin-access classification confirms the same residual classes: 55 Routable A2 matches and 12 unmatched local M1/flop markers.
ICC2 track setup was probed again. `report_tracks` shows default tracks exist, but `report_track_constraints` is empty and `report_track_patterns` is empty for M1..M8. This sharpens the preferred-grid issue: the design has basic tracks, but lacks ICC2 track-pattern/constraint semantics that route.detail.force_end_on_preferred_grid can use. SAED32 tech remains read-only.
Backend-only modified LEF trial was run with unchanged 8.5ns post-DFT handoff. Original EDK NDM fair baseline has 412 route DRC. libdir modify LEF NDM improves this to 151 route DRC with open nets 0, legality 0, and PG DRC clean. This is strong evidence that backend physical abstract data contributes heavily to route DRC, but backend remains open because 151 DRC remains, mostly Off-grid.
Auto-route option trials on the libdir modify LEF backend were run. M9 max signal routing improves DRC only from 151 to 147. M8 post-route detail repair improves only 151 to 150. M9 plus post-route detail repair worsens 147 to 149. All trials keep open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Current best libdir auto-route result is M9 without repair at 147 DRC, still mostly Off-grid.
Conclusion: the remaining backend issue is not solved by simply allowing M9 or rerunning detail repair. The evidence still points to lower-metal pin/via/grid physical abstract behavior. For the portfolio/time-limited goal, front-end closure remains the clean finish point; backend remains investigation evidence, not signoff.
The clean 8.5ns libdir modify LEF plus NOR2 resize ECO trial is not a valid ECO comparison because the ECO file was generated from the no012 netlist. ICC2 route still reports 147 DRC, but 42 ECO swaps failed and 1 target was missing, so the result should be read as another M9-only libdir route result.
The valid libdir modify LEF combination trial used the matching no_or2x1_nor2x012_hvt post-DFT netlist, the 43-cell NOR2X4_HVT to NOR2X2_HVT ECO, the VDD/M2 PG hotspot blockage, and M8 max signal routing. All 43 swaps applied, but final route DRC is 89 all-Off-grid. This is worse than the original-EDK NDM current-best 67 DRC result. Current backend conclusion: modified LEF helps the clean handoff, but the best no012 ECO path still uses the original EDK NDM result as the strongest backend evidence.
Matched A2 VIA1 route blockage probes were tested on the current-best original-EDK no012/NOR2 resize ECO flow. A 0.055um blockage gives 70 DRC and a 0.025um blockage gives 67 DRC. Both sharply reduce Off-grid but create many Shorts. This confirms A2 VIA1 access is causal, but route blockage is not a DRC-clean closure method.
OR2X4_HVT/A2-only VIA1 route blockage was also tested after correcting the TSV format. The blockages were created, but route DRC worsened to 114. This rejects route blockage as the next closure path and keeps the current best at the NOR2 resize ECO 67-DRC result.
The saved ICC2 block was restored after rejected blockage trials using the current-best NOR2 resize ECO flow with no route blockage. Official final check_routes is still 67 DRC with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Route DRC clean is still not achieved.
The current-best NOR2 resize ECO flow was also tested with post-route incremental detail repair. The pre-repair official state was the same 67 DRC, but 200 iterations of route_detail repair worsened the final official result to 114 DRC. Therefore repeated detail repair is rejected for this flow. Current best remains 67 DRC, open nets 0, legality 0, PG connectivity clean, and PG DRC clean.
The current-best NOR2 resize ECO flow was tested with explicit M1/M2 track constraints plus force_end_on_preferred_grid. The track constraints were accepted, but official check_routes stayed at 67 DRC with open nets 0, legality 0, PG connectivity clean, and PG DRC clean. Route DRC clean is still not achieved; the active goal must remain open.
The current-best NOR2 resize ECO flow was tested with advanced legalizer, pin-color alignment, M1/M2 pin-color layers, and pin-access placement options. Official check_routes worsened to 109 all-Off-grid DRC. It was also tested with M9 max signal routing, which worsened to 125 DRC. Current best remains 67 DRC and not clean.
```

## Fmax Estimate

```text
Basis: post-DFT topo/SDF STA
Clock: 10.00 ns
Worst setup slack: 1.48 ns
Estimated critical path delay: 8.52 ns
Ideal Fmax: about 117.4 MHz
8.5 ns result: passed FE closure with notes; estimated critical path delay about 8.06 ns and ideal Fmax about 124.1 MHz
Next trial: 8.0 ns only as stretch; 8.5 ns is the better portfolio finish point for current time constraints
```

## 2026-05-10 Backend Route DRC Clean Trial

최종 accepted backend trial:

```text
route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin
```

조건:

```text
frontend handoff:
  no_or2x1_nor2x012_hvt post-DFT netlist/SDC/scan DEF 유지

backend physical abstract:
  trim_all_pin NDM

backend ECO:
  NOR2X4_HVT -> NOR2X2_HVT 43개
  u_core/core_i/U1723 MUX41X2_HVT -> MUX41X1_HVT 1개
  ECO_SWAP_DONT_TOUCH=true
```

공식 결과:

```text
check_routes.rpt:
  open nets 0
  TOTAL VIOLATIONS 0
  Total number of DRCs 0

check_legality.rpt:
  TOTAL 0 Violations

pg_connectivity.rpt:
  VDD/VSS floating counts all 0

pg_drc.rpt:
  report file generated; route log check_pg_drc says No errors found
```

현재 판정:

```text
ICC2 route DRC clean achieved for this controlled backend trial.
Full backend signoff is not complete.
```

남은 backend 후속:

```text
1. extraction / post-route STA
2. SPEF 기반 PrimeTime signoff-style timing check
3. DEF/GDS 출력
4. signoff DRC/LVS/IR/EM은 별도 signoff tool evidence 필요
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin/01_init_design/eco_swap.rpt
7_Backend_ICC2/3_Log/trials/route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin/route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin.log
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin/06_route/pg_drc.rpt
```

## 2026-05-10 Post-Route ECO Export And Formality

완료한 후속 flow:

```text
1. ICC2 route-clean saved block에서 post-route ECO netlist export
2. post-DFT netlist vs post-route ECO netlist Formality N2N
```

export 산출물:

```text
7_Backend_ICC2/2_Output/08_export/post_route_eco_drc_clean/cv32e40p_synth_wrap.post_route_eco_drc_clean.vg
7_Backend_ICC2/2_Output/08_export/post_route_eco_drc_clean/cv32e40p_synth_wrap.post_route_eco_drc_clean.sdc
7_Backend_ICC2/2_Output/08_export/post_route_eco_drc_clean/cv32e40p_synth_wrap.post_route_eco_drc_clean.sdf
7_Backend_ICC2/2_Output/08_export/post_route_eco_drc_clean/cv32e40p_synth_wrap.post_route_eco_drc_clean.def
```

export 전 block check:

```text
check_routes:
  open nets 0
  TOTAL VIOLATIONS 0
  Total number of DRCs 0

check_legality:
  TOTAL 0 Violations
```

Formality N2N:

```text
reference:
  3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg

implementation:
  7_Backend_ICC2/2_Output/08_export/post_route_eco_drc_clean/cv32e40p_synth_wrap.post_route_eco_drc_clean.vg

result:
  Verification SUCCEEDED
  passing compare points 2243
  failing compare points 0
  unmatched compare points 0
  scan_out don't-verify 1
  clock-gate LAT not compared 74
```

현재 판정:

```text
Backend ECO functional equivalence is checked for functional mode.
다음 단계는 RC extraction / SPEF 생성 / PrimeTime post-route STA.
```

증거:

```text
7_Backend_ICC2/3_Log/08_export/export_post_route_eco_drc_clean.log
7_Backend_ICC2/2_Output/08_export/post_route_eco_drc_clean/export_manifest.txt
7_Backend_ICC2/4_Report/08_export/post_route_eco_drc_clean/check_routes.before_export.rpt
7_Backend_ICC2/4_Report/08_export/post_route_eco_drc_clean/check_legality.before_export.rpt
5_FM_N2N/3_Log/fm_n2n_post_route_eco_drc_clean.log
5_FM_N2N/4_Report/post_route_eco_drc_clean/n2n_post_route_eco_drc_clean.failing_points.rpt
5_FM_N2N/4_Report/post_route_eco_drc_clean/n2n_post_route_eco_drc_clean.unmatched_points.post_verify.rpt
5_FM_N2N/4_Report/post_route_eco_drc_clean/n2n_post_route_eco_drc_clean.passing_points.post_verify.rpt
```

## 2026-05-10 Post-Route SPEF STA

완료:

```text
1. ICC2 route-clean saved block에서 SPEF 추출
2. PrimeTime에서 post-route ECO netlist + SPEF 기반 STA 수행
```

SPEF:

```text
cmax:
  7_Backend_ICC2/2_Output/07_extract_sta/post_route_eco_drc_clean/cv32e40p_synth_wrap.post_route_eco_drc_clean.spef.saed32_cmax_25.spef

cmin:
  7_Backend_ICC2/2_Output/07_extract_sta/post_route_eco_drc_clean/cv32e40p_synth_wrap.post_route_eco_drc_clean.spef.saed32_cmin_25.spef

annotation:
  cmax/cmin 모두 17863 pin-to-pin nets annotated as RC networks
```

PrimeTime 결과:

```text
cmax:
  setup violation 없음
  hold violation 없음
  worst listed setup slack +2.17 ns
  worst listed hold slack +0.05 ns
  max_capacitance violations 376

cmin:
  setup violation 없음
  hold violation 없음
  worst listed setup slack +2.35 ns
  worst listed hold slack +0.05 ns
  max_capacitance violations 179
```

현재 판정:

```text
10 ns post-route SPEF STA timing은 닫힘.
단, max_capacitance design-rule violation이 남아 full signoff clean은 아님.
```

## 2026-05-10 Max-Cap ECO Update

목표:

```text
post-route SPEF STA의 max_capacitance violation을 줄이고,
route DRC와 setup/hold timing을 유지한다.
```

진행:

```text
ECO3 open_site:
  ICC2 internal max_cap 368 -> 2
  PT SPEF residual cmax 11, cmin 1
  판정: partial

ECO4 occupied_site:
  ICC2 internal max_cap 13 -> 0
  PT SPEF max_cap 0
  route DRC M1 Short 3개 발생
  판정: max_cap은 해결, route clean 아님

ECO5 route repair:
  ECO4 block 복사
  short bbox 주변 incremental route_detail + route_eco
  route DRC 0
  legality 0
  ICC2 internal constraints total violation 0
  PT SPEF max_cap cmax/cmin 0
```

현재 판정:

```text
max_capacitance cleanup은 완료 후보.
10 ns setup/hold timing도 유지됨.
단, PT cmax constraint report에 max_transition 1개가 precision note와 함께 남음:
  u_core/core_i/id_stage_i/U246/Y
  required 0.0948 ns, actual 0.0953 ns, slack -0.0005 ns

ICC2 internal constraint report는 max_transition 0, max_capacitance 0, total 0.
따라서 다음 선택지는 transition note를 별도 추적하거나,
필요하면 max_transition 전용 ECO를 추가로 수행하는 것.
```

Formality:

```text
ECO5 netlist N2N Formality PASS.
passing compare points 2243
failing compare points 0
unmatched compare points 0
```

증거:

```text
7_Backend_ICC2/3_Log/07_extract_sta/max_cap_eco5_route_repair.log
7_Backend_ICC2/2_Output/07_extract_sta/maxcap_eco5_route_repair/route_repair_manifest.txt
7_Backend_ICC2/4_Report/07_extract_sta/maxcap_eco5_route_repair/check_routes.after_route_repair.rpt
7_Backend_ICC2/4_Report/07_extract_sta/maxcap_eco5_route_repair/check_legality.after_route_repair.rpt
7_Backend_ICC2/4_Report/07_extract_sta/maxcap_eco5_route_repair/constraints.after_route_repair.rpt
6_STA/3_Log/pt_maxcap_eco5_10ns_spef.log
6_STA/4_Report/maxcap_eco5_route_repair_spef/maxcap_eco5.func_tt_10ns_spef.cmax.constraints.rpt
6_STA/4_Report/maxcap_eco5_route_repair_spef/maxcap_eco5.func_tt_10ns_spef.cmin.constraints.rpt
6_STA/4_Report/maxcap_eco5_route_repair_spef/maxcap_eco5.func_tt_10ns_spef.cmax.global_timing.rpt
6_STA/4_Report/maxcap_eco5_route_repair_spef/maxcap_eco5.func_tt_10ns_spef.cmin.global_timing.rpt
6_STA/4_Report/maxcap_eco5_route_repair_spef/maxcap_eco5.transition_probe.cmax.max_transition_4digits.rpt
5_FM_N2N/3_Log/fm_n2n_maxcap_eco5_route_repair.log
5_FM_N2N/4_Report/maxcap_eco5_route_repair/n2n_maxcap_eco5_route_repair.failing_points.rpt
```

다음 후보:

```text
1. PT max_transition 0.5 ps residue를 고칠지 waiver/note로 둘지 결정
2. DEF/GDS export
3. signoff checklist 정리
4. front-end 중심 포트폴리오 산출물 패키징
```

증거:

```text
7_Backend_ICC2/3_Log/07_extract_sta/extract_spef_post_route_eco_drc_clean.log
7_Backend_ICC2/2_Output/07_extract_sta/post_route_eco_drc_clean/extract_manifest.txt
6_STA/3_Log/pt_post_route_eco_10ns_spef.log
6_STA/4_Report/post_route_eco_drc_clean_spef/post_route_eco.func_tt_10ns_spef.run_manifest.rpt
6_STA/4_Report/post_route_eco_drc_clean_spef/post_route_eco.func_tt_10ns_spef.cmax.global_timing.rpt
6_STA/4_Report/post_route_eco_drc_clean_spef/post_route_eco.func_tt_10ns_spef.cmin.global_timing.rpt
6_STA/4_Report/post_route_eco_drc_clean_spef/post_route_eco.func_tt_10ns_spef.cmax.constraints.rpt
6_STA/4_Report/post_route_eco_drc_clean_spef/post_route_eco.func_tt_10ns_spef.cmin.constraints.rpt
```
