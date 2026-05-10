################################################################################
# ICC2 eco_opt / PrimeTime option probe
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/07_extract_sta/max_cap_repair
file mkdir $REPORT_DIR

redirect -file $REPORT_DIR/man_set_eco_opt_options.rpt {man set_eco_opt_options}
redirect -file $REPORT_DIR/man_set_pt_options.rpt {man set_pt_options}
redirect -file $REPORT_DIR/man_report_pt_options.rpt {man report_pt_options}
redirect -file $REPORT_DIR/man_check_pt_qor.rpt {man check_pt_qor}

exit
