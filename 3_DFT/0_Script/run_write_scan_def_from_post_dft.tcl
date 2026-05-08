################################################################################
# post-DFT DDC에서 ICC2용 scan DEF만 다시 쓰는 스크립트
#
# 목적:
#   기존 DFT run을 다시 하지 않고, 저장된 post-DFT DDC에 들어 있는 scan chain
#   정보를 DEF SCANCHAINS section으로 출력합니다.
#
# 공부 포인트:
#   SPF는 ATPG용 test protocol이고, scan DEF는 physical placer가 scan chain
#   ordering/reorder 정보를 읽기 위한 backend handoff입니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

source configs/library_setup.tcl

set TOP_NAME cv32e40p_synth_wrap
set POST_DFT_DDC 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.ddc
set POST_DFT_DIR 3_DFT/2_Output/post_dft_topo
set REPORT_DIR 3_DFT/4_Report/topo

file mkdir $POST_DFT_DIR
file mkdir $REPORT_DIR

define_design_lib WORK -path 3_DFT/work_scan_def

read_ddc $POST_DFT_DDC
current_design $TOP_NAME
link

current_test_mode Internal_scan

report_scan_path -view existing_dft > $REPORT_DIR/scan_path.existing.scan_def_source.rpt

write_scan_def \
  -version 5.8 \
  -output $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.scan.def

exit
