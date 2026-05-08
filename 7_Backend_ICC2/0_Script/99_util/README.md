# 99_util

Small helper scripts used by the backend flow.

## run_trial_60util_to_route.tcl

60% floorplan utilization trial.
Rebuilds ICC2 lib and reruns init, floorplan, PG, place, CTS, and route.

Use only for route DRC diagnosis.
Main flow scripts remain under `01_init_design` through `06_route`.

Optional environment variables:

```text
TRIAL_NAME=60util_m8
SIGNAL_MIN_ROUTING_LAYER=M1
SIGNAL_MAX_ROUTING_LAYER=M8
```

`SIGNAL_MAX_ROUTING_LAYER` is for route-layer-bound experiments.
Leave it unset for the original density-only trial.

## run_trial_detail_route_repair.tcl

Incremental detail-route repair trial on the current ICC2 block.
Use after route DRC detail diagnosis.

Optional environment variables:

```text
TRIAL_NAME=detail_repair_200iter
DETAIL_ROUTE_ITERATIONS=200
```

This does not rebuild from init.
It starts from the current saved ICC2 block.

## PG port diagnostic trials

```text
run_pg_port_diagnose.tcl
  VDD/VSS and VDD_1/VSS_1 port/terminal counts를 확인합니다.

run_pg_port_cleanup_trial.tcl
  VDD/VSS stale port 삭제 trial입니다. save/reopen 뒤 유지되지 않아 final fix로 쓰지 않습니다.

run_pg_terminal_attach_trial.tcl
  VDD/VSS port에 M8 terminal을 붙이는 trial입니다.
  accepted offset 위치는 VDD {{13 3} {15 5}}, VSS {{10 3} {12 5}}입니다.

run_pg_terminal_reassign_trial.tcl
  VDD_1_0/VSS_1_0 terminal owner reassign trial입니다.
  ICC2가 non-bond-pad terminal port 변경을 막아서 rejected입니다.
```

## run_offtrack_pin_diagnose.tcl

`check_routability`가 좌표만 보여주는 M1 off-track pin warning을 실제 pin/cell/net 이름으로 추적합니다.

현재 결과:

```text
8개 off-track warning은 top-level PG port가 아니라 stdcell M1 pin입니다.
주요 cell은 SDFFARX1_RVT/QN, INVX8_LVT/A, MUX41X1_HVT/S1입니다.
```

결과 문서:

```text
docs/backend/offtrack_pin_diagnosis.md
```

## run_contact_code_diagnose.tcl

`ZRT-022 Cannot find a default contact code for layer CO` warning을 진단합니다.

현재 결과:

```text
CO layer는 존재하지만 CO용 via_def/default contact는 없습니다.
VIA1에는 default via_def VIA12SQ_C가 있습니다.
따라서 ZRT-022는 CO pin-shape warning이고, M1-M2 via가 통째로 없는 문제는 아닙니다.
```

결과 문서:

```text
docs/backend/contact_code_diagnosis.md
```

## run_mw_ref_open_trial.tcl

원본 SAED32 Milkyway reference library를 ICC2 `create_lib -ref_libs`에 직접 넣어 자동 변환/link가 되는지 확인합니다.

현재 결과:

```text
Milkyway direct path는 이 환경에서 blocked입니다.
icc_shell 없음, Milkyway/MDataPrep license 없음, export tar.gz 생성 실패.
현재 backend는 DB+LEF -> NDM path를 계속 사용합니다.
```

보조 wrapper:

```text
icc_milkyway_exec_wrapper.sh
```

결과 문서:

```text
docs/backend/mw_ref_open_trial.md
```
