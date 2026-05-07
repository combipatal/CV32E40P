# Decision Log

## Fixed Decisions

```text
Primary goal: Front-End closure
Conditional Phase 2: ICC2 backend after Front-End closure
Run name: tt_mvt_10ns_scan1
Source intake: plain clone into rtl/cv32e40p
Top: cv32e40p_synth_wrap
Wrapper policy: pass through all functional ports
Initial config: FPU=0, COREV_PULP=0, COREV_CLUSTER=0, NUM_MHPMCOUNTERS=1
Initial corner: TT 1.05V 25C
Initial libraries: RVT + LVT + HVT mixed-VT
Clock period: 10 ns
Clock gate cell: CGLPPRX2_RVT
DFT insertion: DC/DFT Compiler
Scan chain count: 1
ATPG: TetraMAX stuck-at
Required equivalence: R2N and N2N Formality
Baseline freeze: tt_mvt_10ns_scan1 front-end baseline fixed at commit 5473b61
Next timing exploration: estimate from post-DFT topo/SDF slack before changing clock
```

See:

```text
docs/tt_mvt_10ns_scan1_execution_spec.md
```

## Baseline Freeze

```text
Date: 2026-05-07
Baseline: tt_mvt_10ns_scan1
Commit: 5473b61
Status: Front-End baseline completed, not signoff-clean
Evidence: DC topo, R2N, DFT topo, N2N, post-DFT SDF STA, TetraMAX stuck-at ATPG
Reason: Freeze the first complete reproducible 10 ns run before Fmax experiments.
```

## Fmax Estimate Decision

```text
Basis: post-DFT topo/SDF PrimeTime STA
Clock period: 10.00 ns
Worst setup slack: 1.48 ns
Estimated critical path delay: 8.52 ns
Ideal Fmax estimate: 117.4 MHz
Next trial candidates: 8.5 ns first, 8.0 ns if 8.5 ns is clean enough
Constraint: this is pre-layout/topographical estimate, not post-route signoff Fmax
```
