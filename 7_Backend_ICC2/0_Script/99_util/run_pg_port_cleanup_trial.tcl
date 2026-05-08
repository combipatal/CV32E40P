################################################################################
# ICC2 PG stale top port cleanup trial
#
# 목적:
#   compile_pg가 만든 실제 boundary PG port는 VDD_1/VSS_1입니다.
#   별도로 남은 VDD/VSS top port는 terminal이 0개라 route에서 no-pin/unplaced 경고를 냅니다.
#   이 trial은 VDD/VSS stale port만 제거하고 PG connectivity가 유지되는지 봅니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME pg_port_cleanup
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_pg_port
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set fp [open $REPORT_DIR/cleanup_summary.rpt w]

puts $fp "Before cleanup"
foreach port_name {VDD VSS VDD_1 VSS_1} {
  set ports [get_ports -quiet $port_name]
  puts $fp "Port $port_name count=[sizeof_collection $ports]"
  if {[sizeof_collection $ports] > 0} {
    set nets [get_attribute $ports net]
    set terms [get_terminals -quiet -of_objects $ports]
    puts $fp "  net=[get_object_name $nets]"
    puts $fp "  direction=[get_attribute $ports direction]"
    puts $fp "  port_type=[get_attribute $ports port_type]"
    puts $fp "  physical_status=[get_attribute $ports physical_status]"
    puts $fp "  terminal_count=[sizeof_collection $terms]"
  }
}
puts $fp ""

set stale_ports [get_ports -quiet {VDD VSS}]
if {[sizeof_collection $stale_ports] > 0} {
  remove_ports -force $stale_ports
}

puts $fp "After cleanup"
foreach port_name {VDD VSS VDD_1 VSS_1} {
  set ports [get_ports -quiet $port_name]
  puts $fp "Port $port_name count=[sizeof_collection $ports]"
  if {[sizeof_collection $ports] > 0} {
    set nets [get_attribute $ports net]
    set terms [get_terminals -quiet -of_objects $ports]
    puts $fp "  net=[get_object_name $nets]"
    puts $fp "  direction=[get_attribute $ports direction]"
    puts $fp "  port_type=[get_attribute $ports port_type]"
    puts $fp "  physical_status=[get_attribute $ports physical_status]"
    puts $fp "  terminal_count=[sizeof_collection $terms]"
  }
}
puts $fp ""
close $fp

report_ports [get_ports -quiet {VDD VSS VDD_1 VSS_1}] > $REPORT_DIR/report_ports.after.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.after.rpt \
  > $REPORT_DIR/pg_connectivity.after.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $REPORT_DIR/pg_drc.after.rpt

check_routes > $REPORT_DIR/check_routes.after_cleanup.rpt

save_block
save_lib

exit
