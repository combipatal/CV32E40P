################################################################################
# CV32E40P TetraMAX stuck-at ATPG 스크립트: no_mux41x_hvt 실험
#
# 입력:
#   MUX41X*_HVT dont_use 합성 + topo DFT post-DFT netlist + SPF
# 목표:
#   1개 muxed scan chain으로 stuck-at ATPG 1차 run 수행
# 기준:
#   TT mixed-VT RVT + LVT + HVT cell model
################################################################################

set DESIGN_NAME cv32e40p_synth_wrap

set ROOT_DIR /DATA/home/edu135/CV32E40P
set LIB_DIR  /DATA/home/edu135/lib/SAED32_EDK/lib

set NETLIST_FILE $ROOT_DIR/3_DFT/2_Output/post_dft_topo_no_mux41x_hvt/cv32e40p_synth_wrap.post_dft_topo_no_mux41x_hvt.vg
set SPF_FILE     $ROOT_DIR/3_DFT/2_Output/post_dft_topo_no_mux41x_hvt/cv32e40p_synth_wrap.post_dft_topo_no_mux41x_hvt.spf

set PATTERN_DIR  $ROOT_DIR/4_ATPG/2_Output/patterns_no_mux41x_hvt
set REPORT_DIR   $ROOT_DIR/4_ATPG/4_Report/stuck_at_topo_no_mux41x_hvt

file mkdir $PATTERN_DIR
file mkdir $REPORT_DIR

################################################################################
# mixed-VT cell model과 post-DFT topo netlist를 읽습니다.
################################################################################

read_netlist -library $LIB_DIR/stdcell_rvt/verilog/saed32nm.tv
read_netlist -library $LIB_DIR/stdcell_lvt/verilog/saed32nm_lvt.tv
read_netlist -library $LIB_DIR/stdcell_hvt/verilog/saed32nm_hvt.tv

read_netlist $NETLIST_FILE

################################################################################
# ATPG model을 만듭니다.
################################################################################

# B12는 floating input rule입니다.
# scan/test-only 포트 때문에 초기 build가 멈추지 않도록 1차 run에서는 ignore합니다.
set_rules B12 ignore
set_learning -atpg_equivalence

run_build_model $DESIGN_NAME

################################################################################
# DC가 만든 SPF로 scan DRC를 수행합니다.
################################################################################

set_drc -allow_unstable_set_resets
set_drc -clock -dynamic -nodisturb_clock_grouping

# Z3는 wire contention 가능성 rule입니다.
# 1차 stuck-at ATPG run은 멈추지 않게 warning으로 낮추고,
# signoff-clean이 아니라 DFT/ATPG DRC note로 기록합니다.
set_rules Z3 warning
set_contention nowire -severity warning

run_drc $SPF_FILE

report_scan_chains        > $REPORT_DIR/scan_chains.rpt
report_scan_cells -all    > $REPORT_DIR/scan_cells.rpt
report_nonscan_cells -all > $REPORT_DIR/nonscan_cells.rpt
report_pi_constraints     > $REPORT_DIR/pi_constraints.rpt
report_po_masks           > $REPORT_DIR/po_masks.rpt
report_capture_masks      > $REPORT_DIR/capture_masks.rpt

################################################################################
# stuck-at fault를 만들고 ATPG를 수행합니다.
################################################################################

set_faults -fault_coverage
set_faults -model stuck
set_faults -report collapsed
add_faults -all

set_buses -external_z X
set_simulation -xclock_gives_xout -num_processes 4

set_atpg -capture_cycles 4 -abort_limit 32 -num_processes 4
set_atpg -fill adjacent -coverage 98
set_atpg -merge high -decision random -store

run_atpg

################################################################################
# pattern과 fault report를 저장합니다.
################################################################################

write_patterns $PATTERN_DIR/cv32e40p_synth_wrap.no_mux41x_hvt.stuck_at.serial.stil \
  -format stil -replace -serial
write_patterns $PATTERN_DIR/cv32e40p_synth_wrap.no_mux41x_hvt.stuck_at.short_serial.stil \
  -format stil -replace -serial -first 0 -last 10

report_faults -summary > $REPORT_DIR/faults.summary.rpt
report_faults -all     > $REPORT_DIR/faults.all.rpt

write_faults $REPORT_DIR/faults_all_collapsed.rpt -all -collapsed -replace
write_faults $REPORT_DIR/faults_all_uncollapsed.rpt -all -uncollapsed -replace

analyze_faults -class UD -verbose > $REPORT_DIR/faults_UD.rpt
analyze_faults -class AU -verbose > $REPORT_DIR/faults_AU.rpt
analyze_faults -class ND -verbose > $REPORT_DIR/faults_ND.rpt

report_summaries patterns faults memory_usage cpu_usage > $REPORT_DIR/summary.rpt
report_settings > $REPORT_DIR/settings.rpt

quit
