################################################################################
# ss_setup_eco7: critical FADDX HVT -> RVT setup trial
#
# 목적:
#   SS post-route STA의 최악 ALU carry path를 빠르게 만들기 위해
#   해당 path의 FADDX*_HVT cell만 같은 drive FADDX*_RVT로 바꿉니다.
#   이후 route_eco, DRC/legality 확인, PT용 netlist/SPEF export를 수행합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_BLOCK ${TOP_NAME}_maxtran_eco6_u246_rvt_swap
set ECO_TAG ss_setup_eco7_fadd_rvt_trial
set ECO_BLOCK ${TOP_NAME}_${ECO_TAG}

set SWAP_FILE $PROJECT_ROOT/configs/backend/ss_setup_fadd_hvt_to_rvt_trial.tsv
set OUTPUT_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/07_extract_sta/$ECO_TAG
set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/07_extract_sta/$ECO_TAG
file mkdir $OUTPUT_DIR
file mkdir $REPORT_DIR

set NETLIST_OUT $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.vg
set DEF_OUT     $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.def
set SDC_OUT     $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.sdc
set SDF_OUT     $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.sdf
set SPEF_BASE   $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.spef
set MANIFEST    $OUTPUT_DIR/ss_setup_eco_manifest.txt

open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

report_constraints -all_violators > $REPORT_DIR/constraints.before_ss_setup_eco.rpt
check_routes > $REPORT_DIR/check_routes.before_ss_setup_eco.rpt
check_legality > $REPORT_DIR/check_legality.before_ss_setup_eco.rpt

set fp [open $SWAP_FILE r]
set swap_ok 0
set swap_fail 0
set before_after [open $REPORT_DIR/fadd_swaps.rpt w]
while {[gets $fp line] >= 0} {
  if {$line eq ""} {
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
    size_cell [get_cells $inst] [get_lib_cells $new_lib_cell]
    set_dont_touch [get_cells $inst] true
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

report_constraints -all_violators > $REPORT_DIR/constraints.after_ss_setup_eco.rpt
check_routes > $REPORT_DIR/check_routes.after_ss_setup_eco.rpt
check_legality > $REPORT_DIR/check_legality.after_ss_setup_eco.rpt
report_qor > $REPORT_DIR/qor.after_ss_setup_eco.rpt

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
  error "SS setup ECO trial failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SPEF_STATUS != 0} {
  error "SS setup ECO export failed. See $MANIFEST"
}

exit
