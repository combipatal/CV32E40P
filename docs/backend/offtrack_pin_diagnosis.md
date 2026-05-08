# ICC2 Off-Track Pin Diagnosis

## 목적

PG top-port warning을 제거한 뒤에도 `check_routability`에 남은 8개 M1 off-track pin warning의 실제 object를 찾는다.

## 실행

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_offtrack_pin_diagnose.tcl | tee 7_Backend_ICC2/3_Log/trials/offtrack_pin_diagnose/offtrack_pin_diagnose.log
Block state: current generated 60util_m8 + PG terminal attach routed block
```

## 증거 파일

```text
7_Backend_ICC2/3_Log/trials/offtrack_pin_diagnose/offtrack_pin_diagnose.log
7_Backend_ICC2/4_Report/trials/offtrack_pin_diagnose/99_route_access/check_routability.verbose.rpt
7_Backend_ICC2/4_Report/trials/offtrack_pin_diagnose/99_route_access/offtrack_pin_objects.rpt
```

## Routability 결과

`check_routability.verbose.rpt` 기준:

```text
No PG net open
No standard-cell overlap
No min-grid violations
No blocked ports
No blocked nets
8 off-track pins on M1
```

남은 중요 warning:

```text
ZRT-511: tie connections not connected to real PG
ZRT-022: Cannot find a default contact code for layer CO
ZRT-585: CGLPPRX*_*/ENL internal port is not physical
ZRT-761: 8 M1 off-track pins
```

`ZRT-585`의 6개 non-physical internal pin은 clock-gate library frame 내부 `ENL` port다.

```text
CGLPPRX2_RVT.frame/ENL
CGLPPRX8_LVT.frame/ENL
CGLPPRX8_RVT.frame/ENL
CGLPPRX2_LVT.frame/ENL
CGLPPRX2_HVT.frame/ENL
CGLPPRX8_HVT.frame/ENL
```

## Off-Track Pin Object

`offtrack_pin_objects.rpt`에서 좌표를 실제 pin/cell로 매핑했다.

```text
1. u_core/core_i/cs_registers_i/mepc_q_reg[28]/QN
   cell: SDFFARX1_RVT
   layer: M1 CO
   bbox: {271.9750 48.5780} {272.2230 49.9700}

2. u_core/core_i/cs_registers_i/mepc_q_reg[31]/QN
   cell: SDFFARX1_RVT
   layer: M1 CO
   bbox: {271.9750 61.9540} {272.2230 63.3460}

3. u_core/core_i/id_stage_i/register_file_i/mem_reg[2][15]/QN
   cell: SDFFARX1_RVT
   layer: M1 CO
   bbox: {138.2150 170.6060} {138.4630 171.9980}

4. u_core/core_i/HFSINV_25033_829/A
   cell: INVX8_LVT
   net: u_core/core_i/HFSNET_41
   layer: M1
   bbox: {128.3210 196.2200} {129.5720 196.3750}

5. u_core/core_i/cs_registers_i/mhpmcounter_q_reg[3][35]/QN
   cell: SDFFARX1_RVT
   layer: M1 CO
   bbox: {271.9750 232.4980} {272.2230 233.8900}

6. u_core/core_i/if_stage_i/instr_rdata_id_o_reg[28]/QN
   cell: SDFFARX1_RVT
   layer: M1 CO
   bbox: {271.9750 247.5180} {272.2230 248.9100}

7. u_core/core_i/U1545/S1
   cell: MUX41X1_HVT
   net: u_core/core_i/n2323
   layer: M1 CO
   bbox: {128.1690 285.5150} {129.4050 285.7600}

8. u_core/core_i/HFSINV_20734_818/A
   cell: INVX8_LVT
   net: u_core/core_i/HFSNET_41
   layer: M1
   bbox: {262.6890 288.3770} {263.9400 288.5320}
```

Region 7 also intersects the same cell's `VSS` pin because the VSS rail overlaps the expanded search box, but the reported signal access warning maps to `U1545/S1`.

## Library Geometry Clue

SAED32 technology file:

```text
File: /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
Layer: M1
pitch: 0.152
defaultWidth: 0.05
minSpacing: 0.05
onWireTrack: 1
```

The flagged cells come from normal SAED32 stdcell LEF geometry:

```text
SDFFARX1_RVT QN:
  LEF has M1/CO pin geometry near x=5.127..5.375 and y=0.154..1.546.

INVX8_LVT A:
  LEF has M1 pin geometry near x=0.249..1.500 and y=0.660..0.815.

MUX41X1_HVT S1:
  LEF has M1/CO pin geometry near x=0.249..1.485 and y=0.088..0.333.
```

## 판단

현재 증거상 off-track warning은 top-level PG port 문제가 아니다.

이유:

```text
PG net open 없음
VDD/VSS no-pin/unplaced warning 제거됨
blocked port/net 없음
standard-cell overlap 없음
min-grid violation 없음
warning 좌표가 실제 stdcell M1 pin shape와 매핑됨
```

가장 강한 후보는 SAED32 stdcell pin access와 ICC2 routing track/contact setup 사이의 불일치다.

구체적으로는 다음 항목을 봐야 한다.

```text
M1 routing track 정의와 stdcell pin shape alignment
CO default contact code warning ZRT-022
VIA1/contact rule selection
DB+LEF -> NDM 변환 과정의 pin access 정보
Milkyway reference와 LEF-built NDM의 차이
```

## 하지 말 것

```text
stdcell LEF/NDM pin geometry를 임의 수정하지 않는다.
off-track pin만 보고 cell placement를 수동 이동하지 않는다.
blind detail_route 반복을 main fix로 쓰지 않는다.
route DRC clean 전에는 post-route STA를 signoff처럼 말하지 않는다.
```

## 다음 액션

```text
1. CO default contact code/ZRT-022 원인을 먼저 확인한다.
2. SAED32 Milkyway reference library를 직접 사용할 수 있는지 다시 확인한다.
3. LEF-built NDM의 M1 track/pin access 정보를 ICC2에서 report한다.
4. lower-metal route/via/contact option을 작은 trial로 하나씩 바꿔 비교한다.
5. scan DEF handoff는 별도 cleanup으로 유지한다.
```
