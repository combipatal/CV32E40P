################################################################################
# ICC2 max capacitance repair option probe
#
# 목적:
#   route_opt / eco_opt 관련 옵션과 app option 이름을 확인합니다.
#   실제 design 수정은 하지 않습니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/07_extract_sta/max_cap_repair
file mkdir $REPORT_DIR

redirect -file $REPORT_DIR/man_route_opt.rpt {man route_opt}
redirect -file $REPORT_DIR/man_eco_opt.rpt {man eco_opt}
redirect -file $REPORT_DIR/man_insert_buffer.rpt {man insert_buffer}
redirect -file $REPORT_DIR/man_size_cell.rpt {man size_cell}
redirect -file $REPORT_DIR/app_options_max_cap.rpt {report_app_options *max_cap*}
redirect -file $REPORT_DIR/app_options_route_opt.rpt {report_app_options *route_opt*}
redirect -file $REPORT_DIR/app_options_eco.rpt {report_app_options *eco*}

exit
