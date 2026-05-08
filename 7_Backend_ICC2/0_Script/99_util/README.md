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
