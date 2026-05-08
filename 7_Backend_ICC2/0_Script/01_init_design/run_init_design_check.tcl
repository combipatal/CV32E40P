################################################################################
# ICC2 init-design sanity check
#
# 목적:
#   post-DFT netlist를 ICC2 physical design library로 열 수 있는지 확인합니다.
#   아직 실제 floorplan을 만드는 단계는 아닙니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

################################################################################
# ICC2 design library를 만듭니다.
# ref_libs에는 DB+LEF로 만든 NDM reference library를 연결합니다.
################################################################################

if {[file exists $ICC2_LIB_DIR]} {
  file delete -force $ICC2_LIB_DIR
}

create_lib $ICC2_LIB_DIR \
  -technology $TECH_FILE \
  -ref_libs [list $NDM_RVT $NDM_LVT $NDM_HVT]

################################################################################
# TLU+ RC tech를 ICC2 library에 읽습니다.
# placement/timing estimate에서 layer RC가 필요합니다.
################################################################################

read_parasitic_tech \
  -tlup $TLUPLUS_MAX \
  -layermap $TLUPLUS_MAP \
  -name saed32_cmax

read_parasitic_tech \
  -tlup $TLUPLUS_MIN \
  -layermap $TLUPLUS_MAP \
  -name saed32_cmin

################################################################################
# post-DFT netlist를 읽고 link합니다.
# 여기서 unresolved cell이 나오면 backend 진행 전에 library 문제가 있는 것입니다.
################################################################################

read_verilog $POST_DFT_NETLIST
current_design $TOP_NAME
link_block

################################################################################
# Front-End SDC를 읽습니다.
# backend 초기 check에서는 같은 10 ns functional mode를 유지합니다.
################################################################################

read_sdc $POST_DFT_SDC

################################################################################
# default corner에 min/max parasitic model을 연결합니다.
# TT 1.05V 25C timing library를 쓰되, RC는 Cmin/Cmax로 early/late를 잡습니다.
################################################################################

set_parasitic_parameters \
  -early_spec saed32_cmin \
  -early_temperature 25 \
  -late_spec saed32_cmax \
  -late_temperature 25

################################################################################
# 기본 check와 evidence report를 남깁니다.
################################################################################

report_ref_libs > $INIT_REPORT_DIR/ref_libs.rpt
report_parasitic_parameters > $INIT_REPORT_DIR/parasitic_parameters.rpt
report_design -physical > $INIT_REPORT_DIR/design_physical.rpt
report_design > $INIT_REPORT_DIR/design.rpt

# ICC2의 check_design은 -checks를 명시해야 합니다.
# floorplan 전 단계이므로 netlist/link/timing 중심의 초기 check만 수행합니다.
check_design \
  -checks {netlist design_mismatch timing} \
  -ems_database $INIT_REPORT_DIR/check_design.ems \
  -log_file $INIT_REPORT_DIR/check_design.rpt

report_timing -max_paths 10 > $INIT_REPORT_DIR/timing.rpt

save_block
save_lib

exit
