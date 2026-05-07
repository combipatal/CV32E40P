# AGENTS.md instructions for /DATA/home/edu135/CV32E40P

## Project Purpose

This repository is a CV32E40P ASIC implementation project.

The first required milestone is Front-End closure:

```text
RTL intake
Design Compiler synthesis
Formality R2N
DFT insertion
Formality N2N
TetraMAX stuck-at ATPG
PrimeTime STA
```

ICC2 backend is conditional Phase 2 and should not be treated as a first-pass success requirement.

## Fixed Run

The first run is:

```text
tt_mvt_10ns_scan1
```

Meaning:

```text
TT 1.05V 25C
RVT + LVT + HVT mixed-VT
10 ns clock period
1 muxed scan chain
```

The execution contract is:

```text
docs/tt_mvt_10ns_scan1_execution_spec.md
```

Read that file before changing scripts, constraints, wrappers, filelists, or tool setup.

## Recording Discipline

Do not leave important decisions only in chat or terminal output. Record them in the project.

## Communication Style

Default to caveman-style concise communication in this project:

```text
short sentences
low filler
technical substance preserved
direct status and next action
```

Use fuller wording only when needed for:

```text
destructive action confirmation
security/legal/safety warning
multi-step instructions where terse fragments may cause mistakes
user asks for explanation or clarification
```

## Learning-Oriented Scripts

The user is learning EDA flow and Tcl. Prefer readable, direct Tcl over highly reusable framework code.

For scripts:

```text
simple variables
explicit file paths
one clear step after another
few procs unless genuinely needed
short comments before important blocks
```

Avoid over-engineered abstractions in first-pass DC/FM/DFT/ATPG/PT scripts. Make the flow easy to read, debug, and study.

Use these files:

```text
00_Project_Tracking/DECISION_LOG.md
  Fixed choices and rationale.

00_Project_Tracking/RUN_MANIFEST.md
  Source revision, libraries, tool versions, clock target, run config.

00_Project_Tracking/RUN_LOG.md
  Commands run, stage status, pass/fail notes, report paths.

00_Project_Tracking/PROJECT_STATUS.md
  Current phase and next milestone checklist.

00_Project_Tracking/RESULT_SUMMARY.md
  Final tables for synthesis, FM, DFT, ATPG, STA.
```

When a tool run completes, update `RUN_LOG.md` and the relevant result table. If a run fails, record:

```text
stage
command
log path
first fatal error
suspected root cause
next action
```

## Evidence Policy

Every major claim must point to an artifact.

Examples:

```text
Synthesis passed -> DC log + check_design report + mapped netlist path
R2N passed -> Formality verify report
DFT inserted -> scan report + post-DFT netlist
ATPG completed -> coverage report + pattern summary
STA passed/failed -> PrimeTime timing report + WNS/TNS table
```

Do not claim:

```text
full verification
ISA compliance
production DFT signoff
IR/EM signoff
GDS signoff
tapeout readiness
```

unless there is explicit evidence in reports and docs.

## Folder Conventions

This project follows a DC_LAB_3-style flow layout:

```text
2_Synthesis/
2.5_FM_R2N/
3_DFT/
4_ATPG/
5_FM_N2N/
6_STA/
7_Backend_ICC2/
```

Each stage keeps:

```text
0_Script/
1_Input/
2_Output/
3_Log/
4_Report/
```

Shared source/config areas:

```text
rtl/
filelists/
constraints/
configs/
scripts/
runs/
reports/
docs/
```

Prefer adding generated reports under the matching numbered stage and copying/summarizing final portfolio-ready tables under `reports/summary/` and `00_Project_Tracking/RESULT_SUMMARY.md`.

## Source Policy

CV32E40P is brought in as a plain clone:

```text
rtl/cv32e40p/
```

Do not directly edit upstream RTL unless explicitly required. Add project-specific RTL under:

```text
rtl/wrappers/
rtl/tech/
```

Record the upstream commit in:

```text
docs/source_revision.md
runs/tt_mvt_10ns_scan1/source_revision.txt
00_Project_Tracking/RUN_MANIFEST.md
```

## Filelist Policy

Do not modify the upstream manifest directly.

Use:

```text
filelists/cv32e40p_upstream_manifest.f
filelists/cv32e40p_dc.f
filelists/cv32e40p_fm_ref.f
```

Exclude simulation-only and testbench-only files from synthesis and FM reference filelists.

The behavioral simulation clock gate must not be used for synthesis:

```text
cv32e40p_sim_clock_gate.sv
```

Use the project technology replacement in `rtl/tech/`.

## Tool And Library Decisions

Initial libraries:

```text
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db
```

Clock gate:

```text
CGLPPRX2_RVT
CLK  <- clk_i
EN   <- en_i
SE   <- scan_cg_en_i
GCLK -> clk_o
```

Initial timing target:

```text
clk_i = 10 ns
```

DFT:

```text
tool: DC/DFT Compiler
scan chains: 1
ATPG: TetraMAX stuck-at
```

## Debug Order

Debug in stage order. Do not skip ahead and debug later tools before earlier evidence is clean.

```text
1. source/filelist/package order
2. DC analyze/elaborate/link
3. DC compile
4. Formality R2N
5. DFT DRC and insert_dft
6. Formality N2N
7. TetraMAX stuck-at ATPG
8. PrimeTime STA
9. ICC2 conditional backend
```

When changing constraints, scripts, wrappers, or libraries, record why in `DECISION_LOG.md`.

## Portfolio Notes

Keep portfolio material factual and evidence-backed.

The main narrative is:

```text
Open-source industrial RISC-V CPU RTL was converted into implementation-ready
ASIC input, synthesized with SAED32 mixed-VT libraries, checked with Formality,
passed through scan insertion, checked again with N2N Formality, exercised with
stuck-at ATPG, and analyzed with PrimeTime STA.
```

Save portfolio-ready notes under:

```text
docs/portfolio/
reports/summary/
00_Project_Tracking/RESULT_SUMMARY.md
```
