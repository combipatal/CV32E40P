################################################################################
# ICC2 signal route 1차 스크립트
#
# 목적:
#   CTS가 끝난 design에서 signal net global/detail routing을 수행합니다.
#
# 공부 포인트:
#   route_auto는 signal routing의 기본 명령입니다.
#   clock net은 CTS 단계에서 이미 route_clock으로 라우팅되어 있습니다.
#   route 후에는 DRC/open/short, timing, legality, PG 상태를 다시 봐야 합니다.
#   이 단계는 signoff route가 아니라 first-pass route 가능성 확인입니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

################################################################################
# CTS까지 저장된 block을 엽니다.
################################################################################

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# signal routing입니다.
# check_routability는 routing 전에 congestion/blocked pin 같은 가능성 문제를 봅니다.
# signal route는 M1-M8까지만 사용합니다.
# trial 결과 M9/MRDL을 열어두는 것보다 M8 상한이 warning과 DRC를 조금 줄였습니다.
# route_auto가 global route와 detail route를 수행합니다.
################################################################################

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

catch {report_ignored_layers > $ROUTE_REPORT_DIR/ignored_layers.rpt}

check_routability > $ROUTE_REPORT_DIR/check_routability.rpt

route_auto

################################################################################
# routing 후 evidence report입니다.
################################################################################

check_routes > $ROUTE_REPORT_DIR/check_routes.rpt
report_qor > $ROUTE_REPORT_DIR/qor.rpt
report_timing -delay_type max -max_paths 20 > $ROUTE_REPORT_DIR/timing.max.rpt
report_timing -delay_type min -max_paths 20 > $ROUTE_REPORT_DIR/timing.min.rpt
report_utilization > $ROUTE_REPORT_DIR/utilization.rpt
report_design -physical > $ROUTE_REPORT_DIR/design_physical.rpt
check_legality > $ROUTE_REPORT_DIR/check_legality.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $ROUTE_REPORT_DIR/pg_connectivity_detail.rpt \
  > $ROUTE_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $ROUTE_REPORT_DIR/pg_drc.rpt

save_block
save_lib

exit
