################################################################################
# ICC2 placement 1차 스크립트
#
# 목적:
#   power plan 이후 standard cell을 core row 위에 배치하고 legalization을 확인합니다.
#
# 공부 포인트:
#   create_placement는 coarse placement입니다.
#   legalize_placement는 cell을 row/site grid에 맞게 정렬하고 overlap을 줄입니다.
#   stdcell PG connectivity는 cell 위치가 있어야 의미 있게 검사됩니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

################################################################################
# power plan까지 저장된 design block을 엽니다.
################################################################################

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# 1차 배치입니다.
# timing_driven을 켜서 timing 정보를 고려하되, 아직 CTS/route 전 초기 배치입니다.
#
# 현재 DFT 산출물에는 ICC2용 scan DEF가 없습니다.
# scan DEF가 없으면 ICC2 placer가 scan chain reorder 정보를 못 읽고 중단합니다.
# 1차 placement 가능성 확인을 위해 missing scan DEF는 계속 진행하도록 둡니다.
# 나중에 backend 품질을 올릴 때 DC/DFT에서 scan DEF를 만들어 넘기는 것이 정식 방향입니다.
################################################################################

set_app_options -name place.coarse.continue_on_missing_scandef -value true

create_placement \
  -effort medium \
  -timing_driven \
  -congestion

################################################################################
# coarse placement 결과를 legal row/site 위치로 정리합니다.
################################################################################

legalize_placement

################################################################################
# 배치 후 library PG pin과 VDD/VSS net 연결을 다시 명시합니다.
################################################################################

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

################################################################################
# placement 결과 evidence report입니다.
################################################################################

check_legality > $PLACE_REPORT_DIR/check_legality.rpt
report_utilization > $PLACE_REPORT_DIR/utilization.rpt
report_qor > $PLACE_REPORT_DIR/qor.rpt
report_timing -max_paths 20 > $PLACE_REPORT_DIR/timing.rpt
report_design -physical > $PLACE_REPORT_DIR/design_physical.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $PLACE_REPORT_DIR/pg_connectivity_detail.rpt \
  > $PLACE_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $PLACE_REPORT_DIR/pg_drc.rpt

save_block
save_lib

exit
