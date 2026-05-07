# tt_mvt_10ns_scan1 Fmax Estimate

## Baseline

```text
Run: tt_mvt_10ns_scan1
Commit: 5473b61
Status: Front-End baseline complete, not signoff-clean
Clock: 10.00 ns
Corner: TT 1.05V 25C
Libraries: SAED32 RVT + LVT + HVT mixed-VT
Top: cv32e40p_synth_wrap
DFT: 1 muxed scan chain, chain0 length 2130
```

## Evidence

```text
Post-DFT STA:
  6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.global_timing.rpt
  6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.setup_timing.rpt
  6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.hold_timing.rpt

DFT:
  3_DFT/4_Report/topo/post_dft.qor.rpt
  3_DFT/4_Report/topo/post_dft.drc.rpt

ATPG:
  4_ATPG/4_Report/stuck_at_topo/summary.rpt
```

## Timing Basis

```text
Post-DFT SDF STA setup violations: none
Post-DFT SDF STA hold violations: none
Worst setup slack: 1.48 ns
Worst hold slack: 0.03 ns
```

## Calculation

```text
Estimated critical path delay = clock period - worst setup slack
Estimated critical path delay = 10.00 ns - 1.48 ns
Estimated critical path delay = 8.52 ns

Ideal Fmax = 1 / 8.52 ns
Ideal Fmax = 117.4 MHz
```

## Interpretation

```text
This is a pre-layout/topographical estimate.
It is suitable for choosing the next synthesis trial.
It is not a post-route signoff Fmax.
```

## Next Clock Trial

```text
Recommended first trial: 8.5 ns
Reason: closest to estimated critical delay without jumping too far.

Optional aggressive trial: 8.0 ns
Reason: useful if 8.5 ns is clean or nearly clean.

Avoid first jumping to 5.0 ns.
Reason: current evidence does not support a 200 MHz baseline yet.
```

## Carry-Forward Notes

```text
Keep max_cap/max_transition cleanup as physical/backend follow-up.
Keep DFT TEST-505 and TetraMAX Z3 notes categorized.
If the clock is changed, rerun at least:
  DC topo synthesis
  R2N Formality
  DFT topo
  N2N Formality
  post-DFT SDF STA
  TetraMAX stuck-at ATPG
```
