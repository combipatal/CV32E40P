# 2026-05-07 Baseline Freeze And Fmax Estimate

## Frozen Baseline

```text
Run: tt_mvt_10ns_scan1
Commit: 5473b61
Decision: use this as the first complete Front-End baseline
Status: complete baseline, not signoff-clean
```

## Why Frozen

```text
The flow now reaches:
DC topo synthesis
R2N Formality
DFT topo with post-DFT SDF/SPF
N2N Formality
post-DFT SDF STA
TetraMAX stuck-at ATPG
```

## Fmax Estimate

```text
Basis: post-DFT topo/SDF STA
Clock: 10.00 ns
Worst setup slack: 1.48 ns
Estimated critical delay: 8.52 ns
Ideal Fmax: about 117.4 MHz
```

## Next Trial

```text
Use 8.5 ns as first Fmax-oriented synthesis trial.
Use 8.0 ns only after reviewing the 8.5 ns result.
Do not jump directly to 5.0 ns.
```
