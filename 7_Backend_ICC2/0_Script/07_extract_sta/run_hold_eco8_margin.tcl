################################################################################
# hold_eco8: PrimeTime ECO hold margin trial
#
# 목적:
#   ECO7 이후 남은 FF -40C hold violation을 줄이기 위한 hold 전용 ECO입니다.
#   현재 ICC2 scenario는 TT 중심이므로, TT hold에 margin을 걸어 delay 삽입을
#   유도한 뒤 FF -40C PrimeTime SPEF STA로 실제 효과를 검증합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set SRC_BLOCK ${TOP_NAME}_ss_setup_eco7_fadd_rvt_trial
set ECO_TAG hold_eco8_margin80ps
set HOLD_MARGIN 0.08
set PHYSICAL_MODE occupied_site

if {[info exists ::env(ECO_TAG)]} {
  set ECO_TAG $::env(ECO_TAG)
}
if {[info exists ::env(SRC_BLOCK)]} {
  set SRC_BLOCK $::env(SRC_BLOCK)
}
if {[info exists ::env(HOLD_MARGIN)]} {
  set HOLD_MARGIN $::env(HOLD_MARGIN)
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
set MANIFEST    $OUTPUT_DIR/hold_eco_manifest.txt

open_lib $ICC2_LIB_DIR
copy_block -from_block $SRC_BLOCK -to_block $ECO_BLOCK
current_block $ECO_BLOCK

# ECO 전 기준 상태를 저장합니다.
check_routes > $REPORT_DIR/check_routes.before_hold_eco.rpt
check_legality > $REPORT_DIR/check_legality.before_hold_eco.rpt
report_qor > $REPORT_DIR/qor.before_hold_eco.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.before_hold_eco.rpt

# eco_opt가 내부 PrimeTime ECO를 호출할 수 있도록 PT 위치를 지정합니다.
set_pt_options -pt_exec $PT_EXEC -work_dir $PT_WORK_DIR
report_pt_options > $REPORT_DIR/pt_options.rpt

# 이 flow는 ICC2 NEX/write_parasitics 기반입니다. StarRC 요구를 피합니다.
set_app_options -name extract.starrc_mode -value false

# hold 전용 ECO입니다. HOLD_MARGIN은 TT 내부 hold 여유를 일부 소모시켜
# FF -40C hold 개선을 노리는 실험 knob입니다.
set ECO_STATUS [catch {
  eco_opt -types hold -hold_margin $HOLD_MARGIN -physical_mode $PHYSICAL_MODE -save_session $SESSION_DIR
} ECO_MSG]

# ECO 후 상태를 저장합니다.
report_qor > $REPORT_DIR/qor.after_hold_eco.rpt
report_constraints -all_violators > $REPORT_DIR/constraints.after_hold_eco.rpt
check_routes > $REPORT_DIR/check_routes.after_hold_eco.rpt
check_legality > $REPORT_DIR/check_legality.after_hold_eco.rpt

# 변경된 cell과 buffer 개수를 빠르게 볼 수 있게 요약 report를 남깁니다.
report_design -library -physical > $REPORT_DIR/design.after_hold_eco.rpt
report_reference > $REPORT_DIR/reference.after_hold_eco.rpt

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
puts $FP "eco_command=eco_opt -types hold -hold_margin $HOLD_MARGIN -physical_mode $PHYSICAL_MODE"
puts $FP "hold_margin=$HOLD_MARGIN"
puts $FP "physical_mode=$PHYSICAL_MODE"
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
puts $FP "write_sdc_status=$WRITE_SDC_STATUS"
puts $FP "write_sdf_status=$WRITE_SDF_STATUS"
puts $FP "write_def_status=$WRITE_DEF_STATUS"
puts $FP "write_parasitics_status=$WRITE_SPEF_STATUS"
close $FP

if {$ECO_STATUS != 0} {
  error "hold ECO failed: $ECO_MSG"
}
if {$WRITE_V_STATUS != 0 || $WRITE_SDC_STATUS != 0 || $WRITE_SDF_STATUS != 0 || $WRITE_DEF_STATUS != 0 || $WRITE_SPEF_STATUS != 0} {
  error "hold ECO export failed. See $MANIFEST"
}

exit
