################################################################################
# ICC2 PG top port 진단 스크립트
#
# 목적:
#   route log의 VDD/VSS top port no-pin/unplaced 경고가 실제로 어떤 상태인지
#   port, terminal, PG shape 수로 확인합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME pg_port_diagnose
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_pg_port
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set REPORT_FILE $REPORT_DIR/pg_port_summary.rpt
set fp [open $REPORT_FILE w]

puts $fp "PG top port diagnosis"
puts $fp ""

foreach net_name {VDD VSS} {
  set ports [get_ports -quiet $net_name]
  set nets [get_nets -quiet $net_name]
  set terms [get_terminals -quiet -of_objects $ports]
  set shapes [get_shapes -quiet -of_objects $nets]
  set vias [get_vias -quiet -of_objects $nets]

  puts $fp "Net: $net_name"
  puts $fp "  port_count     : [sizeof_collection $ports]"
  puts $fp "  terminal_count : [sizeof_collection $terms]"
  puts $fp "  shape_count    : [sizeof_collection $shapes]"
  puts $fp "  via_count      : [sizeof_collection $vias]"

  if {[sizeof_collection $ports] > 0} {
    puts $fp "  port_names:"
    foreach_in_collection port $ports {
      puts $fp "    [get_object_name $port]"
    }
  }

  if {[sizeof_collection $terms] > 0} {
    puts $fp "  terminals:"
    foreach_in_collection term $terms {
      puts $fp "    [get_object_name $term]"
    }
  }

  puts $fp ""
}

puts $fp "All top-level terminals"
set all_terms [get_terminals -quiet *]
puts $fp "  total_terminal_count: [sizeof_collection $all_terms]"
foreach_in_collection term $all_terms {
  set term_name [get_object_name $term]
  set term_layer [get_attribute -quiet $term layer_name]
  set term_bbox [get_attribute -quiet $term bbox]
  set term_port [get_attribute -quiet $term port]
  set port_name ""
  if {[sizeof_collection $term_port] > 0} {
    set port_name [get_object_name $term_port]
  }
  puts $fp "  $term_name port=$port_name layer=$term_layer bbox=$term_bbox"
}
puts $fp ""

close $fp

report_ports [get_ports -quiet {VDD VSS}] > $REPORT_DIR/report_ports.vdd_vss.rpt
check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.rpt \
  > $REPORT_DIR/pg_connectivity.rpt

exit
