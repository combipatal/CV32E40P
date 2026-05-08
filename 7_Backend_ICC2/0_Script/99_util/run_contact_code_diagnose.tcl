################################################################################
# ICC2 CO/VIA contact code 진단 스크립트
#
# 목적:
#   check_routability의 ZRT-022 경고를 확인합니다.
#   CO layer는 stdcell 내부 contact/pin shape에 쓰입니다.
#   VIA1은 실제 signal routing에서 M1-M2 연결에 쓰입니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME contact_code_diagnose
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_contact_code
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# 현재 block의 routing track과 via definition을 그대로 기록합니다.
################################################################################

report_tracks -significant_digits 4 > $REPORT_DIR/tracks.all.rpt
report_tracks -layer M1 -significant_digits 4 > $REPORT_DIR/tracks.m1.rpt
report_tracks -layer M2 -significant_digits 4 > $REPORT_DIR/tracks.m2.rpt

report_via_defs -verbose -nosplit > $REPORT_DIR/via_defs.current_block.rpt

foreach_in_collection lib [get_libs *] {
  set lib_name [get_object_name $lib]
  report_via_defs -verbose -nosplit -library $lib > $REPORT_DIR/via_defs.$lib_name.rpt
}

################################################################################
# cut layer별 via_def 존재 여부를 확인합니다.
# CO용 via_def가 없으면 ZRT-022의 직접 원인입니다.
################################################################################

set fp [open $REPORT_DIR/contact_code_summary.rpt w]
puts $fp "ICC2 contact code diagnosis"
puts $fp ""

set via_defs ""
catch {set via_defs [get_via_defs -quiet *]}
puts $fp "container: current_block"
puts $fp "  total_via_defs: [sizeof_collection $via_defs]"
foreach cut_layer {CO VIA1 VIA2 VIA3 VIA4 VIA5 VIA6 VIA7 VIA8} {
  set count 0
  set default_count 0
  set names ""
  foreach_in_collection via_def $via_defs {
    set cut_names [get_attribute -quiet $via_def cut_layer_names]
    if {[lsearch -exact $cut_names $cut_layer] >= 0} {
      incr count
      set via_name [get_object_name $via_def]
      set lower [get_attribute -quiet $via_def lower_layer_name]
      set upper [get_attribute -quiet $via_def upper_layer_name]
      set is_default [get_attribute -quiet $via_def is_default]
      set excluded [get_attribute -quiet $via_def is_excluded_for_signal_route]
      if {$is_default == "true"} {
        incr default_count
      }
      append names "    $via_name lower=$lower upper=$upper default=$is_default excluded_for_signal=$excluded\n"
    }
  }
  puts $fp "  cut_layer: $cut_layer via_def_count=$count default_count=$default_count"
  if {$names != ""} {
    puts -nonewline $fp $names
  }
}
puts $fp ""

foreach_in_collection lib [get_libs *] {
  set lib_name [get_object_name $lib]
  set via_defs ""
  catch {set via_defs [get_via_defs -quiet -library $lib *]}

  puts $fp "container: library $lib_name"
  puts $fp "  total_via_defs: [sizeof_collection $via_defs]"

  foreach cut_layer {CO VIA1 VIA2 VIA3 VIA4 VIA5 VIA6 VIA7 VIA8} {
    set count 0
    set default_count 0
    set names ""

    foreach_in_collection via_def $via_defs {
      set cut_names [get_attribute -quiet $via_def cut_layer_names]
      if {[lsearch -exact $cut_names $cut_layer] >= 0} {
        incr count
        set via_name [get_object_name $via_def]
        set lower [get_attribute -quiet $via_def lower_layer_name]
        set upper [get_attribute -quiet $via_def upper_layer_name]
        set is_default [get_attribute -quiet $via_def is_default]
        set excluded [get_attribute -quiet $via_def is_excluded_for_signal_route]
        if {$is_default == "true"} {
          incr default_count
        }
        append names "    $via_name lower=$lower upper=$upper default=$is_default excluded_for_signal=$excluded\n"
      }
    }

    puts $fp "  cut_layer: $cut_layer via_def_count=$count default_count=$default_count"
    if {$names != ""} {
      puts -nonewline $fp $names
    }
  }
  puts $fp ""
}

################################################################################
# 주요 layer 속성도 함께 남깁니다.
################################################################################

puts $fp "Layer summary"
foreach layer_name {CO VIA1 M1 M2 M1PIN} {
  set layer [get_layers -quiet $layer_name]
  puts $fp "layer: $layer_name"
  puts $fp "  count: [sizeof_collection $layer]"
  if {[sizeof_collection $layer] > 0} {
    foreach attr {layer_number mask_name pitch default_width min_width min_spacing routing_direction} {
      set value ""
      catch {set value [get_attribute -quiet $layer $attr]}
      puts $fp "  $attr: $value"
    }
  }
  puts $fp ""
}

close $fp

################################################################################
# ZRT-022가 이 block에서 재현되는지 같은 자리에서 다시 확인합니다.
################################################################################

check_routability > $REPORT_DIR/check_routability.contact.rpt

exit
