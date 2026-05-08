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
```

### Timing

```text
Stage | Clock | WNS | TNS | Area | Power | Notes
Post-synth pre-DFT topo/SDF | 10 ns | 1.61 ns | 0.00 ns | 45313.37 cell area | see topo post_compile.power.rpt | DC Graphical topo + PT SDF STA timing clean, DRC not clean
Post-DFT topo/SDF | 10 ns | 1.48 ns | 0.00 ns | 49449.82 cell area | see post_dft.power.rpt | DFT inserted; PT post-DFT SDF STA setup/hold clean, hold slack 0.03 ns
ICC2 initial placement | 10 ns | 0.57 ns | not summarized | 49449.8147 cell area | not summarized | pre-CTS/pre-route ICC2 timing estimate with TLU+ RC after PG closure
ICC2 first-pass CTS | 10 ns | 1.98 ns listed worst setup path | not summarized | 58348.41 design area in log final QoR | not summarized | post-CTS/pre-signal-route timing estimate; listed worst hold slack 0.02 ns
ICC2 first-pass route | 10 ns | 2.00 ns listed worst setup path | not summarized | 58348.41 cell area | not summarized | post-route estimate with detailed routed nets; listed worst hold slack 0.02 ns; route DRC not clean
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
