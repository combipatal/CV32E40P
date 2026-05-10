################################################################################
# setup_recovery_hvt_to_rvt: setup 회복용 HVT -> RVT cell swap ECO
#
# 목적:
#   hold ECO 이후 SS setup이 깨진 특정 path에서 일부 HVT cell만 RVT로 바꿉니다.
#   작은 ECO로 먼저 timing tradeoff를 확인합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_BLOCK ${TOP_NAME}_hold_eco13_final6_nbuffx2
set ECO_TAG hold_eco14_setup_recovery_u1856_u1857_rvt
set SWAP_FILE $PROJECT_ROOT/configs/backend/hold_eco14_mhpmcounter_setup_hvt_to_rvt.tsv

if {[info exists ::env(SRC_BLOCK)]} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(ECO_TAG)]} {
  set ECO_TAG $::env(ECO_TAG)
}
if {[info exists ::env(SWAP_FILE)]} {
  set SWAP_FILE $::env(SWAP_FILE)
}

set ECO_BLOCK ${TOP_NAME}_${ECO_TAG}
set OUTPUT_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/07_extract_sta/$ECO_TAG
set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/07_extract_sta/$ECO_TAG
file mkdir $OUTPUT_DIR
file mkdir $REPORT_DIR

set NETLIST_OUT $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.vg
set DEF_OUT     $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.def
set SDC_OUT     $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.sdc
set SDF_OUT     $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.sdf
set SPEF_BASE   $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.spef
set MANIFEST    $OUTPUT_DIR/setup_recovery_eco_manifest.txt

open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

report_constraints -all_violators > $REPORT_DIR/constraints.before_setup_recovery.rpt
check_routes > $REPORT_DIR/check_routes.before_setup_recovery.rpt
check_legality > $REPORT_DIR/check_legality.before_setup_recovery.rpt

set fp [open $SWAP_FILE r]
set swap_ok 0
set swap_fail 0
set before_after [open $REPORT_DIR/setup_recovery_swaps.rpt w]

while {[gets $fp line] >= 0} {
  if {$line eq ""} {
    continue
  }
  if {[string index $line 0] eq "#"} {
    continue
  }

  set fields [split $line "\t"]
  set inst [lindex $fields 0]
  set old_ref [lindex $fields 1]
  set new_ref [lindex $fields 2]
  set new_lib_cell saed32rvt_tt/$new_ref

  puts $before_after "### $inst $old_ref -> $new_ref"
  catch {report_cells $inst} before_msg
  puts $before_after "before:"
  puts $before_after $before_msg

  set status [catch {
    set cell_obj [get_cells $inst]
    set current_ref [get_attribute $cell_obj ref_name]
    if {$current_ref ne $old_ref} {
      error "ref mismatch: expected $old_ref, got $current_ref"
    }
    size_cell $cell_obj [get_lib_cells $new_lib_cell]
    set_dont_touch $cell_obj true
  } msg]

  if {$status == 0} {
    incr swap_ok
  } else {
    incr swap_fail
    puts $before_after "SWAP_FAILED: $msg"
  }

  catch {report_cells $inst} after_msg
  puts $before_after "after:"
  puts $before_after $after_msg
}

close $fp
close $before_after

# 바뀐 cell 주변 net만 ECO routing합니다.
set ROUTE_STATUS [catch {
  route_eco -reroute modified_nets_first_then_others -reuse_existing_global_route true -max_detail_route_iterations 120
} ROUTE_MSG]

report_constraints -all_violators > $REPORT_DIR/constraints.after_setup_recovery.rpt
check_routes > $REPORT_DIR/check_routes.after_setup_recovery.rpt
check_legality > $REPORT_DIR/check_legality.after_setup_recovery.rpt
report_qor > $REPORT_DIR/qor.after_setup_recovery.rpt
report_reference > $REPORT_DIR/reference.after_setup_recovery.rpt

set WRITE_V_STATUS [catch {write_verilog $NETLIST_OUT} WRITE_V_MSG]
set WRITE_SDC_STATUS [catch {write_sdc -output $SDC_OUT} WRITE_SDC_MSG]
set WRITE_SDF_STATUS [catch {write_sdf $SDF_OUT} WRITE_SDF_MSG]
set WRITE_DEF_STATUS [catch {write_def $DEF_OUT} WRITE_DEF_MSG]
set WRITE_SPEF_STATUS [catch {write_parasitics -format spef -output $SPEF_BASE} WRITE_SPEF_MSG]

save_block

set FP [open $MANIFEST w]
puts $FP "eco_tag=$ECO_TAG"
puts $FP "source_block=$SRC_BLOCK"
puts $FP "eco_block=$ECO_BLOCK"
puts $FP "swap_file=$SWAP_FILE"
puts $FP "swap_ok=$swap_ok"
puts $FP "swap_fail=$swap_fail"
puts $FP "route_status=$ROUTE_STATUS"
puts $FP "route_message=$ROUTE_MSG"
puts $FP "netlist=$NETLIST_OUT"
puts $FP "def=$DEF_OUT"
puts $FP "sdc=$SDC_OUT"
puts $FP "sdf=$SDF_OUT"
puts $FP "spef_base=$SPEF_BASE"
puts $FP "write_verilog_status=$WRITE_V_STATUS"
puts $FP "write_sdc_status=$WRITE_SDC_STATUS"
puts $FP "write_sdf_status=$WRITE_SDF_STATUS"
puts $FP "write_def_status=$WRITE_DEF_STATUS"
puts $FP "write_parasitics_status=$WRITE_SPEF_STATUS"
close $FP

if {$swap_fail != 0 || $ROUTE_STATUS != 0} {
  error "setup recovery ECO failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SPEF_STATUS != 0} {
  error "setup recovery ECO export failed. See $MANIFEST"
}

exit
