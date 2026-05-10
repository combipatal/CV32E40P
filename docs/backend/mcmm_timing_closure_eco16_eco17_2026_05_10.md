# ECO16/ECO17 Residual Max-Cap Closure

Date: 2026-05-10

## Starting Point

Base block:

```text
hold_eco15_maxcap_occupied_from_eco14
```

ECO15 status:

```text
Physical: route DRC 0, open nets 0, legality 0
PT TT/SS/FF -40C cmax/cmin setup/hold: clean
PT FF -40C cmax constraint: 8 small max_cap violations
```

Root cause:

```text
ICC2 active max_cap ECO scenario fixed internal max_cap to 0,
but external PrimeTime FF -40C cmax still saw tighter residual pin limits.
The residual list was short and the violation magnitudes were tiny.
```

## ECO16b

Action:

```text
Resize the 7 non-flop residual max_cap drivers.
Run legalize_placement before route_eco.
```

Why legalization was required:

```text
The first ECO16 size trial changed cell widths and produced placement overlaps.
ECO16b added legalize_placement, then reran route_eco.
```

Result:

```text
size_ok=7
size_fail=0
route DRC=0
open nets=0
legality violations=0
ICC2 max_cap violations=0
PT FF -40C cmax residual max_cap: 1
```

Remaining pin:

```text
u_core/core_i/id_stage_i/register_file_i/mem_reg[9][14]/Q
required 8.00, actual 8.01
```

Decision:

```text
Do not resize or swap the scan flop for a 0.01 residual load issue.
Use load splitting instead.
```

Evidence:

```text
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco16b_residual_maxcap_size7_legalize/residual_maxcap_size_eco_manifest.txt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco16b_residual_maxcap_size7_legalize/check_routes.after_residual_maxcap_size.rpt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco16b_residual_maxcap_size7_legalize/check_legality.after_residual_maxcap_size.rpt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco16b_residual_maxcap_size7_legalize/constraints.after_residual_maxcap_size.rpt
6_STA/4_Report/hold_eco16b_residual_maxcap_size7_legalize_spef_ff1p16vn40c_propclk/hold_eco16b.func_ff1p16vn40c_10ns_spef_propclk.cmax.constraints.rpt
```

## ECO17

Action:

```text
Insert one NBUFFX2_HVT after:
u_core/core_i/id_stage_i/register_file_i/mem_reg[9][14]/Q
```

Rationale:

```text
The violation was a flop Q load issue, not a logic depth issue.
Adding one buffer splits downstream capacitance and avoids changing the scan flop.
```

Physical result:

```text
added=1
failed=0
route_status=0
route DRC=0
open nets=0
legality violations=0
ICC2 max_cap violations=0
```

PrimeTime propagated-clock SPEF STA result:

```text
TT 1.05V 25C cmax/cmin: setup clean, hold clean, constraints clean
SS 0.95V 125C cmax/cmin: setup clean, hold clean, constraints clean
FF 1.16V -40C cmax/cmin: setup clean, hold clean, constraints clean
```

All six `report_constraint -all_violators` reports contain only headers and no violator rows.

Evidence:

```text
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco17_flop_q_load_split/residual_maxcap_output_buffer_eco_manifest.txt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco17_flop_q_load_split/check_routes.after_output_buffer.rpt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco17_flop_q_load_split/check_legality.after_output_buffer.rpt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco17_flop_q_load_split/constraints.after_output_buffer.rpt
6_STA/4_Report/hold_eco17_flop_q_load_split_spef_tt1p05v25c_propclk/
6_STA/4_Report/hold_eco17_flop_q_load_split_spef_ss0p95v125c_propclk/
6_STA/4_Report/hold_eco17_flop_q_load_split_spef_ff1p16vn40c_propclk/
```

## Current Recommendation

Use `hold_eco17_flop_q_load_split` as the current STA-clean backend candidate.

Final ECO N2N Formality:

```text
tool: Formality W-2024.09-SP5
reference: post_dft_topo_no_or2x1_nor2x012_hvt
implementation: hold_eco17_flop_q_load_split
result: PASS
passing compare points: 2243
failing compare points: 0
unmatched compare points: 0
not compared: 74 clock-gate LAT, 1 scan_out don't-verify
```

Evidence:

```text
5_FM_N2N/0_Script/run_fm_n2n_hold_eco17_flop_q_load_split.tcl
5_FM_N2N/4_Report/hold_eco17_flop_q_load_split/n2n_hold_eco17_flop_q_load_split.verify.rpt
5_FM_N2N/4_Report/hold_eco17_flop_q_load_split/n2n_hold_eco17_flop_q_load_split.failing_points.rpt
5_FM_N2N/4_Report/hold_eco17_flop_q_load_split/n2n_hold_eco17_flop_q_load_split.unmatched_points.post_verify.rpt
5_FM_N2N/4_Report/hold_eco17_flop_q_load_split/n2n_hold_eco17_flop_q_load_split.passing_points.post_verify.rpt
```

Remaining caveat:

```text
This is educational backend closure evidence.
Do not call it full foundry signoff without DRC/LVS with signoff decks, IR/EM, antenna, noise, and final signoff STA methodology.
```
