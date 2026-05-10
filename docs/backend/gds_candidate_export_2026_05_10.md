# ECO17 GDS Candidate Export

Date: 2026-05-10

## Input State

Source block:

```text
cv32e40p_synth_wrap_hold_eco17_flop_q_load_split
```

Known clean evidence before GDS export:

```text
route DRC: 0
open nets: 0
legality: 0
PT TT/SS/FF -40C cmax/cmin setup/hold: clean
PT TT/SS/FF -40C cmax/cmin report_constraint: clean
Formality N2N: PASS, 2243 passing, 0 failing
```

## GDS Export Flow

Script:

```text
7_Backend_ICC2/0_Script/09_gds/run_write_gds_eco17_candidate.tcl
```

Command:

```text
icc2_shell -batch -f 7_Backend_ICC2/0_Script/09_gds/run_write_gds_eco17_candidate.tcl
```

The script copies the source block to:

```text
cv32e40p_synth_wrap_hold_eco17_gds_candidate
```

Then it performs:

```text
1. create_stdcell_fillers
2. connect_pg_net -automatic
3. check_routes
4. check_legality
5. report_constraints -all_violators
6. write_verilog
7. write_def
8. write_sdc
9. write_gds with stdcell GDS merge files
```

## Filler Result

Filler cells found:

```text
RVT: SHFILL128/64/3/2/1
HVT: SHFILL128/64/3/2/1
LVT: SHFILL128/64/3/2/1
```

Inserted fillers reported by ICC2:

```text
SHFILL128_RVT: 9
SHFILL64_RVT : 58
SHFILL3_RVT  : 23827
SHFILL2_RVT  : 3015
SHFILL1_RVT  : 3332
```

PG reconnect:

```text
Power net VDD: 16903 -> 47765 pins
Ground net VSS: 16903 -> 47765 pins
```

## Output

Generated GDS:

```text
7_Backend_ICC2/2_Output/09_gds/hold_eco17_gds_candidate/cv32e40p_synth_wrap.hold_eco17_gds_candidate.gds
```

File check:

```text
GDSII Stream file version 5.0
size: 46 MB
```

Other generated handoff files:

```text
7_Backend_ICC2/2_Output/09_gds/hold_eco17_gds_candidate/cv32e40p_synth_wrap.hold_eco17_gds_candidate.vg
7_Backend_ICC2/2_Output/09_gds/hold_eco17_gds_candidate/cv32e40p_synth_wrap.hold_eco17_gds_candidate.def
7_Backend_ICC2/2_Output/09_gds/hold_eco17_gds_candidate/cv32e40p_synth_wrap.hold_eco17_gds_candidate.sdc
7_Backend_ICC2/2_Output/09_gds/hold_eco17_gds_candidate/gds_export_manifest.txt
```

## Post-Filler Checks

ICC2 route check:

```text
open nets: 0
route DRC: 0
```

ICC2 legality:

```text
TOTAL 0 Violations
```

ICC2 constraints:

```text
max_transition violations: 0
max_capacitance violations: 0
min_capacitance violations: 0
min_pulse_width violations: 0
total violations: 0
```

Evidence:

```text
7_Backend_ICC2/4_Report/09_gds/hold_eco17_gds_candidate/check_routes.after_filler.rpt
7_Backend_ICC2/4_Report/09_gds/hold_eco17_gds_candidate/check_legality.after_filler.rpt
7_Backend_ICC2/4_Report/09_gds/hold_eco17_gds_candidate/constraints.after_filler.rpt
```

## Caveat

This is an ICC2 educational final-candidate GDS.

Do not call it tapeout-ready or full signoff.

Missing full signoff items:

```text
signoff DRC deck
LVS
antenna signoff
IR/EM
noise
metal fill
final signoff STA methodology
```
