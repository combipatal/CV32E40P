# 2026-05-07 DFT/N2N/ATPG/STA Status

## Summary

```text
Front-end baseline now reaches:
DFT topo -> N2N Formality -> post-DFT SDF STA -> TetraMAX stuck-at ATPG.
```

## Key Fix

```text
Initial ATPG coverage was low because the SPF was written before insert_dft.
That SPF had an empty ScanStructures block.
The DFT script now writes SPF after insert_dft.
TetraMAX now traces chain0 successfully with 2130 scan cells.
```

## Evidence

```text
DFT log:
  3_DFT/3_Log/dft_topo.log

DFT reports:
  3_DFT/4_Report/topo/post_dft.drc.rpt
  3_DFT/4_Report/topo/scan_path.existing.rpt
  3_DFT/4_Report/topo/post_dft.qor.rpt

Post-DFT artifacts:
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.ddc
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.vg
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.sdc
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.sdf
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.spf

N2N reports:
  5_FM_N2N/4_Report/n2n_topo.failing_points.rpt
  5_FM_N2N/4_Report/n2n_topo.passing_points.post_verify.rpt

Post-DFT SDF STA reports:
  6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.global_timing.rpt
  6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.setup_timing.rpt
  6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.hold_timing.rpt

ATPG reports:
  4_ATPG/4_Report/stuck_at_topo/summary.rpt
  4_ATPG/4_Report/stuck_at_topo/faults.summary.rpt
  4_ATPG/4_Report/stuck_at_topo/scan_chains.rpt

ATPG pattern:
  4_ATPG/2_Output/patterns/cv32e40p_synth_wrap.stuck_at.serial.stil
```

## Results

```text
DFT:
  scan chains: 1
  chain0 length: 2130
  DFT DRC: PASS_WITH_NOTE
  note: TEST-505 constant-1 clock-gate cell

N2N Formality:
  result: Verification SUCCEEDED
  passing compare points: 2243
  failing compare points: 0

Post-DFT SDF STA:
  read_sdf errors: 0
  setup violations: none
  hold violations: none
  worst setup slack: 1.48 ns
  worst hold slack: 0.03 ns

TetraMAX stuck-at:
  total collapsed faults: 82949
  test coverage: 98.64%
  fault coverage: 98.55%
  patterns: 448 basic_scan
```

## Remaining Notes

```text
Do not claim production DFT signoff.
TetraMAX still reports 6 Z3 wire-contention warnings.
DC/PT max_cap and max_transition cleanup remains a physical/backend follow-up.
```
