################################################################################
# 남은 route DRC 관련 cell pin access 상세 확인
#
# 목적:
#   route_combo_no_or2x1_nor2x012_hvt 계열에서 남은 110개 DRC 주변에
#   반복 등장한 ref cell의 pin access 상태를 직접 확인합니다.
#
# 공부 포인트:
#   marker context는 "어떤 셀 근처에서 DRC가 났는지"를 보여줍니다.
#   report_cell_pin_access는 그 셀 pin이 routing access point를 충분히 갖는지 봅니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME remaining_drc_pin_access
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_pin_access
if {[info exists ::env(REPORT_DIR)]} {
  set REPORT_DIR $::env(REPORT_DIR)
}
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# 남은 DRC context에서 반복된 ref cell을 대상으로 합니다.
# MUX41X1/X2는 ZRT-044 warning 확인용으로 같이 봅니다.
################################################################################

set TARGET_CELLS [get_cells -quiet -hierarchical -filter { \
  ref_name==NOR2X4_HVT || \
  ref_name==NOR2X2_HVT || \
  ref_name==OR2X4_HVT || \
  ref_name==NOR2X0_HVT || \
  ref_name==SDFFARX1_RVT || \
  ref_name==MUX41X1_HVT || \
  ref_name==MUX41X2_HVT \
}]

set status_fp [open $REPORT_DIR/status.rpt w]
puts $status_fp "Remaining DRC pin access detail"
puts $status_fp "target_cell_count=[sizeof_collection $TARGET_CELLS]"
puts $status_fp ""

set list_fp [open $REPORT_DIR/target_cells.list w]
foreach_in_collection cell $TARGET_CELLS {
  puts $list_fp "[get_object_name $cell] ref=[get_attribute -quiet $cell ref_name] origin=[get_attribute -quiet $cell origin]"
}
close $list_fp

set status [catch {
  report_cell_pin_access \
    -cells $TARGET_CELLS \
    -details \
    > $REPORT_DIR/report_cell_pin_access.targets.details.rpt
} msg]

puts $status_fp "report_cell_pin_access -details status=$status"
puts $status_fp $msg
close $status_fp

exit
