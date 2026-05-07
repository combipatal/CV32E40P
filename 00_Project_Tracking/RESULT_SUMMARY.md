# Result Summary

## Summary Tables

### Implementation

```text
Stage | Tool | Result | Key Output | Notes
RTL intake | git/filelist | PASS | rtl/cv32e40p + filelists/cv32e40p_dc.tcl | upstream sim clock gate/tb excluded
Synthesis | DC | PASS_WITH_NOTE | 2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.{ddc,vg,sdc} | 10 ns TT mixed-VT; one rounded max_cap residual
Topo synthesis | DC Graphical | PASS_WITH_NOTE | 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.{ddc,vg,sdc,sdf} | 10 ns TT mixed-VT; timing-clean, DRC-not-clean
R2N | Formality | PASS | 2.5_FM_R2N/4_Report/r2n_topo.*.rpt | topo RTL-to-netlist verify succeeded; no failing compare points
DFT | DC/DFT Compiler topo | PASS_WITH_NOTE | 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.{ddc,vg,sdc,sdf,spf} | 1 muxed chain, SPF has chain0 length 2130; DFT DRC has TEST-505 note
N2N | Formality | PASS | 5_FM_N2N/4_Report/n2n_topo.*.rpt | pre-DFT topo netlist vs post-DFT topo netlist; 2243 passing, 0 failing
ATPG | TetraMAX | PASS_WITH_NOTE | 4_ATPG/4_Report/stuck_at_topo/summary.rpt | stuck-at reached 98.64% test coverage; TMAX DRC has 6 Z3 wire-contention warnings
STA | PrimeTime | PASS_WITH_NOTE | 6_STA/4_Report/pre_dft.func_tt_10ns.*.rpt | setup/hold clean; PT max_cap residual requires follow-up
SDF STA | PrimeTime | PASS_WITH_NOTE | 6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.*.rpt | SDF annotated with 0 errors; setup/hold clean; max_cap residual remains
Post-DFT SDF STA | PrimeTime | PASS_WITH_NOTE | 6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.*.rpt | post-DFT SDF annotated with 0 errors; setup/hold clean; max_cap residual remains
```

### Timing

```text
Stage | Clock | WNS | TNS | Area | Power | Notes
Post-synth pre-DFT | 10 ns | 0.02 ns | 0.00 ns | 44899.37 cell area | see post_compile.power.rpt | DC reports no timing violations
Post-synth pre-DFT topo/SDF | 10 ns | 1.61 ns | 0.00 ns | 45313.37 cell area | see topo post_compile.power.rpt | DC Graphical topo + PT SDF STA timing clean, DRC not clean
Post-DFT topo/SDF | 10 ns | 1.48 ns | 0.00 ns | 49449.82 cell area | see post_dft.power.rpt | DFT inserted; PT post-DFT SDF STA setup/hold clean, hold slack 0.03 ns
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
