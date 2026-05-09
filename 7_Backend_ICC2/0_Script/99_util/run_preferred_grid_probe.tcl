################################################################################
# ICC2 preferred-grid / routing-track 진단 스크립트
#
# 목적:
#   route.detail.force_end_on_preferred_grid 옵션이 무시되는 이유를 좁힙니다.
#   현재 block에서 routing direction, track, 관련 명령 지원 여부를 기록합니다.
#
# 주의:
#   이 스크립트는 report-only 진단용입니다.
#   block/lib를 저장하지 않습니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME preferred_grid_probe
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_preferred_grid
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

set fp [open $REPORT_DIR/preferred_grid_probe_summary.rpt w]
puts $fp "Preferred grid / routing track probe"
puts $fp ""

puts $fp "Command availability:"
foreach cmd_name {
  set_preferred_routing_direction
  report_preferred_routing_direction
  create_track
  report_tracks
} {
  set matches [info commands $cmd_name]
  puts $fp "  $cmd_name: $matches"
}
puts $fp ""

puts $fp "Layer attributes before any trial command:"
foreach layer_name {M1 M2 M3 M4 M5 M6 M7 M8 M9 MRDL VIA1 VIA2} {
  set layer_obj [get_layers -quiet $layer_name]
  if {[sizeof_collection $layer_obj] == 0} {
    puts $fp "  $layer_name: MISSING"
    continue
  }

  puts $fp "  $layer_name:"
  foreach attr {pitch default_width min_width min_spacing routing_direction preferred_direction direction on_wire_track on_grid} {
    set status [catch {get_attribute $layer_obj $attr} value]
    if {$status == 0} {
      puts $fp "    $attr = $value"
    }
  }
}
puts $fp ""

set status [catch {
  set_preferred_routing_direction \
    -layers {M1 M3 M5 M7 M9} \
    -direction horizontal
  set_preferred_routing_direction \
    -layers {M2 M4 M6 M8 MRDL} \
    -direction vertical
} msg]
puts $fp "set_preferred_routing_direction trial status=$status"
puts $fp $msg
puts $fp ""

puts $fp "Layer attributes after set_preferred_routing_direction trial:"
foreach layer_name {M1 M2 M3 M4 M5 M6 M7 M8 M9 MRDL} {
  set layer_obj [get_layers -quiet $layer_name]
  if {[sizeof_collection $layer_obj] == 0} {
    puts $fp "  $layer_name: MISSING"
    continue
  }

  puts $fp "  $layer_name:"
  foreach attr {routing_direction preferred_direction direction} {
    set status [catch {get_attribute $layer_obj $attr} value]
    if {$status == 0} {
      puts $fp "    $attr = $value"
    }
  }
}
close $fp

catch {report_tracks -significant_digits 4 > $REPORT_DIR/tracks.all.rpt}
catch {report_tracks -layer M1 -significant_digits 4 > $REPORT_DIR/tracks.m1.rpt}
catch {report_tracks -layer M2 -significant_digits 4 > $REPORT_DIR/tracks.m2.rpt}
catch {report_ignored_layers > $REPORT_DIR/ignored_layers.rpt}

close_blocks -force
exit
