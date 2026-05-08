################################################################################
# ICC2 route DRC 원인 확인용 60% utilization trial
#
# 목적:
#   기존 first-pass floorplan은 target core utilization 65%였습니다.
#   CTS buffer가 추가된 뒤 route 시점 실제 utilization은 약 77%까지 올라갔고,
#   route DRC 408개가 남았습니다.
#
#   기본 trial은 floorplan target만 60%로 낮추고 같은 PG/place/CTS/route를 수행합니다.
#   DRC가 크게 줄면 routing density가 주요 원인입니다.
#   DRC가 거의 그대로면 tech/via/grid/PG cleanup 쪽 원인이 더 큽니다.
#
#   SIGNAL_MAX_ROUTING_LAYER 환경변수를 주면 signal route layer bound도 같이 시험합니다.
#
# 주의:
#   이 스크립트는 ICC2 design library를 처음부터 다시 만듭니다.
#   기존 baseline report는 건드리지 않고 trial report 아래에 결과를 남깁니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TRIAL_NAME 60util
if {[info exists ::env(TRIAL_NAME)]} {
  set TRIAL_NAME $::env(TRIAL_NAME)
}

set SIGNAL_MIN_ROUTING_LAYER M1
set SIGNAL_MAX_ROUTING_LAYER ""
if {[info exists ::env(SIGNAL_MIN_ROUTING_LAYER)]} {
  set SIGNAL_MIN_ROUTING_LAYER $::env(SIGNAL_MIN_ROUTING_LAYER)
}
if {[info exists ::env(SIGNAL_MAX_ROUTING_LAYER)]} {
  set SIGNAL_MAX_ROUTING_LAYER $::env(SIGNAL_MAX_ROUTING_LAYER)
}

set CORE_UTILIZATION 0.60
if {[info exists ::env(CORE_UTILIZATION)]} {
  set CORE_UTILIZATION $::env(CORE_UTILIZATION)
}

set PLACE_PIN_DENSITY_AWARE ""
set PLACE_MAX_DENSITY ""
set PLACE_TARGET_ROUTING_DENSITY ""
set PLACE_INCREASED_CELL_EXPANSION ""
if {[info exists ::env(PLACE_PIN_DENSITY_AWARE)]} {
  set PLACE_PIN_DENSITY_AWARE $::env(PLACE_PIN_DENSITY_AWARE)
}
if {[info exists ::env(PLACE_MAX_DENSITY)]} {
  set PLACE_MAX_DENSITY $::env(PLACE_MAX_DENSITY)
}
if {[info exists ::env(PLACE_TARGET_ROUTING_DENSITY)]} {
  set PLACE_TARGET_ROUTING_DENSITY $::env(PLACE_TARGET_ROUTING_DENSITY)
}
if {[info exists ::env(PLACE_INCREASED_CELL_EXPANSION)]} {
  set PLACE_INCREASED_CELL_EXPANSION $::env(PLACE_INCREASED_CELL_EXPANSION)
}

set TRIAL_ROOT $PROJECT_ROOT/7_Backend_ICC2/4_Report/trials/$TRIAL_NAME
set TRIAL_INIT_DIR $TRIAL_ROOT/01_init_design
set TRIAL_FLOORPLAN_DIR $TRIAL_ROOT/02_floorplan
set TRIAL_POWER_DIR $TRIAL_ROOT/03_power
set TRIAL_PLACE_DIR $TRIAL_ROOT/04_place
set TRIAL_CTS_DIR $TRIAL_ROOT/05_cts
set TRIAL_ROUTE_DIR $TRIAL_ROOT/06_route

file mkdir $TRIAL_ROOT
file mkdir $TRIAL_INIT_DIR
file mkdir $TRIAL_FLOORPLAN_DIR
file mkdir $TRIAL_POWER_DIR
file mkdir $TRIAL_PLACE_DIR
file mkdir $TRIAL_CTS_DIR
file mkdir $TRIAL_ROUTE_DIR

################################################################################
# 1. Init design
# post-DFT netlist와 SDC를 ICC2 physical library로 다시 읽습니다.
################################################################################

if {[file exists $ICC2_LIB_DIR]} {
  file delete -force $ICC2_LIB_DIR
}

create_lib $ICC2_LIB_DIR \
  -technology $TECH_FILE \
  -ref_libs [list $NDM_RVT $NDM_LVT $NDM_HVT]

read_parasitic_tech \
  -tlup $TLUPLUS_MAX \
  -layermap $TLUPLUS_MAP \
  -name saed32_cmax

read_parasitic_tech \
  -tlup $TLUPLUS_MIN \
  -layermap $TLUPLUS_MAP \
  -name saed32_cmin

read_verilog $POST_DFT_NETLIST
current_design $TOP_NAME
link_block

read_sdc $POST_DFT_SDC

set_parasitic_parameters \
  -early_spec saed32_cmin \
  -early_temperature 25 \
  -late_spec saed32_cmax \
  -late_temperature 25

report_ref_libs > $TRIAL_INIT_DIR/ref_libs.rpt
report_parasitic_parameters > $TRIAL_INIT_DIR/parasitic_parameters.rpt
report_design -physical > $TRIAL_INIT_DIR/design_physical.rpt
report_design > $TRIAL_INIT_DIR/design.rpt

check_design \
  -checks {netlist design_mismatch timing} \
  -ems_database $TRIAL_INIT_DIR/check_design.ems \
  -log_file $TRIAL_INIT_DIR/check_design.rpt

report_timing -max_paths 10 > $TRIAL_INIT_DIR/timing.rpt

################################################################################
# 2. Floorplan
# target core utilization을 trial 환경변수로 조절합니다.
# 기본값은 기존 60% trial과 같습니다.
################################################################################

set CORE_ASPECT_RATIO {1 1}
set CORE_OFFSET_UM 20.0

initialize_floorplan \
  -control_type core \
  -shape R \
  -side_ratio $CORE_ASPECT_RATIO \
  -core_utilization $CORE_UTILIZATION \
  -core_offset $CORE_OFFSET_UM \
  -flip_first_row true

place_pins -self

report_design -physical > $TRIAL_FLOORPLAN_DIR/design_physical.rpt
report_utilization > $TRIAL_FLOORPLAN_DIR/utilization.rpt
report_qor > $TRIAL_FLOORPLAN_DIR/qor.rpt
report_timing -max_paths 10 > $TRIAL_FLOORPLAN_DIR/timing.rpt

check_design \
  -checks {netlist design_mismatch timing} \
  -ems_database $TRIAL_FLOORPLAN_DIR/check_design.ems \
  -log_file $TRIAL_FLOORPLAN_DIR/check_design.rpt

################################################################################
# 3. Power
# 기존 first-pass PG 구조와 동일하게 stdcell rail, ring, mesh를 만듭니다.
################################################################################

if {[sizeof_collection [get_nets -quiet VDD]] == 0} {
  create_net -power VDD
}

if {[sizeof_collection [get_nets -quiet VSS]] == 0} {
  create_net -ground VSS
}

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

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

create_pg_std_cell_conn_pattern stdcell_rail_pattern \
  -layers {M1}

set_pg_strategy stdcell_rail_strategy \
  -core \
  -pattern {{name: stdcell_rail_pattern}{nets: {VDD VSS}}}

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

set_pg_strategy_via_rule pg_via_all \
  -via_rule {{intersection: all}{via_master: default}} \
  -tag pg_initial_via

compile_pg \
  -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
  -via_rule pg_via_all

################################################################################
# compile_pg가 만든 실제 boundary PG port는 VDD_1/VSS_1입니다.
# VDD/VSS port는 save/reopen 뒤 terminal 없이 다시 보일 수 있으므로
# 작은 M8 terminal을 붙여 route no-pin/unplaced 경고를 제거합니다.
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

report_pg_patterns > $TRIAL_POWER_DIR/pg_patterns.rpt
report_pg_strategies > $TRIAL_POWER_DIR/pg_strategies.rpt
report_pg_strategy_via_rules > $TRIAL_POWER_DIR/pg_strategy_via_rules.rpt
report_ports [get_ports -quiet {VDD VSS VDD_1 VSS_1}] > $TRIAL_POWER_DIR/pg_ports.rpt
check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $TRIAL_POWER_DIR/pg_connectivity_detail.rpt \
  > $TRIAL_POWER_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $TRIAL_POWER_DIR/pg_drc.rpt

report_design -physical > $TRIAL_POWER_DIR/design_physical.rpt
report_utilization > $TRIAL_POWER_DIR/utilization.rpt
report_qor > $TRIAL_POWER_DIR/qor.rpt

################################################################################
# 4. Placement
# scan DEF가 아직 없으므로 기존 first-pass와 같이 bypass하고 배치합니다.
# pin access spreading trial에서는 env로 coarse placement option만 추가합니다.
################################################################################

set_app_options -name place.coarse.continue_on_missing_scandef -value true
if {$PLACE_PIN_DENSITY_AWARE ne ""} {
  set_app_options -name place.coarse.pin_density_aware -value $PLACE_PIN_DENSITY_AWARE
}
if {$PLACE_MAX_DENSITY ne ""} {
  set_app_options -name place.coarse.max_density -value $PLACE_MAX_DENSITY
}
if {$PLACE_TARGET_ROUTING_DENSITY ne ""} {
  set_app_options -name place.coarse.target_routing_density -value $PLACE_TARGET_ROUTING_DENSITY
}
if {$PLACE_INCREASED_CELL_EXPANSION ne ""} {
  set_app_options -name place.coarse.increased_cell_expansion -value $PLACE_INCREASED_CELL_EXPANSION
}

report_app_options place.coarse.* > $TRIAL_PLACE_DIR/place_coarse_app_options.rpt

create_placement \
  -effort medium \
  -timing_driven \
  -congestion

legalize_placement

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

check_legality > $TRIAL_PLACE_DIR/check_legality.rpt
report_utilization > $TRIAL_PLACE_DIR/utilization.rpt
report_qor > $TRIAL_PLACE_DIR/qor.rpt
report_timing -max_paths 20 > $TRIAL_PLACE_DIR/timing.rpt
report_design -physical > $TRIAL_PLACE_DIR/design_physical.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $TRIAL_PLACE_DIR/pg_connectivity_detail.rpt \
  > $TRIAL_PLACE_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $TRIAL_PLACE_DIR/pg_drc.rpt

################################################################################
# 5. CTS
# 기존 first-pass CTS 설정과 동일하게 clk_i clock tree를 만듭니다.
################################################################################

set CTS_CLOCK clk_i
set CTS_TARGET_SKEW 0.20

set_clock_tree_options \
  -clocks [get_clocks $CTS_CLOCK] \
  -target_skew $CTS_TARGET_SKEW

set_clock_routing_rules \
  -clocks [get_clocks $CTS_CLOCK] \
  -min_routing_layer M4 \
  -max_routing_layer M6 \
  -default_rule

check_clock_trees \
  -clocks [get_clocks $CTS_CLOCK] \
  > $TRIAL_CTS_DIR/check_clock_trees.pre.rpt

report_clock_tree_options > $TRIAL_CTS_DIR/clock_tree_options.rpt
report_clock_routing_rules > $TRIAL_CTS_DIR/clock_routing_rules.rpt

clock_opt \
  -from build_clock \
  -to route_clock

check_clock_trees \
  -clocks [get_clocks $CTS_CLOCK] \
  > $TRIAL_CTS_DIR/check_clock_trees.post.rpt

report_clock_qor -type summary > $TRIAL_CTS_DIR/clock_qor.summary.rpt
report_clock_qor -type latency > $TRIAL_CTS_DIR/clock_qor.latency.rpt
report_clock_qor -type drc_violators > $TRIAL_CTS_DIR/clock_qor.drc_violators.rpt
report_clock_qor -type area > $TRIAL_CTS_DIR/clock_qor.area.rpt

report_clock_timing -type summary > $TRIAL_CTS_DIR/clock_timing.summary.rpt
report_clock_timing -type skew -setup -nworst 20 > $TRIAL_CTS_DIR/clock_timing.skew_setup.rpt
report_clock_timing -type skew -hold -nworst 20 > $TRIAL_CTS_DIR/clock_timing.skew_hold.rpt
report_clock_timing -type latency -setup -nworst 20 > $TRIAL_CTS_DIR/clock_timing.latency_setup.rpt
report_clock_timing -type latency -hold -nworst 20 > $TRIAL_CTS_DIR/clock_timing.latency_hold.rpt

report_timing -delay_type max -max_paths 20 > $TRIAL_CTS_DIR/timing.max.rpt
report_timing -delay_type min -max_paths 20 > $TRIAL_CTS_DIR/timing.min.rpt
report_qor > $TRIAL_CTS_DIR/qor.rpt
report_utilization > $TRIAL_CTS_DIR/utilization.rpt
report_design -physical > $TRIAL_CTS_DIR/design_physical.rpt
check_legality > $TRIAL_CTS_DIR/check_legality.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $TRIAL_CTS_DIR/pg_connectivity_detail.rpt \
  > $TRIAL_CTS_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $TRIAL_CTS_DIR/pg_drc.rpt

################################################################################
# 6. Route
# 기본 route 설정은 baseline과 동일하게 두고, floorplan density 효과를 봅니다.
#
# SIGNAL_MAX_ROUTING_LAYER 환경변수를 주면 signal route layer bound도 같이 시험합니다.
# 예: SIGNAL_MAX_ROUTING_LAYER=M8
################################################################################

if {$SIGNAL_MAX_ROUTING_LAYER ne ""} {
  set_ignored_layers \
    -min_routing_layer $SIGNAL_MIN_ROUTING_LAYER \
    -max_routing_layer $SIGNAL_MAX_ROUTING_LAYER

  catch {report_ignored_layers > $TRIAL_ROUTE_DIR/ignored_layers.rpt}
}

check_routability > $TRIAL_ROUTE_DIR/check_routability.rpt

route_auto

check_routes > $TRIAL_ROUTE_DIR/check_routes.rpt
report_qor > $TRIAL_ROUTE_DIR/qor.rpt
report_timing -delay_type max -max_paths 20 > $TRIAL_ROUTE_DIR/timing.max.rpt
report_timing -delay_type min -max_paths 20 > $TRIAL_ROUTE_DIR/timing.min.rpt
report_utilization > $TRIAL_ROUTE_DIR/utilization.rpt
report_design -physical > $TRIAL_ROUTE_DIR/design_physical.rpt
check_legality > $TRIAL_ROUTE_DIR/check_legality.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $TRIAL_ROUTE_DIR/pg_connectivity_detail.rpt \
  > $TRIAL_ROUTE_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $TRIAL_ROUTE_DIR/pg_drc.rpt

save_block
save_lib

exit
