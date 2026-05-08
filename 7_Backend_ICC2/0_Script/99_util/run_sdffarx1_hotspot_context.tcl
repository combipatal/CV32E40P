################################################################################
# SDFFARX1_RVT hotspot blocked access 주변 ICC2 context 추출
#
# 목적:
#   Python overlap 분석에서 hotspot 안에 들어온 SDFFARX1_RVT blocked access point를
#   ICC2 database에서 다시 열어 cell/pin/주변 shape/PG shape를 확인합니다.
#
# 주의:
#   이 스크립트는 현재 저장된 ICC2 block을 열어 report만 작성합니다.
#   route option trial 이후 block이면 routing shape는 baseline과 조금 다를 수 있습니다.
#   cell placement와 PG mesh 확인용으로 사용합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME sdffarx1_hotspot_context
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set INPUT_FILE $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/sdffarx1_hotspot_overlap/99_overlap/sdffarx1_hotspot_points.tsv
if {[info exists ::env(INPUT_FILE)]} {
  set INPUT_FILE $::env(INPUT_FILE)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_context
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set out [open $REPORT_DIR/sdffarx1_hotspot_context.rpt w]
puts $out "SDFFARX1_RVT hotspot context report"
puts $out "input_file=$INPUT_FILE"
puts $out "note=current saved ICC2 block is used for database context"
puts $out ""

set pin_access_cells [list]
set seen_cell_pin [dict create]

set fp [open $INPUT_FILE r]
set line_no 0
while {[gets $fp line] >= 0} {
  incr line_no
  if {$line_no == 1 || $line eq ""} {
    continue
  }

  set fields [split $line "\t"]
  set cell_name [lindex $fields 0]
  set pin_name [lindex $fields 1]
  set point_x [lindex $fields 2]
  set point_y [lindex $fields 3]
  set nearest_type [lindex $fields 7]
  set nearest_layer [lindex $fields 8]
  set nearest_cx [lindex $fields 9]
  set nearest_cy [lindex $fields 10]
  set distance_um [lindex $fields 13]

  set key "$cell_name|$pin_name"
  dict set seen_cell_pin $key 1

  set cell_filter [format {full_name=="%s"} $cell_name]
  set pin_filter [format {name=="%s"} $pin_name]

  set cell [get_cells -quiet -hierarchical -filter $cell_filter]
  if {[sizeof_collection $cell] == 0} {
    puts $out "Point line $line_no"
    puts $out "  cell not found: $cell_name"
    puts $out ""
    continue
  }

  set pin [get_pins -quiet -of_objects $cell -filter $pin_filter]
  set origin [get_attribute -quiet $cell origin]
  set bbox [get_attribute -quiet $cell bbox]
  set orientation [get_attribute -quiet $cell orientation]
  set ref_name [get_attribute -quiet $cell ref_name]

  puts $out "Point line $line_no"
  puts $out "  cell          : $cell_name"
  puts $out "  ref_name      : $ref_name"
  puts $out "  origin        : $origin"
  puts $out "  orientation   : $orientation"
  puts $out "  cell_bbox     : $bbox"
  puts $out "  pin           : $pin_name"
  puts $out "  blocked_point : $point_x $point_y"
  puts $out "  nearest_drc   : $nearest_type / $nearest_layer at $nearest_cx $nearest_cy, distance=$distance_um um"

  if {[sizeof_collection $pin] > 0} {
    puts $out "  pin_bbox      : [get_attribute -quiet $pin bbox]"
    puts $out "  pin_layer     : [get_attribute -quiet $pin layer_name]"
    set pin_net [get_attribute -quiet $pin net]
    if {[sizeof_collection $pin_net] > 0} {
      puts $out "  pin_net       : [get_object_name $pin_net]"
    }
  } else {
    puts $out "  pin not found in ICC2 database"
  }

  set margin 5.0
  set x1 [expr {$point_x - $margin}]
  set y1 [expr {$point_y - $margin}]
  set x2 [expr {$point_x + $margin}]
  set y2 [expr {$point_y + $margin}]
  set region [list [list $x1 $y1] [list $x2 $y2]]

  puts $out "  search_box    : $region"

  set nearby_cells [get_cells -quiet -hierarchical -intersect $region]
  puts $out "  nearby_cells  : [sizeof_collection $nearby_cells]"
  set cell_count 0
  foreach_in_collection near_cell $nearby_cells {
    incr cell_count
    if {$cell_count > 20} {
      puts $out "    ... cell output truncated ..."
      break
    }
    puts $out "    [get_object_name $near_cell] ref=[get_attribute -quiet $near_cell ref_name] origin=[get_attribute -quiet $near_cell origin]"
  }

  set shapes [get_shapes -quiet -intersect $region]
  puts $out "  nearby_shapes : [sizeof_collection $shapes]"
  set shape_count 0
  set pg_m2_count 0
  foreach_in_collection shape $shapes {
    set layer [get_attribute -quiet $shape layer_name]
    set net_obj [get_attribute -quiet $shape net]
    set net_name ""
    if {[sizeof_collection $net_obj] > 0} {
      set net_name [get_object_name $net_obj]
    }
    if {($net_name eq "VDD" || $net_name eq "VSS") && $layer eq "M2"} {
      incr pg_m2_count
    }

    incr shape_count
    if {$shape_count > 40} {
      continue
    }
    puts $out "    shape [get_object_name $shape] layer=$layer net=$net_name bbox=[get_attribute -quiet $shape bbox]"
  }
  puts $out "  nearby_pg_m2_shapes: $pg_m2_count"
  puts $out ""
}
close $fp

set unique_cells [list]
foreach key [dict keys $seen_cell_pin] {
  set cell_name [lindex [split $key "|"] 0]
  if {[lsearch -exact $unique_cells $cell_name] < 0} {
    lappend unique_cells $cell_name
  }
}

set cell_objs [get_cells -quiet __NO_MATCH_FOR_EMPTY_COLLECTION__]
foreach cell_name $unique_cells {
  set cell_filter [format {full_name=="%s"} $cell_name]
  set one_cell [get_cells -quiet -hierarchical -filter $cell_filter]
  if {[sizeof_collection $one_cell] > 0} {
    set cell_objs [add_to_collection $cell_objs $one_cell]
  }
}
puts $out "Unique hotspot SDFFARX1_RVT cells: [llength $unique_cells]"
foreach cell_name $unique_cells {
  puts $out "  $cell_name"
}
puts $out ""
close $out

set status_fp [open $REPORT_DIR/report_cell_pin_access.status.rpt w]
puts $status_fp "report_cell_pin_access for unique hotspot SDFFARX1_RVT cells"
puts $status_fp "unique_cell_count=[llength $unique_cells]"
set status [catch {
  report_cell_pin_access \
    -cells $cell_objs \
    -details \
    > $REPORT_DIR/report_cell_pin_access.hotspot_sdffarx1.details.rpt
} msg]
puts $status_fp "status=$status"
puts $status_fp $msg
close $status_fp

exit
