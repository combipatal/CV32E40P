# Pin Access / Route DRC Overlap And Spread Trial

## 목적

blocked access 좌표와 route DRC bbox가 실제로 같은 물리 영역에 몰리는지 확인하고, placement spreading option이 route DRC와 blocked access를 줄이는지 시험했다.

## 실행

```text
Date: 2026-05-08
Overlap parser:
  python3 scripts/analyze_pin_access_drc_overlap.py

Spreading trial:
  env TRIAL_NAME=pin_access_spread CORE_UTILIZATION=0.60 SIGNAL_MAX_ROUTING_LAYER=M8 PLACE_PIN_DENSITY_AWARE=true PLACE_MAX_DENSITY=0.70 PLACE_TARGET_ROUTING_DENSITY=0.70 PLACE_INCREASED_CELL_EXPANSION=true icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pin_access_spread/pin_access_spread.log -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl

Post-trial blocked access:
  env TRIAL_NAME=pin_access_spread_blocked_detail icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pin_access_spread_blocked_detail/pin_access_spread_blocked_detail.log -f 7_Backend_ICC2/0_Script/99_util/run_pin_access_blocked_detail.tcl
```

## 증거 파일

```text
scripts/analyze_pin_access_drc_overlap.py
scripts/summarize_cell_pin_access.py
7_Backend_ICC2/3_Log/trials/pin_access_spread/pin_access_spread.log
7_Backend_ICC2/4_Report/trials/pin_access_drc_overlap/99_overlap/
7_Backend_ICC2/4_Report/trials/pin_access_spread/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/pin_access_spread/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/pin_access_spread/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/pin_access_spread_blocked_detail/99_pin_access/
```

## Overlap 결과

기준:

```text
blocked_point_count = 305
drc_marker_count    = 400
```

nearest DRC 거리:

```text
<=2um  : 13
<=5um  : 23
<=10um : 51
<=25um : 193
<=50um : 289
```

50um bucket overlap:

```text
overlap_bucket50_count = 21
```

해석:

```text
blocked access와 route DRC가 완전 1:1 같은 좌표는 아니다.
하지만 blocked point 305개 중 289개가 route DRC 50um 안에 있다.
따라서 같은 lower-metal 혼잡/접근성 영역에 같이 몰린다고 보는 것이 타당하다.
```

주요 nearest DRC type:

```text
Off-grid          123
Needs fat contact 112
Diff net spacing   54
Short              16
```

## Spreading Trial 설정

기존 60% + M8 trial에서 placement option만 추가했다.

```text
place.coarse.pin_density_aware = true
place.coarse.max_density = 0.70
place.coarse.target_routing_density = 0.70
place.coarse.increased_cell_expansion = true
```

로그 확인:

```text
Pin density aware placement mode.
Automatic density control selected max_density 0.70.
target_routing_density 0.70은 tool이 0.80으로 올려 사용했다.
```

## Spreading Trial 결과

Route:

```text
open nets = 0
check_routes DRC = 390
```

DRC breakdown:

```text
Diff net spacing       97
Less than minimum area 5
Needs fat contact      121
Off-grid               164
Same net spacing       1
Short                  2
```

비교:

```text
60util_m8 baseline: 400 DRC
detail-route 1iter best evidence: 383 DRC
pin_access_spread: 390 DRC
```

Legality/PG:

```text
placement legality = 0 violations
route legality     = 0 violations
VDD/VSS floating wires/vias/std cells/terminals = 0
PG DRC = no errors
```

Blocked access after spreading:

```text
official blocked pins = 144
line-level blocked entries = 150
```

Ref별 line-level:

```text
SDFFARX1_RVT 126
MUX41X1_HVT   22
INVX8_LVT      2
```

비교:

```text
previous official blocked pins: 117
spread trial official blocked pins: 144

previous line-level blocked entries: 125
spread trial line-level blocked entries: 150
```

## 판단

```text
pin-density/max-density spreading trial은 reject.
이유: route DRC는 400 -> 390으로 조금 줄었지만, blocked access는 117 -> 144로 악화됐다.
```

더 강한 결론:

```text
단순히 cell을 퍼뜨리는 option만으로는 해결되지 않는다.
SDFFARX1_RVT/MUX41X1_HVT pin access는 placement option보다 scan-chain handoff, legalizer pin-track alignment, 또는 lower-metal/via/contact setup 쪽 영향이 크다.
```

## 다음 액션

```text
1. scan DEF 생성/import 가능성 확인.
2. place.legalize.enable_advanced_legalizer와 pin-track alignment 관련 option 확인.
3. MUX41X*_HVT no-valid-via-region warning과 blocked access 증가를 별도 확인.
4. placement spreading option은 단독 fix로 쓰지 않는다.
```
