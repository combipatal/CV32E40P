################################################################################
# ICC2 Milkyway reference library trial
#
# 목적:
#   현재 backend는 DB+LEF로 만든 NDM reference library를 씁니다.
#   이 trial은 원본 SAED32 Milkyway reference library를 create_lib -ref_libs에
#   직접 넣었을 때 ICC2가 자동 cell library를 만들고 post-DFT netlist를 link할 수
#   있는지 확인합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME mw_ref_open_trial
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set TRIAL_LIB_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/trials/$TRIAL_NAME/cv32e40p_icc2_lib_mwref
set TRIAL_LOCAL_LIB_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/trials/$TRIAL_NAME/local_cell_libs
set TRIAL_REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/01_mw_ref_open
set MILKYWAY_EXEC $PROJECT_ROOT/7_Backend_ICC2/0_Script/99_util/icc_milkyway_exec_wrapper.sh

file mkdir $PROJECT_ROOT/7_Backend_ICC2/2_Output/trials/$TRIAL_NAME
file mkdir $TRIAL_LOCAL_LIB_DIR
file mkdir $TRIAL_REPORT_DIR

if {[file exists $TRIAL_LIB_DIR]} {
  file delete -force $TRIAL_LIB_DIR
}

################################################################################
# Milkyway physical source를 ref_libs로 직접 넣어 ICC2 자동 변환을 시도합니다.
################################################################################

set_app_options -name lib.configuration.local_output_dir -value $TRIAL_LOCAL_LIB_DIR
set_app_options -name lib.configuration.icc_shell_exec -value $MILKYWAY_EXEC
set_app_options -name lib.setting.milkyway_exec -value $MILKYWAY_EXEC

create_lib $TRIAL_LIB_DIR \
  -technology $TECH_FILE \
  -ref_libs [list $MW_RVT $MW_LVT $MW_HVT]

################################################################################
# 기존 init flow와 같은 TT timing/RC/netlist/SDC를 읽습니다.
################################################################################

read_parasitic_tech \
  -tlup $TLUPLUS_MAX \
  -layermap $TLUPLUS_MAP \
  -name saed32_cmax

read_parasitic_tech \
  -tlup $TLUPLUS_MIN \
  -layermap $TLUPLUS_MAP \
  -name saed32_cmin

read_verilog $POST_DFT_NETLIST
current_design $TOP_NAME
link_block

read_sdc $POST_DFT_SDC

set_parasitic_parameters \
  -early_spec saed32_cmin \
  -early_temperature 25 \
  -late_spec saed32_cmax \
  -late_temperature 25

################################################################################
# NDM-built flow와 비교할 기본 evidence를 남깁니다.
################################################################################

report_ref_libs > $TRIAL_REPORT_DIR/ref_libs.rpt
report_design -physical > $TRIAL_REPORT_DIR/design_physical.rpt
report_design > $TRIAL_REPORT_DIR/design.rpt
report_via_defs -verbose -nosplit -library [current_lib] > $TRIAL_REPORT_DIR/via_defs.current_lib.rpt
report_tracks -significant_digits 4 > $TRIAL_REPORT_DIR/tracks.rpt

check_design \
  -checks {netlist design_mismatch timing} \
  -ems_database $TRIAL_REPORT_DIR/check_design.ems \
  -log_file $TRIAL_REPORT_DIR/check_design.rpt

report_timing -max_paths 5 > $TRIAL_REPORT_DIR/timing.rpt

save_block
save_lib

exit
