################################################################################
# ICC2 PG top terminal reassign trial
#
# 목적:
#   VDD/VSS port에 새 terminal을 만들면 기존 VDD_1/VSS_1 terminal과 겹쳐
#   duplicate pin shape 경고가 생길 수 있습니다.
#   이 trial은 기존 VDD_1_0/VSS_1_0 terminal의 port owner만 VDD/VSS로 옮깁니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME pg_terminal_reassign
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_pg_port
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set fp [open $REPORT_DIR/terminal_reassign_summary.rpt w]

puts $fp "Before terminal reassign"
foreach port_name {VDD VSS VDD_1 VSS_1} {
  set ports [get_ports -quiet $port_name]
  set terms [get_terminals -quiet -of_objects $ports]
  puts $fp "Port $port_name count=[sizeof_collection $ports] terminal_count=[sizeof_collection $terms]"
}
puts $fp ""

set old_vdd_terms [get_terminals -quiet VDD_top_terminal]
if {[sizeof_collection $old_vdd_terms] > 0} {
  remove_terminals -force $old_vdd_terms
}

set old_vss_terms [get_terminals -quiet VSS_top_terminal]
if {[sizeof_collection $old_vss_terms] > 0} {
  remove_terminals -force $old_vss_terms
}

set vdd_ports [get_ports -quiet VDD]
set vdd_terms [get_terminals -quiet -of_objects $vdd_ports]
if {[sizeof_collection $vdd_ports] > 0 && [sizeof_collection $vdd_terms] == 0} {
  set_attribute [get_terminals VDD_1_0] port $vdd_ports
}

set vss_ports [get_ports -quiet VSS]
set vss_terms [get_terminals -quiet -of_objects $vss_ports]
if {[sizeof_collection $vss_ports] > 0 && [sizeof_collection $vss_terms] == 0} {
  set_attribute [get_terminals VSS_1_0] port $vss_ports
}

puts $fp "After terminal reassign"
foreach port_name {VDD VSS VDD_1 VSS_1} {
  set ports [get_ports -quiet $port_name]
  set terms [get_terminals -quiet -of_objects $ports]
  puts $fp "Port $port_name count=[sizeof_collection $ports] terminal_count=[sizeof_collection $terms]"
}
close $fp

report_ports [get_ports -quiet {VDD VSS VDD_1 VSS_1}] > $REPORT_DIR/report_ports.after.rpt
check_routability > $REPORT_DIR/check_routability.after.rpt
check_routes > $REPORT_DIR/check_routes.after.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $REPORT_DIR/pg_connectivity_detail.after.rpt \
  > $REPORT_DIR/pg_connectivity.after.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $REPORT_DIR/pg_drc.after.rpt

save_block
save_lib

exit
