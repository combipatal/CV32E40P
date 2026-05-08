# Project Status

## Current Phase

```text
Front-End baseline completed; ICC2 backend init/floorplan/place/power/CTS/route first pass completed
Route DRC diagnosis, 60%/M8 trials, lower-metal DRC detail breakdown, detail-route repair trials, PG top-port cleanup, off-track pin object diagnosis, CO/VIA contact diagnosis, Milkyway reference open trial, pin-access/M1-track probe, M1 retrack route trial, create_pin_check_lib trial, blocked-access detail extraction, pin-access/DRC overlap parse, placement spreading trial, scan DEF handoff trial, and advanced legalizer/pin-color trial completed; route DRC cleanup pending
```

## Next Milestone

```text
Clean route DRC before extraction/STA.
```

## Frozen Baseline

```text
Run: tt_mvt_10ns_scan1
Commit: 5473b61
Status: Front-End baseline complete
Meaning: 10 ns topo synthesis, R2N, DFT topo, N2N, post-DFT SDF STA, and stuck-at ATPG are reproducible from scripts.
Not included: production signoff, post-route STA, IR/EM, GDS signoff.
```

## Milestone Checklist

```text
[x] Clone CV32E40P
[x] Record source revision
[x] Create wrapper RTL
[x] Create technology clock gate RTL
[x] Create DC/FM filelists
[x] Create 10 ns SDC
[x] DC Graphical topo analyze/elaborate/link/compile
[x] Formality R2N
[x] DFT insertion
[x] Formality N2N
[x] TetraMAX stuck-at ATPG
[x] PrimeTime STA
[x] Portfolio summary tables
```

## Current Notes

```text
DFT is topographical and writes post-DFT DDC/VG/SDC/SDF/SPF.
SPF is written after insert_dft so TetraMAX sees chain0 length 2130.
TetraMAX stuck-at ATPG reached 98.64% test coverage and 98.55% fault coverage.
Remaining notes: DC DFT TEST-505 constant-1 clock gate, TetraMAX Z3 wire contention warnings, and physical max_cap/max_transition cleanup deferred to backend.
Active synthesis script is only 2_Synthesis/0_Script/run_compile_10ns_topo.tcl.
ICC2 can open/link/save the post-DFT netlist as a physical design library.
Initial ICC2 floorplan exists: rectangular core, 65.40% utilization, 382 pins created.
ICC2 placement exists: 14083 cells legalized with 0 legality violations after PG closure refresh.
ICC2 power plan exists: PG DRC clean, VDD connectivity clean, and VSS connectivity clean.
ICC2 CTS first pass exists: clock_opt completed through route_clock, clock DRC count 0, legality 0 violations, listed setup/hold timing paths MET.
Scan DEF handoff is now available from DFT and was imported by ICC2 in the scan_def_m8 trial.
CTS open items: no default max_transition constraint warning, whole-design electrical DRC remains in post-CTS qor.rpt (1 max_transition and 172 max_cap), and CTS log auto-reported target skew 1.500000 while script option report shows 0.20 ns.
ICC2 route first pass exists: route_auto completed, open nets 0, timing listed paths MET, legality 0 violations, PG DRC clean, and PG connectivity all floating counts 0.
Route open item: check_routes reports 408 DRCs, so extraction/STA should wait until route DRC cleanup.
60% utilization route trial was run. It reports route-stage utilization 0.7324 and check_routes 407 DRCs, almost identical to the 65% baseline 408 DRCs.
60% utilization plus explicit M1-M8 signal route layer trial was run. It reports route-stage utilization 0.7324, check_routes 400 DRCs, and 0 open nets.
Detailed DRC matrix shows all 400 remaining route DRCs are on M1, M2, M1-M2, or VIA1.
Detail route repair was tested. 200 max iterations ended at 398 DRCs. 1 max iteration ended at 383 DRCs, the best count so far, but M1 diff-net spacing grew to 224.
PG top-port cleanup was tested. Accepted fix adds non-overlapping M8 terminals to VDD/VSS at y=3..5um on the PG ring. VDD/VSS no-pin/unplaced warnings are removed and PG remains clean.
Off-track M1 pin object diagnosis was run. The 8 remaining off-track warnings map to stdcell pins: SDFFARX1_RVT/QN, INVX8_LVT/A, and MUX41X1_HVT/S1.
CO/VIA contact diagnosis was run. CO has no default contact, which explains ZRT-022, but VIA1 has default M1-M2 via VIA12SQ_C, so M1-M2 via setup is present.
Milkyway reference open trial was run. Direct Milkyway reference conversion is blocked in this environment because IC Compiler 1 icc_shell is unavailable and Milkyway/MDataPrep license features are unavailable.
Pin access / M1 track probe was run. check_libcell_pin_access needs a create_pin_check_lib-style library and cannot run directly on the current design library. report_cell_pin_access shows the 8 flagged cells have 0 blocked access pins, but the same ref-cell population has 117 blocked access pins.
Manual M1 track recreation was rejected. It can remove visible off-track warnings in an already routed block probe, but after signal-route removal the warning returns and full route explodes to 27260 DRCs, dominated by 24981 illegal-track-route markers.
Formal create_pin_check_lib flow was tested. create_pin_check_lib succeeds for mixed RVT/LVT/HVT and each VT library. check_libcell_pin_access analyze_lib_cell succeeds after setting pin_check.place.preplace_option_file. analyze_lib_pin remains blocked by LIB-001.
Blocked access detail extraction was run. ICC2 official summary remains 117 pins with blocked access. Parsed detail has 125 line-level blocked entries: 116 SDFFARX1_RVT, 9 MUX41X1_HVT, and 0 INVX8_LVT.
Pin access / route DRC overlap was parsed. 289 of 305 blocked access points have a route DRC marker within 50um, and 193 are within 25um. They are related by physical region, but not always exact same-coordinate failures.
Placement spreading trial was run and rejected. It reduced route DRC only from 400 to 390 while blocked access worsened from 117 to 144 official blocked pins.
Scan DEF handoff trial was run. ICC2 read SCANCHAINS and scan-aware DFT optimization validated 1 scan chain; route DRC improved only from 400 to 398.
Advanced legalizer and pin color alignment trials were run and rejected. They keep open nets 0, legality 0, and PG clean, but final route DRC is 605.
Conclusion: lower floorplan utilization, M8 bound, blind detail-route looping, M1 track recreation, generic placement spreading, scan DEF handoff alone, and advanced legalizer/pin-color alignment do not close route. Current evidence points to lower-metal M1/M2/VIA1 access, stdcell pin/via/contact setup, and post-CTS density/clock-buffer interaction.
Extraction and post-route STA are still pending.
```

## Fmax Estimate

```text
Basis: post-DFT topo/SDF STA
Clock: 10.00 ns
Worst setup slack: 1.48 ns
Estimated critical path delay: 8.52 ns
Ideal Fmax: about 117.4 MHz
Next trial: 8.5 ns first; 8.0 ns if 8.5 ns remains clean enough
```
