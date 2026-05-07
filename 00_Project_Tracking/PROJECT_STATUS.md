# Project Status

## Current Phase

```text
Front-End baseline completed through DFT, N2N, ATPG, and post-DFT SDF STA
```

## Next Milestone

```text
Review remaining DRC notes before calling the flow signoff-clean.
```

## Frozen Baseline

```text
Run: tt_mvt_10ns_scan1
Commit: 5473b61
Status: Front-End baseline complete
Meaning: 10 ns topo synthesis, R2N, DFT topo, N2N, post-DFT SDF STA, and stuck-at ATPG are reproducible from scripts.
Not included: production signoff, post-route STA, IR/EM, GDS signoff.
```

## Milestone Checklist

```text
[x] Clone CV32E40P
[x] Record source revision
[x] Create wrapper RTL
[x] Create technology clock gate RTL
[x] Create DC/FM filelists
[x] Create 10 ns SDC
[x] DC analyze/elaborate/link
[x] DC compile
[x] Formality R2N
[x] DFT insertion
[x] Formality N2N
[x] TetraMAX stuck-at ATPG
[x] PrimeTime STA
[x] Portfolio summary tables
```

## Current Notes

```text
DFT is topographical and writes post-DFT DDC/VG/SDC/SDF/SPF.
SPF is written after insert_dft so TetraMAX sees chain0 length 2130.
TetraMAX stuck-at ATPG reached 98.64% test coverage and 98.55% fault coverage.
Remaining notes: DC DFT TEST-505 constant-1 clock gate, TetraMAX Z3 wire contention warnings, and physical max_cap/max_transition cleanup deferred to backend.
```

## Fmax Estimate

```text
Basis: post-DFT topo/SDF STA
Clock: 10.00 ns
Worst setup slack: 1.48 ns
Estimated critical path delay: 8.52 ns
Ideal Fmax: about 117.4 MHz
Next trial: 8.5 ns first; 8.0 ns if 8.5 ns remains clean enough
```
