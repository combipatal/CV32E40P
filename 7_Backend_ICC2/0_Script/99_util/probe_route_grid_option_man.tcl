################################################################################
# ICC2 route grid/via app option man-page 추출
#
# 목적:
#   list_of {string string} 옵션 값 형식을 정확히 확인합니다.
#   추측한 Tcl list 값을 route trial에 넣지 않기 위한 probe입니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set PROBE_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options
file mkdir $PROBE_DIR

redirect -file $PROBE_DIR/man_via_on_grid_by_layer_name.rpt {
  man route.common.via_on_grid_by_layer_name
}

redirect -file $PROBE_DIR/man_wire_on_grid_by_layer_name.rpt {
  man route.common.wire_on_grid_by_layer_name
}

redirect -file $PROBE_DIR/man_extra_via_off_grid_cost_multiplier_by_layer_name.rpt {
  man route.common.extra_via_off_grid_cost_multiplier_by_layer_name
}

redirect -file $PROBE_DIR/man_generate_extra_off_grid_pin_tracks.rpt {
  man route.detail.generate_extra_off_grid_pin_tracks
}

exit
