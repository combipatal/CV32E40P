################################################################################
# ICC2 max capacitance repair command probe
#
# 목적:
#   현재 ICC2 설치에서 max_cap repair에 쓸 수 있는 명령과 옵션을 확인합니다.
#   실제 design 수정은 하지 않습니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/07_extract_sta/max_cap_repair
file mkdir $REPORT_DIR

set FP [open $REPORT_DIR/command_probe.rpt w]

foreach CMD {
  eco_opt
  route_opt
  refine_opt
  clock_opt
  insert_buffer
  size_cell
  report_constraint
  report_qor
  check_routes
} {
  puts $FP "===== help $CMD ====="
  set STATUS [catch {help $CMD} MSG]
  puts $FP "status=$STATUS"
  puts $FP $MSG
  puts $FP ""
}

close $FP
exit
