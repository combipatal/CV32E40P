# SDFFARX1_RVT Hotspot Overlap Diagnosis

## 목적

`SDFFARX1_RVT` blocked access가 route DRC hotspot의 직접 원인인지 확인했다.

이전 분석에서 official blocked access는 `SDFFARX1_RVT`에 많이 몰려 있었다. 그래서 blocked access point와 route DRC marker 좌표를 거리로 매칭했다.

## 실행

처음에는 기존 baseline report를 바로 썼다.

```text
blocked report:
  7_Backend_ICC2/4_Report/trials/pin_access_blocked_detail/99_pin_access/blocked_access.by_ref_cell_pin.rpt
DRC report:
  7_Backend_ICC2/4_Report/06_route/drc_detail/drc.detailed.rpt
output:
  7_Backend_ICC2/4_Report/trials/sdffarx1_hotspot_overlap/99_overlap/
```

그 뒤 ICC2 context를 열어 보니, 현재 saved block은 마지막 route option trial 상태라 기존 blocked report의 cell 좌표와 맞지 않았다.

그래서 현재 saved block 기준으로 blocked access를 다시 뽑고, 같은 route-via-effort DRC report와 다시 매칭했다.

```text
current blocked command:
  env TRIAL_NAME=sdffarx1_current_blocked_detail icc2_shell -batch \
    -output_log_file 7_Backend_ICC2/3_Log/trials/sdffarx1_current_blocked_detail/sdffarx1_current_blocked_detail.log \
    -f 7_Backend_ICC2/0_Script/99_util/run_pin_access_blocked_detail.tcl

current parser command:
  env BLOCKED_REPORT=7_Backend_ICC2/4_Report/trials/sdffarx1_current_blocked_detail/99_pin_access/blocked_access.by_ref_cell_pin.rpt \
      DRC_REPORT=7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/drc_detail/drc.detailed.rpt \
      OUT_DIR=7_Backend_ICC2/4_Report/trials/sdffarx1_current_hotspot_overlap/99_overlap \
      python3 scripts/analyze_sdffarx1_hotspot_overlap.py

current context command:
  env TRIAL_NAME=sdffarx1_hotspot_context \
      INPUT_FILE=/DATA/home/edu135/CV32E40P/7_Backend_ICC2/4_Report/trials/sdffarx1_current_hotspot_overlap/99_overlap/sdffarx1_hotspot_points.tsv \
      icc2_shell -batch \
      -output_log_file 7_Backend_ICC2/3_Log/trials/sdffarx1_hotspot_context/sdffarx1_hotspot_context_current.log \
      -f 7_Backend_ICC2/0_Script/99_util/run_sdffarx1_hotspot_context.tcl
```

## Baseline Report-Only 결과

```text
sdffarx1_blocked_point_count = 284
route_drc_marker_count = 398
hotspot_drc_marker_count = 123
sdffarx1_blocked_points_inside_hotspot = 17
sdffarx1_points_with_nearest_drc_inside_hotspot = 17
```

거리:

```text
all SDFFARX1 blocked points:
  <=5um  = 58 / 284
  <=10um = 105 / 284
  <=25um = 213 / 284

hotspot SDFFARX1 blocked points:
  <=5um  = 14 / 17
  <=10um = 14 / 17
  <=25um = 17 / 17
```

주의:

```text
이 결과는 report-only 분석으로 의미는 있지만, 이후 ICC2 saved block이 route option trial로 바뀌어 DB context와 직접 대조하면 좌표가 안 맞는다.
```

## Current Saved Block 결과

현재 saved block 기준 blocked access summary:

```text
line_level_blocked_entries = 161
SDFFARX1_RVT = 150
MUX41X1_HVT  = 10
INVX8_LVT    = 1
```

`SDFFARX1_RVT` point 단위:

```text
sdffarx1_blocked_point_count = 352
route_drc_marker_count = 389
hotspot_drc_marker_count = 119
sdffarx1_blocked_points_inside_hotspot = 11
sdffarx1_points_with_nearest_drc_inside_hotspot = 11
```

거리:

```text
all SDFFARX1 blocked points:
  <=1um  = 12
  <=2um  = 18
  <=5um  = 54
  <=10um = 140
  <=25um = 237
  <=50um = 342

hotspot SDFFARX1 blocked points:
  <=1um  = 0
  <=2um  = 0
  <=5um  = 6
  <=10um = 10
  <=25um = 11
```

Hotspot 안의 SDFFARX1 blocked pin:

```text
SE  = 3
SI  = 3
CLK = 3
Q   = 2
```

Nearest DRC type:

```text
Needs fat contact = hotspot SDFFARX1 11개 전부의 nearest DRC
```

## ICC2 Context 결과

현재 saved block에서 hotspot SDFFARX1 cell 5개를 `report_cell_pin_access`로 다시 확인했다.

```text
Pins with no access violations      = 23
Pins with blocked access            = 5
Pins with too few access points     = 0
Pins with insufficient track access = 0
```

대표 blocked pins:

```text
u_core/core_i/cs_registers_i/mhpmcounter_q_reg[3][10] / Q
  Blocked Q(M2) 1: {259.7040 211.2160}

u_core/core_i/cs_registers_i/mhpmcounter_q_reg[3][11] / SE
  Blocked SE(M2) 3: {260.3120 214.9825} {260.3120 215.0160} {260.3120 214.9992}

u_core/core_i/ex_stage_i/alu_i/alu_div_i/AReg_DP_reg[24] / SI
  Blocked SI(M2) 3: {259.7040 253.7385} {259.7040 253.7760} {259.7040 253.7572}

u_core/core_i/ex_stage_i/alu_i/alu_div_i/AReg_DP_reg[24] / CLK
  Blocked CLK(M2) 3: {260.3120 253.9080} {260.3120 253.9280} {260.3120 253.9180}
```

주변 context:

```text
각 hotspot point의 5um search box 안에 M2 PG stripe가 1개씩 잡힌다.
예: PATH_13_203 layer=M2 net=VSS bbox={259.8000 10.0000} {260.2000 315.9120}
```

즉 hotspot SDFFARX1 blocked access는 x=259.7~260.3 근처에 몰려 있고, 같은 위치에 VSS M2 PG stripe가 지나간다.

## 판단

`SDFFARX1_RVT`는 route DRC의 단독 원인이 아니다.

이유:

```text
current block 기준 SDFFARX1 blocked point는 352개지만 hotspot 내부는 11개뿐이다.
hotspot DRC marker는 119개라서 SDFFARX1만으로 hotspot 전체를 설명하지 못한다.
```

하지만 `SDFFARX1_RVT`는 hotspot 원인 구성요소가 맞다.

이유:

```text
hotspot 안의 SDFFARX1 blocked point 11개는 모두 nearest DRC가 hotspot 내부다.
11개 중 10개는 DRC와 10um 이내다.
11개 모두 nearest DRC type이 Needs fat contact다.
각 point 주변 5um 안에 M2 VSS PG stripe가 있다.
```

현재 root-cause model은 더 구체화됐다.

```text
PG M2 stripe at x=259.8..260.2
+ SDFFARX1_RVT M2 pin access point at x=259.7..260.3
+ lower-metal via/contact rule
= hotspot Needs-fat-contact / off-grid / spacing DRC 일부 발생
```

## 다음 액션

다음 원인은 `SDFFARX1_RVT` 자체가 아니라, 같은 x=260um PG stripe와 겹치는 다른 cell/route marker까지 묶어 보는 것이다.

```text
1. x=259.8..260.2 M2 VSS stripe 주변 5um 이내 DRC marker 전체를 분리한다.
2. 그 marker 주변 ref cell 분포를 뽑는다.
3. PG stripe를 유지하되 stdcell pin access를 피하는 PG mesh pitch/offset 후보를 만든다.
4. 바로 cell 수동 이동은 하지 않는다.
```
