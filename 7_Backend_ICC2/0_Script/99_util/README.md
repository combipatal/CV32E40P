# 99_util

Small helper scripts used by the backend flow.

## run_trial_60util_to_route.tcl

60% floorplan utilization trial.
Rebuilds ICC2 lib and reruns init, floorplan, PG, place, CTS, and route.

Use only for route DRC diagnosis.
Main flow scripts remain under `01_init_design` through `06_route`.
