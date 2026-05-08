# ICC2 DRC Marker Context Probe

## 목적

`scan_def_m8_restore` 상태에서 route DRC marker 좌표를 뽑고, 대표 marker 주변의 cell/pin/route shape를 확인했다.

이 단계는 fix가 아니라 원인 구체화다.

## 재현 상태

현재 saved ICC2 block을 단순 scan DEF + M8 route 상태로 복구했다.

```text
Trial: scan_def_m8_restore
open nets: 0
route DRC: 397 in route_auto log, 398 in fresh check_routes/detail extraction
PG DRC: clean
```

증거:

```text
7_Backend_ICC2/3_Log/trials/scan_def_m8_restore/scan_def_m8_restore.log
7_Backend_ICC2/4_Report/trials/scan_def_m8_restore/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/check_routes.detail_source.rpt
```

## Marker matrix

Fresh detailed extraction 기준 DRC는 398개다.

```text
Diff net spacing       M1 116, M2 4
Needs fat contact      M1-M2 99
Off-grid               M1 10, M2 78, VIA1 82
Less than minimum area M2 8
Short                  M1 1
```

증거:

```text
7_Backend_ICC2/4_Report/06_route/drc_detail/drc.matrix.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/drc.by_layer.rpt
7_Backend_ICC2/4_Report/06_route/drc_detail/drc.detailed.rpt
```

## Hotspot

20um bucket 기준 hotspot은 오른쪽 상단/ALU-div 쪽에 몰린다.

```text
220-240,220-240: 25
220-240,240-260: 24
240-260,240-260: 22
220-240,200-220: 18
240-260,220-240: 15
```

증거:

```text
7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/representative_summary.rpt
7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/all_drc_markers.tsv
```

## 주변 객체 확인

대표 marker 37개를 뽑았다.

```text
type/layer 대표 22개
top hotspot bucket 대표 15개
```

주변 객체 리포트:

```text
7_Backend_ICC2/4_Report/trials/drc_marker_context/99_marker_context/marker_context.rpt
```

관찰:

```text
M1 diff-net spacing 대표 marker는 OR2X1_HVT pin 근처에 있다.
M2 diff-net spacing 대표 marker 일부는 SDFFARX1_RVT, NBUFFX8_HVT 근처에 있다.
Needs fat contact hotspot marker는 OR2X1_HVT 주변 M1-M2 연결에서 반복된다.
Off-grid hotspot marker는 NOR2X0_HVT 주변 M2/VIA1에서 반복된다.
일부 hotspot marker 검색창에는 VDD/VSS M1/M2/M7/M8 PG shape가 같이 잡힌다.
```

이 결과는 이전의 `SDFFARX1_RVT/MUX41X1_HVT blocked access`만으로는 부족하다는 뜻이다. 실제 route DRC hotspot은 OR2X1_HVT/NOR2X0_HVT 같은 작은 combinational cell 주변과 ALU/div 영역에도 강하게 존재한다.

## 현재 판단

원인은 더 구체화됐다.

```text
1. 전체 DRC는 여전히 lower-metal issue다.
2. hotspot은 특정 영역에 몰린다.
3. marker 주변은 stdcell pin + dense M2/VIA1 signal route + 일부 PG shape가 같이 존재한다.
4. 따라서 다음 trial은 generic spreading보다 hotspot 영역의 placement density/PG interaction/lower-metal routing option을 분리해야 한다.
```

## 다음 후보

```text
1. hotspot 영역 cell density와 PG strap/rail 교차를 정량화한다.
2. hotspot 영역 주변 PG mesh offset/pitch를 바꾸는 작은 trial을 한다.
3. route.common/detail option으로 off-grid/fat-contact를 줄일 수 있는지 check_routability 먼저 비교한다.
4. 필요하면 ALU/div hotspot에 partial placement blockage 또는 soft density screen을 trial한다.
```
