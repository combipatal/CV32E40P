################################################################################
# ICC2 route grid/via option 값 후보 검증
#
# 목적:
#   route.common.via_on_grid_by_layer_name 값 형식은 man page로 확인했습니다.
#   하지만 VIA1 이름은 현재 ICC2에서 invalid였습니다.
#   실제 허용되는 layer 이름 후보를 route trial 전에 작은 probe로 확인합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set PROBE_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options
file mkdir $PROBE_DIR

set PROBE_LIB_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/route_grid_option_probe/99_options/probe_icc2_lib

if {[file exists $PROBE_LIB_DIR]} {
  file delete -force $PROBE_LIB_DIR
}

create_lib $PROBE_LIB_DIR \
  -technology $TECH_FILE \
  -ref_libs [list $NDM_RVT $NDM_LVT $NDM_HVT]

read_verilog $POST_DFT_NETLIST
current_design $TOP_NAME
link_block

set fp [open $PROBE_DIR/route_grid_option_value_probe.rpt w]

puts $fp "via_on_grid_by_layer_name value probe"
puts $fp ""

set via_candidates {
  {{VIA1 true}}
  {VIA1 true}
  {{V1 true}}
  {V1 true}
  {{VIA12 true}}
  {VIA12 true}
  {{VIA12SQ_C true}}
  {VIA12SQ_C true}
  {{M1 true}}
  {M1 true}
  {{M2 true}}
  {M2 true}
}

foreach value $via_candidates {
  set status [catch {
    set_app_options \
      -name route.common.via_on_grid_by_layer_name \
      -value $value
  } msg]
  if {$status == 0} {
    puts $fp "PASS via_on_grid_by_layer_name $value -> $msg"
  } else {
    puts $fp "FAIL via_on_grid_by_layer_name $value -> $msg"
  }
}

puts $fp ""
puts $fp "wire_on_grid_by_layer_name value probe"
puts $fp ""

set wire_candidates {
  {{M1 true}}
  {M1 true}
  {{M2 true}}
  {M2 true}
  {{metal1 true}}
  {metal1 true}
  {{metal2 true}}
  {metal2 true}
}

foreach value $wire_candidates {
  set status [catch {
    set_app_options \
      -name route.common.wire_on_grid_by_layer_name \
      -value $value
  } msg]
  if {$status == 0} {
    puts $fp "PASS wire_on_grid_by_layer_name $value -> $msg"
  } else {
    puts $fp "FAIL wire_on_grid_by_layer_name $value -> $msg"
  }
}

puts $fp ""
puts $fp "extra_via_off_grid_cost_multiplier_by_layer_name value probe"
puts $fp ""

set cost_candidates {
  {{VIA1 0.5}}
  {VIA1 0.5}
  {{V1 0.5}}
  {V1 0.5}
  {{VIA12 0.5}}
  {VIA12 0.5}
  {{M1 0.5}}
  {M1 0.5}
  {{M2 0.5}}
  {M2 0.5}
}

foreach value $cost_candidates {
  set status [catch {
    set_app_options \
      -name route.common.extra_via_off_grid_cost_multiplier_by_layer_name \
      -value $value
  } msg]
  if {$status == 0} {
    puts $fp "PASS extra_via_off_grid_cost_multiplier_by_layer_name $value -> $msg"
  } else {
    puts $fp "FAIL extra_via_off_grid_cost_multiplier_by_layer_name $value -> $msg"
  }
}

close $fp

exit
