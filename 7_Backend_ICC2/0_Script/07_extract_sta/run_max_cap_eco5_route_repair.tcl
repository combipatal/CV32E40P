################################################################################
# maxcap_eco5: ECO4 이후 생긴 국소 route short 보수
#
# 목적:
#   ECO4는 PT max_cap을 0으로 만들었지만 M1 short 3개가 남았습니다.
#   문제가 보고된 작은 bbox 주변만 incremental detail route로 보수합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_BLOCK ${TOP_NAME}_maxcap_eco4_occupied_site
set ECO_TAG maxcap_eco5_route_repair
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
set MANIFEST    $OUTPUT_DIR/route_repair_manifest.txt

# Short 3개가 나온 주변 영역입니다.
# 상세 좌표:
#   {210.3810 122.0640} {210.5310 122.2240}
#   {210.5330 122.0690} {210.6830 122.2190}
#   {210.6850 122.0690} {210.8350 122.2190}
set REPAIR_BOX { {{210.0000 121.5000} {211.2000 122.8000}} }

open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

# 수정 전 상태를 기록합니다.
check_routes > $REPORT_DIR/check_routes.before_route_repair.rpt
check_legality > $REPORT_DIR/check_legality.before_route_repair.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_route_repair.rpt

# 국소 영역부터 detail route를 다시 수행합니다.
set ROUTE_DETAIL_STATUS [catch {
  route_detail -coordinates $REPAIR_BOX -incremental true -max_number_iterations 80
} ROUTE_DETAIL_MSG]

# 남은 DRC가 있으면 ECO router가 주변 net까지 조금 더 자유롭게 고치게 합니다.
set ROUTE_ECO_STATUS [catch {
  route_eco -reroute any_nets -reuse_existing_global_route true -max_detail_route_iterations 80
} ROUTE_ECO_MSG]

# 수정 후 상태를 기록합니다.
check_routes > $REPORT_DIR/check_routes.after_route_repair.rpt
check_legality > $REPORT_DIR/check_legality.after_route_repair.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_route_repair.rpt
report_qor > $REPORT_DIR/qor.after_route_repair.rpt

# 후속 STA/Formality 확인용 산출물을 씁니다.
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
puts $FP "repair_box=$REPAIR_BOX"
puts $FP "route_detail_status=$ROUTE_DETAIL_STATUS"
puts $FP "route_detail_message=$ROUTE_DETAIL_MSG"
puts $FP "route_eco_status=$ROUTE_ECO_STATUS"
puts $FP "route_eco_message=$ROUTE_ECO_MSG"
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

if {$ROUTE_DETAIL_STATUS != 0 || $ROUTE_ECO_STATUS != 0} {
  error "route repair failed. See $MANIFEST"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SPEF_STATUS != 0} {
  error "route repair export failed. See $MANIFEST"
}

exit
