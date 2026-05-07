# 2026-05-07 Front-End R2N Status

## Current Baseline

```text
Run name: tt_mvt_10ns_scan1
Top: cv32e40p_synth_wrap
Corner: TT 1.05V 25C
Libraries: SAED32 RVT + LVT + HVT
Clock: 10 ns
Synthesis mode: DC Graphical topographical
STA mode: PrimeTime functional SDF STA
Equivalence: Formality R2N
```

## Completed Evidence

```text
Topo synthesis: PASS_WITH_NOTE
SDF STA: PASS_WITH_NOTE
Formality R2N: PASS
```

Key reports:

```text
2_Synthesis/4_Report/topo/post_compile.qor.rpt
2_Synthesis/4_Report/topo/post_compile.timing.rpt
6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.timing.rpt
2.5_FM_R2N/4_Report/r2n_topo.failing_points.rpt
2.5_FM_R2N/4_Report/r2n_topo.passing_points.post_verify.rpt
2.5_FM_R2N/4_Report/r2n_topo.unmatched_points.post_verify.rpt
```

## Formality R2N Judgment

```text
Result: Verification SUCCEEDED
Passing compare points: 2243
Failing compare points: 0
```

Settings required for this result:

```text
verification_clock_gate_reverse_gating = true
scan_cg_en_i = 0
scan_en = 0
scan_in = 0
scan_out = directly undriven output, marked don't-verify
```

Reasoning:

```text
DC inserted latch-based integrated clock gates during compile_ultra -gate_clock.
Without reverse clock-gating, Formality reports unmatched implementation LATCG
points and failing register compare points. Enabling reverse clock-gating lets
Formality compare the functional register behavior instead of treating inserted
clock-gate latches as ordinary unmatched state.
```

## Remaining Non-Blocking Item

```text
Topographical synthesis and SDF STA are timing-clean at 10 ns.
max_cap/max_transition design-rule violations remain.
User decision: defer capacitance cleanup to backend/physical phase.
```

## Next Step

```text
Proceed to DFT insertion:
  one muxed scan chain
  scan_en / scan_in / scan_out wrapper ports
  scan_cg_en_i used as clock-gate test enable

Then run:
  Formality N2N
  TetraMAX stuck-at ATPG
  post-DFT STA
```
