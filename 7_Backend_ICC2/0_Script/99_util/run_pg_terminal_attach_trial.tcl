################################################################################
# ICC2 PG top terminal attach trial
#
# 목적:
#   save/reopen 뒤 VDD/VSS top port가 다시 생기면 삭제 방식은 유지되지 않습니다.
#   대신 VDD/VSS port에 작은 M8 terminal을 만들어 no-pin/unplaced 경고를 제거합니다.
#
# 기준:
#   좌표는 VDD/VSS M8 ring shape 안쪽을 사용합니다.
#   기존 VDD_1/VSS_1 boundary terminal과 겹치지 않도록 y=3..5um 위치를 씁니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME pg_terminal_attach
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME/99_pg_port
file mkdir $REPORT_DIR

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

set fp [open $REPORT_DIR/terminal_attach_summary.rpt w]

puts $fp "Before terminal attach"
foreach port_name {VDD VSS VDD_1 VSS_1} {
  set ports [get_ports -quiet $port_name]
  set terms [get_terminals -quiet -of_objects $ports]
  puts $fp "Port $port_name count=[sizeof_collection $ports] terminal_count=[sizeof_collection $terms]"
}
puts $fp ""

set vdd_ports [get_ports -quiet VDD]
if {[sizeof_collection $vdd_ports] > 0} {
  set vdd_terms [get_terminals -quiet -of_objects $vdd_ports]
  if {[sizeof_collection $vdd_terms] == 0} {
    create_terminal \
      -port $vdd_ports \
      -boundary {{13.0000 3.0000} {15.0000 5.0000}} \
      -layer M8 \
      -direction all \
      -name VDD_top_terminal
  }
}

set vss_ports [get_ports -quiet VSS]
if {[sizeof_collection $vss_ports] > 0} {
  set vss_terms [get_terminals -quiet -of_objects $vss_ports]
  if {[sizeof_collection $vss_terms] == 0} {
    create_terminal \
      -port $vss_ports \
      -boundary {{10.0000 3.0000} {12.0000 5.0000}} \
      -layer M8 \
      -direction all \
      -name VSS_top_terminal
  }
}

puts $fp "After terminal attach"
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
