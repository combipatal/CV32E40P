################################################################################
# PrimeTime post-route ECO / SPEF STA
#
# 목적:
#   ICC2 route-clean block에서 export한 ECO netlist와 SPEF를 사용해
#   functional 10 ns post-route STA를 수행합니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set TOP_NAME cv32e40p_synth_wrap
set TAG post_route_eco_drc_clean
if {[info exists ::env(TAG)]} {
  set TAG $::env(TAG)
}

# mixed-VT timing DB입니다.
# 기본은 기존 TT이고, SS/FF 확인은 env CORNER로 corner 이름만 바꿉니다.
set CORNER tt1p05v25c
if {[info exists ::env(CORNER)]} {
  set CORNER $::env(CORNER)
}

set RVT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_$CORNER.db
set LVT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_$CORNER.db
set HVT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_$CORNER.db

# ICC2 post-route ECO export와 SPEF입니다.
set NETLIST 7_Backend_ICC2/2_Output/08_export/$TAG/cv32e40p_synth_wrap.$TAG.vg
set SPEF_MAX_FILE 7_Backend_ICC2/2_Output/07_extract_sta/$TAG/cv32e40p_synth_wrap.$TAG.spef.saed32_cmax_25.spef
set SPEF_MIN_FILE 7_Backend_ICC2/2_Output/07_extract_sta/$TAG/cv32e40p_synth_wrap.$TAG.spef.saed32_cmin_25.spef

# max_cap ECO trial처럼 산출물 위치가 다를 때 env로 직접 지정할 수 있습니다.
if {[info exists ::env(NETLIST)]} {
  set NETLIST $::env(NETLIST)
}
if {[info exists ::env(SPEF_MAX_FILE)]} {
  set SPEF_MAX_FILE $::env(SPEF_MAX_FILE)
}
if {[info exists ::env(SPEF_MIN_FILE)]} {
  set SPEF_MIN_FILE $::env(SPEF_MIN_FILE)
}

# RC 중복을 피하기 위해 set_load/set_resistance가 많은 ICC2 export SDC는 쓰지 않습니다.
# functional constraint만 읽고, interconnect RC는 SPEF에서만 annotate합니다.
set SDC_FILE constraints/cv32e40p_func_10ns.sdc

set REPORT_DIR 6_STA/4_Report/post_route_eco_drc_clean_spef
if {[info exists ::env(REPORT_DIR)]} {
  set REPORT_DIR $::env(REPORT_DIR)
}
set REPORT_PREFIX post_route_eco.func_${CORNER}_10ns_spef
if {[info exists ::env(REPORT_PREFIX)]} {
  set REPORT_PREFIX $::env(REPORT_PREFIX)
}
file mkdir $REPORT_DIR
file mkdir 6_STA/3_Log

# 지정 corner의 세 VT library가 모두 있는지 먼저 확인합니다.
foreach DB_FILE [list $RVT_DB $LVT_DB $HVT_DB] {
  if {![file exists $DB_FILE]} {
    puts "ERROR: missing timing DB: $DB_FILE"
    exit 1
  }
}

set link_path [list * $RVT_DB $LVT_DB $HVT_DB]

# post-route ECO netlist를 읽고 top design을 link합니다.
read_verilog $NETLIST
current_design $TOP_NAME
link_design

# functional timing constraint와 cmax SPEF RC를 적용합니다.
read_sdc $SDC_FILE
read_parasitics $SPEF_MAX_FILE

# cmax corner: setup 중심 report입니다.
check_timing -verbose > $REPORT_DIR/$REPORT_PREFIX.cmax.check_timing.rpt
report_global_timing > $REPORT_DIR/$REPORT_PREFIX.cmax.global_timing.rpt
report_timing -delay_type max -max_paths 20 -slack_lesser_than 100 > $REPORT_DIR/$REPORT_PREFIX.cmax.setup_timing.rpt
report_timing -delay_type min -max_paths 20 -slack_lesser_than 100 > $REPORT_DIR/$REPORT_PREFIX.cmax.hold_timing.rpt
report_constraint -all_violators > $REPORT_DIR/$REPORT_PREFIX.cmax.constraints.rpt
report_analysis_coverage > $REPORT_DIR/$REPORT_PREFIX.cmax.coverage.rpt

set ANNO_MAX_STATUS [catch {
  report_annotated_parasitics > $REPORT_DIR/$REPORT_PREFIX.cmax.annotated_parasitics.rpt
} ANNO_MAX_MSG]

# cmin corner: 기존 parasitic을 지우고 min RC를 다시 annotate합니다.
remove_annotated_parasitics
read_parasitics $SPEF_MIN_FILE

check_timing -verbose > $REPORT_DIR/$REPORT_PREFIX.cmin.check_timing.rpt
report_global_timing > $REPORT_DIR/$REPORT_PREFIX.cmin.global_timing.rpt
report_timing -delay_type max -max_paths 20 -slack_lesser_than 100 > $REPORT_DIR/$REPORT_PREFIX.cmin.setup_timing.rpt
report_timing -delay_type min -max_paths 20 -slack_lesser_than 100 > $REPORT_DIR/$REPORT_PREFIX.cmin.hold_timing.rpt
report_constraint -all_violators > $REPORT_DIR/$REPORT_PREFIX.cmin.constraints.rpt
report_analysis_coverage > $REPORT_DIR/$REPORT_PREFIX.cmin.coverage.rpt

set ANNO_MIN_STATUS [catch {
  report_annotated_parasitics > $REPORT_DIR/$REPORT_PREFIX.cmin.annotated_parasitics.rpt
} ANNO_MIN_MSG]

set FP [open $REPORT_DIR/$REPORT_PREFIX.run_manifest.rpt w]
puts $FP "tag=$TAG"
puts $FP "corner=$CORNER"
puts $FP "report_prefix=$REPORT_PREFIX"
puts $FP "netlist=$NETLIST"
puts $FP "sdc=$SDC_FILE"
puts $FP "rvt_db=$RVT_DB"
puts $FP "lvt_db=$LVT_DB"
puts $FP "hvt_db=$HVT_DB"
puts $FP "spef_max=$SPEF_MAX_FILE"
puts $FP "spef_min=$SPEF_MIN_FILE"
puts $FP "report_annotated_parasitics_cmax_status=$ANNO_MAX_STATUS"
puts $FP "report_annotated_parasitics_cmax_message=$ANNO_MAX_MSG"
puts $FP "report_annotated_parasitics_cmin_status=$ANNO_MIN_STATUS"
puts $FP "report_annotated_parasitics_cmin_message=$ANNO_MIN_MSG"
close $FP

exit
