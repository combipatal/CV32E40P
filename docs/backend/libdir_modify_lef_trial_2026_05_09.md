# libdir modify LEF backend trial

Date: 2026-05-09

## 목적

Front-end 결과물은 그대로 두고 backend physical library만 바꿔서 route DRC가 줄어드는지 확인했다.

## 고정 입력

```text
netlist: 3_DFT/2_Output/post_dft_topo_8p5ns/cv32e40p_synth_wrap.post_dft_topo_8p5ns.vg
sdc:     3_DFT/2_Output/post_dft_topo_8p5ns/cv32e40p_synth_wrap.post_dft_topo_8p5ns.sdc
scanDEF: 3_DFT/2_Output/post_dft_topo_8p5ns/cv32e40p_synth_wrap.post_dft_topo_8p5ns.scan.def
flow:    7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
util:    60%
route:   max signal layer M8, extra off-grid pin tracks on, high route DRC/via effort
```

## 비교한 library

### 원본 EDK NDM

```text
7_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm
7_Backend_ICC2/2_Output/00_setup/ndm/saed32lvt_tt.ndm
7_Backend_ICC2/2_Output/00_setup/ndm/saed32hvt_tt.ndm
```

### libdir modify LEF 기반 NDM

NDM 생성 스크립트:

```text
7_Backend_ICC2/0_Script/00_setup/build_saed32_ndm_libdir_modify.tcl
```

입력 LEF:

```text
/DATA/home/edu135/lib/libdir/LEF/modify/saed32nm_rvt_1p9m.lef
/DATA/home/edu135/lib/libdir/LEF/modify/saed32nm_lvt_1p9m.lef
/DATA/home/edu135/lib/libdir/LEF/modify/saed32nm_hvt_1p9m.lef
```

출력 NDM:

```text
7_Backend_ICC2/2_Output/00_setup/ndm_libdir_modify/saed32rvt_tt.ndm
7_Backend_ICC2/2_Output/00_setup/ndm_libdir_modify/saed32lvt_tt.ndm
7_Backend_ICC2/2_Output/00_setup/ndm_libdir_modify/saed32hvt_tt.ndm
```

Timing DB는 기존 TT MVT DB를 그대로 사용했다. 즉 logical/timing library는 동일하고, backend physical abstract만 바꾼 비교다.

## 결과

```text
Trial                         Open nets  Route DRC  Main DRC classes
edk_original_8p5ns_scan_def_m8 0          412        Diff spacing 112, min area 5, needs fat contact 128, off-grid 165, short 2
libdir_modify_8p5ns_scan_def_m8 0         151        Diff spacing 6, off-grid 143, short 2
```

공통:

```text
check_legality: 0 violations
check_pg_drc: No errors found
ZRT-044 MUX41X2_HVT/S0 warning: still present
```

## 판단

libdir modify LEF는 backend route DRC를 크게 줄였다.

```text
412 -> 151
```

특히 `Needs fat contact`가 128에서 0으로 사라졌고, `Diff net spacing`도 112에서 6으로 줄었다. 따라서 기존 EDK LEF/NDM physical abstract가 route DRC의 큰 원인 중 하나였다는 증거다.

하지만 backend closure는 아니다.

```text
remaining DRC: 151
main remaining class: Off-grid 143
```

또한 `MUX41X2_HVT/S0 has no valid via regions (ZRT-044)` 경고가 그대로 남아 있다. 즉 수정 LEF는 도움이 되지만, pin/via/grid 문제를 완전히 해결하지는 못한다.

## Evidence

```text
7_Backend_ICC2/3_Log/00_setup/build_saed32_ndm_libdir_modify.log
7_Backend_ICC2/3_Log/trials/libdir_modify_8p5ns_scan_def_m8/route.log
7_Backend_ICC2/3_Log/trials/libdir_modify_8p5ns_scan_def_m8/edk_original_route.log
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m8/01_init_design/ref_libs.rpt
7_Backend_ICC2/4_Report/trials/edk_original_8p5ns_scan_def_m8/01_init_design/ref_libs.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/edk_original_8p5ns_scan_def_m8/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m8/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/edk_original_8p5ns_scan_def_m8/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m8/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/edk_original_8p5ns_scan_def_m8/06_route/pg_drc.rpt
```

## Auto-route option trials

Date: 2026-05-09

수정 LEF 기반 NDM에서 단순 route 옵션으로 더 줄어드는지 확인했다.

고정 조건:

```text
frontend handoff: unchanged 8.5ns post-DFT netlist/SDC/scan DEF
physical library: libdir modify LEF NDM
utilization: 60%
extra off-grid pin tracks: true
route DRC convergence effort: high
route wire/via effort: high
```

비교 결과:

```text
Trial                                      Open nets  Route DRC  Main DRC classes
libdir_modify_8p5ns_scan_def_m8            0          151        Diff 6, Off-grid 143, Short 2
libdir_modify_8p5ns_scan_def_m9            0          147        Diff 7, Off-grid 138, Short 2
libdir_modify_8p5ns_scan_def_m8_repair200  0          150        Diff 6, Off-grid 142, Short 2
libdir_modify_8p5ns_scan_def_m9_repair200  0          149        Diff 6, Off-grid 141, Short 2
```

Post-route repair 전/후:

```text
M8 repair200: route_auto 151 -> repair 후 150
M9 repair200: route_auto 147 -> repair 후 149
```

공통 확인:

```text
check_legality: 0 violations
PG connectivity: VDD/VSS floating wires/vias/std cells all 0
check_pg_drc: no reported PG DRC errors
```

판단:

```text
M9 max signal layer는 151 -> 147로 소폭 개선된다.
post-route detail repair는 효과가 작고, M9에서는 오히려 악화된다.
따라서 단순 auto-route 옵션 조정만으로는 closure 방향이 약하다.
남은 문제는 여전히 대부분 Off-grid이며, lower-metal pin/via/grid physical abstract 쪽 원인 모델이 유지된다.
```

추가된 스크립트 옵션:

```text
POST_ROUTE_DETAIL_REPAIR_ITERATIONS
```

이 값을 주면 `route_auto` 후 `route_detail -incremental true`를 한 번 더 수행하고, before/after `check_routes`를 따로 남긴다.

Evidence:

```text
7_Backend_ICC2/0_Script/99_util/run_trial_60util_to_route.tcl
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9/06_route/check_legality.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9/06_route/pg_connectivity.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9/06_route/pg_drc.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m8_repair200/06_route/check_routes.before_post_repair.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m8_repair200/06_route/post_route_detail_repair.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m8_repair200/06_route/check_routes.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9_repair200/06_route/check_routes.before_post_repair.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9_repair200/06_route/post_route_detail_repair.rpt
7_Backend_ICC2/4_Report/trials/libdir_modify_8p5ns_scan_def_m9_repair200/06_route/check_routes.rpt
```
