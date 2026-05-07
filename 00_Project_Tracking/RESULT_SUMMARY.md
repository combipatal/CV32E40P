# Result Summary

## Summary Tables

### Implementation

```text
Stage | Tool | Result | Key Output | Notes
RTL intake | git/filelist | PASS | rtl/cv32e40p + filelists/cv32e40p_dc.tcl | upstream sim clock gate/tb excluded
Synthesis | DC | PASS_WITH_NOTE | 2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.{ddc,vg,sdc} | 10 ns TT mixed-VT; one rounded max_cap residual
R2N | Formality | TBD | TBD | TBD
DFT | DC/DFT Compiler | TBD | TBD | TBD
N2N | Formality | TBD | TBD | TBD
ATPG | TetraMAX | TBD | TBD | TBD
STA | PrimeTime | PASS_WITH_NOTE | 6_STA/4_Report/pre_dft.func_tt_10ns.*.rpt | setup/hold clean; PT max_cap residual requires follow-up
```

### Timing

```text
Stage | Clock | WNS | TNS | Area | Power | Notes
Post-synth pre-DFT | 10 ns | 0.02 ns | 0.00 ns | 44899.37 cell area | see post_compile.power.rpt | DC reports no timing violations
Post-DFT | 10 ns | TBD | TBD | TBD | TBD | TBD
```

### DFT/ATPG

```text
Item | Result | Notes
Scan chains | 1 | muxed scan
DFT DRC | TBD | TBD
Fault model | stuck-at | first-pass scope
Fault coverage | TBD | TBD
Test coverage | TBD | TBD
```
