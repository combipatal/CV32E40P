# ICC2 Pin-Check Lib Flow And Blocked Access Detail

## 목적

`report_cell_pin_access`에서 보인 same-ref `blocked access 117`의 실제 cell/pin을 찾고, `check_libcell_pin_access`가 요구하는 정식 `create_pin_check_lib` flow를 확인했다.

## 실행

```text
Date: 2026-05-08
Pin-check lib command:
  icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/create_pin_check_lib_trial/create_pin_check_lib_trial.log -f 7_Backend_ICC2/0_Script/99_util/run_create_pin_check_lib_trial.tcl

Blocked detail command:
  icc2_shell -batch -output_log_file 7_Backend_ICC2/3_Log/trials/pin_access_blocked_detail/pin_access_blocked_detail.log -f 7_Backend_ICC2/0_Script/99_util/run_pin_access_blocked_detail.tcl
```

## 증거 파일

```text
7_Backend_ICC2/0_Script/99_util/run_create_pin_check_lib_trial.tcl
7_Backend_ICC2/0_Script/99_util/run_pin_access_blocked_detail.tcl
7_Backend_ICC2/3_Log/trials/create_pin_check_lib_trial/create_pin_check_lib_trial.log
7_Backend_ICC2/3_Log/trials/pin_access_blocked_detail/pin_access_blocked_detail.log
7_Backend_ICC2/4_Report/trials/create_pin_check_lib_trial/99_pin_check_lib/
7_Backend_ICC2/4_Report/trials/pin_access_blocked_detail/99_pin_access/
```

## create_pin_check_lib 결과

명령 help 기준 정식 flow는 `create_pin_check_lib -technology <tf> -ref_libs <ref_libs> <lib_name>` 후 `check_libcell_pin_access` 실행이다.

첫 시도에서 `check_libcell_pin_access`가 실패했다.

```text
Error: Empty value in app_option pin_check.place.preplace_option_file. (PAC-003)
```

따라서 빈 option 파일을 만들고 다음 option을 설정했다.

```text
set_app_options -name pin_check.place.preplace_option_file -value <pin_check_preplace_options.tcl>
```

그 뒤 결과:

```text
Case | create_pin_check_lib | analyze_lib_cell | analyze_lib_pin
RVT+LVT+HVT together | PASS | PASS | FAIL: LIB-001
RVT only | PASS | PASS | FAIL: LIB-001
LVT only | PASS | PASS | FAIL: LIB-001
HVT only | PASS | PASS | FAIL: LIB-001
```

`analyze_lib_cell` 요약:

```text
All mixed-VT cells: skipped 27, met threshold 855
Each VT library: skipped 9, met threshold 285
```

`analyze_lib_pin`은 아직 별도 open item이다.

```text
Error: Current library is not defined. (LIB-001)
```

## Lib-Cell 해석

`analyze_lib_cell`은 SAED32 stdcell pin access 자체가 전부 실패하는 상황은 아니라고 보여준다.

관련 cell clue:

```text
SDFFARX1_RVT pass_rate = 0.9390
MUX41X1_HVT has ALCP-004 no-legal-sites warning in HVT/all report
INVX8_LVT has ALCP-004 no-legal-sites warning in LVT/all report
```

주의할 점:

```text
이 결과는 standalone lib-cell placement/access check다.
현재 routed design의 blocked access는 배치 위치, 주변 cell, route shape, lower-metal congestion 영향을 같이 받는다.
```

## Blocked Access Detail

대상 cell:

```text
ref_name in {SDFFARX1_RVT, INVX8_LVT, MUX41X1_HVT}
same_ref_cell_count = 2244
```

ICC2 summary:

```text
Pins with no access violations:      15316
Pins with blocked access:            117
Pins with too few access points:     0
Pins with insufficient track access: 0
```

파싱한 line-level blocked entry는 125개다.

```text
line_level_blocked_entries = 125
```

차이 해석:

```text
ICC2 summary의 117은 pin/access-check summary count다.
파싱 125는 detail report의 "Blocked ... nonzero" line count다.
한 pin이 여러 blocked line/access point로 나타날 수 있으므로 숫자가 다를 수 있다.
공식 count는 117, 식별용 detail line은 125로 기록한다.
```

Ref별 line-level 분포:

```text
SDFFARX1_RVT | 116
MUX41X1_HVT  | 9
INVX8_LVT    | 0
```

Pin별 line-level 분포:

```text
RSTB | 39
SE   | 23
Q    | 21
CLK  | 20
QN   | 7
SI   | 6
S0   | 5
A1   | 3
S1   | 1
```

초기 예시:

```text
SDFFARX1_RVT | u_core/core_i/id_stage_i/register_file_i/mem_reg[31][10] | CLK  | Blocked CLK(M2)
SDFFARX1_RVT | u_core/core_i/id_stage_i/register_file_i/mem_reg[30][28] | RSTB | Blocked RSTB(M2)
SDFFARX1_RVT | u_core/core_i/id_stage_i/register_file_i/mem_reg[28][9]  | SE   | Blocked SE(M2)
SDFFARX1_RVT | u_core/core_i/id_stage_i/register_file_i/mem_reg[28][22] | Q    | Blocked Q(M2)
```

## 판단

```text
8개 off-track warning cell 자체는 이전 report에서 blocked access 0이었다.
하지만 같은 ref population에는 공식 count 117 blocked access가 있다.
이번 detail 기준 blocked access는 SDFFARX1_RVT에 거의 집중된다.
INVX8_LVT는 off-track warning에는 있었지만 same-ref blocked detail에는 0개다.
```

현재 가장 강한 결론:

```text
단순 M1 track recreation 문제 아님.
stdcell library 전체가 unusable한 문제도 아님.
배치된 design context에서 SDFFARX1_RVT/MUX41X1_HVT 주변 lower-metal access가 막히는 문제에 가깝다.
```

## 다음 액션

```text
1. blocked SDFFARX1_RVT/MUX41X1_HVT instance 좌표를 route DRC hotspot과 겹쳐 본다.
2. register_file scan flop 밀집 영역과 M1/M2/VIA1 DRC 위치를 비교한다.
3. scan DEF handoff 또는 placement spreading trial을 우선 검토한다.
4. analyze_lib_pin LIB-001은 필요할 때 별도 current-lib context로 재조사한다.
5. M1 track 수동 재생성 방향은 계속 보류한다.
```
