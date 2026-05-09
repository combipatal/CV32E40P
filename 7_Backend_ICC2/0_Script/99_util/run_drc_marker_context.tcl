################################################################################
# DRC marker 주변 객체 확인 스크립트
#
# 목적:
#   detailed DRC report에서 고른 대표 marker 좌표 주변의 cell, pin, shape를 봅니다.
#   route DRC가 stdcell pin 근처인지, PG shape 근처인지, signal route끼리인지 구분합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME drc_marker_context
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_marker_context
set MARKER_FILE $REPORT_DIR/representative_drc_markers.tsv

if {[info exists ::env(REPORT_DIR)]} {
  set REPORT_DIR $::env(REPORT_DIR)
}

if {[info exists ::env(MARKER_FILE)]} {
  set MARKER_FILE $::env(MARKER_FILE)
}

file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set fp [open $MARKER_FILE r]
set out [open $REPORT_DIR/marker_context.rpt w]

puts $out "DRC marker context report"
puts $out "marker_file=$MARKER_FILE"
puts $out ""

set line_no 0
set has_tag_column 1
while {[gets $fp line] >= 0} {
  incr line_no
  if {$line_no == 1} {
    set header_fields [split $line "\t"]
    if {[lindex $header_fields 0] ne "tag"} {
      set has_tag_column 0
    }
    continue
  }
  if {$line eq ""} {
    continue
  }

  set fields [split $line "\t"]
  if {$has_tag_column} {
    set tag [lindex $fields 0]
    set error_id [lindex $fields 1]
    set error_type [lindex $fields 2]
    set error_layer [lindex $fields 3]
    set cx [lindex $fields 4]
    set cy [lindex $fields 5]
    set x1 [lindex $fields 7]
    set y1 [lindex $fields 8]
    set x2 [lindex $fields 9]
    set y2 [lindex $fields 10]
  } else {
    set error_id [lindex $fields 0]
    set error_type [lindex $fields 1]
    set error_layer [lindex $fields 2]
    set cx [lindex $fields 3]
    set cy [lindex $fields 4]
    set x1 [lindex $fields 6]
    set y1 [lindex $fields 7]
    set x2 [lindex $fields 8]
    set y2 [lindex $fields 9]
    set tag "all_${error_id}"
  }

  set margin 0.25
  set llx [expr {$x1 - $margin}]
  set lly [expr {$y1 - $margin}]
  set urx [expr {$x2 + $margin}]
  set ury [expr {$y2 + $margin}]
  set region [list [list $llx $lly] [list $urx $ury]]

  puts $out "Marker $tag"
  puts $out "  error_id    : $error_id"
  puts $out "  error_type  : $error_type"
  puts $out "  error_layer : $error_layer"
  puts $out "  center      : $cx $cy"
  puts $out "  bbox        : [list [list $x1 $y1] [list $x2 $y2]]"
  puts $out "  search_box  : $region"

  set pins [get_pins -quiet -hierarchical -intersect $region]
  if {[sizeof_collection $pins] == 0} {
    set pins [get_pins -quiet -intersect $region]
  }
  puts $out "  pins        : [sizeof_collection $pins]"
  foreach_in_collection pin $pins {
    set pin_name [get_object_name $pin]
    set pin_bbox [get_attribute -quiet $pin bbox]
    set pin_layer [get_attribute -quiet $pin layer_name]
    set pin_net [get_attribute -quiet $pin net]
    set net_name ""
    if {[sizeof_collection $pin_net] > 0} {
      set net_name [get_object_name $pin_net]
    }

    set parent_cell [get_cells -quiet -of_objects $pin]
    set cell_name ""
    set ref_name ""
    set origin ""
    if {[sizeof_collection $parent_cell] > 0} {
      set cell_name [get_object_name $parent_cell]
      set ref_name [get_attribute -quiet $parent_cell ref_name]
      set origin [get_attribute -quiet $parent_cell origin]
    }

    puts $out "    pin $pin_name"
    puts $out "      bbox     : $pin_bbox"
    puts $out "      layer    : $pin_layer"
    puts $out "      net      : $net_name"
    puts $out "      cell     : $cell_name"
    puts $out "      ref_name : $ref_name"
    puts $out "      origin   : $origin"
  }

  set cells [get_cells -quiet -hierarchical -intersect $region]
  puts $out "  cells       : [sizeof_collection $cells]"
  foreach_in_collection cell $cells {
    puts $out "    cell [get_object_name $cell] ref=[get_attribute -quiet $cell ref_name] origin=[get_attribute -quiet $cell origin]"
  }

  set shapes [get_shapes -quiet -intersect $region]
  puts $out "  shapes      : [sizeof_collection $shapes]"
  set shape_idx 0
  foreach_in_collection shape $shapes {
    incr shape_idx
    if {$shape_idx > 20} {
      puts $out "    ... shape output truncated ..."
      break
    }

    set shape_layer [get_attribute -quiet $shape layer_name]
    set shape_bbox [get_attribute -quiet $shape bbox]
    set shape_net [get_attribute -quiet $shape net]
    set shape_net_name ""
    if {[sizeof_collection $shape_net] > 0} {
      set shape_net_name [get_object_name $shape_net]
    }

    puts $out "    shape [get_object_name $shape]"
    puts $out "      layer : $shape_layer"
    puts $out "      bbox  : $shape_bbox"
    puts $out "      net   : $shape_net_name"
  }

  puts $out ""
}

close $fp
close $out

exit
