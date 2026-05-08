# ICC2 CO/VIA Contact Code Diagnosis

## 목적

`check_routability`의 다음 warning 원인을 확인한다.

```text
Warning: Cannot find a default contact code for layer CO. (ZRT-022)
```

이 warning이 현재 route DRC의 직접 원인인지, 아니면 stdcell pin access 주변 부수 warning인지 구분한다.

## 실행

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_contact_code_diagnose.tcl | tee 7_Backend_ICC2/3_Log/trials/contact_code_diagnose/contact_code_diagnose.log
Block state: current generated routed block after PG terminal cleanup
```

## 증거 파일

```text
7_Backend_ICC2/3_Log/trials/contact_code_diagnose/contact_code_diagnose.log
7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/contact_code_summary.rpt
7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/check_routability.contact.rpt
7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/via_defs.cv32e40p_icc2_lib.rpt
7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/tracks.m1.rpt
7_Backend_ICC2/4_Report/trials/contact_code_diagnose/99_contact_code/tracks.m2.rpt
```

## 결과 요약

`CO` layer는 ICC2 layer로 존재한다.

```text
layer: CO
layer_number: 28
mask_name: polyCont
pitch: 0.0000
default_width: 0.0420
min_width: 0.0420
min_spacing: 0.0500
routing_direction: unknown
```

하지만 `CO` cut layer에 대한 via_def/default contact는 없다.

```text
cut_layer: CO via_def_count=0 default_count=0
```

반대로 signal routing에 필요한 `VIA1`에는 default via_def가 있다.

```text
cut_layer: VIA1 via_def_count=6 default_count=1
VIA12SQ_C lower=M1 upper=M2 default=true excluded_for_signal=false
VIA12BAR_C lower=M1 upper=M2 default=false excluded_for_signal=true
VIA12LG_C lower=M1 upper=M2 default=false excluded_for_signal=false
VIA12SQ lower=M1 upper=M2 default=false excluded_for_signal=false
VIA12BAR lower=M1 upper=M2 default=false excluded_for_signal=true
VIA12LG lower=M1 upper=M2 default=false excluded_for_signal=false
```

따라서 `ZRT-022`의 직접 원인은 명확하다.

```text
SAED32 tech에는 CO layer가 있지만 CO용 ContactCode/via_def는 없다.
stdcell LEF pin에 CO shapes가 있기 때문에 ICC2 routability checker가 CO cut layer를 본다.
그 상태에서 default CO contact를 찾다가 warning을 낸다.
```

## 중요한 구분

`CO`는 stdcell 내부 poly/contact pin geometry에 쓰인다.

현재 signal route의 metal-to-metal 연결은 `VIA1`, `VIA2`, ...를 쓴다.

즉:

```text
CO default contact 없음 = ZRT-022 직접 원인
VIA1 default 없음 = 아님
```

현재 리포트상 `VIA1` default는 존재한다.

그러므로 `ZRT-022` 하나만으로 "M1-M2 routing via setup이 완전히 없다"고 말하면 안 된다.

## Track / Pin Alignment 단서

`report_tracks` 결과:

```text
M1 X start 0.0880 pitch 0.1520
M1 Y start 0.0880 pitch 0.1520
M2 X start 0.0880 pitch 0.1520
M2 Y start 0.0880 pitch 0.1520
```

SAED32 unit site:

```text
Tile unit width 0.152
Tile unit height 1.672
```

즉 track pitch와 site width는 같다.

하지만 off-track warning에 걸린 pin 좌표는 track에서 완전히 중심 정렬되지 않는다.

예:

```text
x=271.995 nearest_track=272.016 delta=-0.0210
x=272.037 nearest_track=272.016 delta=+0.0210
x=128.321 nearest_track=128.376 delta=-0.0550
x=262.689 nearest_track=262.744 delta=-0.0550
y=48.628 nearest_track=48.576 delta=+0.0520
y=248.860 nearest_track=248.912 delta=-0.0520
```

이것은 off-track warning과 일관된다.

## 판단

현재 문제는 두 층으로 봐야 한다.

### 1. CO warning

```text
ZRT-022는 CO용 default contact가 없어서 발생한다.
SAED32 tech file에서도 CO ContactCode는 없다.
이 warning은 stdcell pin LEF에 CO geometry가 있기 때문에 보인다.
```

이 자체는 바로 route DRC 400개의 직접 원인이라고 보기 어렵다.

이유:

```text
VIA1 default contact는 존재한다.
route DRC matrix의 큰 항목은 M1/M2/VIA1/M1-M2다.
check_routability는 blocked port/net, PG open, min-grid, overlap을 보고하지 않는다.
```

### 2. 실제 route DRC 후보

더 강한 후보:

```text
stdcell M1 pin geometry와 ICC2 routing track/pin-access grid의 alignment 문제
VIA1 default via는 있지만 pin-access 위치에서 legal via/contact 선택이 어려움
SAED32 LEF-built NDM의 access point 품질 또는 track derivation 문제
```

## 다음 액션

우선순위:

```text
1. CO ContactCode를 임의 생성하지 않는다. CO는 stdcell 내부 contact 성격이므로 위험하다.
2. NDM을 DB+LEF로 만든 방식과 기존 Milkyway reference 방식의 차이를 비교한다.
3. ICC2가 pin access point를 어떻게 생성하는지 report/check할 방법을 찾는다.
4. 작은 trial로 M1 routing track offset 또는 pin access 관련 option을 하나씩 바꿔 check_routability만 비교한다.
5. full route 재실행은 routability warning이 줄어드는 trial을 먼저 찾은 뒤 수행한다.
```

## 현재 결론

`ZRT-022`는 확인된 문제지만 route closure의 단독 원인으로 보기는 어렵다.

현재 route DRC root cause는 여전히:

```text
SAED32 stdcell M1 pin access
ICC2 M1/M2 routing track
VIA1 contact legality
LEF-built NDM access quality
```

이 조합이다.
