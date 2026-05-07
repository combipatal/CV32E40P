# Project Structure

This project uses a DC_LAB_3-style numbered flow layout, with extra directories for CV32E40P source intake and portfolio documentation.

## Main Flow

```text
1_Verilog_VCS_Verdi/
  Optional simulation/smoke-test area.

2_Synthesis/
  Design Compiler synthesis area.

2.5_FM_R2N/
  Formality RTL-to-netlist equivalence.

3_DFT/
  DC/DFT Compiler scan insertion area.

4_ATPG/
  TetraMAX stuck-at ATPG area.

5_FM_N2N/
  Formality pre-DFT-netlist to post-DFT-netlist equivalence.

6_STA/
  PrimeTime STA area.

7_Backend_ICC2/
  Conditional Phase 2 backend area.
```

## Shared Inputs

```text
rtl/
  cv32e40p/
  wrappers/
  tech/

filelists/
constraints/
configs/
scripts/
```

## Run and Report Areas

```text
runs/tt_mvt_10ns_scan1/
reports/
docs/
00_Project_Tracking/
01_RTL_Intake_Notes/
```

The execution contract for the first run is:

```text
docs/tt_mvt_10ns_scan1_execution_spec.md
```
