################################################################################
# ECO7 FF hold path probe
#
# 목적:
#   ECO7 이후 FF -40C hold violation을 더 자세히 뽑습니다.
#   기본 STA script는 top 20 path만 저장하므로, hold ECO 후보를 고르기 위해
#   cmax/cmin 각각 top 300 violating min-delay path를 따로 저장합니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set TOP_NAME cv32e40p_synth_wrap
set CORNER ff1p16vn40c
set TAG ss_setup_eco7_fadd_rvt_trial

set RVT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_$CORNER.db
set LVT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_$CORNER.db
set HVT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_$CORNER.db

set NETLIST 7_Backend_ICC2/2_Output/07_extract_sta/$TAG/cv32e40p_synth_wrap.$TAG.vg
set SDC_FILE constraints/cv32e40p_func_10ns.sdc
set SPEF_MAX_FILE 7_Backend_ICC2/2_Output/07_extract_sta/$TAG/cv32e40p_synth_wrap.$TAG.spef.saed32_cmax_25.spef
set SPEF_MIN_FILE 7_Backend_ICC2/2_Output/07_extract_sta/$TAG/cv32e40p_synth_wrap.$TAG.spef.saed32_cmin_25.spef

set REPORT_DIR 6_STA/4_Report/ss_setup_eco7_fadd_rvt_trial_spef_ff1p16vn40c_propclk/hold_probe
file mkdir $REPORT_DIR

foreach DB_FILE [list $RVT_DB $LVT_DB $HVT_DB] {
  if {![file exists $DB_FILE]} {
    puts "ERROR: missing timing DB: $DB_FILE"
    exit 1
  }
}

set link_path [list * $RVT_DB $LVT_DB $HVT_DB]

read_verilog $NETLIST
current_design $TOP_NAME
link_design
read_sdc $SDC_FILE
set_propagated_clock [get_clocks clk_i]

# cmax RC에서 hold path를 많이 저장합니다.
read_parasitics $SPEF_MAX_FILE
report_global_timing > $REPORT_DIR/eco7.ff1p16vn40c.cmax.global_timing.rpt
report_timing -delay_type min -max_paths 300 -nworst 1 -slack_lesser_than 0.0 -path full_clock_expanded > $REPORT_DIR/eco7.ff1p16vn40c.cmax.hold_300.rpt
report_constraint -all_violators -max_delay -min_delay > $REPORT_DIR/eco7.ff1p16vn40c.cmax.timing_constraints.rpt

# cmin RC에서 hold path를 많이 저장합니다.
remove_annotated_parasitics
read_parasitics $SPEF_MIN_FILE
report_global_timing > $REPORT_DIR/eco7.ff1p16vn40c.cmin.global_timing.rpt
report_timing -delay_type min -max_paths 300 -nworst 1 -slack_lesser_than 0.0 -path full_clock_expanded > $REPORT_DIR/eco7.ff1p16vn40c.cmin.hold_300.rpt
report_constraint -all_violators -max_delay -min_delay > $REPORT_DIR/eco7.ff1p16vn40c.cmin.timing_constraints.rpt

set FP [open $REPORT_DIR/eco7.ff1p16vn40c.hold_probe_manifest.rpt w]
puts $FP "tag=$TAG"
puts $FP "corner=$CORNER"
puts $FP "propagate_clock=1"
puts $FP "netlist=$NETLIST"
puts $FP "sdc=$SDC_FILE"
puts $FP "spef_max=$SPEF_MAX_FILE"
puts $FP "spef_min=$SPEF_MIN_FILE"
close $FP

exit
