################################################################################
# ECO swap 대상 cell의 최종 ref_name 확인
#
# 목적:
#   ECO swap은 init 단계에서 size_cell로 적용합니다.
#   이후 place/CTS/route optimization이 cell을 다시 size/VT 변경할 수 있습니다.
#   그래서 swap TSV에 적힌 cell들이 최종 block에서 어떤 ref_name인지 확인합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set ECO_SWAP_FILE ""
if {[info exists ::env(ECO_SWAP_FILE)]} {
  set ECO_SWAP_FILE $::env(ECO_SWAP_FILE)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/eco_swap_final_ref
if {[info exists ::env(REPORT_DIR)]} {
  set REPORT_DIR $::env(REPORT_DIR)
}
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set out [open $REPORT_DIR/eco_swap_final_ref.rpt w]
puts $out "cell\told_ref\trequested_new_ref\tfinal_ref\tstatus"

if {$ECO_SWAP_FILE eq ""} {
  puts $out "ERROR\t\t\t\tECO_SWAP_FILE_not_set"
  close $out
  exit 1
}

set fp [open $ECO_SWAP_FILE r]
set line_no 0
while {[gets $fp line] >= 0} {
  incr line_no
  if {$line_no == 1} {
    continue
  }
  if {$line eq ""} {
    continue
  }

  set fields [split $line "\t"]
  set cell_name [lindex $fields 0]
  set old_ref [lindex $fields 1]
  set requested_new_ref [lindex $fields 2]

  set cell [get_cells -quiet $cell_name]
  if {[sizeof_collection $cell] == 0} {
    puts $out "$cell_name\t$old_ref\t$requested_new_ref\t\tMISSING_CELL"
    continue
  }

  set final_ref [get_attribute -quiet $cell ref_name]
  set status CHANGED_BY_OPT
  if {$final_ref eq $requested_new_ref} {
    set status KEPT_REQUESTED_REF
  }

  puts $out "$cell_name\t$old_ref\t$requested_new_ref\t$final_ref\t$status"
}
close $fp
close $out

exit
