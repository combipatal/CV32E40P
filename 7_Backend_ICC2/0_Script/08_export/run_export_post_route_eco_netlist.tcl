################################################################################
# ICC2 post-route ECO netlist export
#
# 목적:
#   DRC clean이 확인된 route-clean saved block에서 Formality 비교용
#   post-route ECO netlist와 보조 산출물을 씁니다.
#
# 기준 block:
#   route_no012_nor2x4_to_nor2x2_mux41x2x1_eco_ndm_trim_all_pin trial이
#   마지막으로 저장한 cv32e40p_icc2_lib/cv32e40p_synth_wrap block입니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set EXPORT_TAG post_route_eco_drc_clean
if {[info exists ::env(EXPORT_TAG)]} {
  set EXPORT_TAG $::env(EXPORT_TAG)
}

set EXPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/08_export/$EXPORT_TAG
set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/08_export/$EXPORT_TAG
file mkdir $EXPORT_DIR
file mkdir $REPORT_DIR

set NETLIST_OUT $EXPORT_DIR/cv32e40p_synth_wrap.$EXPORT_TAG.vg
set SDC_OUT     $EXPORT_DIR/cv32e40p_synth_wrap.$EXPORT_TAG.sdc
set SDF_OUT     $EXPORT_DIR/cv32e40p_synth_wrap.$EXPORT_TAG.sdf
set DEF_OUT     $EXPORT_DIR/cv32e40p_synth_wrap.$EXPORT_TAG.def
set MANIFEST    $EXPORT_DIR/export_manifest.txt

# route-clean trial이 저장한 ICC2 design library를 엽니다.
open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

# export 전에 현재 block 상태를 다시 report로 남깁니다.
check_routes > $REPORT_DIR/check_routes.before_export.rpt
check_legality > $REPORT_DIR/check_legality.before_export.rpt
report_qor > $REPORT_DIR/qor.before_export.rpt
report_timing -delay_type max -max_paths 20 > $REPORT_DIR/timing.max.before_export.rpt
report_timing -delay_type min -max_paths 20 > $REPORT_DIR/timing.min.before_export.rpt

# Formality용 post-route logical netlist입니다.
write_verilog $NETLIST_OUT

# 후속 STA/문서화를 위한 보조 산출물입니다.
# 일부 command option은 환경마다 다를 수 있어 실패 시 manifest에 기록하고 계속 진행합니다.
set SDC_STATUS [catch {write_sdc -output $SDC_OUT} SDC_MSG]
set SDF_STATUS [catch {write_sdf $SDF_OUT} SDF_MSG]
set DEF_STATUS [catch {write_def $DEF_OUT} DEF_MSG]

set FP [open $MANIFEST w]
puts $FP "export_tag=$EXPORT_TAG"
puts $FP "icc2_lib_dir=$ICC2_LIB_DIR"
puts $FP "top_name=$TOP_NAME"
puts $FP "netlist=$NETLIST_OUT"
puts $FP "sdc=$SDC_OUT"
puts $FP "sdf=$SDF_OUT"
puts $FP "def=$DEF_OUT"
puts $FP "write_sdc_status=$SDC_STATUS"
puts $FP "write_sdc_message=$SDC_MSG"
puts $FP "write_sdf_status=$SDF_STATUS"
puts $FP "write_sdf_message=$SDF_MSG"
puts $FP "write_def_status=$DEF_STATUS"
puts $FP "write_def_message=$DEF_MSG"
close $FP

save_block
save_lib

exit
