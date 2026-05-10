# CV32E40P Project Closure

Date: 2026-05-10 UTC

## Closure Declaration

```text
Status: CLOSED_AS_EDUCATIONAL_FE_TO_BE_IMPLEMENTATION_FLOW
Scope: learning/portfolio FE-to-BE flow, not tapeout signoff
Final candidate: hold_eco17_flop_q_load_split / hold_eco17_gds_candidate
```

CV32E40P 프로젝트는 학습용 FE-to-BE implementation flow로 종료한다.

완료 범위는 8.5 ns front-end closure, post-route MCMM ECO17 timing/electrical cleanup, final ECO17 N2N Formality PASS, 그리고 educational GDS candidate export까지다.

## Final Evidence

```text
Front-end target: 8.5 ns
Post-DFT SDF STA: setup/hold clean
Post-DFT setup slack: +0.44 ns
Post-DFT hold slack: +0.04 ns
ATPG fault coverage: 98.31%
ATPG test coverage: 98.40%
ATPG patterns: 416
```

```text
Backend candidate: hold_eco17_flop_q_load_split
Route DRC: 0
Open nets: 0
Legality violations: 0
PrimeTime propagated-clock SPEF STA: TT/SS/FF -40C cmax/cmin setup/hold clean
PrimeTime report_constraint -all_violators: TT/SS/FF -40C cmax/cmin clean
ICC2 electrical constraints after filler: total violations 0
```

```text
Final ECO17 Formality N2N: PASS
Passing compare points: 2243
Failing compare points: 0
Unmatched compare points: 0
Clock-gate LAT not compared: 74, consistent with previous functional N2N policy
```

```text
GDS candidate: cv32e40p_synth_wrap.hold_eco17_gds_candidate.gds
GDSII Stream version: 5.0
Recorded GDS size: 46 MB
GDS export status: PASS_WITH_SIGNOFF_CAVEAT
```

## What This Project Proves

```text
1. Build a reproducible front-end flow from open RTL.
2. Close a mixed-VT 8.5 ns synthesis/DFT/STA/Formality/ATPG milestone.
3. Carry the post-DFT netlist into ICC2 through floorplan, PG, place, CTS, route, SPEF STA, ECO, and GDS export.
4. Debug backend issues using report evidence instead of guesswork.
5. Handle MCMM ECO tradeoffs: SS setup, FF hold, residual max_cap, flop-Q load split.
6. Keep claim boundaries clear: educational GDS candidate, not tapeout signoff.
```

## Claim Boundary

Acceptable claim:

```text
CV32E40P 8.5 ns FE closure and ECO17 educational backend/GDS candidate completed.
```

Do not claim:

```text
tapeout-ready
foundry signoff clean
production signoff GDS
full backend signoff
```

Missing full-signoff items:

```text
signoff DRC deck
LVS
antenna signoff
IR/EM
noise
metal fill
final signoff STA methodology
waiver/review policy for foundry handoff
```

## Final Interview Sentence

```text
CV32E40P RISC-V core를 대상으로 DC/PT/Formality/DFT/TetraMAX/ICC2 기반 FE-to-BE flow를 구축했다. 8.5 ns front-end closure 이후 post-route MCMM ECO를 통해 route DRC 0, open nets 0, legality 0, TT/SS/FF setup/hold clean 상태를 확보했고, final N2N Formality PASS 및 학습용 GDS export까지 완료했다. 다만 signoff DRC/LVS, antenna, IR/EM, metal fill은 범위 밖으로 명확히 분리했다.
```

## Next Action After Closure

```text
1. Portfolio two-page report update
2. Study-plan extraction from scripts/reports
3. Move active implementation effort to MNIST/NPU project
```
