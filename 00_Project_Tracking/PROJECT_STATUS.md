# Project Status

## Current Phase

```text
Front-End baseline completed; ICC2 backend init/floorplan/place/power/CTS/route first pass completed
Route DRC diagnosis, 60%/M8 trials, lower-metal DRC detail breakdown, detail-route repair trials, PG top-port cleanup, off-track pin object diagnosis, CO/VIA contact diagnosis, Milkyway reference open trial, pin-access/M1-track probe, M1 retrack route trial, create_pin_check_lib trial, blocked-access detail extraction, pin-access/DRC overlap parse, placement spreading trial, scan DEF handoff trial, advanced legalizer/pin-color trial, DRC marker context probe, hotspot partial blockage probe, route DRC root-cause hypothesis write-up, hotspot DRC-to-PG distance probe, PG M2 offset probe, PG blockage trials, route grid option probes, and current-best DRC geometry residue analysis completed; root cause narrowed but route DRC not closed
```

## Next Milestone

```text
Target OR2X1_HVT and NOR2X*_HVT lower-metal pin/contact behavior on the current-best 368 DRC route before further broad fix trials.
```

## Frozen Baseline

```text
Run: tt_mvt_10ns_scan1
Commit: 5473b61
Status: Front-End baseline complete
Meaning: 10 ns topo synthesis, R2N, DFT topo, N2N, post-DFT SDF STA, and stuck-at ATPG are reproducible from scripts.
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
```

## Current Notes

```text
DFT is topographical and writes post-DFT DDC/VG/SDC/SDF/SPF.
SPF is written after insert_dft so TetraMAX sees chain0 length 2130.
TetraMAX stuck-at ATPG reached 98.64% test coverage and 98.55% fault coverage.
Remaining notes: DC DFT TEST-505 constant-1 clock gate, TetraMAX Z3 wire contention warnings, and physical max_cap/max_transition cleanup deferred to backend.
Active synthesis script is only 2_Synthesis/0_Script/run_compile_10ns_topo.tcl.
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
Next backend action should split the fix strategy by class: blocked-access pins, A2 edge snapping, and OR track-center mismatch. Broad cell bans should remain rejected unless a targeted structural mapping change has FE and backend evidence.
```

## Fmax Estimate

```text
Basis: post-DFT topo/SDF STA
Clock: 10.00 ns
Worst setup slack: 1.48 ns
Estimated critical path delay: 8.52 ns
Ideal Fmax: about 117.4 MHz
Next trial: 8.5 ns first; 8.0 ns if 8.5 ns remains clean enough
```
