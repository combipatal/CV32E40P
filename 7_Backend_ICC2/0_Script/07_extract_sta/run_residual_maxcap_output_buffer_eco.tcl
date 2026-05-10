################################################################################
# residual_maxcap_output_buffer_eco: flop Q max_cap load-split ECO
#
# 목적:
#   driver size 변경으로 남은 flop Q max_cap 1개를 buffer 삽입으로 분산합니다.
#   scan flop 종류를 직접 바꾸지 않아 DFT 구조 변경 위험을 줄입니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_BLOCK ${TOP_NAME}_hold_eco16b_residual_maxcap_size7_legalize
set ECO_TAG hold_eco17_flop_q_load_split
set PIN_FILE $PROJECT_ROOT/configs/backend/hold_eco17_flop_q_load_split_pins.rpt
set BUFFER_LIB_CELL saed32hvt_tt/NBUFFX2_HVT

if {[info exists ::env(SRC_BLOCK)]} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(ECO_TAG)]} {
  set ECO_TAG $::env(ECO_TAG)
}
if {[info exists ::env(PIN_FILE)]} {
  set PIN_FILE $::env(PIN_FILE)
}
if {[info exists ::env(BUFFER_LIB_CELL)]} {
  set BUFFER_LIB_CELL $::env(BUFFER_LIB_CELL)
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
set MANIFEST    $OUTPUT_DIR/residual_maxcap_output_buffer_eco_manifest.txt

open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

check_routes > $REPORT_DIR/check_routes.before_output_buffer.rpt
check_legality > $REPORT_DIR/check_legality.before_output_buffer.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_output_buffer.rpt

set fp [open $PIN_FILE r]
set added 0
set failed 0
set rpt [open $REPORT_DIR/output_buffer_add.rpt w]

while {[gets $fp line] >= 0} {
  set pin_name [string trim $line]
  if {$pin_name eq ""} {
    continue
  }
  if {[string index $pin_name 0] eq "#"} {
    continue
  }

  puts $rpt "### add $BUFFER_LIB_CELL after $pin_name"
  set status [catch {
    set pin_obj [get_pins $pin_name]
    if {[sizeof_collection $pin_obj] != 1} {
      error "pin not unique or missing: $pin_name"
    }
    add_buffer $pin_obj -lib_cell $BUFFER_LIB_CELL -snap
  } msg]

  if {$status == 0} {
    incr added
    puts $rpt "ADD_OK $pin_name $msg"
  } else {
    incr failed
    puts $rpt "ADD_FAIL $pin_name $msg"
  }
}

close $fp
close $rpt

set LEGALIZE_STATUS [catch {legalize_placement} LEGALIZE_MSG]
check_legality > $REPORT_DIR/check_legality.after_legalize_before_route.rpt

set ROUTE_STATUS [catch {
  route_eco -reroute modified_nets_first_then_others -reuse_existing_global_route true -max_detail_route_iterations 160
} ROUTE_MSG]

report_constraints -all_violators > $REPORT_DIR/constraints.after_output_buffer.rpt
check_routes > $REPORT_DIR/check_routes.after_output_buffer.rpt
check_legality > $REPORT_DIR/check_legality.after_output_buffer.rpt
report_qor > $REPORT_DIR/qor.after_output_buffer.rpt
report_reference > $REPORT_DIR/reference.after_output_buffer.rpt

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
puts $FP "pin_file=$PIN_FILE"
puts $FP "buffer_lib_cell=$BUFFER_LIB_CELL"
puts $FP "added=$added"
puts $FP "failed=$failed"
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

if {$failed != 0 || $LEGALIZE_STATUS != 0 || $ROUTE_STATUS != 0} {
  error "residual maxcap output buffer ECO failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SPEF_STATUS != 0} {
  error "residual maxcap output buffer ECO export failed. See $MANIFEST"
}

exit
