# Result Summary

## Summary Tables

### Implementation

```text
Stage | Tool | Result | Key Output | Notes
RTL intake | git/filelist | PASS | rtl/cv32e40p + filelists/cv32e40p_dc.tcl | upstream sim clock gate/tb excluded
Topo synthesis | DC Graphical | PASS_WITH_NOTE | 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.{ddc,vg,sdc,sdf} | 10 ns TT mixed-VT; timing-clean, DRC-not-clean
R2N | Formality | PASS | 2.5_FM_R2N/4_Report/r2n_topo.*.rpt | topo RTL-to-netlist verify succeeded; no failing compare points
DFT | DC/DFT Compiler topo | PASS_WITH_NOTE | 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.{ddc,vg,sdc,sdf,spf} | 1 muxed chain, SPF has chain0 length 2130; DFT DRC has TEST-505 note
N2N | Formality | PASS | 5_FM_N2N/4_Report/n2n_topo.*.rpt | pre-DFT topo netlist vs post-DFT topo netlist; 2243 passing, 0 failing
ATPG | TetraMAX | PASS_WITH_NOTE | 4_ATPG/4_Report/stuck_at_topo/summary.rpt | stuck-at reached 98.64% test coverage; TMAX DRC has 6 Z3 wire-contention warnings
SDF STA | PrimeTime | PASS_WITH_NOTE | 6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.*.rpt | SDF annotated with 0 errors; setup/hold clean; max_cap residual remains
Post-DFT SDF STA | PrimeTime | PASS_WITH_NOTE | 6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.*.rpt | post-DFT SDF annotated with 0 errors; setup/hold clean; max_cap residual remains
8.5 ns FE closure | DC/FM/DFT/PT/TetraMAX | PASS_WITH_NOTE | 2_Synthesis/4_Report/topo_8p5ns, 3_DFT/4_Report/topo_8p5ns, 6_STA/4_Report/post_dft_topo_8p5ns_sdf, 4_ATPG/4_Report/stuck_at_topo_8p5ns | clean baseline mixed-VT flow, no backend dont_use workaround; setup/hold clean; known DFT/ATPG/electrical notes remain
ICC2 init_design | ICC2 | PASS_WITH_NOTE | 7_Backend_ICC2/2_Output/01_init_design/cv32e40p_icc2_lib | post-DFT netlist linked and saved as physical design; no floorplan yet; check_design has 0 errors and 14004 warnings
ICC2 floorplan initial | ICC2 | PASS_WITH_NOTE | 7_Backend_ICC2/4_Report/02_floorplan/{design_physical,utilization,qor}.rpt | rectangular floorplan created; utilization 65.40%; 382 pins created; no power plan yet
ICC2 placement initial | ICC2 | PASS_WITH_NOTE | 7_Backend_ICC2/4_Report/04_place/check_legality.rpt | 14083 cells placed/legalized; 0 legality violations; no scan DEF, so placement uses continue_on_missing_scandef
ICC2 power initial | ICC2 | PASS | 7_Backend_ICC2/4_Report/03_power/{pg_connectivity,pg_drc}.rpt | M7 horizontal mesh offset 28um; PG DRC clean; VDD/VSS floating wires, vias, and std cells all 0
ICC2 CTS initial | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/05_cts/{clock_qor.summary,clock_qor.drc_violators,qor,check_legality,pg_connectivity}.rpt | clock_opt through route_clock; clock DRC 0; legality 0; timing paths MET; whole-design DRC still has 1 max_transition/172 max_cap, VSS floating boundary terminals 2
ICC2 route initial | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/06_route/{check_routes,qor,check_legality,pg_connectivity}.rpt | route_auto completed; open nets 0; route DRC 408 remains; legality 0; PG clean
ICC2 route 60% util trial | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/60util/06_route/{check_routes,utilization,timing.max,timing.min}.rpt | route-stage utilization 0.7324; open nets 0; check_routes DRC 407 remains; timing paths MET; density-only fix rejected
ICC2 route 60% util + M8 trial | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/60util_m8/06_route/{check_routes,ignored_layers,utilization,timing.max,timing.min}.rpt | signal route layer bound M1-M8; route-stage utilization 0.7324; open nets 0; check_routes DRC 400 remains; timing paths MET; layer-bound helps slightly but does not close route
ICC2 route DRC detail diagnosis | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/06_route/drc_detail/{drc.matrix,drc.by_layer,drc.detailed}.rpt | current block is 60util_m8 state; all 400 DRCs are on M1/M2/M1-M2/VIA1; next focus is lower-metal/via/contact/grid cleanup
ICC2 detail-route repair trial | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/detail_repair_1iter/06_route/{check_routes.after,drc.after.matrix,timing.max.after,timing.min.after}.rpt | best DRC count so far is 383 after 1 iteration; 200-iteration run ends at 398; open nets 0 and timing paths MET; not route closure
ICC2 PG top port cleanup | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/{terminal_attach_summary,check_routability.after,pg_connectivity.after,pg_drc.after}.rpt | VDD/VSS no-pin/unplaced warning removed by offset M8 terminal attach; PG remains clean; route DRC still 400
ICC2 off-track pin diagnosis | ICC2 | RECORDED | 7_Backend_ICC2/4_Report/trials/offtrack_pin_diagnose/99_route_access/{check_routability.verbose,offtrack_pin_objects}.rpt | 8 M1 off-track warnings map to stdcell pins: SDFFARX1_RVT/QN, INVX8_LVT/A, MUX41X1_HVT/S1; next focus is pin-access/track/contact setup
ICC2 CO/VIA contact diagnosis | ICC2 | RECORDED | 7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/{contact_code_summary,check_routability.contact}.rpt | CO has no default contact, explaining ZRT-022; VIA1 has default VIA12SQ_C, so M1-M2 via setup is present
ICC2 Milkyway reference trial | ICC2 | BLOCKED | 7_Backend_ICC2/3_Log/trials/mw_ref_open_trial/mw_ref_open_trial.log | direct MW ref conversion blocked: no icc_shell, Milkyway/MDataPrep license unavailable, export tar.gz missing; continue DB+LEF-built NDM path
ICC2 pin access / M1 track probe | ICC2 | RECORDED | 7_Backend_ICC2/4_Report/trials/pin_access_track_probe/99_pin_access_track/{report_cell_pin_access.flagged_cells,report_cell_pin_access.same_refs,check_routability.*}.rpt | flagged 8 cells have 0 blocked access pins, same ref-cell population has 117 blocked access pins; routed-block M1 offset probe alone is not enough evidence for a fix
ICC2 M1 retrack route trial | ICC2 | REJECTED | 7_Backend_ICC2/3_Log/trials/m1_retrack_route_088/m1_retrack_route_088.log | after signal route removal, M1 track recreation at 0.088 still has 8 off-track warnings and route DRC explodes from 400 to 27260, dominated by illegal track route
ICC2 create_pin_check_lib trial | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/create_pin_check_lib_trial/99_pin_check_lib/{create_pin_check_lib_status,check_libcell_pin_access.all.analyze_lib_cell}.rpt | create_pin_check_lib succeeds for mixed-VT and per-VT refs; analyze_lib_cell succeeds after pin_check.place.preplace_option_file setup; analyze_lib_pin still fails with LIB-001
ICC2 blocked access detail | ICC2 | RECORDED | 7_Backend_ICC2/4_Report/trials/pin_access_blocked_detail/99_pin_access/{report_cell_pin_access.same_refs.details,blocked_access.compact_summary}.rpt | official summary has 117 blocked pins; parsed detail has 125 line-level blocked entries: SDFFARX1_RVT 116, MUX41X1_HVT 9, INVX8_LVT 0
ICC2 pin access / DRC overlap | script | RECORDED | 7_Backend_ICC2/4_Report/trials/pin_access_drc_overlap/99_overlap/overlap_summary.rpt | 305 blocked points vs 400 DRC markers; 289 blocked points have nearest DRC within 50um and 193 within 25um
ICC2 pin-density spread trial | ICC2 | REJECTED | 7_Backend_ICC2/4_Report/trials/pin_access_spread/06_route/check_routes.rpt | open nets 0, legality 0, PG clean, but route DRC 390 and blocked access worsens to 144 official blocked pins; not a standalone fix
ICC2 scan DEF handoff route trial | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/scan_def_m8/06_route/check_routes.rpt | ICC2 read DFT scan DEF and optimize_dft validated 1 scan chain; route DRC 398 and open nets 0; scan DEF alone not enough
ICC2 advanced legalizer + pin color trial | ICC2 | REJECTED | 7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/check_routes.rpt | pin_color_align legality 0, PG clean, open nets 0, but route DRC 605; advanced legalizer/pin color not accepted
ICC2 DRC marker context probe | ICC2/script | RECORDED | 7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/marker_context.rpt | scan_def_m8_restore detailed DRC has 398 markers; hotspots concentrate at x=220..260um/y=200..260um; representative markers hit OR2X1_HVT/NOR2X0_HVT/SDFFARX1_RVT/NBUFFX8_HVT local pin/route context
ICC2 hotspot partial blockage probe | ICC2 | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/check_routes.rpt | hotspot {{215 195} {265 265}} 40% partial blockage gives DRC 390 vs scan_def_m8_restore 398; open nets 0, legality 0, PG clean; hotspot density alone not root cause
ICC2 route DRC root-cause investigation | docs/script | RECORDED | docs/backend/route_drc_root_cause_investigation.md | active goal shifted to root-cause identification; hotspot has 123 DRC markers, dominated by M2/VIA1 off-grid; leading hypotheses are pin access/off-grid, M2 PG interaction, LEF-built NDM quality, and route off-grid/via policy
ICC2 hotspot DRC-to-PG distance probe | ICC2/script | RECORDED | 7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance/hotspot_drc_pg_distance_summary.rpt | hotspot has 3 M2 PG stripes; 78/123 hotspot markers are within 5um of M2 PG, but 45/123 are farther than 5um
ICC2 PG M2 offset probe | ICC2 | INVALID_FOR_CLOSURE_BUT_INFORMATIVE | 7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/check_routes.rpt | M2 PG offset 30um changes signal DRC 398 -> 377 but creates PG DRC 97 after route; PG position affects route DRC but this offset is not a valid fix
no_mux41x_hvt front-end experiment | DC/FM/DFT/TMAX/PT | PASS_WITH_NOTE | docs/backend/no_mux41x_hvt_experiment_2026_05_09.md | MUX41X1_HVT 67 -> 0 and MUX41X1_RVT 0 -> 67; R2N/N2N pass; ATPG and PT remain usable
ICC2 no_mux41x_hvt route combo trial | ICC2 | REJECTED | 7_Backend_ICC2/4_Report/trials/route_combo_no_mux41x_hvt/06_route/check_routes.rpt | route DRC 399, open nets 0, legality 0, PG clean; worse than route_combo_scan_def_m8 at 381, so not accepted
ICC2 local PG M2 cut trial | ICC2 | BEST_CURRENT_OPEN_CAUSE_EVIDENCE | 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/check_routes.rpt | hotspot VSS M2 cut keeps open nets 0, legality 0, PG connectivity/DRC clean, and route DRC improves 381 -> 377; cause evidence, not final PG style
ICC2 all-M2 hotspot PG cut trial | ICC2 | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/check_routes.rpt | hotspot x=220 VSS/x=240 VDD/x=260 VSS cuts keep open nets 0, legality 0, PG clean, but route DRC is 378; spacing improves while fat-contact worsens
ICC2 x=240 VDD PG cut trial | ICC2 | BEST_CURRENT_OPEN_CAUSE_EVIDENCE | 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/check_routes.rpt | hotspot x=240 VDD cut keeps open nets 0, legality 0, PG clean, and improves route DRC to 376
ICC2 x=220 VSS PG cut trial | ICC2 | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/check_routes.rpt | hotspot x=220 VSS cut keeps open nets 0, legality 0, PG clean, but route DRC is 380; worse than x=240 VDD cut
```

### Backend Init

```text
Item | Result | Evidence | Notes
NDM reference build | PASS_WITH_NOTE | 7_Backend_ICC2/3_Log/00_setup/build_saed32_ndm.log | RVT/LVT/HVT NDM built from DB+LEF; library warnings recorded
ICC2 post-DFT open/link/save | PASS_WITH_NOTE | 7_Backend_ICC2/3_Log/01_init_design/init_design_check.log | cv32e40p_synth_wrap linked; block and lib saved
ICC2 check_design | PASS_WITH_NOTE | 7_Backend_ICC2/4_Report/01_init_design/check_design.rpt | 0 errors, 14004 warnings before floorplan
Physical area seen by ICC2 | RECORDED | 7_Backend_ICC2/4_Report/01_init_design/design_physical.rpt | total physical cell area 49449.815
Initial floorplan | PASS_WITH_NOTE | 7_Backend_ICC2/4_Report/02_floorplan/design_physical.rpt | core area {20 20} {295.728 294.208}; 1:1 aspect target; 20um core offset
Initial utilization | RECORDED | 7_Backend_ICC2/4_Report/02_floorplan/utilization.rpt | utilization 0.6540; total capacity area 75606.8234; cell area 49449.8147
Initial pin placement | PASS | 7_Backend_ICC2/3_Log/02_floorplan/floorplan_initial.log | place_pins -self created 382 pins
TLU+ parasitic setup | PASS | 7_Backend_ICC2/4_Report/01_init_design/parasitic_parameters.rpt | default corner uses saed32_cmin early and saed32_cmax late at 25C
Initial placement legality | PASS | 7_Backend_ICC2/4_Report/04_place/check_legality.rpt | TOTAL 0 violations after legalize_placement
Initial placement timing estimate | PASS_WITH_NOTE | 7_Backend_ICC2/4_Report/04_place/timing.rpt | worst listed setup slack 0.57 ns after PG closure placement refresh; pre-CTS/pre-route estimate only
Initial PG DRC | PASS | 7_Backend_ICC2/4_Report/03_power/pg_drc.rpt | check_pg_drc reports no errors for chosen 40um mesh pitch and M7 offset 28um
Initial PG connectivity | PASS | 7_Backend_ICC2/4_Report/03_power/pg_connectivity.rpt | VDD floating wires/vias/std cells 0/0/0; VSS floating wires/vias/std cells 0/0/0
Placement-stage PG connectivity | PASS | 7_Backend_ICC2/4_Report/04_place/pg_connectivity.rpt | PG remains connected after placement refresh; VDD/VSS floating wires, vias, and std cells all 0
First-pass CTS clock tree | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/05_cts/clock_qor.summary.rpt | clk_i has 2130 sinks, 6 levels, 11 repeaters, max latency 0.37 ns, global skew 0.33 ns
First-pass CTS clock DRC | PASS | 7_Backend_ICC2/4_Report/05_cts/clock_qor.drc_violators.rpt | transition/cap/fanout/netlength DRC count all 0 for clk_i
First-pass CTS legality | PASS | 7_Backend_ICC2/4_Report/05_cts/check_legality.rpt | TOTAL 0 violations
First-pass CTS PG check | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt | VDD floating wires/vias/std cells/terminals 0; VSS floating wires/vias/std cells 0 but floating terminals 2
First-pass CTS whole-design DRC | OPEN | 7_Backend_ICC2/4_Report/05_cts/qor.rpt | Max Trans Violations 1; Max Cap Violations 172
First-pass route open nets | PASS | 7_Backend_ICC2/4_Report/06_route/check_routes.rpt | Total open nets 0
First-pass route DRC | OPEN | 7_Backend_ICC2/4_Report/06_route/check_routes.rpt | TOTAL VIOLATIONS 408: diff-net spacing 131, less-than-min-area 8, needs-fat-contact 106, off-grid 163
First-pass route legality | PASS | 7_Backend_ICC2/4_Report/06_route/check_legality.rpt | TOTAL 0 violations
First-pass route PG | PASS | 7_Backend_ICC2/4_Report/06_route/pg_connectivity.rpt | VDD/VSS floating wires/vias/std cells/terminals all 0; PG DRC reports no errors
60% utilization route trial | OPEN | 7_Backend_ICC2/4_Report/trials/60util/06_route/check_routes.rpt | check_routes reports 407 DRCs and 0 open nets; DRC classes: diff-net spacing 102, min-area 8, needs-fat-contact 128, off-grid 166, same-net spacing 1, short 2
60% utilization + M8 route-layer trial | OPEN | 7_Backend_ICC2/4_Report/trials/60util_m8/06_route/check_routes.rpt | check_routes reports 400 DRCs and 0 open nets; DRC classes: diff-net spacing 122, min-area 7, needs-fat-contact 108, off-grid 160, short 3
Route DRC layer matrix | OPEN | 7_Backend_ICC2/4_Report/06_route/drc_detail/drc.matrix.rpt | all 400 DRCs are lower-metal/access: M1 125, M1-M2 108, M2 88, VIA1 79
Detail route repair 200iter | OPEN | 7_Backend_ICC2/4_Report/trials/detail_repair_200iter/06_route/check_routes.after.rpt | check_routes reports 398 DRCs and 0 open nets; long incremental detail routing does not converge
Detail route repair 1iter | OPEN | 7_Backend_ICC2/4_Report/trials/detail_repair_1iter/06_route/check_routes.after.rpt | check_routes reports 383 DRCs and 0 open nets; best count so far but M1 diff-net spacing grows to 224
PG top port cleanup | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/check_routability.after.rpt | VDD/VSS no-pin/unplaced warning removed; 8 M1 off-track pin warnings remain; route DRC still open
Off-track M1 pin object diagnosis | RECORDED | 7_Backend_ICC2/4_Report/trials/offtrack_pin_diagnose/99_route_access/offtrack_pin_objects.rpt | remaining 8 off-track warnings are stdcell M1 pins, not top-level PG ports; ZRT-022 CO contact setup remains suspicious
CO/VIA contact code diagnosis | RECORDED | 7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/contact_code_summary.rpt | CO via_def/default count is 0/0, but VIA1 is 6/1 with default VIA12SQ_C; do not patch CO yet
Milkyway reference open trial | BLOCKED | 7_Backend_ICC2/3_Log/trials/mw_ref_open_trial/mw_ref_open_trial.log | original SAED32 MW refs cannot be converted in current environment; DB+LEF-built NDM remains active backend path
Pin access / M1 track probe | RECORDED | 7_Backend_ICC2/4_Report/trials/pin_access_track_probe/99_pin_access_track/report_cell_pin_access.flagged_cells.rpt | flagged 8 cells report 46 no-violation pins and 0 blocked access pins; same ref-cell population reports 117 blocked access pins
M1 retrack full-route trial | REJECTED | 7_Backend_ICC2/3_Log/trials/m1_retrack_route_088/m1_retrack_route_088.log | route_auto after signal-route removal and M1 track recreate reports 0 open nets but 27260 DRCs; manual M1 track recreation rejected
create_pin_check_lib analyze_lib_cell | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/create_pin_check_lib_trial/99_pin_check_lib/check_libcell_pin_access.all.analyze_lib_cell.rpt | mixed-VT pin-check lib created; analyze_lib_cell reports skipped 27 and met threshold 855; analyze_lib_pin remains blocked by LIB-001
Blocked access detail extraction | RECORDED | 7_Backend_ICC2/4_Report/trials/pin_access_blocked_detail/99_pin_access/blocked_access.compact_summary.rpt | official count 117 blocked pins; parsed detail line count 125, concentrated in SDFFARX1_RVT and MUX41X1_HVT
Pin access / DRC overlap | RECORDED | 7_Backend_ICC2/4_Report/trials/pin_access_drc_overlap/99_overlap/overlap_summary.rpt | 21 shared 50um buckets; nearest DRC type counts are Off-grid 123, Needs fat contact 112, Diff net spacing 54, Short 16
Pin-density spread route trial | REJECTED | 7_Backend_ICC2/4_Report/trials/pin_access_spread/06_route/check_routes.rpt | check_routes DRC 390, official blocked pins 144; spreading worsens pin access despite slight DRC reduction
Scan DEF route trial | PASS_WITH_OPEN | 7_Backend_ICC2/4_Report/trials/scan_def_m8/06_route/check_routes.rpt | check_routes DRC 398 and open nets 0; scan-aware DFT optimization works but route DRC remains open
Advanced legalizer + pin color route trial | REJECTED | 7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/check_routes.rpt | check_routes DRC 605 and open nets 0; legality/PG clean, but worse than scan_def_m8
DRC marker context probe | RECORDED | 7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/representative_summary.rpt | fresh marker matrix: M1 diff spacing 116, M1-M2 fat contact 99, M2 off-grid 78, VIA1 off-grid 82; top 20um buckets around x=220..260/y=200..260
Hotspot partial blockage probe | OPEN | 7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/check_routes.rpt | hotspot {{215 195} {265 265}} 40% blockage reduces DRC only 398 -> 390; density-only hotspot fix is weak
Route DRC root-cause hypothesis | RECORDED | docs/backend/route_drc_root_cause_investigation.md | hotspot window has 123 markers: Off-grid VIA1 48, Off-grid M2 46, Diff M1 18, Needs fat contact 10, Off-grid M1 1
Hotspot DRC-to-PG distance | RECORDED | 7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance/hotspot_drc_pg_distance_summary.rpt | 23/123 markers within 1um of M2 PG, 78/123 within 5um, 45/123 farther than 5um
PG M2 offset 30um probe | INVALID_FOR_CLOSURE_BUT_INFORMATIVE | 7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/drc_detail/drc.matrix.rpt | signal DRC 377, but PG DRC 97; diff spacing improves 120 -> 82 while fat-contact worsens 99 -> 127 and off-grid remains 170 -> 163
Route extra off-grid pin tracks probe | OPEN | 7_Backend_ICC2/4_Report/trials/route_offgrid_tracks_scan_def_m8/06_route/drc_detail/drc.matrix.rpt | route DRC 385 and open nets 0; PG clean; off-grid 170 -> 160 and needs-fat-contact 99 -> 84, so helpful but not root-cause closure
Route via/DRC effort high probe | OPEN | 7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/drc_detail/drc.matrix.rpt | route DRC 389 and open nets 0; PG clean; off-grid remains 163, so simple route effort is not the main cause
PG M2 offset 24/26/28 sweep | REJECTED | 7_Backend_ICC2/4_Report/trials/pgm2off24_scan_def_m8/06_route/check_routes.rpt | signal route DRCs are 377/384/383 and open nets 0, but PG DRC creates 102/82/83 M1 insufficient-spacing errors; offset-only fix rejected
Hotspot 40% partial blockage fix trial | OPEN | 7_Backend_ICC2/4_Report/trials/hotspot_blk40_scan_def_m8/06_route/check_routes.rpt | route DRC 391, open nets 0, legality 0, PG clean; local spreading alone is weak
Route combo fix trial | BEST_CURRENT_OPEN | 7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/check_routes.rpt | route DRC 381, open nets 0, legality 0, PG clean; accepted as current backend baseline candidate, but route DRC remains open
no_mux41x_hvt route combo trial | REJECTED | 7_Backend_ICC2/4_Report/trials/route_combo_no_mux41x_hvt/06_route/check_routes.rpt | route DRC 399, open nets 0, legality 0, PG clean; MUX41X*_HVT avoidance alone worsens current best route result
Local VSS M2 PG cut trial | BEST_CURRENT_OPEN_CAUSE_EVIDENCE | 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/check_routes.rpt | route DRC 377, open nets 0, legality 0, PG connectivity clean, PG DRC clean; proves local PG M2 obstruction contributes to hotspot DRC
All-M2 hotspot PG cut trial | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/check_routes.rpt | route DRC 378, open nets 0, legality 0, PG clean; diff spacing improves to 96 but needs-fat-contact worsens to 113
x=240 VDD PG cut trial | BEST_CURRENT_OPEN_CAUSE_EVIDENCE | 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/check_routes.rpt | route DRC 376, open nets 0, legality 0, PG clean; current best valid backend candidate
x=220 VSS PG cut trial | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/check_routes.rpt | route DRC 380, open nets 0, legality 0, PG clean; not accepted as best
x=240 VDD PG cut restore | BEST_CURRENT_OPEN_RESTORED | 7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240_restore/06_route/check_routes.rpt | saved ICC2 block restored to best candidate; route DRC 376, open nets 0, legality 0, PG connectivity clean, PG DRC clean
Clean x=240 VDD PG blockage trial | BEST_CURRENT_OPEN | 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_routes.rpt | set_pg_strategy -blockage for VDD/M2 in hotspot; route DRC 368, open nets 0, legality 0, route-stage PG connectivity clean, PG DRC clean
Clean x=240 VDD + x=260 VSS PG blockage trial | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_vss260/06_route/drc_detail/drc.matrix.rpt | route DRC 376, open nets 0, legality 0, PG clean; needs-fat-contact improves to 104 but spacing/off-grid/shorts worsen, so best remains VDD-only blockage at 368
VDD PG blockage + multi-cell pin-access check trial | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_pincheck/06_route/drc_detail/drc.matrix.rpt | route DRC 368, open nets 0, legality 0, PG clean; same matrix as current best, so the single placement pin-access check option does not improve closure
VDD PG blockage + off-track via-region placement support trial | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_offtrackvia/06_route/drc_detail/drc.matrix.rpt | route DRC 368, open nets 0, legality 0, PG clean; same matrix as current best, so the single off-track via-region legalizer option does not improve closure
Route grid/via option syntax probe | RECORDED | 7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/route_grid_option_value_probe.rpt | single-brace Tcl list text such as '{M2 0.5}' is the correct env value form; double-brace env text causes invalid option values
VDD PG blockage + M2 off-grid via cost 0.5 trial | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2offgridcost05b/06_route/drc_detail/drc.matrix.rpt | option applied, route DRC 368, open nets 0, legality 0, PG clean; matrix unchanged, so small M2 off-grid via cost does not improve closure
VDD PG blockage + VIA1 on-grid route option trial | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_via1ongrid_b/06_route/check_routes.rpt | option applied, route DRC 368, open nets 0, legality 0, PG clean; DRC type counts unchanged and ZRT-044 remains, so VIA1 on-grid forcing does not improve closure
VDD PG blockage + M2 wire-on-grid route option trial | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m2wireongrid/06_route/check_routes.rpt | option applied, route DRC worsens to 378, open nets 0, legality 0, PG clean; grid policy changes DRC mix but not closure
Current best saved-block restore | BEST_CURRENT_OPEN_RESTORED | 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240_restore2/06_route/check_routes.rpt | saved ICC2 block restored to VDD/M2 PG blockage best condition; route DRC 368, open nets 0, legality 0, PG clean
VDD PG blockage + M1 wire-on-grid route option trial | PASS_WITH_OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_pgblock_vdd240_m1wireongrid/06_route/check_routes.rpt | option applied, route DRC worsens to 380, open nets 0, legality 0, PG clean; fat-contact improves but spacing/off-grid worsen
Current-best DRC geometry residue analysis | RECORDED | 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.geometry_analysis.rpt | 120/120 M1-M2 needs-fat-contact markers share residue rx=0.064/ry=0.064; M2/VIA1 off-grid markers cluster around the same y residue, supporting lower-metal pin/contact/grid mismatch plus PG obstruction
Current-best marker context probe | RECORDED | 7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/99_marker_context/marker_context.rpt | 35 representative markers map mostly to OR2X1_HVT, NOR2X0_HVT, and NOR2X4_HVT pins; OR2X1_HVT dominates M1 spacing/fat-contact representatives, while NOR2X*_HVT dominates M2/VIA1 off-grid representatives
OR2X1_HVT dont_use route combo trial | BEST_CURRENT_OPEN_CAUSE_EVIDENCE | 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/check_routes.rpt | route DRC improves 368 -> 203 with open nets 0, legality 0, PG connectivity clean, PG DRC clean; final DRC is Off-grid 203 only; OR2X1_HVT confirmed as major spacing/fat-contact contributor, but remaining off-grid root cause persists
OR2X1_HVT + NOR2X0_HVT + NOR2X2_HVT dont_use route combo trial | BEST_CURRENT_OPEN_CAUSE_EVIDENCE | 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/06_route/drc_detail/drc.matrix.rpt | route DRC improves 203 -> 188 with open nets 0, legality 0, PG connectivity clean, PG DRC clean; final DRC is Off-grid 186 and Diff net spacing 2; remaining representative markers are dominated by NOR2X1_HVT and persistent MUX41X2_HVT/S0 valid-via-region warning
OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT dont_use route combo trial | BEST_CURRENT_OPEN_CAUSE_EVIDENCE | 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/06_route/drc_detail/drc.matrix.rpt | route DRC improves 188 -> 110 with open nets 0, legality 0, PG connectivity clean, PG DRC clean; final matrix is M1 5, M2 53, VIA1 52; NOR2X1_HVT confirmed as major lower-metal off-grid contributor
OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT + NOR2X4_HVT dont_use route combo trial | REJECTED | 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/drc_detail/drc.matrix.rpt | FE passed, but route DRC worsens 110 -> 481 with open nets 0, legality 0, PG clean; Off-grid 477, M2 232, VIA1 245; broad NOR2X4_HVT removal causes restructuring and is not a valid fix
OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT + OR2X4_HVT dont_use route combo trial | REJECTED | 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_or2x4_hvt/06_route/check_routes.rpt | FE passed, but route DRC is 111 with open nets 0, legality 0, PG clean; this is worse than no012 110 and A1/A2 pin-swap 103, so narrow OR2X4_HVT add-on avoidance is not a fix
NOR2X4->NOR2X2 ECO + A1/A2 pin-swap route trial | REJECTED | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_plus_a2_pin_swap/06_route/drc_detail/drc.matrix.rpt | all 43 resize ECOs and 52 pin swaps applied, but route DRC worsens from current best 67 to 112 with open nets 0, legality 0, PG clean; M1 4, M2 54, VIA1 54; current best remains NOR2-only resize ECO
Original EDK NDM 8.5ns backend fair baseline | OPEN_BASELINE | 7_Backend_ICC2/4_Report/trials/edk_original_8p5ns_scan_def_m8/06_route/check_routes.rpt | same 8.5ns post-DFT handoff as libdir modify trial; route DRC 412, open nets 0, legality 0, PG DRC clean; main classes are diff spacing 112, needs-fat-contact 128, off-grid 165
libdir modify LEF NDM 8.5ns backend trial | OPEN_BUT_IMPROVED | 7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m8/06_route/check_routes.rpt | frontend handoff unchanged; backend physical NDM uses /DATA/home/edu135/lib/libdir/LEF/modify; route DRC improves 412 -> 151, open nets 0, legality 0, PG DRC clean; remaining DRC mostly off-grid 143, ZRT-044 still present
libdir modify LEF + M9 signal max route trial | OPEN_BUT_BEST_LIBDIR_AUTO_ROUTE | 7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9/06_route/check_routes.rpt | frontend handoff unchanged; route DRC 147, open nets 0, legality 0, PG connectivity clean, PG DRC clean; M8 baseline 151 -> M9 147, so improvement is small
libdir modify LEF + M8 post-route repair trial | OPEN_REPAIR_WEAK | 7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m8_repair200/06_route/check_routes.rpt | route_auto 151 -> incremental route_detail repair 150; open nets 0, legality 0, PG clean; repair loop is not an effective closure knob
libdir modify LEF + M9 post-route repair trial | OPEN_REPAIR_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9_repair200/06_route/check_routes.rpt | route_auto 147 -> incremental route_detail repair 149; open nets 0, legality 0, PG clean; M9 alone remains better than M9 plus repair
libdir modify LEF + clean 8.5ns + stale no012 ECO file | INVALID_ECO_COMPARISON | 7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9_nor2x4_to_nor2x2_eco/01_init_design/eco_swap.rpt | route DRC 147, open nets 0, legality 0, PG clean, but 42 ECO swaps failed and 1 target was missing because the ECO list was generated from the no012 netlist; treat as M9-only, not a valid ECO result
libdir modify LEF + no012 NOR2 resize ECO + PG block | OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/libdir_modify_no012_nor2x4_to_nor2x2_eco_m8_pgblock/06_route/check_routes.rpt | all 43 ECO swaps applied and were kept dont_touch, but route DRC is 89 all-Off-grid; original-EDK NDM current-best remains better at official 67 DRC under the no012/ECO/PG-block flow
NOR2 resize ECO + matched A2 VIA1 blockage 0.055um | OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_a2_via1_blockage/06_route/check_routes.rpt | route DRC 70, open nets 0, legality 0, PG clean; Off-grid improves 59 -> 5 but Short worsens 4 -> 57, so broad A2 VIA1 blockage proves causality but is not a fix
NOR2 resize ECO + matched A2 VIA1 blockage 0.025um | OPEN_TIE_REJECTED_AS_FIX | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_a2_via1_blockage_025/06_route/check_routes.rpt | route DRC 67, open nets 0, legality 0, PG clean; Off-grid improves 59 -> 1 but Short worsens 4 -> 59, so it ties count while worsening class quality
NOR2 resize ECO + OR2X4 A2 VIA1 blockage 0.025um | OPEN_REJECTED_AS_BEST | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_or2x4_a2_blockage_025_fix/06_route/check_routes.rpt | route DRC 114, open nets 0, legality 0, PG clean; corrected OR2X4-only blockages applied but worsened Off-grid/Short, so OR2X4 A2 blockage is not a fix
NOR2 resize ECO + post-route detail repair 200 | OPEN_REPAIR_REJECTED_AS_FIX | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_repair200/06_route/check_routes.rpt | before repair DRC 67, after incremental route_detail repair DRC 114; open nets 0, legality 0, PG clean; repair loop worsens off-grid count and is not accepted
NOR2 resize ECO + M1/M2 track constraint probe | OPEN_REJECTED_AS_FIX | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_track_constraint_m1m2_core/06_route/check_routes.rpt | M1/M2 track constraints applied and report_track_constraints is non-empty, but official check_routes remains 67 DRC with open nets 0, legality 0, PG clean; route_auto internal 66 is not accepted over final check_routes 67
NOR2 resize ECO + advanced legalizer/pin-color M1/M2 | OPEN_REJECTED_AS_FIX | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_advlegalizer_pin_color_m1m2/06_route/check_routes.rpt | route DRC worsens to 109 all-Off-grid with open nets 0, legality 0, PG clean; placement pin-access alignment remains rejected for this ECO state
NOR2 resize ECO + M9 max signal route | OPEN_REJECTED_AS_FIX | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_m9/06_route/check_routes.rpt | route DRC worsens to 125 with open nets 0, legality 0, PG clean; allowing M9 is not a closure knob for the residual lower-metal A2 issue
trim_all_pin NDM + NOR2 resize ECO | OPEN_BUT_NEAR_CLEAN | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_eco_ndm_trim_all_pin/06_route/check_routes.rpt | route DRC improves 67 -> 1 with open nets 0, legality 0, PG clean; remaining marker is M1 Off-grid at u_core/core_i/U1723 MUX41X2_HVT/S0
trim_all_pin NDM + NOR2 resize ECO + one MUX41 resize ECO | ROUTE_DRC_CLEAN | 7_Backend_ICC2/4_Report/trials/route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin/06_route/check_routes.rpt | official check_routes reports open nets 0 and DRC 0; check_legality 0 violations; PG connectivity all floating counts 0; route log check_pg_drc says No errors found
```

### Timing

```text
Stage | Clock | WNS | TNS | Area | Power | Notes
Post-synth pre-DFT topo/SDF | 10 ns | 1.61 ns | 0.00 ns | 45313.37 cell area | see topo post_compile.power.rpt | DC Graphical topo + PT SDF STA timing clean, DRC not clean
Post-DFT topo/SDF | 10 ns | 1.48 ns | 0.00 ns | 49449.82 cell area | see post_dft.power.rpt | DFT inserted; PT post-DFT SDF STA setup/hold clean, hold slack 0.03 ns
Post-synth pre-DFT topo | 8.5 ns | 0.41 ns | 0.00 ns | 45394.19 cell area | see topo_8p5ns post_compile.power.rpt | DC Graphical topo timing clean; backend dont_use variants not used
Post-DFT topo/SDF | 8.5 ns | 0.44 ns | 0.00 ns | 49429.48 cell area | see topo_8p5ns post_dft.power.rpt | PT post-DFT SDF STA setup/hold clean; hold slack 0.04 ns; SDF annotation errors 0
ICC2 initial placement | 10 ns | 0.57 ns | not summarized | 49449.8147 cell area | not summarized | pre-CTS/pre-route ICC2 timing estimate with TLU+ RC after PG closure
ICC2 first-pass CTS | 10 ns | 1.98 ns listed worst setup path | not summarized | 58348.41 design area in log final QoR | not summarized | post-CTS/pre-signal-route timing estimate; listed worst hold slack 0.02 ns
ICC2 first-pass route | 10 ns | 2.00 ns listed worst setup path | not summarized | 58348.41 cell area | not summarized | post-route estimate with detailed routed nets; listed worst hold slack 0.02 ns; route DRC not clean
ICC2 60% util route trial | 10 ns | 2.10 ns listed worst setup path | not summarized | not summarized | not summarized | route DRC not clean; listed worst hold slack 0.02 ns
ICC2 60% util + M8 route-layer trial | 10 ns | 2.11 ns listed worst setup path | not summarized | not summarized | not summarized | route DRC not clean; listed worst hold slack 0.02 ns
ICC2 detail route repair 1iter | 10 ns | 2.11 ns listed worst setup path | not summarized | not summarized | not summarized | route DRC not clean; listed worst hold slack 0.02 ns
no_mux41x_hvt post-DFT topo/SDF | 10 ns | no setup violation | 0.00 ns | 49420.84 DC post-DFT cell area | see topo_no_mux41x_hvt post_dft.power.rpt | PT post-DFT SDF STA setup/hold clean; route DRC trial rejected
no_or2x1_hvt post-DFT topo/SDF | 10 ns | no setup violation | 0.00 ns | see topo_no_or2x1_hvt reports | see topo_no_or2x1_hvt post_dft.power.rpt | PT post-DFT SDF STA setup/hold clean; route DRC improves to 203 but remains open
no_or2x1_nor2x02_hvt post-DFT topo/SDF | 10 ns | no setup violation | 0.00 ns | see topo_no_or2x1_nor2x02_hvt reports | see topo_no_or2x1_nor2x02_hvt post_dft.power.rpt | PT post-DFT SDF STA setup/hold clean; route DRC improves to 188 but remains open
no_or2x1_nor2x012_hvt post-DFT topo/SDF | 10 ns | no setup violation | 0.00 ns | see topo_no_or2x1_nor2x012_hvt reports | see topo_no_or2x1_nor2x012_hvt post_dft.power.rpt | PT post-DFT SDF STA setup/hold clean; route DRC improves to 110 but remains open
no_or2x1_nor2x0124_hvt post-DFT topo/SDF | 10 ns | no setup violation | 0.00 ns | 45487.20 pre-DFT cell area | see topo_no_or2x1_nor2x0124_hvt reports | PT post-DFT SDF STA setup/hold clean; backend route trial rejected because DRC worsens to 481
```

### Fmax Estimate

```text
Basis | Clock | Worst Setup Slack | Estimated Critical Delay | Ideal Fmax | Next Trial
Post-DFT topo/SDF STA | 10.00 ns | 1.48 ns | 8.52 ns | 117.4 MHz | 8.5 ns first, then 8.0 ns if clean
Post-DFT topo/SDF STA | 8.50 ns | 0.44 ns | 8.06 ns | 124.1 MHz | 8.0 ns only if the user wants a stretch trial
```

### Equivalence

```text
Stage | Tool | Result | Passing | Failing | Notes
R2N topo | Formality W-2024.09-SP5 | PASS | 2243 | 0 | Functional mode constants applied; reverse clock-gating enabled; undriven scan_out marked don't-verify
N2N post-DFT topo | Formality W-2024.09-SP5 | PASS | 2243 | 0 | Functional mode constants applied; scan_out don't-verify; 74 clock-gate LAT not compared
R2N topo 8.5ns | Formality W-2024.09-SP5 | PASS | 2243 | 0 | Clean baseline mixed-VT 8.5 ns synthesis remains equivalent to RTL
N2N post-DFT topo 8.5ns | Formality W-2024.09-SP5 | PASS | 2243 | 0 | 8.5 ns pre-DFT vs post-DFT remains equivalent in functional mode
R2N no_mux41x_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | MUX41X*_HVT avoidance synthesis remains equivalent to RTL
N2N no_mux41x_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | no_mux41x_hvt pre-DFT vs post-DFT remains equivalent in functional mode
R2N no_or2x1_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | OR2X1_HVT avoidance synthesis remains equivalent to RTL
N2N no_or2x1_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | no_or2x1_hvt pre-DFT vs post-DFT remains equivalent in functional mode
R2N no_or2x1_nor2x02_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | OR2X1_HVT + NOR2X0_HVT + NOR2X2_HVT avoidance synthesis remains equivalent to RTL
N2N no_or2x1_nor2x02_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | no_or2x1_nor2x02_hvt pre-DFT vs post-DFT remains equivalent in functional mode
R2N no_or2x1_nor2x012_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT avoidance synthesis remains equivalent to RTL
N2N no_or2x1_nor2x012_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | no_or2x1_nor2x012_hvt pre-DFT vs post-DFT remains equivalent in functional mode
R2N no_or2x1_nor2x0124_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT + NOR2X4_HVT avoidance synthesis remains equivalent to RTL
N2N no_or2x1_nor2x0124_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | no_or2x1_nor2x0124_hvt pre-DFT vs post-DFT remains equivalent in functional mode
R2N no_or2x1_nor2x012_or2x4_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | Narrow OR2X4_HVT add-on avoidance synthesis remains equivalent to RTL
N2N no_or2x1_nor2x012_or2x4_hvt | Formality W-2024.09-SP5 | PASS | 2243 | 0 | no_or2x1_nor2x012_or2x4_hvt pre-DFT vs post-DFT remains equivalent in functional mode
```

### DFT/ATPG

```text
Item | Result | Notes
Scan chains | 1 | muxed scan
Scan length | 2130 | TetraMAX traced chain0 scan_in -> scan_out
DFT DRC | PASS_WITH_NOTE | 1 TEST-505 constant-1 clock-gate note; 2130 valid scan cells
Fault model | stuck-at | first-pass scope
Fault coverage | 98.55% | 82949 collapsed faults, DT 81697, PT 99, UD 74, AU 14, ND 1065
Test coverage | 98.64% | 448 internal basic_scan patterns; ATPG stopped after meeting 98% target
no_mux41x_hvt fault coverage | 98.51% | 82941 collapsed faults, DT 81662, PT 94, UD 77, AU 14, ND 1094
no_mux41x_hvt test coverage | 98.61% | 448 internal basic_scan patterns; ATPG stopped after meeting 98% target
8.5ns scan chains | 1 | muxed scan
8.5ns scan length | 2130 | TetraMAX traced chain0 scan_in -> scan_out
8.5ns DFT DRC | PASS_WITH_NOTE | 1 TEST-505 constant-1 clock-gate note; 2130 valid scan cells
8.5ns fault coverage | 98.31% | 83009 collapsed faults, DT 81553, PT 111, UD 75, AU 14, ND 1256
8.5ns test coverage | 98.40% | 416 internal basic_scan patterns; ATPG stopped after meeting 98% target
```
