################################################################################
# ICC2 floorplan 1차 스크립트
#
# 목적:
#   init_design에서 저장한 post-DFT design block을 열고,
#   floorplan boundary/core/row/track을 처음 생성합니다.
#
# 공부 포인트:
#   init_design은 "netlist를 물리 DB로 열 수 있나"를 확인합니다.
#   floorplan은 "cell이 배치될 core 면적과 die/core 경계"를 정합니다.
#   아직 power ring/strap, placement, CTS, routing은 하지 않습니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

################################################################################
# init_design 결과 library와 block을 엽니다.
################################################################################

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# 1차 floorplan 기준값입니다.
#
# core_utilization 0.65:
#   standard cell 총 면적이 core 면적의 65% 정도가 되도록 core 크기를 잡습니다.
#   남은 35%는 routing congestion, buffer 추가, physical-only cell 공간입니다.
#
# side_ratio {1 1}:
#   가로:세로 비율을 1:1로 둡니다.
#   CPU core 첫 pass에서는 정사각형이 디버그하기 쉽습니다.
#
# core_offset {20}:
#   die boundary와 core boundary 사이 margin을 20um 둡니다.
#   나중에 power ring/IO pin/route 여유로 씁니다.
################################################################################

set CORE_UTILIZATION 0.65
set CORE_ASPECT_RATIO {1 1}
set CORE_OFFSET_UM 20.0

initialize_floorplan \
  -control_type core \
  -shape R \
  -side_ratio $CORE_ASPECT_RATIO \
  -core_utilization $CORE_UTILIZATION \
  -core_offset $CORE_OFFSET_UM \
  -flip_first_row true

################################################################################
# top-level port pin을 core edge track 위에 자동 배치합니다.
# 아직 pin constraint file은 없으므로 ICC2 기본 규칙으로 1차 배치만 봅니다.
################################################################################

place_pins -self

################################################################################
# floorplan 결과 evidence report입니다.
################################################################################

report_design -physical > $FLOORPLAN_REPORT_DIR/design_physical.rpt
report_utilization > $FLOORPLAN_REPORT_DIR/utilization.rpt
report_qor > $FLOORPLAN_REPORT_DIR/qor.rpt
report_timing -max_paths 10 > $FLOORPLAN_REPORT_DIR/timing.rpt

check_design \
  -checks {netlist design_mismatch timing} \
  -ems_database $FLOORPLAN_REPORT_DIR/check_design.ems \
  -log_file $FLOORPLAN_REPORT_DIR/check_design.rpt

save_block
save_lib

exit
