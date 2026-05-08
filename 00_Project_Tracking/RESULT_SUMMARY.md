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
```

### Timing

```text
Stage | Clock | WNS | TNS | Area | Power | Notes
Post-synth pre-DFT topo/SDF | 10 ns | 1.61 ns | 0.00 ns | 45313.37 cell area | see topo post_compile.power.rpt | DC Graphical topo + PT SDF STA timing clean, DRC not clean
Post-DFT topo/SDF | 10 ns | 1.48 ns | 0.00 ns | 49449.82 cell area | see post_dft.power.rpt | DFT inserted; PT post-DFT SDF STA setup/hold clean, hold slack 0.03 ns
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
