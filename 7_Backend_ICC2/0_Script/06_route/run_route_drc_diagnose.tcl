################################################################################
# ICC2 route DRC 원인 확인 스크립트
#
# 목적:
#   route_auto 후 남은 DRC가 어떤 상태인지 재확인합니다.
#   check_routability는 routing 가능성, congestion, pin 접근성 문제를 보는 용도입니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

check_routability > $ROUTE_REPORT_DIR/check_routability.post_route.rpt
check_routes > $ROUTE_REPORT_DIR/check_routes.fresh.rpt
report_utilization > $ROUTE_REPORT_DIR/utilization.fresh.rpt
report_qor > $ROUTE_REPORT_DIR/qor.fresh.rpt

save_block
save_lib

exit
