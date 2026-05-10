################################################################################
# maxcap_eco4 route DRC 상세 확인
#
# 목적:
#   check_routes가 보고한 Short 3개의 layer/bbox/net 정보를 뽑습니다.
#   수정 전에 원인을 먼저 확인하기 위한 probe입니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set BLOCK_NAME ${TOP_NAME}_maxcap_eco4_occupied_site
set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/07_extract_sta/maxcap_eco4_occupied_site
set ERR_FILE $ICC2_LIB_DIR/$BLOCK_NAME/attach/design.errdm/zroute.err

open_lib $ICC2_LIB_DIR
open_block $BLOCK_NAME

# 최신 route DRC를 다시 계산해서 error DB를 갱신합니다.
check_routes > $REPORT_DIR/check_routes.probe_drc_detail.rpt

# error DB에서 Short violation을 상세 출력합니다.
set DRC_DATA [open_drc_error_data -file_name $ERR_FILE]
set SHORT_TYPES [get_drc_error_types -error_data $DRC_DATA {Short}]
report_drc_error -error_data $DRC_DATA -error_type $SHORT_TYPES -report_type detailed -nosplit > $REPORT_DIR/route_drc_short_detail.rpt
report_drc_error -error_data $DRC_DATA -error_type $SHORT_TYPES -report_type matrix -nosplit > $REPORT_DIR/route_drc_short_matrix.rpt

exit
