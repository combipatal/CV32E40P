# ICC2 First-Pass Route Plan

## Scope

First-pass signal routing after CTS.

## Starting Point

```text
Input block: cv32e40p_icc2_lib:cv32e40p_synth_wrap.design
State: post-CTS
Clock: clk_i
Clock period: 10 ns
Corner: TT 1.05V 25C
```

## Acceptance Criteria

```text
route_auto completes
check_routes report is generated
timing max/min reports are generated
check_legality reports result
PG connectivity and PG DRC reports are generated
Any remaining electrical/PG/open-route issues are recorded before extraction/STA
```

## Risk Notes

```text
This is not signoff route.
Post-CTS already had whole-design max_transition/max_cap open items.
VSS had 2 terminal-only sub-networks after CTS.
Scan DEF is still missing, so scan-aware placement/reorder was not active.
```

## Result Snapshot

```text
Date: 2026-05-08
Result: PASS_WITH_OPEN
Script: 7_Backend_ICC2/0_Script/06_route/run_route_initial.tcl
Log: 7_Backend_ICC2/3_Log/06_route/route_initial.log

Completed:
  route_auto
  route reports
  timing reports
  legality report
  PG reports

Main evidence:
  open nets: 0
  route DRC: 408 in check_routes report
  route_auto stopped because detail route did not converge
  route DRC classes: diff-net spacing 131, minimum area 8, needs fat contact 106, off-grid 163
  timing: listed setup/hold paths are MET
  legality: TOTAL 0 violations
  PG connectivity: VDD/VSS floating wires/vias/std cells/terminals all 0
  PG DRC: no errors

Open items before extraction/STA:
  route DRC must be reduced to 0
  max routing layer was not explicitly set
  check_routability should be run before future route attempts
  top VDD/VSS ports are reported unplaced/no-pin during routing
```

## Diagnosis Snapshot

```text
Date: 2026-05-08
Script: 7_Backend_ICC2/0_Script/06_route/run_route_drc_diagnose.tcl

Fresh evidence:
  check_routability: no PG net open
  check_routability: no blocked ports/nets
  check_routability: no standard-cell overlap
  check_routability: no min-grid violations
  check_routability: found 2 unplaced top PG ports
  check_routability: found 3 off-track M1 pins
  check_routability: found one long VSS PG detail_route shape
  check_routes.fresh: 408 route DRCs, 0 open nets
  utilization.fresh: 77.17%

Current diagnosis:
  Route DRC is not caused by open nets or PG connectivity failure.
  Most likely cause is combined routing congestion, PG/top-port cleanup, and
  tech/via/contact/grid setup.
```
