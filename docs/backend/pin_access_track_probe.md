# ICC2 Pin Access / M1 Track Probe

## 목적

route DRC 400개가 M1/M2/VIA1 lower-metal 영역에 남아 있어서, full route를 반복하기 전에 pin access와 M1 routing track 영향을 분리해서 확인했다.

## 실행

```text
Date: 2026-05-08
Probe command:
  icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pin_access_track_probe/pin_access_track_probe.log -f 7_Backend_ICC2/0_Script/99_util/run_pin_access_track_probe.tcl

Full-route trial command:
  icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/m1_retrack_route_088/m1_retrack_route_088.log -f 7_Backend_ICC2/0_Script/99_util/run_m1_retrack_route_trial.tcl
```

## 증거 파일

```text
7_Backend_ICC2/0_Script/99_util/run_pin_access_track_probe.tcl
7_Backend_ICC2/0_Script/99_util/run_m1_retrack_route_trial.tcl
7_Backend_ICC2/3_Log/trials/pin_access_track_probe/pin_access_track_probe.log
7_Backend_ICC2/3_Log/trials/m1_retrack_route_088/m1_retrack_route_088.log
7_Backend_ICC2/4_Report/trials/pin_access_track_probe/99_pin_access_track/
7_Backend_ICC2/4_Report/trials/m1_retrack_route_088/06_route/
```

## Pin Access 결과

`check_libcell_pin_access`는 일반 design library에서 바로 실행되지 않았다.

```text
Error: Current library is not created by command create_pin_check_lib, cannot run pin access checking command for it. (PAC-001)
```

대신 `report_cell_pin_access`는 실행됐다.

```text
flagged_cell_count = 8
flagged cells:
  Pins with no access violations      = 46
  Pins with blocked access            = 0
  Pins with too few access points     = 0
  Pins with insufficient track access = 0

same ref cells:
  cell refs = SDFFARX1_RVT, INVX8_LVT, MUX41X1_HVT
  cell count = 2244
  Pins with no access violations      = 15316
  Pins with blocked access            = 117
  Pins with too few access points     = 0
  Pins with insufficient track access = 0
```

해석:

```text
8개 off-track warning에 직접 매핑된 cell은 report_cell_pin_access 기준으로 막힌 pin access가 없다.
하지만 같은 ref cell 전체에는 blocked access 117개가 있으므로, lower-metal access 문제가 더 넓게 존재할 가능성은 남아 있다.
```

## M1 Track Offset Probe

baseline routed block에서 M1 track start만 바꿔 `check_routability`를 비교했다.

```text
M1 pitch = 0.152um
baseline start = 0.088um
```

결과:

```text
Case | ZRT-761 off-track result
baseline | 8 warnings
M1 start 0.000 | warning limit exceeded, worse
M1 start 0.012 | no ZRT-761 lines
M1 start 0.050 | no ZRT-761 lines
M1 start 0.076 | no ZRT-761 lines
M1 start 0.088 | no ZRT-761 lines
M1 start 0.126 | no ZRT-761 lines
```

단독 probe만 보면 M1 track 재생성이 좋아 보인다. 그러나 이 결과는 이미 routed 된 block에서 나온 값이라 기존 pin-connect/route shape가 access를 가리고 있을 수 있다.

## Full Route Trial

가장 보수적인 `M1 start=0.088`로 trial block을 만들고, signal route를 제거한 뒤 M1 track을 재생성하고 route를 다시 돌렸다.

시작 기준:

```text
check_routes.before_remove.rpt
Total number of DRCs = 400
```

route 전 `check_routability.after_recreate.rpt`:

```text
ZRT-761 off-track M1 pin warning = 8
No min-grid violations
No blocked ports
No blocked nets
```

즉, signal route를 제거한 실제 reroute 조건에서는 M1 track 재생성이 off-track 문제를 없애지 못했다.

route 결과는 악화됐다.

```text
DR finished with 0 open nets
Total number of DRCs = 27260
Illegal track route = 24981
Off-grid = 1104
Short = 441
```

마지막 script는 `route_auto` 후 internal hook error로 후속 report를 못 썼다.

```text
Error: Problem running after command hook 'system_internal' for command route_auto
```

스크립트는 이후 `route_auto`를 `catch`로 감싸도록 수정했다.

## 판단

```text
M1 track 재생성은 reject.
이유: routed block에서 check_routability만 보면 좋아 보이지만, 실제 signal reroute에서는 DRC가 400에서 27260으로 악화된다.
주요 악화 항목은 Illegal track route 24981개다.
```

현재 강한 결론:

```text
단순 M1 track offset 문제가 아니다.
기존 routed shape가 있는 상태의 check_routability 결과는 혼자 믿으면 안 된다.
실제 route closure는 pin access library/check flow, NDM/LEF track metadata, lower-metal routing rule, 또는 placement/scan handoff 쪽을 더 봐야 한다.
```

## 다음 액션

```text
1. create_pin_check_lib 기반의 정식 libcell pin access check 방법을 확인한다.
2. same-ref 117 blocked access pin의 실제 cell/pin을 뽑는다.
3. route track을 수동 재생성하는 방향은 중단한다.
4. 다음 full route trial은 track 재생성이 아니라 pin-access/NDM setup 또는 placement/scan DEF 쪽 변경으로 제한한다.
```
