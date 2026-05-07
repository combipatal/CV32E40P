# CV32E40P Front-End Closure Execution Spec

## Run Identity

Run name:

```text
tt_mvt_10ns_scan1
```

Meaning:

```text
tt     = TT 1.05V 25C initial PVT corner
mvt    = mixed-VT synthesis using RVT + LVT + HVT
10ns   = 100 MHz baseline clock target
scan1  = one muxed scan chain
```

This file records the fixed execution decisions before running the CV32E40P implementation flow. The original project plan remains the high-level direction; this document is the concrete execution contract for the first reproducible run.

## Primary Goal

The primary goal is Front-End closure, not full RTL-to-GDS in the first pass.

Required closure scope:

```text
CV32E40P RTL intake
Design Compiler synthesis
Formality R2N equivalence
DFT insertion with one scan chain
Formality N2N equivalence
TetraMAX stuck-at ATPG
PrimeTime STA
```

Conditional Phase 2:

```text
If Front-End closure is clean, extend to ICC2 backend:
init design, floorplan, placement, CTS, route, post-route STA.
```

## Source Intake

CV32E40P source policy:

```text
Plain clone, not git submodule.
```

Expected source path:

```text
rtl/cv32e40p/
```

Clone command:

```bash
git clone https://github.com/openhwgroup/cv32e40p.git rtl/cv32e40p
```

Revision must be recorded before running synthesis:

```bash
git -C rtl/cv32e40p rev-parse HEAD
```

Record the result in:

```text
docs/source_revision.md
runs/tt_mvt_10ns_scan1/source_revision.txt
```

## Top-Level Policy

Do not modify upstream `cv32e40p_top` directly for DFT ports.

Synthesis and DFT top:

```text
cv32e40p_synth_wrap
```

Wrapper policy:

```text
u_core: cv32e40p_top
all cv32e40p_top functional ports pass through
no functional port tie-off inside wrapper
only DFT ports are added at wrapper level
```

Extra wrapper DFT ports:

```text
scan_en
scan_in
scan_out
```

Existing CV32E40P clock-gate test control:

```text
scan_cg_en_i
```

The wrapper must preserve the functional shape of the core so that synthesis, Formality, DFT, and ATPG issues are not hidden by wrapper-level constant propagation.

## CV32E40P Configuration

Initial configuration:

```text
FPU = 0
COREV_PULP = 0
COREV_CLUSTER = 0
NUM_MHPMCOUNTERS = 1
```

Rationale:

```text
Start with the smallest useful RV32IMC-class implementation baseline.
Avoid FPU/PULP/cluster expansion until filelist, constraints, clock gating,
R2N, DFT, N2N, and ATPG are clean.
```

## Filelist Policy

Do not edit the upstream manifest directly.

Create separate implementation filelists:

```text
filelists/cv32e40p_upstream_manifest.f
filelists/cv32e40p_dc.f
filelists/cv32e40p_fm_ref.f
```

Expected policy:

```text
cv32e40p_upstream_manifest.f:
  Copy/reference of upstream manifest for traceability.

cv32e40p_dc.f:
  Synthesis-only RTL source set.
  Includes cv32e40p_synth_wrap.sv.
  Includes technology clock gate replacement.

cv32e40p_fm_ref.f:
  Formality reference-side source set.
  Must match the synthesizable source set used by DC.
```

Exclude from synthesis filelists:

```text
bhv/cv32e40p_sim_clock_gate.sv
bhv/cv32e40p_tb_wrapper.sv
SVA-only files
tracer/simulation-only files
testbench-only files
```

## Library Setup

Initial PVT corner:

```text
TT 1.05V 25C
```

Initial target libraries:

```text
RVT + LVT + HVT mixed-VT
```

Expected `.db` files:

```text
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db
```

Initial DC setup intent:

```tcl
set_app_var target_library [list \
  $env(SAED32_RVT_TT_DB) \
  $env(SAED32_LVT_TT_DB) \
  $env(SAED32_HVT_TT_DB) \
]

set_app_var link_library [concat {*} [list \
  $env(SAED32_RVT_TT_DB) \
  $env(SAED32_LVT_TT_DB) \
  $env(SAED32_HVT_TT_DB) \
]]
```

Later expansion:

```text
Add SS/FF multi-corner STA only after this baseline is clean.
Do not mix multi-corner setup debug with first-pass RTL/filelist/DFT debug.
```

## Clock Gate Replacement

Do not use:

```text
cv32e40p_sim_clock_gate.sv
```

Technology clock-gate cell:

```text
CGLPPRX2_RVT
```

Confirmed Liberty pin mapping:

```text
CLK   clock input
EN    functional enable
SE    scan/test enable
GCLK  gated clock output
```

Wrapper mapping:

```text
clk_i         -> CLK
en_i          -> EN
scan_cg_en_i  -> SE
clk_o         -> GCLK
```

Expected replacement RTL:

```systemverilog
module cv32e40p_clock_gate (
  input  logic clk_i,
  input  logic en_i,
  input  logic scan_cg_en_i,
  output logic clk_o
);
  CGLPPRX2_RVT u_icg (
    .CLK  (clk_i),
    .EN   (en_i),
    .SE   (scan_cg_en_i),
    .GCLK (clk_o)
  );
endmodule
```

## Timing Constraint Baseline

Initial functional clock:

```text
clk_i period = 10 ns
frequency = 100 MHz
```

Initial SDC intent:

```tcl
create_clock -name clk_i -period 10.0 [get_ports clk_i]
set_clock_uncertainty 0.1 [get_clocks clk_i]

# Functional mode.
set_case_analysis 0 [get_ports scan_cg_en_i]
set_case_analysis 0 [get_ports scan_en]

# Reset is asynchronous active-low and should not be timed as data.
set_false_path -from [get_ports rst_ni]
```

After the 10 ns flow is complete:

```text
Use remaining setup slack to estimate next feasible clock target.
Optional later trials: 7.5 ns, 5 ns, or Fmax-oriented sweep.
```

Portfolio phrasing:

```text
Started with a conservative 100 MHz baseline to validate the complete
front-end, DFT, equivalence, ATPG, and STA flow. Remaining timing margin was
then used to estimate the next feasible clock target.
```

## DFT Policy

DFT insertion tool:

```text
Design Compiler / DFT Compiler
```

Scan structure:

```text
scan chain count = 1
scan style = muxed scan
scan input = scan_in
scan output = scan_out
scan enable = scan_en
clock gate test enable = scan_cg_en_i
```

Reset and test-mode handling:

```text
rst_ni:
  Do not tie off inside wrapper.
  Treat as controllable primary input.
  ATPG/test procedure should hold inactive value 1 when needed.

scan_cg_en_i:
  Functional mode = 0
  Scan/ATPG mode = 1

scan_en:
  Shift mode = 1
  Capture/functional mode = 0
```

Required DFT steps:

```text
set_scan_configuration
create_test_protocol
dft_drc
insert_dft
report_scan_path
report_dft_signal
write post-DFT netlist/DDC/SDC
```

DFT success criteria:

```text
One scan chain inserted.
DFT DRC clean or every remaining violation categorized.
Clock-gated registers testable through scan_cg_en_i.
Post-DFT netlist generated for N2N Formality and ATPG.
```

## Formality Policy

R2N is mandatory:

```text
Reference: cv32e40p_synth_wrap RTL + synthesizable source set
Implementation: DC pre-DFT mapped netlist
SVF: generated during DC synthesis
```

N2N is mandatory:

```text
Reference: DC pre-DFT mapped netlist
Implementation: DC post-DFT mapped netlist
Purpose: prove scan insertion preserved functional behavior
```

SVF rule:

```text
set_svf must be enabled before compile/DFT transformations, not after.
```

Acceptable outcomes:

```text
Strong:
  R2N pass and N2N pass.

Acceptable for debug milestone:
  Any mismatch is categorized by root cause:
  clock gate model, scan/test mode constraint, SVF ordering, blackbox,
  undriven/static input, or library model issue.
```

## ATPG Policy

ATPG tool:

```text
TetraMAX / tmax
```

ATPG fault model:

```text
stuck-at only
```

Required ATPG outputs:

```text
fault list
ATPG patterns
fault coverage
test coverage
untestable fault summary
aborted fault summary
DRC summary
```

Out of initial scope:

```text
transition delay ATPG
at-speed ATPG
test compression
MBIST
production test signoff claim
```

Portfolio wording:

```text
Implemented a one-chain muxed-scan DFT prototype and ran stuck-at ATPG to
validate that the synthesized CPU netlist could be taken through a complete
scan-test generation loop.
```

## PrimeTime STA Policy

Required STA points:

```text
post-synthesis pre-DFT STA
post-DFT STA
```

Initial STA mode:

```text
functional mode
scan_cg_en_i = 0
scan_en = 0
rst_ni false path
```

Required reports:

```text
check_timing
report_analysis_coverage
report_constraint -all_violators
report_timing -max_paths 20
report_qor
```

Timing analysis focus:

```text
WNS/TNS at 10 ns
critical path category
whether scan insertion affected timing
remaining slack for Fmax estimate
constraint coverage gaps
```

## Tool Paths

Confirmed tools:

```text
dc_shell:
  /tools/synopsys/syn/W-2024.09-SP5-5/bin/dc_shell

pt_shell:
  /tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell

fm_shell:
  /tools/synopsys/fm/W-2024.09-SP5/bin/fm_shell

icc2_shell:
  /tools/synopsys/syn/W-2024.09-SP5-5/icc2/bin/icc2_shell
```

`~/.bashrc` has been updated to define:

```bash
export ICC2_HOME="$DC_HOME/icc2"
```

and add:

```bash
"$ICC2_HOME/bin"
```

to the Synopsys PATH loop.

Before running ATPG, confirm:

```bash
command -v tmax
tmax -version
```

## Backend Collateral for Conditional Phase 2

Known available collateral:

```text
Stdcell LEF:
  /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef

Milkyway:
  /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m

Tech file:
  /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf

TLU+:
  /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
  /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus

GDS:
  /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/gds/saed32nm_rvt_oa.gds
```

Known physical utility cells:

```text
TIEH_RVT
TIEL_RVT
SHFILL1_RVT
SHFILL2_RVT
SHFILL3_RVT
SHFILL64_RVT
SHFILL128_RVT
ANTENNA_RVT
DCAP_RVT
```

Phase 2 is not part of first-pass success. It starts only after Front-End closure evidence is complete.

## Directory Layout

Expected project layout:

```text
rtl/
  cv32e40p/
  wrappers/
  tech/

filelists/
  cv32e40p_upstream_manifest.f
  cv32e40p_dc.f
  cv32e40p_fm_ref.f

constraints/
  cv32e40p_func_10ns.sdc
  cv32e40p_dft_10ns.sdc

configs/
  env.template.sh
  library_setup.tcl

scripts/
  dc/
  fm/
  dft/
  atpg/
  pt/
  util/

runs/
  tt_mvt_10ns_scan1/
    dc/
    fm_r2n/
    dft/
    fm_n2n/
    atpg/
    pt/
    reports/

docs/
  source_revision.md
  tt_mvt_10ns_scan1_execution_spec.md
  flow_summary.md
  issue_action_result.md
  physical_closure_plan.md
  portfolio_notes.md
```

## Required Reports and Evidence

DC synthesis:

```text
analyze/elaborate/link log
check_design report
report_qor
report_timing
report_area
report_power
pre-DFT mapped netlist
pre-DFT DDC
pre-DFT SDC
SVF
```

Formality R2N:

```text
match report
verify report
failing points report if any
root-cause notes if not clean
```

DFT:

```text
DFT DRC report
scan configuration report
scan chain report
post-DFT mapped netlist
post-DFT DDC
post-DFT SDC
```

Formality N2N:

```text
match report
verify report
scan/test-mode setup notes
```

ATPG:

```text
DRC report
fault summary
coverage report
pattern generation summary
untestable/aborted classification
```

PrimeTime:

```text
post-synth STA report
post-DFT STA report
timing coverage
constraint violators
critical paths
Fmax estimate note
```

## Success Criteria

Minimum acceptable completion:

```text
CV32E40P source cloned and revision recorded
DC filelist generated without simulation-only clock gate/TB files
cv32e40p_synth_wrap elaborates
CGLPPRX2_RVT clock gate wrapper links
10 ns mixed-VT synthesis completes
R2N Formality attempted with categorized result
DFT insertion attempted with one scan chain
N2N Formality attempted with categorized result
stuck-at ATPG attempted with coverage/fault summary
PrimeTime STA reports generated
```

Strong completion:

```text
DC clean check_design or only understood warnings
R2N Formality pass
DFT DRC clean or minor categorized warnings
N2N Formality pass
TetraMAX stuck-at ATPG completes
post-DFT STA has no unexpected constraint coverage gaps
portfolio-ready summary tables produced
```

## Actual Pre-DFT Run Result

Run date:

```text
2026-05-07
```

Completed scope:

```text
DC analyze/elaborate/link
DC 10 ns TT mixed-VT synthesis
PrimeTime pre-DFT functional STA
```

Generated implementation artifacts:

```text
2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.ddc
2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.vg
2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.sdc
2_Synthesis/2_Output/svf/cv32e40p_synth_wrap.pre_dft.svf
```

DC synthesis result:

```text
Clock target: 10 ns
Corner: TT 1.05V 25C
Library policy: RVT + LVT + HVT mixed-VT
Setup WNS: 0.02 ns
Setup TNS: 0.00 ns
Setup violating paths: 0
Hold violating paths: 0
Leaf cells: 14300
Sequential cells: 2205
Cell area: 44899.37
Design area: 60869.92
```

PrimeTime pre-DFT STA result:

```text
check_timing: succeeded
Setup violations: none
Hold violations: none
Worst reported setup slack: 0.02 ns
Worst setup endpoint: data_addr_o[31]
Worst setup startpoint: u_core/core_i/id_stage_i/prepost_useincr_ex_o_reg
```

Residual items before claiming full Front-End closure:

```text
DC reports one rounded max_cap residual at 16.00/16.00.
PrimeTime reports 476 max_cap violations.
PrimeTime max_cap behavior needs investigation or a documented waiver before R2N/DFT closure is called clean.
R2N, DFT insertion, N2N, and TetraMAX ATPG are still pending.
```

Interpretation:

```text
The first baseline proved that the RTL intake, implementation filelist,
technology clock-gate replacement, wrapper top, 10 ns SDC, DC compile, and
PrimeTime setup/hold STA path are usable. Timing is clean at 100 MHz with only
0.02 ns margin, so later Fmax exploration should start from this baseline.
The remaining pre-DFT concern is design-rule consistency, especially max_cap
between DC and PrimeTime.
```

## Portfolio Tables to Prepare

Implementation table:

```text
Stage | Tool | Input | Output | Result | Notes
RTL intake | git/filelist | upstream CV32E40P | DC/FM filelists | TBD | simulation-only files excluded
Synthesis | DC | RTL + TT mixed-VT libs | pre-DFT netlist | TBD | 10 ns baseline
R2N | Formality | RTL/netlist/SVF | verify report | TBD | equivalence
DFT | DC/DFT Compiler | pre-DFT netlist | scan netlist | TBD | one chain
N2N | Formality | pre/post DFT netlists | verify report | TBD | scan equivalence
ATPG | TetraMAX | post-DFT netlist | patterns/coverage | TBD | stuck-at
STA | PrimeTime | pre/post DFT netlists | timing reports | TBD | Fmax estimate
```

PPA/timing table:

```text
Stage | Clock | WNS | TNS | Area | Power | Cell Count | Notes
Post-synth pre-DFT | 10 ns | TBD | TBD | TBD | TBD | TBD | baseline
Post-DFT | 10 ns | TBD | TBD | TBD | TBD | TBD | scan overhead
```

DFT/ATPG table:

```text
Item | Result | Notes
Scan chains | 1 | muxed scan
Scan enable | scan_en | wrapper port
Clock-gate test enable | scan_cg_en_i | drives ICG SE
DFT DRC | TBD | clean/categorized
Fault model | stuck-at | first-pass scope
Fault coverage | TBD | from TetraMAX
Test coverage | TBD | from TetraMAX
Untestable faults | TBD | classify
Aborted faults | TBD | classify
```

## Portfolio Narrative Draft

Short version:

```text
I took the OpenHW CV32E40P RISC-V core through a front-end ASIC implementation
closure flow using SAED32 mixed-VT libraries. The flow covered RTL intake,
synthesis, RTL-to-netlist Formality, scan insertion, netlist-to-netlist
Formality, stuck-at ATPG, and PrimeTime STA at a conservative 100 MHz baseline.
```

Technical emphasis:

```text
The main engineering work was not just running synthesis. The project required
turning an open-source CPU repository into implementation-ready ASIC input:
filtering simulation-only source files, replacing the behavioral clock gate
with a technology ICG cell, defining a DFT wrapper, preserving functional
interfaces for equivalence, and carrying the netlist through scan insertion and
ATPG.
```

Avoid these claims unless later evidence supports them:

```text
full RTL verification
ISA compliance verification
production DFT signoff
IR/EM signoff
full GDS signoff
commercial tapeout readiness
```

## Pre-Run Checklist

Before executing scripts:

```text
[ ] source ~/.bashrc
[ ] command -v dc_shell
[ ] command -v fm_shell
[ ] command -v pt_shell
[ ] command -v icc2_shell
[ ] command -v tmax
[ ] confirm TT RVT/LVT/HVT .db paths exist
[ ] confirm CGLPPRX2_RVT exists in chosen Liberty
[ ] clone rtl/cv32e40p
[ ] record CV32E40P commit hash
[ ] create wrapper and clock gate replacement RTL
[ ] create DC/FM filelists
[ ] create 10 ns SDC
[ ] run DC analyze/elaborate/link before compile
```

## Open Risks

Known risks:

```text
SystemVerilog package/file order may need cleanup.
Upstream manifest includes simulation-only files and cannot be used directly.
Formality may require careful SVF ordering and scan/test-mode setup.
DFT DRC may expose reset/clock-gating controllability issues.
TetraMAX may need a specific SAED32 ATPG library model or converted model.
Backend Phase 2 still needs ICC2 library setup validation.
```

Risk response:

```text
Debug in order:
1. analyze/elaborate/link
2. synthesis
3. R2N
4. DFT DRC
5. N2N
6. ATPG
7. STA

Do not debug later stages before earlier stage evidence is clean.
```
