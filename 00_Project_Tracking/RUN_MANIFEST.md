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

## tt_mvt_8p5ns_scan1

```text
CV32E40P commit: 6033d2b1be3295ec774d17ac4cf226faacfdeb08
Clock period: 8.5 ns
PVT corner: TT 1.05V 25C
VT libraries: RVT + LVT + HVT
Scan chains: 1
ATPG model: stuck-at
Active policy: clean baseline mixed-VT, no backend DRC workaround dont_use list
Constraint: constraints/cv32e40p_func_8p5ns.sdc
Synthesis script: 2_Synthesis/0_Script/run_compile_8p5ns_topo.tcl
DFT script: 3_DFT/0_Script/run_insert_dft_8p5ns_topo.tcl
Post-DFT STA script: 6_STA/0_Script/run_pt_post_dft_8p5ns_sdf.tcl
ATPG script: 4_ATPG/0_Script/run_tmax_stuck_at_8p5ns_topo.tcl
```

## Library Paths

```text
RVT TT: /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
LVT TT: /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
HVT TT: /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db
```

## Tool Versions

```text
dc_shell: W-2024.09-SP5-5
fm_shell: W-2024.09-SP5
pt_shell: W-2024.09-SP5-3
icc2_shell: W-2024.09-SP2-T-20250916
lm_shell: W-2024.09-SP2-T-20250916
tmax: W-2024.09-SP5-5
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
