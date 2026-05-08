################################################################################
# ICC2 create_pin_check_lib 정식 flow trial
#
# 목적:
#   check_libcell_pin_access가 요구하는 pin-check library를 만들어 보고,
#   SAED32 RVT/LVT/HVT ref library별 pin access check가 가능한지 확인합니다.
#
# 공부 포인트:
#   일반 design library에서는 check_libcell_pin_access가 PAC-001로 실패합니다.
#   create_pin_check_lib로 만든 library에서만 이 명령을 실행할 수 있습니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME create_pin_check_lib_trial
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_pin_check_lib
set OUTPUT_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/trials/$TRIAL_NAME
file mkdir $REPORT_DIR
file mkdir $OUTPUT_DIR

set PREPLACE_OPTION_FILE $OUTPUT_DIR/pin_check_preplace_options.tcl
set preplace_fp [open $PREPLACE_OPTION_FILE w]
puts $preplace_fp "# pin-check placement 전에 읽히는 option file입니다."
puts $preplace_fp "# 현재 trial은 추가 배치 option 없이 기본값으로 확인합니다."
close $preplace_fp

set_app_options \
  -name pin_check.place.preplace_option_file \
  -value $PREPLACE_OPTION_FILE

set status_fp [open $REPORT_DIR/create_pin_check_lib_status.rpt w]
puts $status_fp "create_pin_check_lib trial"
puts $status_fp "preplace_option_file=$PREPLACE_OPTION_FILE"
puts $status_fp ""

################################################################################
# 1. mixed-VT ref library list를 한 번에 넣어 봅니다.
################################################################################

set CHECK_LIB_ALL $OUTPUT_DIR/check_lib_all.nlib
if {[file exists $CHECK_LIB_ALL]} {
  file delete -force $CHECK_LIB_ALL
}

puts $status_fp "Trial 1: all NDM refs together"
set status [catch {
  create_pin_check_lib \
    -technology $TECH_FILE \
    -ref_libs [list $NDM_RVT $NDM_LVT $NDM_HVT] \
    $CHECK_LIB_ALL
} msg]
puts $status_fp "create all status=$status"
puts $status_fp $msg
puts $status_fp ""

if {$status == 0} {
  set status2 [catch {
    check_libcell_pin_access \
      -mode analyze_lib_cell \
      > $REPORT_DIR/check_libcell_pin_access.all.analyze_lib_cell.rpt
  } msg2]
  puts $status_fp "check all analyze_lib_cell status=$status2"
  puts $status_fp $msg2

  set status3 [catch {
    check_libcell_pin_access \
      -mode analyze_lib_pin \
      > $REPORT_DIR/check_libcell_pin_access.all.analyze_lib_pin.rpt
  } msg3]
  puts $status_fp "check all analyze_lib_pin status=$status3"
  puts $status_fp $msg3
  puts $status_fp ""
}

################################################################################
# 2. 한 번에 실패하면 VT별로 따로 확인합니다.
################################################################################

set REF_TRIALS [list \
  [list rvt $NDM_RVT] \
  [list lvt $NDM_LVT] \
  [list hvt $NDM_HVT] \
]

foreach item $REF_TRIALS {
  set vt_name [lindex $item 0]
  set ref_lib [lindex $item 1]
  set check_lib $OUTPUT_DIR/check_lib_${vt_name}.nlib

  if {[file exists $check_lib]} {
    file delete -force $check_lib
  }

  puts $status_fp "Trial VT=$vt_name"
  set status [catch {
    create_pin_check_lib \
      -technology $TECH_FILE \
      -ref_libs $ref_lib \
      $check_lib
  } msg]
  puts $status_fp "create $vt_name status=$status"
  puts $status_fp $msg

  if {$status == 0} {
    set status2 [catch {
      check_libcell_pin_access \
        -mode analyze_lib_cell \
        > $REPORT_DIR/check_libcell_pin_access.${vt_name}.analyze_lib_cell.rpt
    } msg2]
    puts $status_fp "check $vt_name analyze_lib_cell status=$status2"
    puts $status_fp $msg2

    set status3 [catch {
      check_libcell_pin_access \
        -mode analyze_lib_pin \
        > $REPORT_DIR/check_libcell_pin_access.${vt_name}.analyze_lib_pin.rpt
    } msg3]
    puts $status_fp "check $vt_name analyze_lib_pin status=$status3"
    puts $status_fp $msg3
  }

  puts $status_fp ""
}

close $status_fp

exit
