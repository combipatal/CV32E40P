################################################################################
# ICC2 M1 track 재생성 후 route trial
#
# 목적:
#   check_routability에서 M1 track을 재생성하면 off-track warning이 사라졌습니다.
#   이 변화가 실제 route DRC도 줄이는지 full route trial로 확인합니다.
#
# 공부 포인트:
#   remove_tracks/create_track은 routing grid를 다시 정의합니다.
#   remove_routes -net_types signal은 PG/clock route는 두고 signal route만 지웁니다.
#   원본 block은 직접 저장하지 않고 trial block으로 복사해서 실험합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME m1_retrack_route_088
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set M1_START 0.088
if {[info exists ::env(M1_START)]} {
  set M1_START $::env(M1_START)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/06_route
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR

################################################################################
# 1. 원본 block을 trial block으로 복사합니다.
################################################################################

open_block -edit $TOP_NAME

set TRIAL_BLOCK ${TOP_NAME}_${TRIAL_NAME}
copy_block \
  -force \
  -from_block $TOP_NAME \
  -to_block $TRIAL_BLOCK

close_blocks -force
open_block -edit $TRIAL_BLOCK

################################################################################
# 2. signal route를 지우고 M1 track을 명시적으로 다시 만듭니다.
################################################################################

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

catch {report_ignored_layers > $REPORT_DIR/ignored_layers.rpt}

check_routes > $REPORT_DIR/check_routes.before_remove.rpt

remove_routes \
  -net_types signal \
  -global_route \
  -detail_route \
  -lib_cell_pin_connect \
  -macro_pin_connect

remove_tracks \
  -layer M1 \
  -force

set M1_PITCH 0.152
set M1_COUNT_X 2151
set M1_COUNT_Y 2144
set M1_WIDTH 0.050

create_track \
  -layer M1 \
  -dir X \
  -coord $M1_START \
  -space $M1_PITCH \
  -count $M1_COUNT_X \
  -width $M1_WIDTH

create_track \
  -layer M1 \
  -dir Y \
  -coord $M1_START \
  -space $M1_PITCH \
  -count $M1_COUNT_Y \
  -width $M1_WIDTH

report_tracks -layer M1 > $REPORT_DIR/tracks.m1.after_recreate.rpt
check_routability > $REPORT_DIR/check_routability.after_recreate.rpt

################################################################################
# 3. signal route를 다시 수행하고 DRC/timing/PG evidence를 저장합니다.
################################################################################

# 일부 환경에서는 route_auto 본 작업이 끝난 뒤 internal hook에서 error가 날 수 있습니다.
# 이 경우에도 check_routes report를 남길 수 있게 catch로 계속 진행합니다.
set route_status [catch {
  route_auto
} route_msg]

set route_fp [open $REPORT_DIR/route_auto.status.rpt w]
puts $route_fp "route_auto status=$route_status"
puts $route_fp $route_msg
close $route_fp

check_routes > $REPORT_DIR/check_routes.after_route.rpt

set ZROUTE_DATA [open_drc_error_data [get_drc_error_data -all zroute.err]]

report_drc_error \
  -error_data $ZROUTE_DATA \
  -report_type matrix \
  > $REPORT_DIR/drc.after_route.matrix.rpt

report_drc_error \
  -error_data $ZROUTE_DATA \
  -report_type error_layer \
  > $REPORT_DIR/drc.after_route.by_layer.rpt

close_drc_error_data $ZROUTE_DATA -force

report_qor > $REPORT_DIR/qor.after_route.rpt
report_timing -delay_type max -max_paths 20 > $REPORT_DIR/timing.max.after_route.rpt
report_timing -delay_type min -max_paths 20 > $REPORT_DIR/timing.min.after_route.rpt
report_utilization > $REPORT_DIR/utilization.after_route.rpt
report_design -physical > $REPORT_DIR/design_physical.after_route.rpt
check_legality > $REPORT_DIR/check_legality.after_route.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.after_route.rpt \
  > $REPORT_DIR/pg_connectivity.after_route.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $REPORT_DIR/pg_drc.after_route.rpt

save_block
save_lib

exit
