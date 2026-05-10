################################################################################
# maxtran_eco6: U246 RVT swap trial
#
# 목적:
#   PT cmax에서 남은 max_transition -0.0005 ns를 한 개 cell ECO로 줄입니다.
#
# 배경:
#   U246은 이미 AND4X4_HVT입니다.
#   SAED32 HVT에는 AND4X8_HVT가 없으므로 HVT drive upsize는 불가능합니다.
#   가장 작은 대안으로 같은 drive의 AND4X4_RVT로 VT swap을 시도합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_BLOCK ${TOP_NAME}_maxcap_eco5_route_repair
set ECO_TAG maxtran_eco6_u246_rvt_swap
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
set MANIFEST    $OUTPUT_DIR/maxtran_eco_manifest.txt

set ECO_INST u_core/core_i/id_stage_i/U246
set OLD_REF AND4X4_HVT
set NEW_LIB_CELL saed32rvt_tt/AND4X4_RVT

open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

# 수정 전 상태를 기록합니다.
report_cells $ECO_INST > $REPORT_DIR/u246.before.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_maxtran_eco.rpt
check_routes > $REPORT_DIR/check_routes.before_maxtran_eco.rpt
check_legality > $REPORT_DIR/check_legality.before_maxtran_eco.rpt

# U246 한 개 cell만 HVT에서 RVT로 바꿉니다.
set SIZE_STATUS [catch {
  size_cell [get_cells $ECO_INST] [get_lib_cells $NEW_LIB_CELL]
} SIZE_MSG]
set_dont_touch [get_cells $ECO_INST] true

# cell ECO 이후 변경된 net 주변만 먼저 고치고, 필요 시 주변 net도 허용합니다.
set ROUTE_STATUS [catch {
  route_eco -reroute modified_nets_first_then_others -reuse_existing_global_route true -max_detail_route_iterations 80
} ROUTE_MSG]

# 수정 후 상태를 기록합니다.
report_cells $ECO_INST > $REPORT_DIR/u246.after.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_maxtran_eco.rpt
check_routes > $REPORT_DIR/check_routes.after_maxtran_eco.rpt
check_legality > $REPORT_DIR/check_legality.after_maxtran_eco.rpt
report_qor > $REPORT_DIR/qor.after_maxtran_eco.rpt

# 후속 PT/FM 확인용 산출물을 씁니다.
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
puts $FP "eco_inst=$ECO_INST"
puts $FP "old_ref=$OLD_REF"
puts $FP "new_lib_cell=$NEW_LIB_CELL"
puts $FP "size_status=$SIZE_STATUS"
puts $FP "size_message=$SIZE_MSG"
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

if {$SIZE_STATUS != 0 || $ROUTE_STATUS != 0} {
  error "max_transition ECO failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SPEF_STATUS != 0} {
  error "max_transition ECO export failed. See $MANIFEST"
}

exit
