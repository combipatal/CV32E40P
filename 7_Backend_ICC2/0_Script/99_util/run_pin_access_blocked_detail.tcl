################################################################################
# ICC2 blocked pin access 상세 식별 스크립트
#
# 목적:
#   report_cell_pin_access summary에서 보인 blocked access 117개가
#   어떤 cell/pin인지 실제 이름으로 뽑습니다.
#
# 공부 포인트:
#   report_cell_pin_access는 배치된 design context에서 pin access를 봅니다.
#   check_libcell_pin_access는 별도 create_pin_check_lib flow가 필요합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME pin_access_blocked_detail
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_pin_access
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# off-track warning에 나온 ref cell 전체를 대상으로 pin access detail을 봅니다.
################################################################################

set REF_CELLS [get_cells -quiet -hierarchical -filter {ref_name==SDFFARX1_RVT || ref_name==INVX8_LVT || ref_name==MUX41X1_HVT}]

set status_fp [open $REPORT_DIR/status.rpt w]
puts $status_fp "Pin access blocked detail"
puts $status_fp "same_ref_cell_count=[sizeof_collection $REF_CELLS]"
puts $status_fp ""

set status [catch {
  report_cell_pin_access \
    -cells $REF_CELLS \
    -details \
    > $REPORT_DIR/report_cell_pin_access.same_refs.details.rpt
} msg]

puts $status_fp "report_cell_pin_access -details status=$status"
puts $status_fp $msg
close $status_fp

################################################################################
# Tcl에서 직접 cell 단위 summary도 뽑습니다.
# 각 cell을 하나씩 report하면 느릴 수 있어서, 기본적으로는 detail raw report를
# shell/rg로 파싱하는 것을 주 evidence로 둡니다.
################################################################################

set cell_fp [open $REPORT_DIR/same_ref_cells.list w]
foreach_in_collection cell $REF_CELLS {
  puts $cell_fp "[get_object_name $cell] ref=[get_attribute -quiet $cell ref_name] origin=[get_attribute -quiet $cell origin]"
}
close $cell_fp

exit
