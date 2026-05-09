################################################################################
# ICC2 NDM build command help probe
#
# 목적:
#   현재 SAED32 NDM은 create_workspace/read_db/read_lef/commit_workspace로 만듭니다.
#   남은 route DRC가 NDM pin-access/grid setup과 관련 있어 보이므로,
#   NDM 생성 명령에 관련 option이 있는지 help를 report로 남깁니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME ndm_build_help_probe
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_help
file mkdir $REPORT_DIR

redirect -file $REPORT_DIR/create_workspace.help.rpt {help -verbose create_workspace}
redirect -file $REPORT_DIR/read_lef.help.rpt {help -verbose read_lef}
redirect -file $REPORT_DIR/check_workspace.help.rpt {help -verbose check_workspace}
redirect -file $REPORT_DIR/commit_workspace.help.rpt {help -verbose commit_workspace}
redirect -file $REPORT_DIR/configure_frame_options.help.rpt {help -verbose configure_frame_options}
redirect -file $REPORT_DIR/set_attribute.help.rpt {help -verbose set_attribute}

exit
