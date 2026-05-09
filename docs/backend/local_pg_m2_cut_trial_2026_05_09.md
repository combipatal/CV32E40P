# Local PG M2 Cut Trial - 2026-05-09

## 목적

```text
hotspot 주변 x=259.8..260.2um VSS M2 PG stripe가 signal route DRC에 실제로 영향을 주는지 확인한다.
```

이 실험은 정식 power plan 수정이 아니다.
원인 분리용 실험이다.

## 적용한 조건

```text
Trial: route_combo_pgcut_vss260
Base: route_combo_scan_def_m8
Core utilization: 0.60
Signal route max layer: M8
Scan DEF: 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def
Route detail options:
  route.detail.generate_extra_off_grid_pin_tracks=true
  route.detail.drc_convergence_effort_level=high
  route.detail.optimize_wire_via_effort_level=high
PG cut boundary: {{258.0 195.0} {262.0 265.0}}
PG cut net: VSS
```

## PG 수정 내용

```text
cut_shape: PATH_13_203 net=VSS layer=M2 bbox={259.8000 10.0000} {260.2000 315.9120}
created bottom segment: {259.8000 10.0000} {260.2000 195.0}
created top segment: {259.8000 265.0} {260.2000 315.9120}
removed_vias: 0
removed_shapes: 1
created_segments: 2
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/03_power/pg_m2_hotspot_cut.rpt
```

## 결과 비교

```text
Trial                       Open nets  Legality  PG DRC  Route DRC
route_combo_scan_def_m8     0          0         clean   381
route_combo_pgcut_vss260    0          0         clean   377
```

DRC class 비교:

```text
Class                  route_combo_scan_def_m8  route_combo_pgcut_vss260
Diff net spacing       127                      129
Less than min area     3                        1
Needs fat contact      91                       79
Off-grid               157                      166
Same net spacing       1                        1
Short                  2                        1
Total                  381                      377
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss260/06_route/pg_drc.rpt
```

## 판단

```text
결론: PG M2 stripe는 hotspot DRC의 실제 기여 원인이다.
근거: 같은 route option에서 PG-clean 상태를 유지하면서 route DRC가 381 -> 377로 감소했다.
한계: 개선 폭은 4개뿐이다. PG M2 하나만으로 전체 route DRC를 설명할 수 없다.
```

이 결과는 다음 모델을 강화한다.

```text
x=260um VSS M2 PG stripe
+ SDFFARX1_RVT/기타 stdcell pin access
+ M2/VIA1 contact legality
= hotspot route DRC
```

정식 수정 방향은 수동 shape 절단이 아니다.
후속 작업은 영역별 PG strategy, M2 PG pitch/offset/width 조정, stdcell pin access 영향이 큰 영역의 placement/routing 제약을 함께 조합해야 한다.

## All-M2 Hotspot Cut 추가 Trial

목적:

```text
x=260um VSS stripe 하나가 아니라 hotspot 안의 M2 PG stripe 전체가 원인인지 확인한다.
```

적용:

```text
Trial: route_combo_pgcut_allm2_hotspot
PG cut boundary: {{215.0 195.0} {265.0 265.0}}
PG cut nets: VDD VSS
```

잘린 M2 PG stripe:

```text
VSS x=219.8..220.2
VDD x=239.8..240.2
VSS x=259.8..260.2
removed_shapes: 3
created_segments: 6
removed_vias: 0
```

결과:

```text
Trial                         Open nets  Legality  PG DRC  Route DRC
route_combo_scan_def_m8       0          0         clean   381
route_combo_pgcut_vss260      0          0         clean   377
route_combo_pgcut_allm2       0          0         clean   378
```

DRC class 비교:

```text
Class                  scan_def_m8  vss260_cut  allm2_cut
Diff net spacing       127          129         96
Less than min area     3            1           3
Needs fat contact      91           79          113
Off-grid               157          166         163
Same net spacing       1            1           1
Short                  2            1           2
Total                  381          377         378
```

판단:

```text
all-M2 hotspot cut은 정식 best가 아니다.
vss260_cut 377보다 1개 나쁘다.
하지만 원인 해석에는 중요하다.
M2 PG를 줄이면 diff-net spacing은 127/129 -> 96으로 크게 줄어든다.
대신 M1-M2 needs-fat-contact가 79/91 -> 113으로 늘어난다.
따라서 M2 PG obstruction과 M1-M2 via/contact legality는 trade-off 관계다.
```

새 root-cause 해석:

```text
M2 PG stripe는 signal spacing을 압박한다.
하지만 M2 PG를 무작정 없애면 signal이 다른 M1-M2 access를 쓰면서 fat-contact 문제가 증가한다.
다음은 x=220 VSS, x=240 VDD, x=260 VSS stripe를 개별 분리해 어느 stripe가 순개선인지 확인해야 한다.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/03_power/pg_m2_hotspot_cut.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_allm2_hotspot/06_route/drc_detail/drc.matrix.rpt
```

## x=240 VDD 개별 Cut Trial

목적:

```text
hotspot 중앙 VDD M2 stripe 하나만 분리했을 때 순개선인지 확인한다.
```

적용:

```text
Trial: route_combo_pgcut_vdd240
PG cut boundary: {{238.0 195.0} {242.0 265.0}}
PG cut net: VDD
```

잘린 M2 PG stripe:

```text
VDD x=239.8..240.2
removed_shapes: 1
created_segments: 2
removed_vias: 0
```

결과:

```text
Trial                         Open nets  Legality  PG DRC  Route DRC
route_combo_scan_def_m8       0          0         clean   381
route_combo_pgcut_vss260      0          0         clean   377
route_combo_pgcut_allm2       0          0         clean   378
route_combo_pgcut_vdd240      0          0         clean   376
```

DRC class:

```text
Class                  vdd240_cut
Diff net spacing       125
Less than min area     4
Needs fat contact      84
Off-grid               160
Same net spacing       1
Short                  2
Total                  376
```

판단:

```text
x=240 VDD M2 cut은 현재 best다.
route_combo_scan_def_m8 대비 381 -> 376으로 5개 개선된다.
route_combo_pgcut_vss260 대비 377 -> 376으로 1개 개선된다.
PG connectivity와 PG DRC는 clean이다.
```

원인 해석:

```text
x=240 VDD M2 stripe는 hotspot DRC에 순악영향을 준다.
하지만 개선 폭은 5개뿐이므로 전체 DRC의 단독 원인은 아니다.
남은 DRC는 여전히 M1 diff spacing, M1-M2 needs-fat-contact, M2/VIA1 off-grid가 주축이다.
다음 stripe 분리 후보는 x=220 VSS다.
```

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/03_power/pg_m2_hotspot_cut.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vdd240/06_route/drc_detail/drc.matrix.rpt
```

## x=220 VSS 개별 Cut Trial

목적:

```text
hotspot 왼쪽 VSS M2 stripe 하나만 분리했을 때 순개선인지 확인한다.
```

적용:

```text
Trial: route_combo_pgcut_vss220
PG cut boundary: {{218.0 195.0} {222.0 265.0}}
PG cut net: VSS
```

잘린 M2 PG stripe:

```text
VSS x=219.8..220.2
removed_shapes: 1
created_segments: 2
removed_vias: 0
```

결과:

```text
Trial                         Open nets  Legality  PG DRC  Route DRC
route_combo_scan_def_m8       0          0         clean   381
route_combo_pgcut_vdd240      0          0         clean   376
route_combo_pgcut_vss220      0          0         clean   380
```

DRC class:

```text
Class                  vss220_cut
Diff net spacing       109
Less than min area     4
Needs fat contact      103
Off-grid               158
Same net spacing       1
Short                  5
Total                  380
```

판단:

```text
x=220 VSS cut은 current best가 아니다.
baseline 381 대비 1개만 개선되고, vdd240_cut 376보다 4개 나쁘다.
diff-net spacing은 줄지만 needs-fat-contact와 short가 증가한다.
따라서 x=220 VSS stripe는 제거 우선순위가 아니다.
```

현재 PG-cut 결론:

```text
x=240 VDD cut: best, route DRC 376
x=260 VSS cut: useful, route DRC 377
x=220 VSS cut: weak, route DRC 380
all-M2 cut: trade-off, route DRC 378
```

정식 PG 전략 후보는 x=240 VDD hotspot segment를 우선 피하는 방향이다.

Evidence:

```text
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/03_power/pg_m2_hotspot_cut.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/route_combo_pgcut_vss220/06_route/drc_detail/drc.matrix.rpt
```
