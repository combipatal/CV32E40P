# Run Manifest

## tt_mvt_10ns_scan1

```text
CV32E40P commit: 6033d2b1be3295ec774d17ac4cf226faacfdeb08
Clock period: 10 ns
PVT corner: TT 1.05V 25C
VT libraries: RVT + LVT + HVT
Scan chains: 1
ATPG model: stuck-at
```

## Library Paths

```text
RVT TT: /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
LVT TT: /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
HVT TT: /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db
```

## Tool Versions

```text
dc_shell: TBD
fm_shell: TBD
pt_shell: TBD
icc2_shell: W-2024.09-SP2-T-20250916
lm_shell: W-2024.09-SP2-T-20250916
tmax: TBD
```

## Backend ICC2 Reference Libraries

```text
NDM RVT: 7_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm
NDM LVT: 7_Backend_ICC2/2_Output/00_setup/ndm/saed32lvt_tt.ndm
NDM HVT: 7_Backend_ICC2/2_Output/00_setup/ndm/saed32hvt_tt.ndm
Tech file: /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
Source DB+LEF conversion script: 7_Backend_ICC2/0_Script/00_setup/build_saed32_ndm.tcl
```

## Backend Floorplan Initial Settings

```text
Script: 7_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.tcl
Shape: rectangle
Target core utilization: 0.65
Reported utilization: 0.6540
Aspect ratio target: 1:1
Core offset: 20um
Core area: {20 20} {295.728 294.208}
Top-level pins created: 382
```
