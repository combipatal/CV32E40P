################################################################################
# Hotspot 주변 PG shape 추출 스크립트
#
# 목적:
#   route DRC hotspot 안에 있는 VDD/VSS PG shape를 TSV로 저장합니다.
#   이후 DRC marker와 PG stripe 거리 통계를 계산해 PG 간섭 가설을 봅니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME root_cause_probe
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set HOTSPOT_BOUNDARY {{215.0 195.0} {265.0 265.0}}
if {[info exists ::env(HOTSPOT_BOUNDARY)]} {
  set HOTSPOT_BOUNDARY $::env(HOTSPOT_BOUNDARY)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_pg_distance
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set out [open $REPORT_DIR/hotspot_pg_shapes.tsv w]
puts $out "shape_name\tnet\tlayer\tx1\ty1\tx2\ty2"

set shapes [get_shapes -quiet -intersect $HOTSPOT_BOUNDARY]
foreach_in_collection shape $shapes {
  set layer [get_attribute -quiet $shape layer_name]
  set net_obj [get_attribute -quiet $shape net]
  set net_name ""
  if {[sizeof_collection $net_obj] > 0} {
    set net_name [get_object_name $net_obj]
  }

  if {$net_name ne "VDD" && $net_name ne "VSS"} {
    continue
  }

  set bbox [get_attribute -quiet $shape bbox]
  set ll [lindex $bbox 0]
  set ur [lindex $bbox 1]
  set x1 [lindex $ll 0]
  set y1 [lindex $ll 1]
  set x2 [lindex $ur 0]
  set y2 [lindex $ur 1]

  puts $out "[get_object_name $shape]\t$net_name\t$layer\t$x1\t$y1\t$x2\t$y2"
}

close $out

set summary [open $REPORT_DIR/hotspot_pg_shape_probe_summary.rpt w]
puts $summary "hotspot_boundary: $HOTSPOT_BOUNDARY"
puts $summary "shape_count_intersect_all: [sizeof_collection $shapes]"
puts $summary "output: $REPORT_DIR/hotspot_pg_shapes.tsv"
close $summary

exit
