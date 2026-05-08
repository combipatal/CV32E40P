# MUX41X2_HVT/S0 Pin Access Diagnosis

## 목적

다음 반복 warning의 원인을 확인했다.

```text
Warning: Standard cell pin MUX41X2_HVT/S0 has no valid via regions. (ZRT-044)
```

이 warning은 baseline route와 route option probe에서 계속 반복됐다.

## 확인한 증거

```text
7_Backend_ICC2/4_Report/trials/scan_def_m8_restore/06_route/check_routability.rpt
7_Backend_ICC2/4_Report/trials/route_offgrid_tracks_scan_def_m8/06_route/check_routability.rpt
7_Backend_ICC2/4_Report/trials/route_via_effort_scan_def_m8/06_route/check_routability.rpt
7_Backend_ICC2/4_Report/trials/create_pin_check_lib_trial/99_pin_check_lib/check_libcell_pin_access.hvt.analyze_lib_cell.rpt
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef
/DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
```

## ICC2 / Pin Check 결과

`check_routability`는 routing option trial 후에도 같은 warning을 냈다.

```text
Warning: Standard cell pin MUX41X2_HVT/S0 has no valid via regions. (ZRT-044)
```

`create_pin_check_lib` 기반의 library cell check에서도 같은 성격의 warning이 재현됐다.

```text
Warning: Reference 'saed32hvt_tt/MUX41X2_HVT/frame' pin 'S0' has no via regions. Using pin shape. (PDC-001)
```

즉 이 문제는 특정 배치 instance 하나만의 congestion이 아니라, `MUX41X2_HVT/S0` library pin access 자체에서 시작된다.

## LEF 형상 비교

`MUX41X2_HVT/S0` pin의 M1 형상:

```text
PIN S0
  PORT
    LAYER M1 ;
      RECT 2.1620 1.4440 2.7080 1.4940 ;
```

M1 pin 높이:

```text
1.4940 - 1.4440 = 0.0500um
```

비교용 `MUX41X1_HVT/S0` pin의 M1 형상:

```text
PIN S0
  PORT
    LAYER M1 ;
      RECT 2.1620 1.4440 2.7080 1.4940 ;
      RECT 2.5290 1.4940 2.6590 1.5810 ;
```

`MUX41X1_HVT/S0`는 같은 얇은 stripe에 추가 M1 tab가 있다. `MUX41X2_HVT/S0`는 그 tab가 없다.

## VIA1 요구 면적

기본 M1-M2 via는 `VIA12SQ_C`다.

```text
cutWidth            = 0.05
cutHeight           = 0.05
lowerLayerEncWidth  = 0.03
lowerLayerEncHeight = 0.005
```

따라서 M1 쪽에는 최소한 다음 정도의 landing 여유가 필요하다.

```text
cut 0.05 + enclosure 0.005 * 2 = 0.060um
```

그런데 `MUX41X2_HVT/S0`의 M1 stripe 높이는 0.050um뿐이다.

해석:

```text
기본 VIA12SQ_C를 MUX41X2_HVT/S0 M1 stripe 안에 합법적으로 올리기 어렵다.
그래서 ICC2가 valid via region을 만들지 못하고 ZRT-044/PDC-001을 낸다.
```

## 판단

이 원인은 확인됐다.

```text
MUX41X2_HVT/S0는 LEF상 M1 access 형상이 너무 얇아서 기본 VIA1 valid via region을 만들기 어렵다.
```

하지만 이것만으로 route DRC 전체 398개를 모두 설명하지는 않는다.

이유:

```text
report_cell_pin_access 공식 summary는 blocked access 117 pins를 보고한다.
detail parser 기준 line-level blocked entry 125개는 SDFFARX1_RVT 116개와 MUX41X1_HVT 9개로 나뉜다.
route DRC matrix는 M1/M2/VIA1/off-grid/needs-fat-contact가 넓게 섞여 있다.
PG M2 mesh 위치도 route DRC에 영향을 준다.
```

따라서 현재 root-cause model은 다음과 같다.

```text
SAED32 일부 stdcell의 lower-metal pin access margin이 작다.
그 위에 PG M2 mesh와 M2/VIA1 route policy가 겹치면서 hotspot DRC가 남는다.
MUX41X2_HVT/S0는 그중 명확히 증명된 library pin-access 약점이다.
```

## 다음 액션

수정 trial은 다음 중 하나를 독립적으로 테스트해야 한다.

```text
1. MUX41X2_HVT 사용을 제한하거나 MUX41X1_HVT/RVT 등으로 대체 가능한지 DC/ICC2 cell usage를 확인한다.
2. SDFFARX1_RVT blocked access가 실제 hotspot DRC와 얼마나 겹치는지 더 좁힌다.
3. PG M2 mesh를 pin access 취약 row와 덜 겹치게 만드는 정식 PG 구조를 다시 설계한다.
4. LEF/NDM patch는 최후 수단으로만 둔다. vendor/library geometry 수정은 검증 부담이 크다.
```
