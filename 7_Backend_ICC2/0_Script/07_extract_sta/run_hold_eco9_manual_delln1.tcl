################################################################################
# hold_eco9: manual DELLN1 hold delay insertion trial
#
# 목적:
#   ECO8 자동 hold ECO는 TT default scenario에서 violation을 못 봐서 buffer 0개였습니다.
#   여기서는 FF -40C hold probe report의 unique endpoint D pin에 DELLN1X2_HVT를
#   직접 삽입해서 hold 개선 효과를 봅니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_BLOCK ${TOP_NAME}_ss_setup_eco7_fadd_rvt_trial
set ECO_TAG hold_eco9_manual_delln1_all
set DELAY_LIB_CELL saed32hvt_tt/DELLN1X2_HVT
set HOLD_REPORT $PROJECT_ROOT/6_STA/4_Report/ss_setup_eco7_fadd_rvt_trial_spef_ff1p16vn40c_propclk/hold_probe/eco7.ff1p16vn40c.cmin.hold_300.rpt
set MAX_ENDPOINTS 10000
set INCLUDE_ENDPOINT_REGEX ""
set EXCLUDE_ENDPOINT_REGEX ""

if {[info exists ::env(ECO_TAG)]} {
  set ECO_TAG $::env(ECO_TAG)
}
if {[info exists ::env(SRC_BLOCK)]} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(DELAY_LIB_CELL)]} {
  set DELAY_LIB_CELL $::env(DELAY_LIB_CELL)
}
if {[info exists ::env(HOLD_REPORT)]} {
  set HOLD_REPORT $::env(HOLD_REPORT)
}
if {[info exists ::env(MAX_ENDPOINTS)]} {
  set MAX_ENDPOINTS $::env(MAX_ENDPOINTS)
}
if {[info exists ::env(INCLUDE_ENDPOINT_REGEX)]} {
  set INCLUDE_ENDPOINT_REGEX $::env(INCLUDE_ENDPOINT_REGEX)
}
if {[info exists ::env(EXCLUDE_ENDPOINT_REGEX)]} {
  set EXCLUDE_ENDPOINT_REGEX $::env(EXCLUDE_ENDPOINT_REGEX)
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
set MANIFEST    $OUTPUT_DIR/hold_manual_eco_manifest.txt

open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

check_routes > $REPORT_DIR/check_routes.before_hold_manual.rpt
check_legality > $REPORT_DIR/check_legality.before_hold_manual.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_hold_manual.rpt

set delay_cell [get_lib_cells -quiet $DELAY_LIB_CELL]
if {[sizeof_collection $delay_cell] != 1} {
  error "Cannot find delay lib cell: $DELAY_LIB_CELL"
}

# PT hold report에서 unique endpoint를 읽습니다.
set endpoints {}
set fp [open $HOLD_REPORT r]
while {[gets $fp line] >= 0} {
  if {[regexp {Endpoint:[ ]+([^ ]+)} $line -> endpoint]} {
    if {[lsearch -exact $endpoints $endpoint] < 0} {
      lappend endpoints $endpoint
    }
  }
}
close $fp

set added 0
set skipped 0
set failed 0
set filtered_include 0
set filtered_exclude 0
set add_log [open $REPORT_DIR/manual_delln1_add_buffer.rpt w]

foreach endpoint $endpoints {
  if {$added >= $MAX_ENDPOINTS} {
    break
  }

  # ECO10 같은 후속 실험에서 setup-critical endpoint를 제외하기 위한 필터입니다.
  if {$INCLUDE_ENDPOINT_REGEX ne "" && ![regexp $INCLUDE_ENDPOINT_REGEX $endpoint]} {
    incr filtered_include
    puts $add_log "SKIP_INCLUDE_FILTER ${endpoint}/D"
    continue
  }
  if {$EXCLUDE_ENDPOINT_REGEX ne "" && [regexp $EXCLUDE_ENDPOINT_REGEX $endpoint]} {
    incr filtered_exclude
    puts $add_log "SKIP_EXCLUDE_FILTER ${endpoint}/D"
    continue
  }

  set pin_name ${endpoint}/D
  set pin_obj [get_pins -quiet [list $pin_name]]
  if {[sizeof_collection $pin_obj] != 1} {
    incr skipped
    puts $add_log "SKIP_NO_PIN $pin_name"
    continue
  }

  set status [catch {
    add_buffer $pin_obj -lib_cell $delay_cell -snap
  } msg]
  if {$status == 0} {
    incr added
    puts $add_log "ADD_OK $pin_name $msg"
  } else {
    incr failed
    puts $add_log "ADD_FAIL $pin_name $msg"
  }
}
close $add_log

# 새로 들어간 delay cell을 site grid에 맞추고 ECO routing합니다.
set LEGALIZE_STATUS [catch {legalize_placement} LEGALIZE_MSG]
set ROUTE_STATUS [catch {
  route_eco -reroute modified_nets_first_then_others -reuse_existing_global_route true -max_detail_route_iterations 160
} ROUTE_MSG]

report_constraints -all_violators > $REPORT_DIR/constraints.after_hold_manual.rpt
check_routes > $REPORT_DIR/check_routes.after_hold_manual.rpt
check_legality > $REPORT_DIR/check_legality.after_hold_manual.rpt
report_qor > $REPORT_DIR/qor.after_hold_manual.rpt
report_reference > $REPORT_DIR/reference.after_hold_manual.rpt

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
puts $FP "delay_lib_cell=$DELAY_LIB_CELL"
puts $FP "hold_report=$HOLD_REPORT"
puts $FP "max_endpoints=$MAX_ENDPOINTS"
puts $FP "include_endpoint_regex=$INCLUDE_ENDPOINT_REGEX"
puts $FP "exclude_endpoint_regex=$EXCLUDE_ENDPOINT_REGEX"
puts $FP "unique_endpoints=[llength $endpoints]"
puts $FP "added=$added"
puts $FP "skipped=$skipped"
puts $FP "failed=$failed"
puts $FP "filtered_include=$filtered_include"
puts $FP "filtered_exclude=$filtered_exclude"
puts $FP "legalize_status=$LEGALIZE_STATUS"
puts $FP "legalize_message=$LEGALIZE_MSG"
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

if {$failed != 0 || $LEGALIZE_STATUS != 0 || $ROUTE_STATUS != 0} {
  error "manual hold ECO failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SPEF_STATUS != 0} {
  error "manual hold ECO export failed. See $MANIFEST"
}

exit
