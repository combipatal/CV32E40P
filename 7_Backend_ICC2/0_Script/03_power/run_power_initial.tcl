################################################################################
# ICC2 power plan 1차 스크립트
#
# 목적:
#   floorplan block에 VDD/VSS power network를 처음 생성합니다.
#
# 공부 포인트:
#   ring은 core 주변의 굵은 전원 배선입니다.
#   mesh는 core 내부를 지나가며 ring과 rail을 이어주는 전원 strap입니다.
#   standard cell rail은 cell row를 따라 흐르는 얇은 VDD/VSS rail입니다.
#   compile_pg는 pattern/strategy로 정의한 전원망을 실제 shape/via로 만듭니다.
#   여기서는 macro가 없으므로 macro power connection은 아직 없습니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

################################################################################
# floorplan까지 저장된 design block을 엽니다.
################################################################################

open_lib $ICC2_LIB_DIR
open_block -edit $TOP_NAME

################################################################################
# VDD/VSS PG net을 만듭니다.
# post-DFT netlist에는 top-level power port가 없으므로 ICC2에서 PG net을 만듭니다.
################################################################################

if {[sizeof_collection [get_nets -quiet VDD]] == 0} {
  create_net -power VDD
}

if {[sizeof_collection [get_nets -quiet VSS]] == 0} {
  create_net -ground VSS
}

################################################################################
# 재실행을 위한 cleanup입니다.
# 이미 만들어진 VDD/VSS PG shape/via와 PG rule을 지우고 다시 만듭니다.
# net 자체는 유지합니다.
################################################################################

set PG_NETS [get_nets -quiet {VDD VSS}]

set OLD_PG_VIAS [get_vias -quiet -of_objects $PG_NETS]
if {[sizeof_collection $OLD_PG_VIAS] > 0} {
  remove_objects -force $OLD_PG_VIAS
}

set OLD_PG_SHAPES [get_shapes -quiet -of_objects $PG_NETS]
if {[sizeof_collection $OLD_PG_SHAPES] > 0} {
  remove_objects -force $OLD_PG_SHAPES
}

catch {remove_pg_strategy_via_rules -all}
catch {remove_pg_strategies -all}
catch {remove_pg_patterns -all}

################################################################################
# library cell의 power/ground pin을 VDD/VSS net에 연결합니다.
# non-UPF single-voltage design이므로 manual mode로 명시합니다.
################################################################################

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

################################################################################
# standard cell row rail pattern입니다.
# M1 rail은 standard cell power pin과 직접 맞닿는 기본 전원 rail입니다.
################################################################################

create_pg_std_cell_conn_pattern stdcell_rail_pattern \
  -layers {M1}

set_pg_strategy stdcell_rail_strategy \
  -core \
  -pattern {{name: stdcell_rail_pattern}{nets: {VDD VSS}}}

################################################################################
# core ring pattern입니다.
# M7/M8을 사용해 core 주변에 비교적 굵은 VDD/VSS ring을 만듭니다.
# 초기 floorplan margin이 20um이므로 ring offset은 5um로 둡니다.
################################################################################

create_pg_ring_pattern core_ring_pattern \
  -horizontal_layer M7 \
  -vertical_layer M8 \
  -horizontal_width 2.0 \
  -vertical_width 2.0 \
  -horizontal_spacing 1.0 \
  -vertical_spacing 1.0 \
  -corner_bridge true

set_pg_strategy core_ring_strategy \
  -core \
  -pattern {{name: core_ring_pattern}{nets: {VDD VSS}}{offset: {5 5}}} \
  -extension {{stop: design_boundary_and_generate_pin}}

################################################################################
# core mesh pattern입니다.
# M2 vertical strap은 M1 stdcell rail과 가까운 metal에서 먼저 연결합니다.
# M7/M8 strap은 상위 mesh/ring 연결 경로입니다.
# pitch 40um는 첫 pass용 보수적 값입니다. IR drop 분석 전까지는 학습용 기준입니다.
# M7 offset은 28um로 둡니다.
# 20um/22um에서는 일부 stdcell M1 rail과 M7 strap이 같은 y에 놓여 M1-M2 via가 빠졌습니다.
################################################################################

create_pg_mesh_pattern core_mesh_pattern \
  -layers { \
    {{vertical_layer: M2}{width: 0.4}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}} \
    {{vertical_layer: M8}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}} \
    {{horizontal_layer: M7}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 28.0}} \
  }

set_pg_strategy core_mesh_strategy \
  -core \
  -pattern {{name: core_mesh_pattern}{nets: {VDD VSS}}} \
  -extension {{stop: innermost_ring}}

################################################################################
# strategy 사이의 교차점에 via를 만듭니다.
# default via를 쓰면 technology file에 정의된 via stack을 ICC2가 선택합니다.
################################################################################

set_pg_strategy_via_rule pg_via_all \
  -via_rule {{intersection: all}{via_master: default}} \
  -tag pg_initial_via

################################################################################
# PG network 생성입니다.
# stdcell rail, core ring, core mesh를 한 번에 생성합니다.
################################################################################

compile_pg \
  -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
  -via_rule pg_via_all

################################################################################
# compile_pg가 boundary PG pin을 만들면서 실제 물리 port는 VDD_1/VSS_1로 생깁니다.
# 별도로 남은 VDD/VSS port는 terminal이 0개라 route에서 no-pin 경고를 냅니다.
# 삭제는 save/reopen 뒤 다시 생길 수 있어, VDD/VSS port에 작은 M8 terminal을 붙입니다.
# 기존 VDD_1/VSS_1 boundary terminal과 겹치지 않도록 y=3..5um 위치를 씁니다.
################################################################################

set VDD_PORTS [get_ports -quiet VDD]
if {[sizeof_collection $VDD_PORTS] > 0} {
  set VDD_TERMS [get_terminals -quiet -of_objects $VDD_PORTS]
  if {[sizeof_collection $VDD_TERMS] == 0} {
    create_terminal \
      -port $VDD_PORTS \
      -boundary {{13.0000 3.0000} {15.0000 5.0000}} \
      -layer M8 \
      -direction all \
      -name VDD_top_terminal
  }
}

set VSS_PORTS [get_ports -quiet VSS]
if {[sizeof_collection $VSS_PORTS] > 0} {
  set VSS_TERMS [get_terminals -quiet -of_objects $VSS_PORTS]
  if {[sizeof_collection $VSS_TERMS] == 0} {
    create_terminal \
      -port $VSS_PORTS \
      -boundary {{10.0000 3.0000} {12.0000 5.0000}} \
      -layer M8 \
      -direction all \
      -name VSS_top_terminal
  }
}

################################################################################
# power plan 결과 evidence report입니다.
################################################################################

report_pg_patterns > $POWER_REPORT_DIR/pg_patterns.rpt
report_pg_strategies > $POWER_REPORT_DIR/pg_strategies.rpt
report_pg_strategy_via_rules > $POWER_REPORT_DIR/pg_strategy_via_rules.rpt
report_ports [get_ports -quiet {VDD VSS VDD_1 VSS_1}] > $POWER_REPORT_DIR/pg_ports.rpt
check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $POWER_REPORT_DIR/pg_connectivity_detail.rpt \
  > $POWER_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $POWER_REPORT_DIR/pg_drc.rpt

report_design -physical > $POWER_REPORT_DIR/design_physical.rpt
report_utilization > $POWER_REPORT_DIR/utilization.rpt
report_qor > $POWER_REPORT_DIR/qor.rpt

save_block
save_lib

exit
