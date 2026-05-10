# MCMM Timing Closure ECO7 Notes

Date: 2026-05-10

## Current Feedback Loop

The active pass/fail loop is:

```text
ICC2 ECO netlist/SPEF export
PrimeTime SS propagated-clock STA
PrimeTime FF -40C propagated-clock STA
compare global_timing + constraints reports
```

This is now sharper than TT-only STA because it catches:

```text
SS setup failure
FF hold failure
electrical design-rule residue
```

## ECO7 Change

ECO7 changed 32 critical SS setup-path full-adder cells from HVT to RVT.

Source block:

```text
cv32e40p_synth_wrap_maxtran_eco6_u246_rvt_swap
```

New block:

```text
cv32e40p_synth_wrap_ss_setup_eco7_fadd_rvt_trial
```

Swap file:

```text
configs/backend/ss_setup_fadd_hvt_to_rvt_trial.tsv
```

Main script:

```text
7_Backend_ICC2/0_Script/07_extract_sta/run_ss_setup_eco7_fadd_rvt_trial.tcl
```

## Physical Result

ECO7 physical result is clean at ICC2 route/electrical level.

Evidence:

```text
7_Backend_ICC2/2_Output/07_extract_sta/ss_setup_eco7_fadd_rvt_trial/ss_setup_eco_manifest.txt
7_Backend_ICC2/4_Report/07_extract_sta/ss_setup_eco7_fadd_rvt_trial/check_routes.after_ss_setup_eco.rpt
7_Backend_ICC2/4_Report/07_extract_sta/ss_setup_eco7_fadd_rvt_trial/check_legality.after_ss_setup_eco.rpt
7_Backend_ICC2/4_Report/07_extract_sta/ss_setup_eco7_fadd_rvt_trial/constraints.after_ss_setup_eco.rpt
```

Observed:

```text
swap_ok = 32
swap_fail = 0
route_eco open nets = 0
route_eco violations = 0
check_routes errors = 0
check_legality violations = 0
ICC2 max_transition/max_capacitance violations = 0
```

## STA Result

PrimeTime was run with `PROPAGATE_CLOCK=1`.

Evidence:

```text
6_STA/4_Report/ss_setup_eco7_fadd_rvt_trial_spef_ss0p95v125c_propclk/
6_STA/4_Report/ss_setup_eco7_fadd_rvt_trial_spef_ff1p16vn40c_propclk/
6_STA/3_Log/pt_ss_setup_eco7_10ns_spef_ss0p95v125c_propclk.log
6_STA/3_Log/pt_ss_setup_eco7_10ns_spef_ff1p16vn40c_propclk.log
```

Summary:

```text
Corner/RC                 Setup                   Hold
SS cmax propagated clock  clean, worst +0.10 ns   clean
SS cmin propagated clock  clean, worst +0.25 ns   clean
FF -40C cmax prop clock   clean                   WNS -0.05 ns, TNS -1.99 ns, 225 endpoints
FF -40C cmin prop clock   clean                   WNS -0.05 ns, TNS -2.39 ns, 268 endpoints
```

Conclusion:

```text
ECO7 fixes the SS setup problem.
The remaining timing problem is FF hold.
```

## Ranked Next Hypotheses

1. Hold paths are short local reg-to-reg paths with too little data delay.
   Prediction: inserting dedicated delay cells or small buffers on the violating data paths should improve FF hold without hurting SS setup much.

2. Propagated CTS skew is making some FF launch/capture pairs pessimistic for hold.
   Prediction: useful-skew/CTS hold optimization or post-route hold ECO should reduce the same endpoint groups.

3. RVT FADD setup ECO increased speed only in ALU setup logic and does not materially affect FF hold.
   Prediction: FF hold endpoint count remains almost identical to ECO6, which is what ECO7 shows.

4. A single global uncertainty/hold-margin knob may hide the problem but is not a real physical fix.
   Prediction: changing constraints can make reports pass, but netlist/SPEF path delay will not improve.

## Recommended Fix Direction

Use a hold-specific ECO, not another setup-speed ECO.

Preferred next step:

```text
Generate FF -40C hold violator list
Group by startpoint/endpoint module
Insert or size delay cells only on repeated short data paths
Run route_eco
Re-run SS setup and FF hold with propagated clock
```

Candidate path groups seen in reports:

```text
debug_force_wakeup_q_reg -> dcsr_q_reg[cause]
alu_div_i/Cnt_DP_reg[0] -> Cnt_DP_reg[1]
instruction_obi_i/state_q_reg -> obi_addr_q_reg[*]
```

## Hold Probe

A deeper FF -40C hold probe was run after ECO7.

Script:

```text
6_STA/0_Script/probe_eco7_ff_hold_paths.tcl
```

Evidence:

```text
6_STA/3_Log/pt_probe_eco7_ff_hold_paths.log
6_STA/4_Report/ss_setup_eco7_fadd_rvt_trial_spef_ff1p16vn40c_propclk/hold_probe/
```

Repeated endpoint/startpoint module groups in the top violating paths:

```text
Group                                                cmax paths  cmin paths
prefetch_buffer_i/fifo_i -> fifo_i                   65          65
instruction_obi_i -> instruction_obi_i               30          30
alu_div_i -> alu_div_i                               20          21
prefetch_controller_i -> prefetch_controller_i        4           2
mhpmevent_minstret_o_reg -> mhpmcounter_q[*]         17          44
```

Observed worst path style:

```text
FF launch -> one or two small data gates -> FF capture
```

Examples:

```text
debug_force_wakeup_q_reg/QN -> AND3X1_HVT -> dcsr_q_reg[cause][8]/D
Cnt_DP_reg[0]/QN -> MUX41X1_HVT -> Cnt_DP_reg[1]/D
state_q_reg/Q -> NBUFFX4_HVT -> AO22X1_HVT -> obi_addr_q_reg[*]/D
```

Available delay cells exist in all VT libraries:

```text
DELLN1X2_RVT/LVT/HVT
DELLN2X2_RVT/LVT/HVT
DELLN3X2_RVT/LVT/HVT
```

Refined next trial:

```text
Use ICC2 hold ECO or targeted DELLN insertion.
Start with repeated groups, not one-off endpoints.
Prefer HVT delay cells for hold because setup is already fixed but still needs margin preservation.
Re-run SS setup after every hold trial.
```

Acceptance target:

```text
SS cmax/cmin setup clean
FF -40C cmax/cmin hold clean
ICC2 route DRC 0
ICC2 legality 0
PT report_constraint all_violators empty or explained
```

## ECO8/ECO9 Hold Trials

ECO8 tried automatic ICC2 hold repair with an 80 ps margin.

Result:

```text
Inserted buffers: 0
Reason: active ICC2 ECO scenario did not see the FF -40C propagated-clock hold failure.
PT FF -40C hold: unchanged from ECO7.
Decision: reject as no-effect.
```

ECO9 tried manual DELLN insertion on every unique FF -40C cmin hold endpoint.

ICC2 physical result:

```text
Inserted DELLN1X2_HVT cells: 268
route DRC: 0
open nets: 0
legality violations: 0
```

FF -40C PrimeTime result:

```text
cmax: no setup violations; hold WNS -0.00 ns / TNS -0.00 ns / 5 endpoints
cmin: no setup violations; hold WNS -0.00 ns / TNS -0.00 ns / 1 endpoint
```

SS PrimeTime result:

```text
cmax: setup WNS -0.44 ns / TNS -1.04 ns / 4 endpoints; hold clean
cmin: setup WNS -0.11 ns / TNS -0.14 ns / 2 endpoints; hold clean
```

Why ECO9 is rejected:

```text
The blanket DELLN insertion fixed most short hold paths but also added endpoint
delay to setup-critical long paths.

Worst broken path:
  mhpmcounter_q_reg[2][2] -> mhpmcounter_q_reg[2][63]

The inserted DELLN1X2_HVT on mhpmcounter_q_reg[2][63]/D adds about 0.32 ns
at SS on a long counter chain. ECO7 only had small positive SS margin, so this
single endpoint delay is enough to create -0.44 ns setup slack.
```

Current diagnosis:

```text
The remaining problem is no longer "which delay cell exists".
The problem is setup/hold tradeoff across corners.

Hold-only endpoint insertion is too blunt.
The next fix must either:
  1. run a real MCMM-aware ICC2 hold ECO with SS setup and FF hold scenarios, or
  2. use manual filtered delay insertion and separately recover setup-critical
     mhpmcounter paths.
```

Recommended next trial:

```text
ECO10 filtered manual hold ECO:
  Start from ECO7, not ECO9.
  Insert DELLN1X2_HVT only on non-mhpmcounter endpoint groups first.
  Exclude mhpmcounter high-bit endpoints that broke SS setup.
  Re-run FF -40C hold and SS setup.

  Script support:
    run_hold_eco9_manual_delln1.tcl now accepts INCLUDE_ENDPOINT_REGEX and
    EXCLUDE_ENDPOINT_REGEX, so ECO10 can reuse the same simple script with
    endpoint filters instead of editing the Tcl each time.

If hold remains only on mhpmcounter:
  Try paired ECO:
    add minimal hold delay on selected mhpmcounter endpoints
    recover setup by swapping selected NAND2X0/INVX1/HADDX cells in the same
    counter path from HVT to RVT
  Then route_eco and re-run SS/FF PT.
```

## ECO10 Filtered Hold Trial

ECO10 reused the manual DELLN script but excluded `mhpmcounter_q_reg`.

Command intent:

```text
Start from ECO7.
Insert DELLN1X2_HVT on non-mhpmcounter hold endpoints.
Skip setup-critical mhpmcounter endpoints.
```

ICC2 physical result:

```text
Unique endpoints in ECO7 cmin hold report: 268
Inserted DELLN1X2_HVT cells: 218
Excluded mhpmcounter endpoints: 50
route DRC: 0
open nets: 0
legality violations: 0
```

PrimeTime result:

```text
SS cmax propagated clock: no setup violations, no hold violations
SS cmin propagated clock: no setup violations, no hold violations

FF -40C cmax propagated clock:
  setup clean
  hold WNS -0.02 ns / TNS -0.27 ns / 28 endpoints

FF -40C cmin propagated clock:
  setup clean
  hold WNS -0.02 ns / TNS -0.48 ns / 51 endpoints
```

Diagnosis refined:

```text
ECO10 proves the non-mhpmcounter hold paths can be fixed without breaking SS setup.
The remaining hold failures are the mhpmcounter endpoints excluded from ECO10.
ECO9 proved that adding DELLN1 directly to those endpoints breaks SS setup.

Therefore the next problem is narrow:
  mhpmcounter hold needs extra min delay,
  but mhpmcounter setup counter-chain needs recovery at SS.
```

Recommended ECO11 direction:

```text
Start from ECO10.
Target only remaining mhpmcounter hold endpoints.
Use paired setup/hold ECO:
  add minimal hold delay on selected mhpmcounter endpoints,
  swap selected cells on the same counter setup chain from HVT to RVT.

Cells seen on worst ECO9 SS setup path:
  many NAND2X0_HVT / INVX1_HVT stages
  endpoint HADDX1_HVT / AO22X1_HVT before the D pin

First probe:
  compare how many HVT->RVT swaps are needed to recover about 0.3 to 0.5 ns
  before inserting DELLN on the same endpoint group.
```

## ECO11-ECO13 Hold/Setup Tradeoff

ECO11:

```text
Start block: hold_eco10_delln1_no_mhpmcounter
Action: insert NBUFFX2_HVT on 50 mhpmcounter endpoints
Physical: route DRC 0, open nets 0, legality 0

SS propagated-clock STA:
  cmax clean
  cmin clean

FF -40C propagated-clock STA:
  cmax hold WNS -0.01 / TNS -0.03 / 8 endpoints
  cmin hold WNS -0.01 / TNS -0.07 / 18 endpoints
```

ECO12:

```text
Start block: hold_eco11_mhpmcounter_nbuffx2
Action: add 19 NBUFFX2_HVT cells on residual endpoints
Physical: route DRC 0, open nets 0, legality 0

FF -40C propagated-clock STA:
  cmax hold WNS -0.00 / TNS -0.00 / 5 endpoints
  cmin hold WNS -0.00 / TNS -0.00 / 1 endpoint

SS propagated-clock STA:
  cmax setup WNS -0.07 / TNS -0.07 / 1 endpoint
  cmin clean

Verdict: reject as final because SS setup is violated.
```

ECO13:

```text
Start block: hold_eco12_residual_nbuffx2
Action: add 6 final NBUFFX2_HVT cells listed in
        7_Backend_ICC2/1_Input/hold_eco13_residual_endpoints.rpt
Physical: route DRC 0, open nets 0, legality 0

FF -40C propagated-clock STA:
  cmax clean
  cmin clean

SS propagated-clock STA:
  cmax setup WNS -0.07 / TNS -0.07 / 1 endpoint
  cmin clean

Verdict: reject as final because SS setup is still violated.
```

Current diagnosis:

```text
The broad non-mhpmcounter hold problem is solved by ECO10.
The remaining problem is a narrow mhpmcounter counter-chain setup/hold tradeoff.

Failing SS setup path after ECO13:
  Startpoint: mhpmcounter_q_reg[2][2]
  Endpoint:   mhpmcounter_q_reg[2][63]
  Worst slack: -0.07 ns at SS cmax propagated-clock

The path contains many HVT stages:
  NAND2X0_HVT
  INVX1_HVT
  HADDX1_HVT
  AO22X1_HVT

The endpoint side includes inserted NBUFFX2_HVT cells.
This fixes FF hold but consumes about the remaining SS setup margin.
```

Ranked fix hypotheses:

```text
1. Targeted setup recovery on the same mhpmcounter path.
   Prediction:
     swapping selected HVT cells in the path to RVT should recover >70 ps SS setup
     while FF hold remains clean or only mildly regresses.

2. Reduce endpoint delay on mhpmcounter_q_reg[2][63].
   Prediction:
     removing one late NBUFFX2_HVT from the endpoint should clean SS setup,
     but may re-open a very small FF hold violation on that endpoint.

3. Move delay earlier or distribute delay away from the setup-critical endpoint.
   Prediction:
     earlier/smaller delay may improve FF hold without adding the full delay
     directly to the capture D arc of the longest counter setup path.

4. Replace manual ECO with real MCMM ICC2 hold repair.
   Prediction:
     if ICC2 sees FF hold and SS setup scenarios simultaneously, it should avoid
     hold fixes that break the mhpmcounter setup path.
```

Recommended next action:

```text
Do a small setup-recovery ECO from ECO13:
  1. Use the ECO13 SS cmax setup report as the target path.
  2. Swap a small number of cells near the endpoint from HVT to RVT first.
  3. Re-route ECO.
  4. Re-run PT:
       FF -40C cmax/cmin
       SS cmax/cmin
  5. Accept only if route DRC 0, legality 0, FF hold clean, and SS setup clean.
```

Evidence:

```text
7_Backend_ICC2/3_Log/07_extract_sta/hold_eco8_margin80ps.log
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco8_margin80ps/hold_eco_manifest.txt
6_STA/3_Log/pt_hold_eco8_10ns_spef_ff1p16vn40c_propclk.log
7_Backend_ICC2/3_Log/07_extract_sta/hold_eco9_manual_delln1_all.log
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco9_manual_delln1_all/hold_manual_eco_manifest.txt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco9_manual_delln1_all/check_routes.after_hold_manual.rpt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco9_manual_delln1_all/check_legality.after_hold_manual.rpt
6_STA/3_Log/pt_hold_eco9_10ns_spef_ff1p16vn40c_propclk.log
6_STA/3_Log/pt_hold_eco9_10ns_spef_ss0p95v125c_propclk.log
6_STA/4_Report/hold_eco9_manual_delln1_all_spef_ff1p16vn40c_propclk/
6_STA/4_Report/hold_eco9_manual_delln1_all_spef_ss0p95v125c_propclk/
7_Backend_ICC2/3_Log/07_extract_sta/hold_eco10_delln1_no_mhpmcounter.log
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco10_delln1_no_mhpmcounter/hold_manual_eco_manifest.txt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco10_delln1_no_mhpmcounter/check_routes.after_hold_manual.rpt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco10_delln1_no_mhpmcounter/check_legality.after_hold_manual.rpt
6_STA/3_Log/pt_hold_eco10_10ns_spef_ff1p16vn40c_propclk.log
6_STA/3_Log/pt_hold_eco10_10ns_spef_ss0p95v125c_propclk.log
6_STA/4_Report/hold_eco10_delln1_no_mhpmcounter_spef_ff1p16vn40c_propclk/
6_STA/4_Report/hold_eco10_delln1_no_mhpmcounter_spef_ss0p95v125c_propclk/
7_Backend_ICC2/3_Log/07_extract_sta/hold_eco11_mhpmcounter_nbuffx2.log
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco11_mhpmcounter_nbuffx2/hold_manual_eco_manifest.txt
6_STA/3_Log/pt_hold_eco11_10ns_spef_ff1p16vn40c_propclk.log
6_STA/3_Log/pt_hold_eco11_10ns_spef_ss0p95v125c_propclk.log
7_Backend_ICC2/3_Log/07_extract_sta/hold_eco12_residual_nbuffx2.log
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco12_residual_nbuffx2/hold_manual_eco_manifest.txt
6_STA/3_Log/pt_hold_eco12_10ns_spef_ff1p16vn40c_propclk.log
6_STA/3_Log/pt_hold_eco12_10ns_spef_ss0p95v125c_propclk.log
7_Backend_ICC2/3_Log/07_extract_sta/hold_eco13_final6_nbuffx2.log
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco13_final6_nbuffx2/hold_manual_eco_manifest.txt
6_STA/3_Log/pt_hold_eco13_10ns_spef_ff1p16vn40c_propclk.log
6_STA/3_Log/pt_hold_eco13_10ns_spef_ss0p95v125c_propclk.log
6_STA/4_Report/hold_eco13_final6_nbuffx2_spef_ss0p95v125c_propclk/hold_eco13.func_ss0p95v125c_10ns_spef_propclk.cmax.setup_timing.rpt
```
