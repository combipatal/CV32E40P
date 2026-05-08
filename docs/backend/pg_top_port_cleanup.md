# PG Top Port Cleanup

## Goal

```text
Remove route-time VDD/VSS top port no-pin/unplaced warnings without breaking PG connectivity.
```

## Problem

`compile_pg` creates usable boundary PG ports as:

```text
VDD_1
VSS_1
```

The design also has logical top ports:

```text
VDD
VSS
```

Diagnosis showed:

```text
VDD   port_count 1, terminal_count 0
VSS   port_count 1, terminal_count 0
VDD_1 port_count 1, terminal_count 8
VSS_1 port_count 1, terminal_count 8
```

So `check_routability` reported:

```text
Port VDD/VSS is unplaced
Ignore 2 top cell ports with no pins
```

## Rejected Trial 1: Remove VDD/VSS Ports

Trial:

```text
remove_ports -force [get_ports {VDD VSS}]
```

Result:

```text
PG connectivity stayed clean.
But after save/reopen or later flow, VDD/VSS appeared again as terminal-less PG ports.
```

Decision:

```text
Do not use remove_ports as the final cleanup method.
```

## Rejected Trial 2: Reassign Existing Terminals

Trial:

```text
set_attribute [get_terminals VDD_1_0] port [get_ports VDD]
set_attribute [get_terminals VSS_1_0] port [get_ports VSS]
```

Result:

```text
ICC2 rejected this.
Error: Attribute 'port' on terminal cannot be updated because the terminal is not a bond pad.
```

Decision:

```text
Do not reassign compile_pg-created terminals.
```

## Rejected Trial 3: Duplicate Existing Boundary Terminal Location

Trial:

```text
create_terminal -port VDD -boundary {{13 0} {15 2}} -layer M8
create_terminal -port VSS -boundary {{10 0} {12 2}} -layer M8
```

Result:

```text
No-pin warning disappeared.
PG connectivity stayed clean.
But check_routability reported duplicate redundant library pin shape warnings.
```

Decision:

```text
Do not overlap the existing VDD_1/VSS_1 boundary terminal shapes.
```

## Accepted Trial: Offset Terminal On Existing M8 Ring

Trial:

```text
create_terminal -port VDD -boundary {{13 3} {15 5}} -layer M8
create_terminal -port VSS -boundary {{10 3} {12 5}} -layer M8
```

Why:

```text
The coordinates are inside the existing M8 VDD/VSS ring shapes.
They do not overlap the existing VDD_1/VSS_1 terminal bboxes at y=0..2.
```

Result:

```text
VDD terminal_count: 0 -> 1
VSS terminal_count: 0 -> 1
VDD_1 terminal_count: 8 remains
VSS_1 terminal_count: 8 remains
save/reopen diagnosis keeps VDD/VSS terminal_count at 1
check_routability no longer reports VDD/VSS no-pin/unplaced warnings
No duplicate redundant pin-shape warning
PG connectivity remains clean
PG DRC reports no errors
Route DRC count unchanged at 400 in the current routed trial block
```

Evidence:

```text
7_Backend_ICC2/3_Log/trials/pg_terminal_attach_offset/pg_terminal_attach_offset.log
7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/terminal_attach_summary.rpt
7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/check_routability.after.rpt
7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/check_routes.after.rpt
7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/pg_connectivity.after.rpt
7_Backend_ICC2/4_Report/trials/pg_terminal_attach_offset/99_pg_port/pg_drc.after.rpt
7_Backend_ICC2/4_Report/trials/pg_port_diagnose_after_offset/99_pg_port/pg_port_summary.rpt
```

## Flow Update

The accepted offset terminal attach is now part of:

```text
7_Backend_ICC2/0_Script/03_power/run_power_initial.tcl
7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
```

This cleanup removes a route setup warning.
It does not close route DRC.

Remaining route issue:

```text
lower-metal/VIA1/contact/grid behavior
8 off-track M1 pins after PG top-port cleanup
route DRC still 400 on current check_routes
```
