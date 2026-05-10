################################################################################
# residual_maxcap_size_eco: PT residual max_cap용 작은 size_cell ECO
#
# 목적:
#   ECO15 이후 PrimeTime FF cmax에만 남은 작은 max_cap violation을
#   지정된 driver cell size 변경으로 먼저 해결해 봅니다.
#   scan flop Q는 첫 trial에서 건드리지 않습니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_BLOCK ${TOP_NAME}_hold_eco15_maxcap_occupied_from_eco14
set ECO_TAG hold_eco16_residual_maxcap_size7
set SIZE_FILE $PROJECT_ROOT/configs/backend/hold_eco16_residual_maxcap_size.tsv

if {[info exists ::env(SRC_BLOCK)]} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(ECO_TAG)]} {
  set ECO_TAG $::env(ECO_TAG)
}
if {[info exists ::env(SIZE_FILE)]} {
  set SIZE_FILE $::env(SIZE_FILE)
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
set SPEF_MAX    $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.spef.saed32_cmax_25.spef
set SPEF_MIN    $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.spef.saed32_cmin_25.spef
set MANIFEST    $OUTPUT_DIR/residual_maxcap_size_eco_manifest.txt

open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

check_routes > $REPORT_DIR/check_routes.before_residual_maxcap_size.rpt
check_legality > $REPORT_DIR/check_legality.before_residual_maxcap_size.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_residual_maxcap_size.rpt

set fp [open $SIZE_FILE r]
set size_ok 0
set size_fail 0
set rpt [open $REPORT_DIR/residual_maxcap_size_swaps.rpt w]

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
  set new_lib_cell [lindex $fields 2]

  puts $rpt "### $inst $old_ref -> $new_lib_cell"
  catch {report_cells $inst} before_msg
  puts $rpt "before:"
  puts $rpt $before_msg

  set status [catch {
    set cell_obj [get_cells $inst]
    set current_ref [get_attribute $cell_obj ref_name]
    if {$current_ref ne $old_ref} {
      error "ref mismatch: expected $old_ref, got $current_ref"
    }
    set lib_cell_obj [get_lib_cells $new_lib_cell]
    if {[sizeof_collection $lib_cell_obj] != 1} {
      error "new lib cell not unique or missing: $new_lib_cell"
    }
    size_cell $cell_obj $lib_cell_obj
    set_dont_touch $cell_obj true
  } msg]

  if {$status == 0} {
    incr size_ok
  } else {
    incr size_fail
    puts $rpt "SIZE_FAILED: $msg"
  }

  catch {report_cells $inst} after_msg
  puts $rpt "after:"
  puts $rpt $after_msg
}

close $fp
close $rpt

# size가 커진 cell이 옆 cell과 겹칠 수 있으므로 먼저 배치 legalize를 수행합니다.
set LEGALIZE_STATUS [catch {legalize_placement} LEGALIZE_MSG]
check_legality > $REPORT_DIR/check_legality.after_legalize_before_route.rpt

# size 변경 주변 net을 ECO routing합니다.
set ROUTE_STATUS [catch {
  route_eco -reroute modified_nets_first_then_others -reuse_existing_global_route true -max_detail_route_iterations 120
} ROUTE_MSG]

report_constraints -all_violators > $REPORT_DIR/constraints.after_residual_maxcap_size.rpt
check_routes > $REPORT_DIR/check_routes.after_residual_maxcap_size.rpt
check_legality > $REPORT_DIR/check_legality.after_residual_maxcap_size.rpt
report_qor > $REPORT_DIR/qor.after_residual_maxcap_size.rpt
report_reference > $REPORT_DIR/reference.after_residual_maxcap_size.rpt

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
puts $FP "size_file=$SIZE_FILE"
puts $FP "size_ok=$size_ok"
puts $FP "size_fail=$size_fail"
puts $FP "legalize_status=$LEGALIZE_STATUS"
puts $FP "legalize_message=$LEGALIZE_MSG"
puts $FP "route_status=$ROUTE_STATUS"
puts $FP "route_message=$ROUTE_MSG"
puts $FP "netlist=$NETLIST_OUT"
puts $FP "def=$DEF_OUT"
puts $FP "sdc=$SDC_OUT"
puts $FP "sdf=$SDF_OUT"
puts $FP "spef_base=$SPEF_BASE"
puts $FP "spef_max=$SPEF_MAX"
puts $FP "spef_min=$SPEF_MIN"
puts $FP "write_verilog_status=$WRITE_V_STATUS"
puts $FP "write_sdc_status=$WRITE_SDC_STATUS"
puts $FP "write_sdf_status=$WRITE_SDF_STATUS"
puts $FP "write_def_status=$WRITE_DEF_STATUS"
puts $FP "write_parasitics_status=$WRITE_SPEF_STATUS"
close $FP

if {$size_fail != 0 || $LEGALIZE_STATUS != 0 || $ROUTE_STATUS != 0} {
  error "residual maxcap size ECO failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SPEF_STATUS != 0} {
  error "residual maxcap size ECO export failed. See $MANIFEST"
}

exit
