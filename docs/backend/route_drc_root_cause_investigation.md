# Route DRC Root-Cause Investigation

## 목적

현재 목표는 DRC를 바로 줄이는 것이 아니라, hotspot DRC의 원인을 찾는 것이다.

따라서 blind route trial은 중단하고, 아래 순서로 원인을 좁힌다.

```text
reproduce -> marker 분해 -> 가설 작성 -> 가설별 probe -> fix trial
```

## 재현 loop

기준 상태는 `scan_def_m8_restore`이다.

```text
open nets: 0
route DRC: 398
legality: 0 violations
PG connectivity: floating 0
PG DRC: clean
```

증거:

```text
7_Backend_ICC2/4_Report/trials/scan_def_m8_restore/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/all_drc_markers.tsv
7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/marker_context.rpt
```

이 loop는 빠르게 다시 확인할 수 있다.

```text
icc2_shell -batch -f 7_Backend_ICC2/0_Script/06_route/run_route_drc_detail.tcl
```

## 전체 DRC 분포

Fresh detail extraction 기준:

```text
total DRC: 398

Diff net spacing       M1 116, M2 4
Needs fat contact      M1-M2 99
Off-grid               M1 10, M2 78, VIA1 82
Less than minimum area M2 8
Short                  M1 1
```

판단:

```text
문제는 top-level open/PG/legality가 아니다.
문제는 M1/M2/VIA1 lower-metal route access 쪽이다.
```

## Hotspot 분포

핫스팟 조사 영역:

```text
{{215.0 195.0} {265.0 265.0}}
```

이 영역 안에 DRC marker 123개가 있다.

```text
Off-grid VIA1          48
Off-grid M2            46
Diff net spacing M1    18
Needs fat contact      10
Off-grid M1             1
```

판단:

```text
hotspot의 주 증상은 M2/VIA1 off-grid다.
전체 DRC에서는 fat-contact도 크지만, hotspot 내부만 보면 off-grid가 우세하다.
```

## 대표 marker 관찰

### Off-grid 대표

예: `error_id 140/141`

```text
type: Off-grid VIA1 + Off-grid M2
center: 230.037 201.640
near cell: NOR2X0_HVT
near pin: A1, VDD, VSS
net: alu_div_i/Cnt_DP[1]
```

이 marker는 같은 좌표에서 M2와 VIA1 off-grid가 같이 나온다.

예: `error_id 184/185`

```text
type: Off-grid VIA1 + Off-grid M2
center: 240.427 222.920
near cell: NOR2X0_HVT
near signal pin: A1
near PG shape:
  VDD M2 bbox {239.8000 13.0000} {240.2000 312.9120}
  VDD M8 bbox {239.5000 13.0000} {240.5000 312.9120}
```

판단:

```text
일부 off-grid marker는 stdcell signal pin, stdcell VDD/VSS pin,
그리고 M2 PG stripe가 같은 작은 창 안에 있다.
```

### Needs fat contact 대표

예: `error_id 262`

```text
type: Needs fat contact
center: 227.784 243.136
near cell: OR2X1_HVT
near pins: A1, Y
near M2 signal routes: several M2 shapes
```

판단:

```text
fat-contact marker는 OR2X1_HVT 같은 작은 comb cell pin 근처에서 반복된다.
이 문제는 PG만으로 설명되지 않고 stdcell pin access + M1-M2 via legality 쪽 냄새가 강하다.
```

## 이미 약해진 가설

### 전체 밀도 문제

60% utilization trial:

```text
route DRC 407
```

60% + M8 route bound:

```text
route DRC 400
```

결론:

```text
전체 core utilization만 낮춰서는 해결되지 않는다.
```

### hotspot cell density만의 문제

hotspot 40% partial blockage:

```text
area/utilization: 증가
route DRC: 398 -> 390
open nets: 0
legality: 0
PG clean
```

결론:

```text
핫스팟 cell density는 영향을 주지만 주원인 단독은 아니다.
```

### advanced legalizer / pin color option 부족

advanced legalizer + pin color trial:

```text
route DRC 605
```

결론:

```text
현재 옵션 조합은 원인 해결 방향이 아니다.
```

## 현재 원인 가설

### H1. stdcell pin access + M2/VIA1 off-grid interaction

우선순위: 높음

근거:

```text
hotspot DRC 123개 중 94개가 M2/VIA1 off-grid다.
대표 marker가 NOR2X0_HVT, OR2X1_HVT 같은 작은 cell pin 근처에 있다.
M2/VIA1 off-grid가 같은 좌표에서 pair로 나온다.
```

예측:

```text
pin access 또는 via-on-grid 제약을 강하게 주면 off-grid가 줄어야 한다.
PG를 바꿔도 일부만 줄고, pin 근처 off-grid는 남을 수 있다.
```

다음 probe:

```text
route.common.via_on_grid_by_layer_name
route.common.wire_on_grid_by_layer_name
route.common.extra_via_off_grid_cost_multiplier_by_layer_name
route.detail.generate_extra_off_grid_pin_tracks
route.detail.force_end_on_preferred_grid
```

위 옵션은 fix로 바로 채택하지 말고, 한 번에 하나씩 원인 probe로만 쓴다.

### H2. M2 PG mesh가 hotspot pin access를 막는다

우선순위: 높음

근거:

```text
일부 off-grid marker 창에 VDD/VSS M2/M8 PG stripe가 같이 잡힌다.
대표 error_id 184/185는 VDD M2 stripe x=239.8..240.2 바로 옆이다.
hotspot은 M2/VIA1 off-grid가 우세하다.
```

반대 근거:

```text
모든 hotspot marker가 PG stripe 중심 근처는 아니다.
Needs fat contact 대표는 signal M2 route와 stdcell pin만으로도 설명된다.
```

예측:

```text
M2 PG mesh offset을 바꾸거나 M2 mesh를 약화하면
PG stripe 근처 off-grid marker가 위치 이동 또는 감소해야 한다.
전체 DRC가 크게 줄지 않아도 PG-related subset은 줄어야 한다.
```

다음 probe:

```text
PG M2 mesh offset 20um -> 30um
또는 hotspot window 안에서 PG shape와 DRC marker 거리 통계 작성
```

### H3. LEF-built NDM / pin-check library quality issue

우선순위: 중간

근거:

```text
SAED32 original Milkyway reference를 직접 쓸 수 없어 DB+LEF-built NDM을 쓰고 있다.
create_pin_check_lib는 되지만 analyze_lib_pin은 LIB-001로 막혔다.
blocked access official count가 117개 있다.
CO default contact가 없다.
```

반대 근거:

```text
VIA1 default via는 존재한다.
CO는 stdcell 내부 contact 계층이라 route M1-M2 DRC 전체를 단독 설명하긴 약하다.
```

예측:

```text
pin-check lib 설정을 더 정식으로 맞추면 특정 ref cell의 blocked pin과 route marker가 더 직접적으로 연결되어야 한다.
vendor Milkyway ref를 쓸 수 있으면 DRC 양상이 달라질 가능성이 있다.
```

### H4. route detail off-grid/via policy가 기본값에서 너무 느슨하다

우선순위: 중간

근거:

```text
ICC2 route app option에 off-grid/via 관련 옵션이 있다.
현재 기본값은 off-grid pin track 추가가 꺼져 있고, via-on-grid/wire-on-grid layer list도 비어 있다.
```

증거:

```text
7_Backend_ICC2/4_Report/trials/root_cause_probe/99_manual/route_common_app_options.rpt
7_Backend_ICC2/4_Report/trials/root_cause_probe/99_manual/route_detail_app_options.rpt
```

예측:

```text
route option만 바꿔도 M2/VIA1 off-grid 수가 변해야 한다.
변화가 없으면 route policy보다 physical obstruction/pin geometry 쪽이 강하다.
```

### H5. scan chain / scan DEF 부재

우선순위: 낮음

근거:

```text
scan DEF handoff 후 route DRC는 398이다.
scan chain read와 optimize_dft는 동작했다.
```

결론:

```text
scan DEF 부재는 현재 hotspot DRC의 주원인이 아니다.
```

## 다음 원인 조사 순서

해결 trial이 아니라 원인 분리 probe로 진행한다.

```text
1. hotspot DRC와 PG M2 stripe 거리 통계를 만든다.
2. PG M2 offset probe를 1회만 돌린다.
   목적: PG 관련 subset이 움직이는지 확인.
3. 변화가 작으면 via/grid route option probe로 이동한다.
4. 변화가 크면 PG mesh 구조가 원인 축으로 확정된다.
5. 마지막까지 manual cell move는 하지 않는다.
```

## 현재 결론

아직 root cause는 확정하지 않았다.

현재 가장 강한 판단은:

```text
hotspot DRC는 단순 배치 밀도 문제가 아니다.
핵심 증상은 ALU/div hotspot 주변의 stdcell pin access와 M2/VIA1 off-grid다.
PG M2 mesh는 일부 marker에서 강한 공범 후보지만, 단독 원인으로 확정되지는 않았다.
```

## PG M2 Distance Probe

PG 간섭 가설을 보기 위해 hotspot 안의 M2 PG shape를 덤프하고, 기존 DRC marker와의 거리를 계산했다.

증거:

```text
7_Backend_ICC2/0_Script/99_util/run_hotspot_pg_shape_probe.tcl
scripts/analyze_hotspot_pg_distance.py
7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance/hotspot_pg_shapes.tsv
7_Backend_ICC2/4_Report/trials/root_cause_probe/99_pg_distance/hotspot_drc_pg_distance_summary.rpt
```

hotspot 안 M2 PG stripe는 3개다.

```text
VSS M2 x=219.8..220.2
VDD M2 x=239.8..240.2
VSS M2 x=259.8..260.2
```

hotspot marker 123개와 M2 PG shape 거리:

```text
<= 0.25um: 6
<= 0.50um: 18
<= 1.00um: 23
<= 2.00um: 32
<= 5.00um: 78
>  5.00um: 45
```

판단:

```text
PG M2 stripe와 매우 가까운 DRC가 실제로 있다.
하지만 전체 123개 중 45개는 5um보다 멀다.
따라서 PG는 원인 축 중 하나지만 단독 원인으로는 부족하다.
```

## PG M2 Offset Probe

PG M2 mesh offset을 20um에서 30um으로 바꾼 probe를 실행했다.

조건:

```text
trial: pgm2off30_scan_def_m8
scan DEF: enabled
signal max layer: M8
PG M2 mesh offset: 30.0
```

증거:

```text
7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/03_power/pg_mesh_trial_settings.rpt
7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/04_place/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/pgm2off30_scan_def_m8/06_route/pg_drc.rpt
```

결과:

```text
route open nets: 0
placement legality: 0 violations
signal route DRC: 398 -> 377
PG DRC after placement: 60 M1 insufficient spacing errors
PG DRC after route: 97 M1 insufficient spacing errors
```

signal route DRC matrix:

```text
Diff net spacing       120 -> 82
Less than minimum area   8 -> 5
Needs fat contact       99 -> 127
Off-grid               170 -> 163
Short                    1 -> 0
```

판단:

```text
M2 PG 위치를 바꾸면 signal route DRC 분포가 크게 변한다.
따라서 PG mesh 위치는 route DRC 원인 축이 맞다.

그러나 30um offset은 PG DRC를 새로 만들기 때문에 해법으로는 invalid다.
또 off-grid는 170 -> 163으로 조금만 줄었다.
따라서 전체 hotspot DRC의 주원인은 PG 하나가 아니라
PG mesh + stdcell pin access + M2/VIA1 route policy가 같이 얽힌 문제로 보는 것이 더 맞다.
```

현재 원인 판단 업데이트:

```text
확정에 가까움:
  PG M2 mesh는 route DRC에 영향을 준다.

아직 미확정:
  PG가 주원인인지, pin/via/grid 정책이 주원인인지.

더 강해진 가설:
  stdcell pin access + M2/VIA1 off-grid interaction
  with PG mesh as a contributing obstruction
```
