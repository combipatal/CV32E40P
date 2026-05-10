################################################################################
# ECO17 GDS candidate export
#
# 목적:
#   STA/N2N clean인 ECO17 block을 복사한 뒤 filler를 삽입하고
#   교육용 final-candidate GDS를 씁니다.
#
# 주의:
#   이 GDS는 ICC2 route/check 기반 candidate입니다.
#   signoff DRC/LVS/IR/EM/antenna/metal fill까지 끝난 tapeout GDS가 아닙니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_BLOCK ${TOP_NAME}_hold_eco17_flop_q_load_split
set GDS_TAG hold_eco17_gds_candidate

if {[info exists ::env(SRC_BLOCK)]} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(GDS_TAG)]} {
  set GDS_TAG $::env(GDS_TAG)
}

set GDS_BLOCK ${TOP_NAME}_${GDS_TAG}
set OUTPUT_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/09_gds/$GDS_TAG
set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/09_gds/$GDS_TAG
file mkdir $OUTPUT_DIR
file mkdir $REPORT_DIR
file mkdir $PROJECT_ROOT/7_Backend_ICC2/3_Log/09_gds

set GDS_OUT      $OUTPUT_DIR/cv32e40p_synth_wrap.$GDS_TAG.gds
set NETLIST_OUT  $OUTPUT_DIR/cv32e40p_synth_wrap.$GDS_TAG.vg
set DEF_OUT      $OUTPUT_DIR/cv32e40p_synth_wrap.$GDS_TAG.def
set SDC_OUT      $OUTPUT_DIR/cv32e40p_synth_wrap.$GDS_TAG.sdc
set MANIFEST     $OUTPUT_DIR/gds_export_manifest.txt

set GDS_MAP $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_gdsout_mw.map
set RVT_GDS $SAED32_ROOT/lib/stdcell_rvt/gds/saed32nm_rvt_oa.gds
set LVT_GDS $SAED32_ROOT/lib/stdcell_lvt/gds/saed32nm_lvt_oa.gds
set HVT_GDS $SAED32_ROOT/lib/stdcell_hvt/gds/saed32nm_hvt_oa.gds

open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $GDS_BLOCK
current_block $GDS_BLOCK

check_routes > $REPORT_DIR/check_routes.before_gds.rpt
check_legality > $REPORT_DIR/check_legality.before_gds.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_gds.rpt

# Filler cell list를 실제 loaded library에서 찾습니다.
# 큰 filler부터 넣어 gap을 줄입니다.
set filler_names {
  SHFILL128_RVT SHFILL64_RVT SHFILL3_RVT SHFILL2_RVT SHFILL1_RVT
  SHFILL128_HVT SHFILL64_HVT SHFILL3_HVT SHFILL2_HVT SHFILL1_HVT
  SHFILL128_LVT SHFILL64_LVT SHFILL3_LVT SHFILL2_LVT SHFILL1_LVT
}

set filler_lib_cells {}
set filler_rpt [open $REPORT_DIR/filler_lib_cells.rpt w]
foreach filler_name $filler_names {
  set lib_cell [get_lib_cells -quiet */$filler_name]
  if {[sizeof_collection $lib_cell] > 0} {
    set one_lib_cell [index_collection $lib_cell 0]
    set full_name [get_object_name $one_lib_cell]
    lappend filler_lib_cells $full_name
    puts $filler_rpt "FOUND $full_name"
  } else {
    puts $filler_rpt "MISSING $filler_name"
  }
}
close $filler_rpt

set FILLER_STATUS 0
set FILLER_MSG ""
if {[llength $filler_lib_cells] == 0} {
  set FILLER_STATUS 1
  set FILLER_MSG "no filler lib cells found"
} else {
  set FILLER_STATUS [catch {
    create_stdcell_fillers -lib_cells $filler_lib_cells -prefix FILL_ECO17_
  } FILLER_MSG]
}

# filler의 VDD/VSS pin을 기존 PG net에 연결합니다.
set PG_STATUS [catch {connect_pg_net -automatic} PG_MSG]

check_routes > $REPORT_DIR/check_routes.after_filler.rpt
check_legality > $REPORT_DIR/check_legality.after_filler.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_filler.rpt
report_qor > $REPORT_DIR/qor.after_filler.rpt
report_reference > $REPORT_DIR/reference.after_filler.rpt

set WRITE_V_STATUS [catch {write_verilog $NETLIST_OUT} WRITE_V_MSG]
set WRITE_DEF_STATUS [catch {write_def $DEF_OUT} WRITE_DEF_MSG]
set WRITE_SDC_STATUS [catch {write_sdc -output $SDC_OUT} WRITE_SDC_MSG]

# stdcell leaf GDS를 merge해서 하나의 top GDS candidate로 씁니다.
set WRITE_GDS_STATUS [catch {
  write_gds \
    -design $GDS_BLOCK \
    -long_names \
    -hierarchy design_lib \
    -layer_map $GDS_MAP \
    -merge_files [list $RVT_GDS $LVT_GDS $HVT_GDS] \
    $GDS_OUT
} WRITE_GDS_MSG]

save_block

set FP [open $MANIFEST w]
puts $FP "gds_tag=$GDS_TAG"
puts $FP "source_block=$SRC_BLOCK"
puts $FP "gds_block=$GDS_BLOCK"
puts $FP "gds=$GDS_OUT"
puts $FP "netlist=$NETLIST_OUT"
puts $FP "def=$DEF_OUT"
puts $FP "sdc=$SDC_OUT"
puts $FP "gds_map=$GDS_MAP"
puts $FP "merge_rvt_gds=$RVT_GDS"
puts $FP "merge_lvt_gds=$LVT_GDS"
puts $FP "merge_hvt_gds=$HVT_GDS"
puts $FP "filler_lib_cells=$filler_lib_cells"
puts $FP "filler_status=$FILLER_STATUS"
puts $FP "filler_message=$FILLER_MSG"
puts $FP "pg_status=$PG_STATUS"
puts $FP "pg_message=$PG_MSG"
puts $FP "write_verilog_status=$WRITE_V_STATUS"
puts $FP "write_def_status=$WRITE_DEF_STATUS"
puts $FP "write_sdc_status=$WRITE_SDC_STATUS"
puts $FP "write_gds_status=$WRITE_GDS_STATUS"
puts $FP "write_gds_message=$WRITE_GDS_MSG"
close $FP

if {$FILLER_STATUS != 0 || $PG_STATUS != 0} {
  error "GDS candidate filler/PG step failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_GDS_STATUS != 0} {
  error "GDS candidate export failed. See $MANIFEST"
}

exit
