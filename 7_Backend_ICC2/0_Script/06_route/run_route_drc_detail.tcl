################################################################################
# ICC2 route DRC 상세 분해 스크립트
#
# 목적:
#   check_routes 요약만으로는 DRC가 어느 layer에 몰리는지 알기 어렵습니다.
#   이 스크립트는 ICC2 zroute.err marker data를 열어서 type/layer/location report를 만듭니다.
#
# 결과 해석:
#   matrix report  : DRC type x layer 표입니다. 가장 먼저 볼 report입니다.
#   error_layer    : layer별 DRC type 집계입니다.
#   detailed       : 각 DRC marker의 bbox와 설명입니다. GUI 확인 좌표로 씁니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set DRC_DETAIL_DIR $ROUTE_REPORT_DIR/drc_detail
if {[info exists ::env(DRC_DETAIL_DIR)]} {
  set DRC_DETAIL_DIR $::env(DRC_DETAIL_DIR)
}
file mkdir $DRC_DETAIL_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# 현재 block 상태에서 route DRC를 다시 확인합니다.
# check_routes 실행 후 ICC2가 zroute.err DRC marker data를 갱신합니다.
################################################################################

check_routes > $DRC_DETAIL_DIR/check_routes.detail_source.rpt

set ZROUTE_DATA [get_drc_error_data -all zroute.err]
if {[sizeof_collection $ZROUTE_DATA] == 0} {
  puts "ERROR: zroute.err DRC data를 찾지 못했습니다."
  exit 1
}

set ZROUTE_DATA [open_drc_error_data $ZROUTE_DATA]

################################################################################
# DRC를 type/layer/상세 좌표로 나누어 저장합니다.
################################################################################

report_drc_error \
  -error_data $ZROUTE_DATA \
  -report_type matrix \
  > $DRC_DETAIL_DIR/drc.matrix.rpt

report_drc_error \
  -error_data $ZROUTE_DATA \
  -report_type error_layer \
  > $DRC_DETAIL_DIR/drc.by_layer.rpt

report_drc_error \
  -error_data $ZROUTE_DATA \
  -report_type error_type \
  > $DRC_DETAIL_DIR/drc.by_type.rpt

report_drc_error \
  -error_data $ZROUTE_DATA \
  -report_type detailed \
  -nosplit \
  > $DRC_DETAIL_DIR/drc.detailed.rpt

write_drc_error_data \
  -error_data $ZROUTE_DATA \
  -file_name $DRC_DETAIL_DIR/zroute.err \
  -overwrite

# zroute.err는 block에 attached된 error data입니다.
# report 추출 후에는 pending marker 변경을 버리고 닫아도 됩니다.
close_drc_error_data $ZROUTE_DATA -force

save_block
save_lib

exit
