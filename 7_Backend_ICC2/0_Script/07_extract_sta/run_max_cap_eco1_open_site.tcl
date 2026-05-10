################################################################################
# ICC2 max_cap ECO trial 1: open_site
#
# 목적:
#   route-clean block을 복사한 뒤 max_capacitance만 보수적으로 수정합니다.
#   기존 clean block은 덮어쓰지 않습니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_TAG post_route_eco_drc_clean
set ECO_TAG maxcap_eco1_open_site
set SRC_BLOCK $TOP_NAME
set PHYSICAL_MODE open_site
if {[info exists ::env(ECO_TAG)]} {
  set ECO_TAG $::env(ECO_TAG)
}
if {[info exists ::env(SRC_BLOCK)]} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(PHYSICAL_MODE)]} {
  set PHYSICAL_MODE $::env(PHYSICAL_MODE)
}

set ECO_BLOCK ${TOP_NAME}_${ECO_TAG}
set OUTPUT_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/07_extract_sta/$ECO_TAG
set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/07_extract_sta/$ECO_TAG
set SESSION_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/07_extract_sta/$ECO_TAG/pt_eco_session
set PT_WORK_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/07_extract_sta/$ECO_TAG/pt_work
set PT_EXEC /tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell
file mkdir $OUTPUT_DIR
file mkdir $REPORT_DIR
file mkdir $SESSION_DIR
file mkdir $PT_WORK_DIR

set NETLIST_OUT $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.vg
set DEF_OUT     $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.def
set SDC_OUT     $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.sdc
set SDF_OUT     $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.sdf
set SPEF_BASE   $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.spef
set SPEF_MAX    $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.spef.saed32_cmax_25.spef
set SPEF_MIN    $OUTPUT_DIR/cv32e40p_synth_wrap.$ECO_TAG.spef.saed32_cmin_25.spef
set MANIFEST    $OUTPUT_DIR/max_cap_eco_manifest.txt

# 기존 route-clean block을 새 block으로 복사해서 원본 보존합니다.
open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

# ECO 전 기준 상태를 저장합니다.
check_routes > $REPORT_DIR/check_routes.before_max_cap_eco.rpt
check_legality > $REPORT_DIR/check_legality.before_max_cap_eco.rpt
report_qor > $REPORT_DIR/qor.before_max_cap_eco.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_max_cap_eco.rpt

# eco_opt는 내부에서 PrimeTime ECO를 호출하므로 PT 실행 파일과 work dir을 지정합니다.
set_pt_options -pt_exec $PT_EXEC -work_dir $PT_WORK_DIR
report_pt_options > $REPORT_DIR/pt_options.rpt

# 이 학습 flow는 StarRC signoff extraction 대신 ICC2 NEX/write_parasitics를 사용합니다.
# eco_opt가 StarRC 설정을 요구하지 않도록 in-design StarRC mode를 끕니다.
set_app_options -name extract.starrc_mode -value false

# max capacitance만 고치는 보수적 ECO입니다.
# open_site는 빈 site가 있을 때만 buffer/place 변경을 허용해서 layout 충격을 줄입니다.
set ECO_STATUS [catch {
  eco_opt -types max_capacitance -physical_mode $PHYSICAL_MODE -save_session $SESSION_DIR
} ECO_MSG]

# ECO 후 상태를 저장합니다.
report_qor > $REPORT_DIR/qor.after_max_cap_eco.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_max_cap_eco.rpt
check_routes > $REPORT_DIR/check_routes.after_max_cap_eco.rpt
check_legality > $REPORT_DIR/check_legality.after_max_cap_eco.rpt

# 후속 PrimeTime/FMAILTY 확인을 위해 산출물을 씁니다.
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
puts $FP "eco_command=eco_opt -types max_capacitance -physical_mode $PHYSICAL_MODE"
puts $FP "pt_exec=$PT_EXEC"
puts $FP "pt_work_dir=$PT_WORK_DIR"
puts $FP "eco_status=$ECO_STATUS"
puts $FP "eco_message=$ECO_MSG"
puts $FP "netlist=$NETLIST_OUT"
puts $FP "def=$DEF_OUT"
puts $FP "sdc=$SDC_OUT"
puts $FP "sdf=$SDF_OUT"
puts $FP "spef_base=$SPEF_BASE"
puts $FP "spef_max=$SPEF_MAX"
puts $FP "spef_min=$SPEF_MIN"
puts $FP "write_verilog_status=$WRITE_V_STATUS"
puts $FP "write_verilog_message=$WRITE_V_MSG"
puts $FP "write_sdc_status=$WRITE_SDC_STATUS"
puts $FP "write_sdc_message=$WRITE_SDC_MSG"
puts $FP "write_sdf_status=$WRITE_SDF_STATUS"
puts $FP "write_sdf_message=$WRITE_SDF_MSG"
puts $FP "write_def_status=$WRITE_DEF_STATUS"
puts $FP "write_def_message=$WRITE_DEF_MSG"
puts $FP "write_parasitics_status=$WRITE_SPEF_STATUS"
puts $FP "write_parasitics_message=$WRITE_SPEF_MSG"
close $FP

if {$ECO_STATUS != 0} {
  error "max_cap eco failed: $ECO_MSG"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SPEF_STATUS != 0} {
  error "max_cap eco export failed. See $MANIFEST"
}

exit
