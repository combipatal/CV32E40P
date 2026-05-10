################################################################################
# ICC2 save_block option probe
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/07_extract_sta/max_cap_repair
file mkdir $REPORT_DIR

redirect -file $REPORT_DIR/man_save_block.rpt {man save_block}
redirect -file $REPORT_DIR/man_copy_block.rpt {man copy_block}
redirect -file $REPORT_DIR/man_open_block.rpt {man open_block}

exit
