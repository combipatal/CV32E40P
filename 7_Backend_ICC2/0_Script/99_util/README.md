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
