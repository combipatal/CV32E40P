# ICC2 Scan DEF / Advanced Legalizer Trial

## 목적

Route DRC가 scan DEF 미전달 때문인지, 아니면 배치/핀 접근성/저층 라우팅 문제인지 분리한다.

## Scan DEF handoff

DFT에서 ICC2용 scan DEF를 만들도록 추가했다.

```text
3_DFT/0_Script/run_insert_dft_10ns_topo.tcl
3_DFT/0_Script/run_write_scan_def_from_post_dft.tcl
3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.scan.def
```

기존 post-DFT DDC에서 scan DEF만 다시 쓰는 스크립트도 만들었다. DFT 전체를 다시 돌리지 않고 handoff 파일을 복구하기 위한 용도다.

증거:

```text
3_DFT/4_Report/topo/scan_path.existing.scan_def_source.rpt
7_Backend_ICC2/3_Log/trials/scan_def_m8/scan_def_m8.log
```

`scan_def_m8` 로그에서 ICC2가 scan DEF를 읽었고, `optimize_dft`가 scan chain 1개를 검증했다. scan wirelength도 줄었다.

```text
Total SCANCHAINS checked: 1
DFT post-opt wirelength: 14900
DFT post-opt wirelength difference: -72.55%
```

## Trial 결과

```text
Trial | scan DEF | key option | open nets | route DRC | status
60util_m8 | no | M1-M8 signal route | 0 | 400 | old best baseline
scan_def_m8 | yes | M1-M8 signal route | 0 | 398 | slight improvement
scan_def_advleg_m8 | yes | advanced legalizer + pin access opts | 0 | 605 | rejected
scan_def_advleg_color_m8 | yes | advanced legalizer + pin color alignment | 0 | 605 | rejected
```

공식 route evidence:

```text
7_Backend_ICC2/4_Report/trials/scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/scan_def_advleg_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/check_routes.rpt
```

`scan_def_advleg_color_m8`에서는 placement legality가 clean이다.

```text
7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/check_legality.rpt
Total Violations 0
```

PG도 clean이다.

```text
7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/pg_drc.rpt
VDD/VSS floating wires/vias/std cells/terminals = 0
check_pg_drc: No errors found
```

## Pin color alignment 확인

ICC2가 요구한 option을 환경변수로 추가했다.

```text
PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK=true
place.legalize.enable_pin_color_alignment_check = true
```

증거:

```text
7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/04_place/place_legalize_app_options.rpt
7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8/06_route/check_legality.rpt
```

Legality report에는 `pin_color_align` rule violation 0개가 찍힌다. 하지만 route DRC는 605개라서 route closure에는 도움이 되지 않았다.

## Blocked access 관찰

`scan_def_advleg_color_m8` saved block에서 같은 ref cell group을 다시 봤다.

```text
7_Backend_ICC2/4_Report/trials/scan_def_advleg_color_m8_blocked_detail/99_pin_access/blocked_access.compact_summary.rpt
```

파서 기준 blocked access point는 254개다.

```text
SDFFARX1_RVT 233
MUX41X1_HVT   16
INVX8_LVT      5
```

주의: 이 숫자는 line-level blocked access point 수다. ICC2 official summary는 최종 routed context에서 "Pins with blocked access: 0"으로 나온다. 따라서 이것만으로 "공식 blocked pin 254개"라고 부르면 안 된다.

## 현재 판단

문제는 많이 구체화됐다.

```text
scan DEF 누락: 해결됨. scan chain handoff와 scan-aware DFT optimization 확인됨.
단순 utilization: 원인 아님. 65% -> 60%로 DRC 거의 안 줄었음.
단순 M8 layer bound: 작은 개선만 있음.
advanced legalizer/pin color: placement legality는 clean이지만 최종 signal route DRC는 악화됨.
남은 핵심: SAED32 stdcell 하단 M1/M2/VIA1 접근, routed context의 via/contact/track 제약, post-CTS density/clock-buffer interaction.
```

## 다음 후보

다음은 advanced legalizer 조합이 아니라, 더 단순한 routed baseline에서 아래를 확인한다.

```text
1. scan_def_m8 또는 detail_repair_1iter 같은 낮은 DRC block으로 복귀
2. route DRC marker를 cell/pin/PG object 근처로 다시 bucketize
3. M1/M2/VIA1 DRC class별 representative marker를 뽑기
4. stdcell rail/PG via와 signal via가 충돌하는지 확인
5. 필요하면 PG mesh pitch/offset 또는 lower-metal keepout을 trial
```
