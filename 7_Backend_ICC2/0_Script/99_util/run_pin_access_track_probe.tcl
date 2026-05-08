################################################################################
# ICC2 pin access / M1 track offset 진단 스크립트
#
# 목적:
#   route DRC가 lower metal(M1/M2/VIA1)에 남는 원인을 좁힙니다.
#   full route를 다시 돌리기 전에 pin 접근성과 M1 track offset 영향을 봅니다.
#
# 주의:
#   이 스크립트는 진단용입니다.
#   M1 track을 바꾸는 trial은 저장하지 않고 close_blocks -force로 버립니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME pin_access_track_probe
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_pin_access_track
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR

################################################################################
# 1. 현재 block의 pin access 상태를 확인합니다.
################################################################################

open_block -edit $TOP_NAME

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

catch {report_ignored_layers > $REPORT_DIR/ignored_layers.rpt}
report_tracks -layer M1 > $REPORT_DIR/tracks.m1.baseline.rpt
report_tracks -layer M2 > $REPORT_DIR/tracks.m2.baseline.rpt

check_routability > $REPORT_DIR/check_routability.baseline.rpt

# check_libcell_pin_access는 library cell/access 문제를 보는 명령입니다.
# 실패해도 나머지 리포트는 계속 남기기 위해 catch로 감쌉니다.
set pin_fp [open $REPORT_DIR/pin_access_command_status.rpt w]

set status [catch {
  check_libcell_pin_access \
    -mode design_under_test \
    -from prepare \
    -to report_route \
    > $REPORT_DIR/check_libcell_pin_access.design_under_test.rpt
} msg]
puts $pin_fp "check_libcell_pin_access status=$status"
puts $pin_fp $msg
puts $pin_fp ""

# check_routability가 찍은 8개 warning 좌표에 대응되는 cell만 따로 봅니다.
set FLAGGED_CELL_NAMES {
  u_core/core_i/cs_registers_i/mepc_q_reg[28]
  u_core/core_i/cs_registers_i/mepc_q_reg[31]
  u_core/core_i/id_stage_i/register_file_i/mem_reg[2][15]
  u_core/core_i/HFSINV_25033_829
  u_core/core_i/cs_registers_i/mhpmcounter_q_reg[3][35]
  u_core/core_i/if_stage_i/instr_rdata_id_o_reg[28]
  u_core/core_i/U1545
  u_core/core_i/HFSINV_20734_818
}

set FLAGGED_CELLS [get_cells -quiet $FLAGGED_CELL_NAMES]
puts $pin_fp "flagged_cell_count=[sizeof_collection $FLAGGED_CELLS]"

set status [catch {
  report_cell_pin_access \
    -cells $FLAGGED_CELLS \
    -details \
    > $REPORT_DIR/report_cell_pin_access.flagged_cells.rpt
} msg]
puts $pin_fp "report_cell_pin_access flagged status=$status"
puts $pin_fp $msg
puts $pin_fp ""

set REF_CELLS [get_cells -quiet -hierarchical -filter {ref_name==SDFFARX1_RVT || ref_name==INVX8_LVT || ref_name==MUX41X1_HVT}]
puts $pin_fp "same_ref_cell_count=[sizeof_collection $REF_CELLS]"

set status [catch {
  report_cell_pin_access \
    -cells $REF_CELLS \
    > $REPORT_DIR/report_cell_pin_access.same_refs.rpt
} msg]
puts $pin_fp "report_cell_pin_access same_refs status=$status"
puts $pin_fp $msg
close $pin_fp

close_blocks -force

################################################################################
# 2. M1 track 시작점만 바꿔 check_routability warning 변화를 봅니다.
#
# M1 pitch는 0.152um입니다.
# baseline start는 0.088um입니다.
# 여기서는 full route를 돌리지 않고 routability warning 변화만 확인합니다.
################################################################################

set summary_fp [open $REPORT_DIR/m1_track_offset_summary.rpt w]
puts $summary_fp "M1 track offset routability probe"
puts $summary_fp "baseline_start=0.088 pitch=0.152"
puts $summary_fp ""

set M1_PITCH 0.152
set M1_COUNT_X 2151
set M1_COUNT_Y 2144
set M1_WIDTH 0.050

set M1_START_LIST {
  0.000
  0.012
  0.050
  0.076
  0.088
  0.126
}

foreach M1_START $M1_START_LIST {
  puts $summary_fp "trial_m1_start=$M1_START"
  puts $summary_fp "  report=check_routability.m1_start_${M1_START}.rpt"

  open_block -edit $TOP_NAME

  set_ignored_layers \
    -min_routing_layer M1 \
    -max_routing_layer M8

  # M1 track만 새 시작점으로 다시 만듭니다.
  remove_tracks -layer M1 -force

  create_track \
    -layer M1 \
    -dir X \
    -coord $M1_START \
    -space $M1_PITCH \
    -count $M1_COUNT_X \
    -width $M1_WIDTH

  create_track \
    -layer M1 \
    -dir Y \
    -coord $M1_START \
    -space $M1_PITCH \
    -count $M1_COUNT_Y \
    -width $M1_WIDTH

  report_tracks -layer M1 > $REPORT_DIR/tracks.m1_start_${M1_START}.rpt
  check_routability > $REPORT_DIR/check_routability.m1_start_${M1_START}.rpt

  # trial 변경은 저장하지 않습니다.
  close_blocks -force
}

close $summary_fp

exit
