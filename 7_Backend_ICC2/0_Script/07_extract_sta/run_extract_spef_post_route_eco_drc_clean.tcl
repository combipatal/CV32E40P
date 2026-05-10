################################################################################
# ICC2 post-route RC extraction / SPEF export
#
# 목적:
#   DRC clean route block에서 RC를 추출하고 PrimeTime post-route STA용
#   SPEF를 씁니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TAG post_route_eco_drc_clean
if {[info exists ::env(EXTRACT_TAG)]} {
  set TAG $::env(EXTRACT_TAG)
}

set OUTPUT_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/07_extract_sta/$TAG
set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/07_extract_sta/$TAG
file mkdir $OUTPUT_DIR
file mkdir $REPORT_DIR

set SPEF_BASE $OUTPUT_DIR/cv32e40p_synth_wrap.$TAG.spef
set SPEF_MAX $OUTPUT_DIR/cv32e40p_synth_wrap.$TAG.spef.saed32_cmax_25.spef
set SPEF_MIN $OUTPUT_DIR/cv32e40p_synth_wrap.$TAG.spef.saed32_cmin_25.spef
set MANIFEST $OUTPUT_DIR/extract_manifest.txt

# DRC clean이 저장된 ICC2 design block을 엽니다.
open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

# 추출 전 block 상태를 확인합니다.
check_routes > $REPORT_DIR/check_routes.before_extract.rpt
check_legality > $REPORT_DIR/check_legality.before_extract.rpt
report_qor > $REPORT_DIR/qor.before_extract.rpt

# 이 ICC2 버전에서는 별도 extract_rc command가 없고,
# write_parasitics가 NEX extraction과 SPEF write를 함께 수행합니다.
set EXTRACT_STATUS 0
set EXTRACT_MSG "write_parasitics performs NEX extraction in this ICC2 version"

# PrimeTime용 SPEF를 씁니다. cmax/cmin 파일이 suffix로 생성됩니다.
set SPEF_STATUS [catch {write_parasitics -format spef -output $SPEF_BASE} SPEF_MSG]

# ICC2 버전별 문법 차이를 대비한 fallback입니다.
if {$SPEF_STATUS != 0} {
  set SPEF_STATUS_FALLBACK [catch {write_parasitics -format spef $SPEF_BASE} SPEF_MSG_FALLBACK]
} else {
  set SPEF_STATUS_FALLBACK 0
  set SPEF_MSG_FALLBACK "not_needed"
}

set FP [open $MANIFEST w]
puts $FP "tag=$TAG"
puts $FP "icc2_lib_dir=$ICC2_LIB_DIR"
puts $FP "top_name=$TOP_NAME"
puts $FP "spef_base=$SPEF_BASE"
puts $FP "spef_max=$SPEF_MAX"
puts $FP "spef_min=$SPEF_MIN"
puts $FP "extract_rc_status=$EXTRACT_STATUS"
puts $FP "extract_rc_message=$EXTRACT_MSG"
puts $FP "write_parasitics_status=$SPEF_STATUS"
puts $FP "write_parasitics_message=$SPEF_MSG"
puts $FP "write_parasitics_fallback_status=$SPEF_STATUS_FALLBACK"
puts $FP "write_parasitics_fallback_message=$SPEF_MSG_FALLBACK"
close $FP

if {$SPEF_STATUS != 0 && $SPEF_STATUS_FALLBACK != 0} {
  error "write_parasitics failed: $SPEF_MSG / $SPEF_MSG_FALLBACK"
}

exit
