# MCMM Timing Closure ECO14/ECO15 Notes

## Current State

Current best timing base:

```text
hold_eco15_maxcap_occupied_from_eco14
```

Physical checks are clean:

```text
route DRC: 0
open nets: 0
legality: 0
```

PrimeTime SPEF propagated-clock setup/hold is clean:

```text
TT cmax/cmin: setup clean, hold clean
SS cmax/cmin: setup clean, hold clean
FF -40C cmax/cmin: setup clean, hold clean
```

Electrical constraint is still open:

```text
FF -40C cmax max_cap: 8 violations
worst: u_core/core_i/id_stage_i/U498/Y
required: 32.00
actual: 32.17
slack: -0.17
```

Evidence:

```text
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco14_setup_recovery_u1856_u1857_rvt/setup_recovery_eco_manifest.txt
7_Backend_ICC2/2_Output/07_extract_sta/hold_eco15_maxcap_occupied_from_eco14/max_cap_eco_manifest.txt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco15_maxcap_occupied_from_eco14/check_routes.after_max_cap_eco.rpt
7_Backend_ICC2/4_Report/07_extract_sta/hold_eco15_maxcap_occupied_from_eco14/check_legality.after_max_cap_eco.rpt
6_STA/4_Report/hold_eco15_maxcap_occupied_from_eco14_spef_ff1p16vn40c_propclk/hold_eco15.func_ff1p16vn40c_10ns_spef_propclk.cmax.constraints.rpt
```

## What ECO14 Did

ECO13 had closed FF hold but broke one SS setup path in the mhpmcounter chain.

ECO14 changed two setup-path cells:

```text
u_core/core_i/cs_registers_i/U1856  HADDX1_HVT -> HADDX1_RVT
u_core/core_i/cs_registers_i/U1857  AO22X1_HVT -> AO22X1_RVT
```

Result:

```text
swap_ok=2
swap_fail=0
route_status=0
SS setup recovered
FF hold stayed clean
```

## What ECO15 Did

ECO15 started from ECO14 and ran:

```text
eco_opt -types max_capacitance -physical_mode occupied_site
```

ICC2 internal result:

```text
max_cap violations: 10 -> 0
size_cell commands: 4
insert_buffer commands: 7
route DRC after route_eco: 0
```

PrimeTime external SPEF result:

```text
TT: clean
SS: clean
FF -40C cmin: clean
FF -40C cmax: 8 max_cap violations
```

This means ICC2's active ECO scenario is not fully matching the external FF -40C cmax PrimeTime constraint check.

## Residual Max-Cap Pins

From the FF -40C cmax PT constraint report:

```text
u_core/core_i/id_stage_i/U498/Y                          32.00 -> 32.17
u_core/core_i/cs_registers_i/ZBUF_570_inst_1936/Y        32.00 -> 32.09
u_core/core_i/U1913/Y                                    16.00 -> 16.09
u_core/core_i/U2030/Y                                    16.00 -> 16.04
u_core/core_i/id_stage_i/ZBUF_69_inst_3241/Y             16.00 -> 16.01
u_core/core_i/id_stage_i/ZBUF_77_inst_1849/Y             16.00 -> 16.01
u_core/core_i/U318/Y                                     16.00 -> 16.01
u_core/core_i/id_stage_i/register_file_i/mem_reg[9][14]/Q 8.00 -> 8.01
```

The magnitudes are small. The fix should be focused.

## Ranked Fix Candidates

1. Targeted driver upsize or VT swap for the 8 residual pins.

Prediction:

```text
If the issue is only FF cmax max_cap margin, then increasing legal driver strength on these nets should remove the PT max_cap report while keeping setup/hold clean.
```

Risk:

```text
May slightly worsen FF hold if a data path is sped up.
Must rerun TT/SS/FF PT after the change.
```

2. Targeted load split by inserting one buffer on the worst high-cap nets.

Prediction:

```text
If the issue is net load distribution, then one inserted buffer near the heavy load side should lower the driver pin cap below the limit.
```

Risk:

```text
Can add delay and hurt SS setup.
More intrusive than a simple driver upsize.
```

3. Build explicit FF -40C cmax scenario inside ICC2 ECO.

Prediction:

```text
If ICC2 sees the same FF cmax constraint as PrimeTime, eco_opt should fix the same 8 pins automatically.
```

Risk:

```text
More setup work.
Could create larger ECO changes than needed.
```

4. Accept setup/hold-only closure and document max_cap as residual electrical DRC.

Prediction:

```text
No further ECO risk.
Portfolio can state setup/hold timing clean, but cannot claim full STA constraint clean.
```

Risk:

```text
Weaker closure claim.
```

## Recommended Next Step

Use option 1 first.

Reason:

```text
The residual violations are tiny.
The pin list is short.
The physical route is already clean.
Targeted size/VT changes are easiest to explain and easiest to back out.
```

Minimum ECO16 validation:

```text
1. ICC2 route DRC 0 / open nets 0 / legality 0
2. PT TT cmax/cmin setup/hold clean and constraints clean
3. PT SS cmax/cmin setup/hold clean and constraints clean
4. PT FF -40C cmax/cmin setup/hold clean and constraints clean
5. Record result in RUN_LOG, PROJECT_STATUS, and RESULT_SUMMARY
```

## ECO16 Concrete Trial Plan

Netlist inspection of the ECO15 export maps the 8 residual pins to this first trial list:

```text
Violating PT pin                                            Current cell/ref              First ECO16 action
u_core/core_i/id_stage_i/U498/Y                             NBUFFX4_HVT                  try stronger buffer or RVT buffer equivalent
u_core/core_i/cs_registers_i/ZBUF_570_inst_1936/Y           NBUFFX4_HVT                  try stronger buffer or RVT buffer equivalent
u_core/core_i/U1913/Y                                       INVX2_HVT                    size to INVX4_HVT
u_core/core_i/U2030/Y                                       NBUFFX2_HVT                  try stronger buffer or RVT buffer equivalent
u_core/core_i/id_stage_i/ZBUF_69_inst_3241/Y                NBUFFX2_HVT                  try stronger buffer or RVT buffer equivalent
u_core/core_i/id_stage_i/ZBUF_77_inst_1849/Y                NBUFFX2_HVT                  try stronger buffer or RVT buffer equivalent
u_core/core_i/U318/Y                                        NBUFFX2_HVT                  try stronger buffer or RVT buffer equivalent
u_core/core_i/id_stage_i/register_file_i/mem_reg[9][14]/Q   SDFFARX1_RVT                 do not blindly resize flop; prefer one load-split buffer if still violated
```

Notes:

```text
1. The NBUFF rows are buffer-tree residuals from earlier ECOs or synthesis buffering.
2. The INV row is the cleanest first size_cell candidate.
3. The flop Q row is only 0.01 over limit; avoid changing scan flop type unless library support and FM/DFT impact are checked.
4. If direct stronger NBUFF cells are not available as legal timing lib cells in the current ICC2 setup, use load split buffer insertion instead.
```

ECO16 should be intentionally small:

```text
step 1: fix the 7 non-flop drivers
step 2: rerun ICC2 route_eco and PT FF cmax only
step 3: touch the flop Q net only if it remains a violator
step 4: rerun full TT/SS/FF cmax/cmin PT
```
