################################################################################
# ICC2 CTS 1차 스크립트
#
# 목적:
#   PG-clean placed design에서 clk_i clock tree를 만들고 clock routing까지 진행합니다.
#
# 공부 포인트:
#   check_clock_trees는 CTS 전에 clock 제약/설정 문제가 있는지 확인합니다.
#   set_clock_tree_options는 skew 목표 같은 CTS 목표를 줍니다.
#   set_clock_routing_rules는 clock net이 어느 metal layer를 쓸지 제한합니다.
#   clock_opt -to route_clock은 clock tree 생성과 clock route까지만 수행합니다.
#   final_opto는 아직 실행하지 않습니다. first-pass CTS 결과를 먼저 확인하기 위함입니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

################################################################################
# placement까지 완료된 block을 엽니다.
################################################################################

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# first-pass CTS 목표입니다.
# 10ns clock에서 0.20ns skew target으로 시작합니다.
# 실제 skew/timing 결과를 보고 다음 pass에서 조정합니다.
################################################################################

set CTS_CLOCK clk_i
set CTS_TARGET_SKEW 0.20

set_clock_tree_options \
  -clocks [get_clocks $CTS_CLOCK] \
  -target_skew $CTS_TARGET_SKEW

################################################################################
# clock routing layer 설정입니다.
# M1/M2는 stdcell rail과 local routing 부담이 크므로 clock은 M4~M6으로 제한합니다.
# 이 설정은 first-pass 기준이며, route congestion과 skew 결과를 보고 조정합니다.
################################################################################

set_clock_routing_rules \
  -clocks [get_clocks $CTS_CLOCK] \
  -min_routing_layer M4 \
  -max_routing_layer M6 \
  -default_rule

################################################################################
# CTS 전 clock tree readiness check입니다.
################################################################################

check_clock_trees \
  -clocks [get_clocks $CTS_CLOCK] \
  > $CTS_REPORT_DIR/check_clock_trees.pre.rpt

report_clock_tree_options > $CTS_REPORT_DIR/clock_tree_options.rpt
report_clock_routing_rules > $CTS_REPORT_DIR/clock_routing_rules.rpt

################################################################################
# clock tree synthesis + clock route입니다.
# final_opto는 routing/optimization 범위가 더 넓으므로 이번 pass에서는 제외합니다.
################################################################################

clock_opt \
  -from build_clock \
  -to route_clock

################################################################################
# CTS 후 clock/timing/physical evidence report입니다.
################################################################################

check_clock_trees \
  -clocks [get_clocks $CTS_CLOCK] \
  > $CTS_REPORT_DIR/check_clock_trees.post.rpt

report_clock_qor -type summary > $CTS_REPORT_DIR/clock_qor.summary.rpt
report_clock_qor -type latency > $CTS_REPORT_DIR/clock_qor.latency.rpt
report_clock_qor -type drc_violators > $CTS_REPORT_DIR/clock_qor.drc_violators.rpt
report_clock_qor -type area > $CTS_REPORT_DIR/clock_qor.area.rpt

report_clock_timing -type summary > $CTS_REPORT_DIR/clock_timing.summary.rpt
report_clock_timing -type skew -setup -nworst 20 > $CTS_REPORT_DIR/clock_timing.skew_setup.rpt
report_clock_timing -type skew -hold -nworst 20 > $CTS_REPORT_DIR/clock_timing.skew_hold.rpt
report_clock_timing -type latency -setup -nworst 20 > $CTS_REPORT_DIR/clock_timing.latency_setup.rpt
report_clock_timing -type latency -hold -nworst 20 > $CTS_REPORT_DIR/clock_timing.latency_hold.rpt

report_timing -delay_type max -max_paths 20 > $CTS_REPORT_DIR/timing.max.rpt
report_timing -delay_type min -max_paths 20 > $CTS_REPORT_DIR/timing.min.rpt
report_qor > $CTS_REPORT_DIR/qor.rpt
report_utilization > $CTS_REPORT_DIR/utilization.rpt
report_design -physical > $CTS_REPORT_DIR/design_physical.rpt
check_legality > $CTS_REPORT_DIR/check_legality.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $CTS_REPORT_DIR/pg_connectivity_detail.rpt \
  > $CTS_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $CTS_REPORT_DIR/pg_drc.rpt

save_block
save_lib

exit
