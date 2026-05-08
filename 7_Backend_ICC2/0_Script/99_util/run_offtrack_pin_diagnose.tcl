################################################################################
# ICC2 off-track M1 pin 진단 스크립트
#
# 목적:
#   check_routability가 좌표만 보여주는 off-track M1 pin을
#   실제 pin/cell/net 이름으로 추적합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME offtrack_pin_diagnose
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_route_access
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# router verbose를 올리면 check_routability가 non-physical internal pin도 더 말해줍니다.
################################################################################

set_app_options -name route.common.verbose_level -value 1

check_routability > $REPORT_DIR/check_routability.verbose.rpt

set fp [open $REPORT_DIR/offtrack_pin_objects.rpt w]

puts $fp "Off-track M1 pin object diagnosis"
puts $fp ""

set OFFTRACK_REGIONS {
  {{271.9750 48.5780} {272.2230 48.6280}}
  {{271.9750 61.9540} {272.2230 62.0040}}
  {{138.2150 171.9480} {138.4630 171.9980}}
  {{128.3210 196.2200} {129.5720 196.2700}}
  {{271.9750 232.4980} {272.2230 232.5480}}
  {{271.9750 248.8600} {272.2230 248.9100}}
  {{129.0100 285.7100} {129.4050 285.7600}}
  {{262.6890 288.4820} {263.9400 288.5320}}
}

set idx 0
foreach region $OFFTRACK_REGIONS {
  incr idx

  set ll [lindex $region 0]
  set ur [lindex $region 1]
  set llx [expr {[lindex $ll 0] - 0.05}]
  set lly [expr {[lindex $ll 1] - 0.05}]
  set urx [expr {[lindex $ur 0] + 0.05}]
  set ury [expr {[lindex $ur 1] + 0.05}]
  set expanded_region [list [list $llx $lly] [list $urx $ury]]

  puts $fp "Region $idx"
  puts $fp "  warning_region  : $region"
  puts $fp "  expanded_region : $expanded_region"

  # physical_context와 intersect는 같이 쓸 수 없어서 계층 pin 기준으로 좌표 검색합니다.
  set pins [get_pins -quiet -hierarchical -intersect $expanded_region]
  if {[sizeof_collection $pins] == 0} {
    set pins [get_pins -quiet -intersect $expanded_region]
  }
  puts $fp "  pin_count       : [sizeof_collection $pins]"

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

    puts $fp "  pin             : $pin_name"
    puts $fp "    bbox          : $pin_bbox"
    puts $fp "    layer         : $pin_layer"
    puts $fp "    net           : $net_name"
    puts $fp "    cell          : $cell_name"
    puts $fp "    ref_name      : $ref_name"
    puts $fp "    cell_origin   : $origin"

    set pin_shapes [get_shapes -quiet -of_objects $pin]
    puts $fp "    pin_shape_count: [sizeof_collection $pin_shapes]"
    foreach_in_collection shape $pin_shapes {
      puts $fp "      shape [get_object_name $shape] layer=[get_attribute -quiet $shape layer_name] bbox=[get_attribute -quiet $shape bbox]"
    }
  }

  puts $fp ""
}

close $fp

exit
