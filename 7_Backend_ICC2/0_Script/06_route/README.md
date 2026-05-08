# 06_route

Global/detail route and route optimization scripts.

## Scripts

```text
run_route_initial.tcl
  CTS block에서 signal route를 수행합니다.
  현재 signal routing layer bound는 M1-M8입니다.

run_route_drc_diagnose.tcl
  route 후 check_routability, check_routes, utilization, QoR를 다시 뽑습니다.

run_route_drc_detail.tcl
  zroute.err marker data를 열어서 DRC matrix/by-layer/detailed report를 만듭니다.
```
