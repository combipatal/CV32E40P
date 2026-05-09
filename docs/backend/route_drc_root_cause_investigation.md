# Route DRC Root-Cause Investigation

## 목적

현재 목표는 DRC를 바로 줄이는 것이 아니라, hotspot DRC의 원인을 찾는 것이다.

따라서 blind route trial은 중단하고, 아래 순서로 원인을 좁힌다.

```text
reproduce -> marker 분해 -> 가설 작성 -> 가설별 probe -> fix trial
```

## 재현 loop

기준 상태는 이제 `route_combo_pgblock_vdd240`이다.

이전 기준 `scan_def_m8_restore`는 398 DRC였고, 원인 탐색용으로 유효했다.
하지만 x=240 VDD/M2 hotspot PG strategy blockage가 PG clean 상태로 DRC를 368까지 낮췄으므로,
이제 남은 DRC의 근본 원인은 368 DRC 기준으로 본다.

```text
open nets: 0
route DRC: 368
legality: 0 violations
PG connectivity: floating 0
PG DRC: clean
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.geometry_analysis.rpt
```

이 loop는 빠르게 다시 확인할 수 있다.

```text
env TRIAL_NAME=route_combo_pgblock_vdd240 \
  CORE_UTILIZATION=0.60 \
  SIGNAL_MAX_ROUTING_LAYER=M8 \
  SCAN_DEF_FILE=3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def \
  PG_M2_HOTSPOT_BLOCKAGE_ENABLE=1 \
  PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY='{{238.0 195.0} {242.0 265.0}}' \
  PG_M2_HOTSPOT_BLOCKAGE_NETS='VDD' \
  PG_M2_HOTSPOT_BLOCKAGE_LAYERS='M2' \
  ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS=true \
  ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL=high \
  ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL=high \
  icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
```

## 전체 DRC 분포

현재 best detail extraction 기준:

```text
total DRC: 368

Needs fat contact      M1-M2 120
Diff net spacing       M1 89, M2 2
Off-grid               VIA1 79, M2 70, M1 3
Less than minimum area M2 5
```

판단:

```text
문제는 top-level open/PG/legality가 아니다.
문제는 M1/M2/VIA1 lower-metal route access 쪽이다.
PG blockage로 일부 줄었지만 남은 368개는 여전히 lower-metal/contact/grid 문제다.
```

## Hotspot 분포

핫스팟 조사 영역:

```text
{{215.0 195.0} {265.0 265.0}}
```

이 영역 안에 DRC marker 120개가 있다.

```text
Off-grid VIA1          48
Off-grid M2            42
Needs fat contact      16
Diff net spacing M1    12
Off-grid M1             1
Less than min area M2   1
```

판단:

```text
hotspot의 주 증상은 여전히 M2/VIA1 off-grid다.
하지만 current best에서는 M1-M2 needs-fat-contact도 hotspot 안에 남아 있다.
```

## Current-Best Geometry Residue Probe

남은 DRC marker 좌표를 0.152um pitch 기준으로 residue 분석했다.

증거:

```text
scripts/analyze_route_drc_geometry.py
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/all_drc_markers.tsv
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/drc.geometry_analysis.rpt
```

핵심 결과:

```text
Needs fat contact M1-M2:
  rx=0.064 ry=0.064 : 120/120

Off-grid VIA1:
  rx=0.061 ry=0.064 : 65
  rx=0.066 ry=0.064 : 13
  rx=0.062 ry=0.064 : 1

Off-grid M2:
  rx=0.061 ry=0.064 : 59
  rx=0.066 ry=0.064 : 10
  rx=0.062 ry=0.064 : 1

Less than min area M2:
  rx=0.064 ry=0.064 : 5/5

Diff net spacing M1:
  rx=0.064 dominates, ry near 0.000 or 0.025
```

판단:

```text
남은 DRC는 랜덤 congestion 문제가 아니다.
M1-M2 needs-fat-contact 120개가 전부 같은 residue에 걸린다.
M2/VIA1 off-grid도 거의 같은 residue cluster에 몰린다.
따라서 root cause는 routing option 하나보다
SAED32 stdcell M1 pin/contact geometry, generated NDM routing grid, VIA1/contact legality,
그리고 local PG obstruction이 맞물린 lower-metal access mismatch로 보는 것이 맞다.
```

PG 거리 분석:

```text
전체 368 marker 중 M2 PG stripe 5um 밖: 246
hotspot M2 PG stripe 5um 안 marker: 59
```

판단:

```text
PG는 분명히 공범이다.
하지만 전체 DRC 대부분은 PG stripe 근처만으로 설명되지 않는다.
PG만 지워서는 closure가 안 되는 이유다.
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

완전한 closure root cause는 아직 1개로 확정하지 않았다.
하지만 broad trial 단계보다 원인은 훨씬 구체화됐다.

현재 가장 강한 판단은:

```text
hotspot DRC는 단순 배치 밀도 문제가 아니다.
남은 368 DRC는 deterministic lower-metal access 문제다.
M1-M2 needs-fat-contact는 전부 같은 grid residue에 걸린다.
M2/VIA1 off-grid도 거의 같은 residue cluster에 몰린다.
PG M2 mesh는 route DRC에 영향을 주는 공범이지만, 단독 원인은 아니다.
가장 강한 root-cause model:
  SAED32 stdcell M1 pin/contact geometry
  + generated NDM routing grid / VIA1 legality mismatch
  + local M2 PG obstruction
```

다음 원인 probe:

```text
route_combo_pgblock_vdd240의 남은 368 DRC marker를 current block 기준으로 다시 cell/pin context에 매핑한다.
목표는 어떤 ref cell/pin이 needs-fat-contact 120개와 M2/VIA1 off-grid residue cluster를 만드는지 확인하는 것이다.
이 확인 전에는 broad dont_use, broad PG blockage, broad route option trial을 늘리지 않는다.
```

## Targeted HVT Avoidance 결과

### OR2X1_HVT

결과:

```text
route DRC: 368 -> 203
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: clean
```

판단:

```text
OR2X1_HVT는 M1 spacing / M1-M2 needs-fat-contact의 큰 원인이 맞다.
하지만 남은 DRC는 모두 Off-grid라서 root cause가 끝난 것은 아니다.
```

### NOR2X0_HVT + NOR2X2_HVT

결과:

```text
route DRC: 203 -> 188
Off-grid: 186
M2: 88
VIA1: 91
```

판단:

```text
NOR2X0_HVT/NOR2X2_HVT는 contributor지만 효과는 작다.
남은 marker context는 NOR2X1_HVT 쪽으로 이동했다.
```

### NOR2X1_HVT

결과:

```text
route DRC: 188 -> 110
Off-grid: 104
Diff net spacing: 5
Short: 1

matrix:
  M1: 5
  M2: 53
  VIA1: 52
```

판단:

```text
NOR2X1_HVT는 major lower-metal off-grid contributor로 확정한다.
MVT 자체는 여전히 유지 가능하다.
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt/99_marker_context/marker_context.rpt
```

### NOR2X4_HVT broad dont_use

결과:

```text
front-end: pass
route DRC: 110 -> 481
Off-grid: 477
M2: 232
VIA1: 245
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: clean
```

판단:

```text
NOR2X4_HVT는 marker context에 많이 보였지만 broad dont_use fix는 아니다.
NOR2X4_HVT 제거는 합성 구조를 크게 바꿔서 small/replacement cell과 routing demand를 늘린다.
cell count도 13880 -> 14302로 증가했다.
따라서 "marker 주변 ref cell = 무조건 dont_use" 접근은 여기서 중단한다.
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x0124_hvt/06_route/drc_detail/drc.matrix.rpt
2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.references.rpt
```

현재 best cause-evidence 상태:

```text
trial: route_combo_no_or2x1_nor2x012_hvt
route DRC: 110
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: clean
```

다음 원인 조사 방향:

```text
1. 110-DRC design을 기준으로 본다.
2. broad dont_use를 더 늘리지 않는다.
3. SDFFARX1_RVT와 MUX41X2_HVT/S0의 pin-access/valid-via-region 문제를 직접 본다.
4. 필요하면 "셀 전체 금지"가 아니라 pin/access-aware placement, scan flop option, 또는 NDM/LEF pin access 설정 쪽을 먼저 검토한다.
```

## Current-Best Marker Context Probe

current-best 368 DRC에서 대표 marker 35개를 다시 ICC2 current block에 매핑했다.

증거:

```text
7_Backend_ICC2/0_Script/99_util/run_drc_marker_context.tcl
7_Backend_ICC2/3_Log/trials/route_combo_pgblock_vdd240_context/route_combo_pgblock_vdd240_context.log
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/06_route/drc_detail/representative_summary.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgblock_vdd240/99_marker_context/marker_context.rpt
```

대표 marker의 nearby pin ref 분포:

```text
OR2X1_HVT      46
NOR2X0_HVT     23
NOR2X4_HVT      6
SDFFARX1_RVT    5
AO22X1_HVT      5
FADDX2_HVT      3
NAND2X0_HVT     2
```

관찰:

```text
M1 diff spacing 대표 3개는 모두 OR2X1_HVT 근처다.
Needs-fat-contact 대표들은 대부분 OR2X1_HVT 근처다.
M2/VIA1 off-grid 대표들은 NOR2X0_HVT/NOR2X4_HVT 근처가 반복된다.
일부 off-grid 대표는 x=240 VDD M8 PG stripe 또는 x=260 VSS M2/M8 PG stripe 근처다.
하지만 많은 대표 marker는 signal M2/M3/M4 route와 stdcell pin만으로도 설명된다.
```

업데이트된 판단:

```text
OR2X1_HVT는 current-best 남은 needs-fat-contact/M1 spacing의 가장 강한 ref-cell 후보이다.
NOR2X0_HVT/NOR2X4_HVT는 M2/VIA1 off-grid의 가장 강한 ref-cell 후보이다.
SDFFARX1_RVT는 hotspot contributor지만 대표 marker 기준 전체 주범은 아니다.
다음 fix 후보는 broad dont_use가 아니라 ref-cell별 targeted trial이어야 한다.
우선순위:
  1. OR2X1_HVT 관련 M1-M2 fat-contact/M1 spacing 원인 확인
  2. NOR2X0_HVT/NOR2X4_HVT 관련 M2/VIA1 off-grid 원인 확인
  3. 필요 시 해당 ref cell만 dont_use 또는 sizing 대체 trial
  4. 동시에 NDM/tech pin-access setup에서 이 ref cell pin access가 왜 같은 residue에 걸리는지 확인
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

## Route Off-Grid / Via Policy Probes

route option이 원인인지 보기 위해 `run_trial_60util_to_route.tcl`에 route option env hook을 추가했다.

추가한 env hook:

```text
ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS
ROUTE_DETAIL_FORCE_END_ON_PREFERRED_GRID
ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL
ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL
ROUTE_COMMON_EXTRA_VIA_OFF_GRID_COST_BY_LAYER
ROUTE_COMMON_VIA_ON_GRID_BY_LAYER
ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER
```

### Extra Off-Grid Pin Tracks

조건:

```text
trial: route_offgrid_tracks_scan_def_m8
scan DEF: enabled
signal max layer: M8
route.detail.generate_extra_off_grid_pin_tracks: true
```

증거:

```text
7_Backend_ICC2/3_Log/trials/route_offgrid_tracks_scan_def_m8/route_offgrid_tracks_scan_def_m8.log
7_Backend_ICC2/4_Report/trials/route_offgrid_tracks_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_offgrid_tracks_scan_def_m8/06_route/route_detail_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_offgrid_tracks_scan_def_m8/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_offgrid_tracks_scan_def_m8/06_route/pg_drc.rpt
```

결과:

```text
route open nets: 0
PG DRC: clean
route DRC: 398 -> 385
```

matrix:

```text
Diff net spacing       120 -> 134
Less than minimum area   8 -> 5
Needs fat contact       99 -> 84
Off-grid               170 -> 160
Short                    1 -> 1
```

판단:

```text
extra off-grid pin track은 일부 효과가 있다.
특히 M1-M2 needs-fat-contact와 off-grid가 조금 줄었다.
하지만 전체 개선은 13개뿐이고 off-grid 160개가 계속 남는다.
따라서 off-grid pin track 부족은 원인 축 중 하나지만 단독 root cause는 아니다.
```

### Route Via/DRC Effort

조건:

```text
trial: route_via_effort_scan_def_m8
scan DEF: enabled
signal max layer: M8
route.detail.drc_convergence_effort_level: high
route.detail.optimize_wire_via_effort_level: high
```

증거:

```text
7_Backend_ICC2/3_Log/trials/route_via_effort_scan_def_m8/route_via_effort_scan_def_m8.log
7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/route_detail_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/pg_drc.rpt
```

결과:

```text
route open nets: 0
PG DRC: clean
route DRC: 398 -> 389
```

matrix:

```text
Diff net spacing       120 -> 135
Less than minimum area   8 -> 5
Needs fat contact       99 -> 84
Off-grid               170 -> 163
Short                    1 -> 1
```

판단:

```text
router effort를 high로 올려도 DRC가 크게 줄지 않는다.
따라서 단순 detail-route effort 부족은 주원인이 아니다.
```

### Route Option Probe 공통 단서

baseline과 두 route option probe 모두 같은 경고를 반복한다.

```text
ZRT-703: force_end_on_preferred_grid ignored because none of the layers have preferred grid
ZRT-022: Cannot find a default contact code for layer CO
ZRT-044: Standard cell pin MUX41X2_HVT/S0 has no valid via regions
```

해석:

```text
preferred-grid 강제 option은 현재 tech setup에서 효과가 없는 축이다.
CO default contact 부재는 계속 보이지만, 기존 contact diagnosis에서 VIA1 default via는 있었다.
MUX41X2_HVT/S0 valid via region 경고는 stdcell pin access / LEF-built NDM access data 쪽 원인 가능성을 키운다.
```

현재 원인 판단 업데이트:

```text
더 약해진 가설:
  단순 router effort 부족
  단순 preferred-grid option 문제

더 강해진 가설:
  stdcell valid via region / pin access data issue
  M2/VIA1 route policy sensitivity
  PG M2 mesh obstruction as a contributing factor
```

## OR2X1_HVT Targeted MVT Probe

조건:

```text
trial: route_combo_no_or2x1_hvt
flow: MVT 유지, OR2X1_HVT만 dont_use
front-end: DC topo -> R2N -> DFT -> N2N -> PT post-DFT SDF
backend: current-best route_combo_pgblock_vdd240 조건 재사용
```

증거:

```text
2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_hvt.log
2_Synthesis/4_Report/topo_no_or2x1_hvt/post_compile.references.rpt
2.5_FM_R2N/4_Report/no_or2x1_hvt/r2n_topo_no_or2x1_hvt.passing_points.post_verify.rpt
3_DFT/3_Log/insert_dft_10ns_topo_no_or2x1_hvt.log
5_FM_N2N/4_Report/no_or2x1_hvt/n2n_topo_no_or2x1_hvt.passing_points.post_verify.rpt
6_STA/3_Log/pt_post_dft_10ns_sdf_no_or2x1_hvt.log
7_Backend_ICC2/3_Log/trials/route_combo_no_or2x1_hvt/route_combo_no_or2x1_hvt.log
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_hvt/06_route/pg_drc.rpt
```

결과:

```text
OR2X1_HVT reference: removed from post_compile.references.rpt
R2N: PASS, 2243 pass / 0 fail
DFT: post-DFT netlist, SDC, SDF, SPF, scan DEF generated
N2N: PASS, 2243 pass / 0 fail
PT SDF STA: setup/hold met at 10ns
ICC2 route open nets: 0
ICC2 legality: 0 violations
ICC2 PG connectivity: clean
ICC2 PG DRC: clean
ICC2 route DRC: 368 -> 203
final DRC type: Off-grid 203 only
```

판단:

```text
OR2X1_HVT는 M1 spacing / M1-M2 needs-fat-contact 계열의 큰 원인이다.
하지만 단독 root cause는 아니다.

이유:
  route DRC가 크게 줄었지만 0은 아니다.
  남은 DRC가 전부 Off-grid로 재정렬됐다.
  로그에서 ZRT-044 MUX41X2_HVT/S0 no valid via regions가 계속 반복된다.
  NOR2X*_HVT도 이전 marker context에서 M2/VIA1 off-grid 대표 셀로 잡혔다.

현재 원인 모델:
  MVT 자체를 버릴 문제는 아니다.
  특정 HVT cell pin/contact geometry가 ICC2 routing grid/VIA1 access와 맞지 않는다.
  OR2X1_HVT는 spacing/fat-contact 축의 주요 셀이다.
  남은 축은 MUX41X2_HVT, NOR2X*_HVT, generated NDM/VIA1 off-grid behavior다.
```

## OR2X1 + NOR2X0/NOR2X2 Targeted Probe

조건:

```text
trial: route_combo_no_or2x1_nor2x02_hvt
flow: MVT 유지, OR2X1_HVT + NOR2X0_HVT + NOR2X2_HVT dont_use
front-end: DC topo -> R2N -> DFT -> N2N -> PT post-DFT SDF
backend: route_combo_no_or2x1_hvt와 같은 current-best physical 조건 재사용
```

증거:

```text
2_Synthesis/3_Log/compile_10ns_topo_no_or2x1_nor2x02_hvt.log
2_Synthesis/4_Report/topo_no_or2x1_nor2x02_hvt/post_compile.references.rpt
2.5_FM_R2N/4_Report/no_or2x1_nor2x02_hvt/r2n_topo_no_or2x1_nor2x02_hvt.passing_points.post_verify.rpt
3_DFT/4_Report/topo_no_or2x1_nor2x02_hvt/post_dft.drc.rpt
5_FM_N2N/4_Report/no_or2x1_nor2x02_hvt/n2n_topo_no_or2x1_nor2x02_hvt.passing_points.post_verify.rpt
6_STA/4_Report/post_dft_topo_sdf_no_or2x1_nor2x02_hvt/post_dft_no_or2x1_nor2x02_hvt.func_tt_10ns_sdf.global_timing.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x02_hvt/99_marker_context/marker_context.rpt
```

결과:

```text
R2N: PASS, 2243 pass / 0 fail
DFT: post-DFT netlist, SDC, SDF, SPF, scan DEF generated
N2N: PASS, 2243 pass / 0 fail
PT SDF STA: setup/hold met at 10ns
ICC2 route open nets: 0
ICC2 legality: 0 violations
ICC2 PG connectivity: clean
ICC2 PG DRC: clean
ICC2 route DRC: 203 -> 188
final DRC matrix:
  M1 8
  M2 88
  M7 1
  VIA1 91
final DRC type:
  Off-grid 186
  Diff net spacing 2
```

판단:

```text
NOR2X0_HVT/NOR2X2_HVT 제거는 효과가 작다.
남은 DRC는 거의 전부 M2/VIA1 Off-grid다.
대표 marker 주변 ref-cell은 NOR2X1_HVT가 가장 많다.
MUX41X2_HVT/S0 no valid via region 경고도 그대로 남는다.

현재 더 좁아진 원인 모델:
  OR2X1_HVT는 spacing/fat-contact 큰 원인으로 확인됐다.
  NOR2X0/NOR2X2는 일부 off-grid contributor였지만 주범은 아니다.
  남은 핵심은 NOR2X1_HVT 중심의 HVT lower-metal pin access/grid 문제다.
  MUX41X2_HVT/S0 valid via region 문제는 별도 persistent root-cause 축이다.
```

## Remaining 110 DRC Pin-Access Coordinate Diagnosis

조건:

```text
trial: route_combo_no_or2x1_nor2x012_hvt_restore
baseline: OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT dont_use
route result: 110 DRC, open nets 0, legality 0, PG clean
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/06_route/drc_detail/all_drc_markers.tsv
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_marker_context_all/marker_context.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/report_cell_pin_access.targets.details.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/drc_to_pin_access_coordinate_match.tsv
```

DRC matrix:

```text
Diff net spacing | M1 3 | M2 2 | total 5
Off-grid         | M1 1 | M2 51 | VIA1 52 | total 104
Short            | M1 1 | total 1
Total DRC        | 110
```

전체 110개 marker 주변 ref cell 집계:

```text
NOR2X4_HVT   85 markers
OR2X4_HVT    16 markers
SDFFARX1_RVT  7 markers
NOR2X0_HVT    2 markers
```

핵심 좌표 매칭:

```text
103 / 110 markers match a report_cell_pin_access coordinate within 0.08um.
All 103 matched points are A2 routable access points.

NOR2X4_HVT/A2 routable access:
  Off-grid VIA1: 43
  Off-grid M2  : 42

OR2X4_HVT/A2 routable access:
  Off-grid VIA1: 8
  Off-grid M2  : 8

NOR2X0_HVT/A2 routable access:
  Off-grid VIA1: 1
  Off-grid M2  : 1
```

판단:

```text
남은 104개 Off-grid 중 103개는 HVT OR/NOR 계열의 A2 access point와 직접 좌표가 맞는다.
report_cell_pin_access는 이 A2 point를 Routable로 보고하지만, check_routes는 같은 좌표를 M2/VIA1 Off-grid로 잡는다.
따라서 남은 주 원인은 단순 blocked pin이 아니다.
원인은 HVT OR/NOR A2 access point와 route/check grid 또는 via/contact generation 사이의 mismatch다.

NOR2X4_HVT broad dont_use는 이미 481 DRC로 악화됐으므로 폐기한다.
다음 fix는 broad dont_use가 아니라:
  A2 access/grid를 피하는 routing option
  HVT OR/NOR A2 사용 instance만 targeted swap/resize
  pin access check library / NDM generation rule 확인
  세 방향 중 하나로 좁혀야 한다.
```

## Extra Off-Grid Pin Track Disable Trial

조건:

```text
trial: route_combo_no012_no_extra_offgrid_tracks
baseline netlist: no_or2x1_nor2x012_hvt
changed option:
  route.detail.generate_extra_off_grid_pin_tracks=false
unchanged:
  core utilization 0.60
  max signal layer M8
  scan DEF import
  VDD/M2 hotspot PG blockage
  high DRC convergence effort
  high wire/via optimization effort
```

증거:

```text
7_Backend_ICC2/3_Log/trials/route_combo_no012_no_extra_offgrid_tracks/route_combo_no012_no_extra_offgrid_tracks.log
7_Backend_ICC2/4_Report/trials/route_combo_no012_no_extra_offgrid_tracks/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_no_extra_offgrid_tracks/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_no_extra_offgrid_tracks/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_no_extra_offgrid_tracks/06_route/pg_drc.rpt
```

결과:

```text
route_auto final DRC: 114
check_routes final DRC: 113
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: no errors

check_routes DRC:
  Off-grid: 107
  Diff net spacing: 4
  Short: 2
```

판단:

```text
generate_extra_off_grid_pin_tracks=false는 폐기한다.
기준 110 DRC보다 나쁘고, A2 off-grid 계열을 없애지 못한다.
이 옵션은 off-grid access를 우회하지 못하고 short/spacing residue만 조금 바꾼다.
```

## Targeted A2 HVT -> LVT ECO Trial

### 목적

남은 110 DRC 중 103개가 HVT OR/NOR A2 access 좌표와 직접 맞았으므로,
해당 instance만 HVT에서 LVT로 바꿔서 cell pin geometry 차이가 원인인지 확인했다.

swap list:

```text
configs/backend/a2_offgrid_hvt_to_lvt_swap.tsv

52 instances:
  NOR2X4_HVT -> NOR2X4_LVT: 43
  OR2X4_HVT  -> OR2X4_LVT : 8
  NOR2X0_HVT -> NOR2X0_LVT: 1
```

### Trial 1: swap only

조건:

```text
trial: route_combo_no012_a2_lvt_swap
ECO_SWAP_FILE=configs/backend/a2_offgrid_hvt_to_lvt_swap.tsv
ECO_SWAP_DONT_TOUCH unset
```

결과:

```text
init ECO swap: 52 PASS
check_routes DRC: 109
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: no errors

DRC:
  Off-grid: 108
  Same net spacing: 1
```

하지만 final-ref audit 결과:

```text
requested LVT kept: 0

final refs:
  NOR2X4_RVT: 41
  OR2X4_RVT : 8
  NOR2X0_HVT: 2
  NOR2X4_HVT: 1
```

판단:

```text
optimizer가 요청한 LVT swap을 모두 다시 바꿨다.
따라서 110 -> 109는 LVT geometry 효과라고 볼 수 없다.
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/01_init_design/eco_swap.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap/99_eco_swap_final_ref/eco_swap_final_ref.rpt
```

### Trial 2: swap + dont_touch

조건:

```text
trial: route_combo_no012_a2_lvt_swap_dt
ECO_SWAP_FILE=configs/backend/a2_offgrid_hvt_to_lvt_swap.tsv
ECO_SWAP_DONT_TOUCH=true
```

결과:

```text
init ECO swap: 52 PASS
dont_touch: 52 applied
final requested LVT refs kept: 52

final refs:
  NOR2X4_LVT: 43
  OR2X4_LVT : 8
  NOR2X0_LVT: 1

check_routes DRC: 110
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: no errors

DRC:
  Off-grid: 109
  Same net spacing: 1
```

판단:

```text
matched A2 instance를 LVT로 강제해도 DRC가 줄지 않는다.
따라서 남은 A2 DRC의 직접 원인은 "HVT cell을 LVT로 바꾸면 해결"이 아니다.

더 강한 원인 모델:
  OR/NOR A2 pin access point가 route engine에는 usable하게 보이지만
  check_routes grid/via/contact rule에는 off-grid로 걸린다.

다음 방향:
  NDM/LEF pin access grid 확인
  VIA1/contact generation rule 확인
  report_cell_pin_access와 check_routes grid 기준 차이 확인
  route access option을 A2 access point 선택 관점에서 확인
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/01_init_design/eco_swap.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_lvt_swap_dt/99_eco_swap_final_ref/eco_swap_final_ref.rpt
```

### Restore

rejected ECO trial 후 saved ICC2 block은 다시 원래 no012 baseline으로 복구했다.

```text
trial: route_combo_no_or2x1_nor2x012_hvt_restore3
check_routes DRC: 110
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: no errors
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore3/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore3/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore3/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore3/06_route/pg_drc.rpt
```

## Via-Ladder Center-Track Option Probe

remaining A2 off-grid class가 `pattern_must_join`/via ladder와 관련 있는지 확인했다.

조건:

```text
trial: route_combo_no012_vialadder_center_track
route.auto_via_ladder.generate_center_track_on_off_grid_pattern_must_join_pin_shapes=true
```

결과:

```text
check_routes DRC: 110
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: no errors

DRC:
  Off-grid: 104
  Diff net spacing: 5
  Short: 1
```

판단:

```text
최종 DRC는 no012 baseline과 동일하다.
따라서 이 option은 fix가 아니다.

하지만 detail route 중간 iteration에서 Off-grid가 101까지 내려갔다.
즉 via-ladder / pattern-must-join / pin-access grid 동작은 remaining A2 off-grid class와 관련 있다.

다음 원인 추적은 broad VT swap이 아니라
NDM/LEF pin-access grid, VIA1/contact definition, route/check grid 기준 차이에 집중한다.
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/route_auto_via_ladder_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_vialadder_center_track/06_route/pg_drc.rpt
```

복구:

```text
trial: route_combo_no_or2x1_nor2x012_hvt_restore4
check_routes DRC: 110
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: no errors
```

## A2 LEF Access Alignment Probe

남은 A2 marker 103개를 unique access point 52개로 줄인 뒤, HVT LEF의 A2 pin shape와 비교했다.

실행:

```text
python3 scripts/analyze_a2_lef_access_alignment.py \
  --lef /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef \
  --match-tsv 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/drc_to_pin_access_coordinate_match.tsv \
  --marker-context 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_marker_context_all/marker_context.rpt \
  --out 7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/a2_lef_access_alignment.rpt
```

결과:

```text
unique A2 access points: 52

by ref:
  NOR2X4_HVT: 43
  OR2X4_HVT : 8
  NOR2X0_HVT: 1

M1 enclosure status:
  NOR2X4_HVT inside_m1_but_enclosure_tight: 33
  NOR2X4_HVT full_m1_enclosure_ok        : 10
  OR2X4_HVT  full_m1_enclosure_ok        : 8
  NOR2X0_HVT inside_m1_but_enclosure_tight: 1
```

핵심 수치:

```text
NOR2X4_HVT/A2 M1 RECT: 0.489 0.553 0.663 0.733
default VIA1 M1 requirement:
  cut_width 0.050
  M1 enc_x 0.030
  M1 enc_y 0.005

VIA1 center legal X max on NOR2X4_HVT/A2 M1:
  0.663 - (0.050/2 + 0.030) = 0.608

observed local access X:
  NOR2X4_HVT: 0.608 for all 43 points
```

판단:

```text
NOR2X4_HVT/A2 access point는 M1 pin 내부에 있지만,
대부분 default VIA1 M1 enclosure legal window의 오른쪽 끝에 정확히 붙어 있다.

그래서 report_cell_pin_access는 Routable로 판단할 수 있지만,
route/check 단계에서는 via/contact snapping 또는 off-grid check에서 걸릴 수 있다.

이것은 "blocked access"가 아니라
edge-of-legal-window pin access + VIA1/contact snapping/grid mismatch 모델이다.
```

VT 비교:

```text
NOR2X0_HVT/NOR2X1_HVT/NOR2X2_HVT/NOR2X4_HVT A2 M1 shape는 동일하다.
NOR2X4_LVT/RVT도 HVT와 A2 M1 shape가 동일하다.
OR2X4_LVT/RVT도 HVT와 A2 M1 shape가 동일하다.
```

따라서:

```text
matched A2 HVT -> LVT swap이 안 먹힌 이유가 설명된다.
단순 VT swap은 pin geometry를 바꾸지 않는다.
NOR2X4_HVT broad dont_use는 구조 재합성을 크게 유발해서 이미 rejected다.
다음 fix는 broad VT replacement가 아니라 route access policy 또는 controlled structural/cell-mapping 대안을 봐야 한다.
```

증거:

```text
scripts/analyze_a2_lef_access_alignment.py
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore/99_pin_access/a2_lef_access_alignment.rpt
```

## M1 Pin-Contained Via Route Policy Trial

edge-of-legal-window 모델을 직접 건드리는 route option을 시험했다.

조건:

```text
trial: route_combo_no012_connect_within_m1_pins
route.common.connect_within_pins_by_layer_name={M1 via_standard_cell_pins}
```

man-page 의미:

```text
M1 standard-cell pin에 연결할 때 via를 pin shape 내부에 포함되도록 제한한다.
```

결과:

```text
check_routes DRC: 148
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: no errors

DRC:
  Connection not within pin: 43
  Diff net spacing: 38
  Less than minimum area: 1
  Needs fat contact: 26
  Off-grid: 31
  Short: 9
```

판단:

```text
fix로는 reject.
baseline 110보다 나쁘다.

하지만 원인 증거로는 강하다.
Off-grid가 104 -> 31로 크게 줄었다.
대신 Connection-not-within-pin / Needs-fat-contact가 생겼다.

즉 남은 DRC는 A2 pin-contained VIA1/access geometry에 의해 지배된다.
route가 pin 내부 제한을 만족하려 하면 다른 lower-metal rule로 튄다.
```

복구:

```text
trial: route_combo_no_or2x1_nor2x012_hvt_restore5
check_routes DRC: 110
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: no errors
```

다음 방향:

```text
broad VT replacement는 더 이상 우선순위가 아니다.
route access policy만으로도 완전 해결은 어렵다.
다음 fix 후보는 controlled structural/cell-mapping change다.
예: remaining NOR2X4_HVT A2 edge instances만 다른 구조로 바꾸는 합성/ECO 후보를 만든 뒤,
full FE equivalence와 backend DRC를 같이 확인한다.
```

증거:

```text
7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/route_common_app_options.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_connect_within_m1_pins/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no_or2x1_nor2x012_hvt_restore5/06_route/check_routes.rpt
```

## Targeted A1/A2 Pin-Swap ECO Trial

원인 모델:

```text
NOR/OR 2-input gate는 A1/A2가 commutative다.
남은 DRC가 A2 pin edge access에 몰려 있으므로,
문제 instance의 A1/A2 net을 바꾸면 같은 논리를 유지하면서 다른 physical pin을 쓸 수 있다.
```

주의:

```text
이것은 post-DFT backend ECO trial이다.
최종 implementation fix로 쓰려면 equivalence 전략이 필요하다.
현재는 route DRC 원인과 fix 방향 확인용이다.
```

목록 생성:

```text
script: scripts/select_a2_commutative_pin_swaps.py
output: configs/backend/a2_edge_commutative_pin_swap.tsv

selected cells:
  NOR2X4_HVT: 43
  OR2X4_HVT : 8
  NOR2X0_HVT: 1
  total     : 52
```

trial:

```text
trial: route_combo_no012_a2_pin_swap
ECO_PIN_SWAP_FILE=configs/backend/a2_edge_commutative_pin_swap.tsv
```

결과:

```text
ECO pin swap:
  PASS: 52
  FAIL: 0

check_routes DRC: 103
open nets: 0
legality: 0
PG connectivity: clean
PG DRC: no errors
```

DRC matrix:

```text
                 | M1  M2   VIA1  | TOTALS BY TYPE
-----------------------------------------------------
Diff net spacing | 1   1    -     | 2
Off-grid         | 2   48   51    | 101
-----------------------------------------------------
                 | M1  M2   VIA1  | 103
TOTALS BY LAYER  | 3   49   51    |
```

판단:

```text
baseline 110 -> pin-swap 103.
Short class가 사라지고 Diff net spacing도 5 -> 2로 줄었다.
Off-grid는 104 -> 101로 소폭 감소했다.

즉 physical pin choice가 영향을 주는 것은 맞다.
그러나 DRC 0이 아니므로 closure는 아니다.
```

대표 marker context:

```text
remaining representative refs:
  NOR2X4_HVT  : dominant
  OR2X4_HVT   : still present
  FADDX2_HVT  : present
  SDFFARX1_RVT: present
```

다음 방향:

```text
1. remaining 103 DRC가 기존 52 swapped cell 주변인지, 새 cell/pin으로 이동했는지 확인
2. 추가 commutative pin swap 후보가 있는지 확인
3. 효과가 있으면 backend ECO가 아니라 synthesis/cell-mapping 단계로 옮겨 FE equivalence 포함 flow로 재현
4. 최종 backend closure 전까지 "verified implementation fix"로 부르지 않는다
```

증거:

```text
configs/backend/a2_edge_commutative_pin_swap.tsv
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/01_init_design/eco_pin_swap.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context/representative_summary.rpt
7_Backend_ICC2/4_Report/trials/route_combo_no012_a2_pin_swap/99_marker_context/marker_context.rpt
```
