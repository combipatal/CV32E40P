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
```

### Timing

```text
Stage | Clock | WNS | TNS | Area | Power | Notes
Post-synth pre-DFT topo/SDF | 10 ns | 1.61 ns | 0.00 ns | 45313.37 cell area | see topo post_compile.power.rpt | DC Graphical topo + PT SDF STA timing clean, DRC not clean
Post-DFT topo/SDF | 10 ns | 1.48 ns | 0.00 ns | 49449.82 cell area | see post_dft.power.rpt | DFT inserted; PT post-DFT SDF STA setup/hold clean, hold slack 0.03 ns
ICC2 initial placement | 10 ns | 0.57 ns | not summarized | 49449.8147 cell area | not summarized | pre-CTS/pre-route ICC2 timing estimate with TLU+ RC after PG closure
ICC2 first-pass CTS | 10 ns | 1.98 ns listed worst setup path | not summarized | 58348.41 design area in log final QoR | not summarized | post-CTS/pre-signal-route timing estimate; listed worst hold slack 0.02 ns
ICC2 first-pass route | 10 ns | 2.00 ns listed worst setup path | not summarized | 58348.41 cell area | not summarized | post-route estimate with detailed routed nets; listed worst hold slack 0.02 ns; route DRC not clean
ICC2 60% util route trial | 10 ns | 2.10 ns listed worst setup path | not summarized | not summarized | not summarized | route DRC not clean; listed worst hold slack 0.02 ns
ICC2 60% util + M8 route-layer trial | 10 ns | 2.11 ns listed worst setup path | not summarized | not summarized | not summarized | route DRC not clean; listed worst hold slack 0.02 ns
ICC2 detail route repair 1iter | 10 ns | 2.11 ns listed worst setup path | not summarized | not summarized | not summarized | route DRC not clean; listed worst hold slack 0.02 ns
```

### Fmax Estimate

```text
Basis | Clock | Worst Setup Slack | Estimated Critical Delay | Ideal Fmax | Next Trial
Post-DFT topo/SDF STA | 10.00 ns | 1.48 ns | 8.52 ns | 117.4 MHz | 8.5 ns first, then 8.0 ns if clean
```

### Equivalence

```text
Stage | Tool | Result | Passing | Failing | Notes
R2N topo | Formality W-2024.09-SP5 | PASS | 2243 | 0 | Functional mode constants applied; reverse clock-gating enabled; undriven scan_out marked don't-verify
N2N post-DFT topo | Formality W-2024.09-SP5 | PASS | 2243 | 0 | Functional mode constants applied; scan_out don't-verify; 74 clock-gate LAT not compared
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
```
