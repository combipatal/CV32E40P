################################################################################
# ICC2 detail route repair trial
#
# 목적:
#   이미 route된 block에서 detail route만 incremental로 더 돌려서
#   lower-metal/VIA1 DRC가 줄어드는지 확인합니다.
#
# 주의:
#   현재 열리는 ICC2 block 상태에서 시작합니다.
#   지금은 60util_m8 trial state 기준으로 사용합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME detail_repair_200iter
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set DETAIL_ROUTE_ITERATIONS 200
if {[info exists ::env(DETAIL_ROUTE_ITERATIONS)]} {
  set DETAIL_ROUTE_ITERATIONS $::env(DETAIL_ROUTE_ITERATIONS)
}

set TRIAL_ROUTE_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/06_route
file mkdir $TRIAL_ROUTE_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# signal route layer bound를 M1-M8로 고정합니다.
################################################################################

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

catch {report_ignored_layers > $TRIAL_ROUTE_DIR/ignored_layers.rpt}

################################################################################
# repair 전 DRC marker를 갱신하고 matrix를 저장합니다.
################################################################################

check_routes > $TRIAL_ROUTE_DIR/check_routes.before.rpt

set ZROUTE_DATA [open_drc_error_data [get_drc_error_data -all zroute.err]]

report_drc_error \
  -error_data $ZROUTE_DATA \
  -report_type matrix \
  > $TRIAL_ROUTE_DIR/drc.before.matrix.rpt

close_drc_error_data $ZROUTE_DATA -force

################################################################################
# incremental detail route repair입니다.
# 기존 global/track route를 유지하고 DRC repair 성격으로 detail route만 더 수행합니다.
################################################################################

route_detail \
  -incremental true \
  -initial_drc_from_input true \
  -start_iteration 1 \
  -max_number_iterations $DETAIL_ROUTE_ITERATIONS

################################################################################
# repair 후 evidence report입니다.
################################################################################

check_routes > $TRIAL_ROUTE_DIR/check_routes.after.rpt

set ZROUTE_DATA [open_drc_error_data [get_drc_error_data -all zroute.err]]

report_drc_error \
  -error_data $ZROUTE_DATA \
  -report_type matrix \
  > $TRIAL_ROUTE_DIR/drc.after.matrix.rpt

report_drc_error \
  -error_data $ZROUTE_DATA \
  -report_type error_layer \
  > $TRIAL_ROUTE_DIR/drc.after.by_layer.rpt

close_drc_error_data $ZROUTE_DATA -force

report_qor > $TRIAL_ROUTE_DIR/qor.after.rpt
report_timing -delay_type max -max_paths 20 > $TRIAL_ROUTE_DIR/timing.max.after.rpt
report_timing -delay_type min -max_paths 20 > $TRIAL_ROUTE_DIR/timing.min.after.rpt
report_utilization > $TRIAL_ROUTE_DIR/utilization.after.rpt
check_legality > $TRIAL_ROUTE_DIR/check_legality.after.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $TRIAL_ROUTE_DIR/pg_connectivity_detail.after.rpt \
  > $TRIAL_ROUTE_DIR/pg_connectivity.after.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $TRIAL_ROUTE_DIR/pg_drc.after.rpt

save_block
save_lib

exit
