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
set PLACE_ADVANCED_LEGALIZER ""
set PLACE_MULTI_CELL_PIN_ACCESS_CHECK ""
set PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS ""
set PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS ""
set PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING ""
set PLACE_SUPPORT_OFF_TRACK_VIA_REGION ""
set PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK ""
set SCAN_DEF_FILE ""
set HOTSPOT_BLOCKAGE_ENABLE ""
set HOTSPOT_BLOCKAGE_BOUNDARY {{215.0 195.0} {265.0 265.0}}
set HOTSPOT_BLOCKAGE_PERCENT 40
set PG_M2_MESH_OFFSET 20.0
set PG_M2_HOTSPOT_BLOCKAGE_ENABLE ""
set PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY {{238.0 195.0} {242.0 265.0}}
set PG_M2_HOTSPOT_BLOCKAGE_NETS {VDD}
set PG_M2_HOTSPOT_BLOCKAGE_LAYERS {M2}
set PG_M2_HOTSPOT_CUT_ENABLE ""
set PG_M2_HOTSPOT_CUT_BOUNDARY {{258.0 195.0} {262.0 265.0}}
set PG_M2_HOTSPOT_CUT_NETS {VSS}
set ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS ""
set ROUTE_DETAIL_FORCE_END_ON_PREFERRED_GRID ""
set ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL ""
set ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL ""
set ROUTE_COMMON_EXTRA_VIA_OFF_GRID_COST_BY_LAYER ""
set ROUTE_COMMON_VIA_ON_GRID_BY_LAYER ""
set ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER ""
set ROUTE_COMMON_CONNECT_WITHIN_PINS_BY_LAYER ""
set ROUTE_AUTO_VIA_LADDER_CENTER_TRACK_OFF_GRID_PMJ ""
set ECO_SWAP_FILE ""
set ECO_SWAP_DONT_TOUCH ""
set ECO_PIN_SWAP_FILE ""
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
if {[info exists ::env(PLACE_ADVANCED_LEGALIZER)]} {
  set PLACE_ADVANCED_LEGALIZER $::env(PLACE_ADVANCED_LEGALIZER)
}
if {[info exists ::env(PLACE_MULTI_CELL_PIN_ACCESS_CHECK)]} {
  set PLACE_MULTI_CELL_PIN_ACCESS_CHECK $::env(PLACE_MULTI_CELL_PIN_ACCESS_CHECK)
}
if {[info exists ::env(PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS)]} {
  set PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS $::env(PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS)
}
if {[info exists ::env(PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS)]} {
  set PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS $::env(PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS)
}
if {[info exists ::env(PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING)]} {
  set PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING $::env(PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING)
}
if {[info exists ::env(PLACE_SUPPORT_OFF_TRACK_VIA_REGION)]} {
  set PLACE_SUPPORT_OFF_TRACK_VIA_REGION $::env(PLACE_SUPPORT_OFF_TRACK_VIA_REGION)
}
if {[info exists ::env(PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK)]} {
  set PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK $::env(PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK)
}
if {[info exists ::env(SCAN_DEF_FILE)]} {
  set SCAN_DEF_FILE $::env(SCAN_DEF_FILE)
}
if {[info exists ::env(HOTSPOT_BLOCKAGE_ENABLE)]} {
  set HOTSPOT_BLOCKAGE_ENABLE $::env(HOTSPOT_BLOCKAGE_ENABLE)
}
if {[info exists ::env(HOTSPOT_BLOCKAGE_BOUNDARY)]} {
  set HOTSPOT_BLOCKAGE_BOUNDARY $::env(HOTSPOT_BLOCKAGE_BOUNDARY)
}
if {[info exists ::env(HOTSPOT_BLOCKAGE_PERCENT)]} {
  set HOTSPOT_BLOCKAGE_PERCENT $::env(HOTSPOT_BLOCKAGE_PERCENT)
}
if {[info exists ::env(PG_M2_MESH_OFFSET)]} {
  set PG_M2_MESH_OFFSET $::env(PG_M2_MESH_OFFSET)
}
if {[info exists ::env(PG_M2_HOTSPOT_BLOCKAGE_ENABLE)]} {
  set PG_M2_HOTSPOT_BLOCKAGE_ENABLE $::env(PG_M2_HOTSPOT_BLOCKAGE_ENABLE)
}
if {[info exists ::env(PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY)]} {
  set PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY $::env(PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY)
}
if {[info exists ::env(PG_M2_HOTSPOT_BLOCKAGE_NETS)]} {
  set PG_M2_HOTSPOT_BLOCKAGE_NETS $::env(PG_M2_HOTSPOT_BLOCKAGE_NETS)
}
if {[info exists ::env(PG_M2_HOTSPOT_BLOCKAGE_LAYERS)]} {
  set PG_M2_HOTSPOT_BLOCKAGE_LAYERS $::env(PG_M2_HOTSPOT_BLOCKAGE_LAYERS)
}
if {[info exists ::env(PG_M2_HOTSPOT_CUT_ENABLE)]} {
  set PG_M2_HOTSPOT_CUT_ENABLE $::env(PG_M2_HOTSPOT_CUT_ENABLE)
}
if {[info exists ::env(PG_M2_HOTSPOT_CUT_BOUNDARY)]} {
  set PG_M2_HOTSPOT_CUT_BOUNDARY $::env(PG_M2_HOTSPOT_CUT_BOUNDARY)
}
if {[info exists ::env(PG_M2_HOTSPOT_CUT_NETS)]} {
  set PG_M2_HOTSPOT_CUT_NETS $::env(PG_M2_HOTSPOT_CUT_NETS)
}
if {[info exists ::env(ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS)]} {
  set ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS $::env(ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS)
}
if {[info exists ::env(ROUTE_DETAIL_FORCE_END_ON_PREFERRED_GRID)]} {
  set ROUTE_DETAIL_FORCE_END_ON_PREFERRED_GRID $::env(ROUTE_DETAIL_FORCE_END_ON_PREFERRED_GRID)
}
if {[info exists ::env(ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL)]} {
  set ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL $::env(ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL)
}
if {[info exists ::env(ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL)]} {
  set ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL $::env(ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL)
}
if {[info exists ::env(ROUTE_COMMON_EXTRA_VIA_OFF_GRID_COST_BY_LAYER)]} {
  set ROUTE_COMMON_EXTRA_VIA_OFF_GRID_COST_BY_LAYER $::env(ROUTE_COMMON_EXTRA_VIA_OFF_GRID_COST_BY_LAYER)
}
if {[info exists ::env(ROUTE_COMMON_VIA_ON_GRID_BY_LAYER)]} {
  set ROUTE_COMMON_VIA_ON_GRID_BY_LAYER $::env(ROUTE_COMMON_VIA_ON_GRID_BY_LAYER)
}
if {[info exists ::env(ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER)]} {
  set ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER $::env(ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER)
}
if {[info exists ::env(ROUTE_COMMON_CONNECT_WITHIN_PINS_BY_LAYER)]} {
  set ROUTE_COMMON_CONNECT_WITHIN_PINS_BY_LAYER $::env(ROUTE_COMMON_CONNECT_WITHIN_PINS_BY_LAYER)
}
if {[info exists ::env(ROUTE_AUTO_VIA_LADDER_CENTER_TRACK_OFF_GRID_PMJ)]} {
  set ROUTE_AUTO_VIA_LADDER_CENTER_TRACK_OFF_GRID_PMJ $::env(ROUTE_AUTO_VIA_LADDER_CENTER_TRACK_OFF_GRID_PMJ)
}
if {[info exists ::env(ECO_SWAP_FILE)]} {
  set ECO_SWAP_FILE $::env(ECO_SWAP_FILE)
}
if {[info exists ::env(ECO_SWAP_DONT_TOUCH)]} {
  set ECO_SWAP_DONT_TOUCH $::env(ECO_SWAP_DONT_TOUCH)
}
if {[info exists ::env(ECO_PIN_SWAP_FILE)]} {
  set ECO_PIN_SWAP_FILE $::env(ECO_PIN_SWAP_FILE)
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

if {$ECO_SWAP_FILE ne ""} {
  # 문제 marker와 좌표가 맞는 instance만 다른 equivalent lib cell로 바꿉니다.
  # TSV 형식: cell old_ref new_ref reason
  set ECO_SWAP_REPORT [open $TRIAL_INIT_DIR/eco_swap.rpt w]
  puts $ECO_SWAP_REPORT "eco_swap_file=$ECO_SWAP_FILE"
  puts $ECO_SWAP_REPORT "format: cell old_ref new_ref reason"

  set ECO_SWAP_FP [open $ECO_SWAP_FILE r]
  set ECO_SWAP_LINE_NO 0
  while {[gets $ECO_SWAP_FP ECO_SWAP_LINE] >= 0} {
    incr ECO_SWAP_LINE_NO
    if {$ECO_SWAP_LINE_NO == 1} {
      continue
    }
    if {$ECO_SWAP_LINE eq ""} {
      continue
    }

    set ECO_SWAP_FIELDS [split $ECO_SWAP_LINE "\t"]
    set ECO_CELL_NAME [lindex $ECO_SWAP_FIELDS 0]
    set ECO_OLD_REF [lindex $ECO_SWAP_FIELDS 1]
    set ECO_NEW_REF [lindex $ECO_SWAP_FIELDS 2]
    set ECO_REASON [lindex $ECO_SWAP_FIELDS 3]

    set ECO_CELL [get_cells -quiet $ECO_CELL_NAME]
    if {[sizeof_collection $ECO_CELL] == 0} {
      puts $ECO_SWAP_REPORT "MISS cell=$ECO_CELL_NAME old=$ECO_OLD_REF new=$ECO_NEW_REF reason=$ECO_REASON"
      continue
    }

    set ECO_LIB_CELL [get_lib_cells -quiet */$ECO_NEW_REF]
    if {[sizeof_collection $ECO_LIB_CELL] == 0} {
      puts $ECO_SWAP_REPORT "MISS_LIB cell=$ECO_CELL_NAME old=$ECO_OLD_REF new=$ECO_NEW_REF reason=$ECO_REASON"
      continue
    }

    set ECO_STATUS [catch {
      size_cell $ECO_CELL -lib_cell $ECO_LIB_CELL
    } ECO_MSG]

    if {$ECO_STATUS == 0} {
      puts $ECO_SWAP_REPORT "PASS cell=$ECO_CELL_NAME old=$ECO_OLD_REF new=$ECO_NEW_REF reason=$ECO_REASON"
      if {$ECO_SWAP_DONT_TOUCH eq "true"} {
        # 후속 optimization이 ECO swap cell을 다시 RVT/HVT로 바꾸지 못하게 고정합니다.
        set_dont_touch $ECO_CELL true
        puts $ECO_SWAP_REPORT "DONT_TOUCH cell=$ECO_CELL_NAME value=true"
      }
    } else {
      puts $ECO_SWAP_REPORT "FAIL cell=$ECO_CELL_NAME old=$ECO_OLD_REF new=$ECO_NEW_REF reason=$ECO_REASON msg=$ECO_MSG"
    }
  }
  close $ECO_SWAP_FP
  close $ECO_SWAP_REPORT
}

if {$ECO_PIN_SWAP_FILE ne ""} {
  # Commutative gate의 A1/A2 net만 서로 바꿉니다.
  # TSV 형식: cell ref pin_a pin_b reason
  set ECO_PIN_SWAP_REPORT [open $TRIAL_INIT_DIR/eco_pin_swap.rpt w]
  puts $ECO_PIN_SWAP_REPORT "eco_pin_swap_file=$ECO_PIN_SWAP_FILE"
  puts $ECO_PIN_SWAP_REPORT "format: cell ref pin_a pin_b reason"

  set ECO_PIN_SWAP_FP [open $ECO_PIN_SWAP_FILE r]
  set ECO_PIN_SWAP_LINE_NO 0
  while {[gets $ECO_PIN_SWAP_FP ECO_PIN_SWAP_LINE] >= 0} {
    incr ECO_PIN_SWAP_LINE_NO
    if {$ECO_PIN_SWAP_LINE_NO == 1} {
      continue
    }
    if {$ECO_PIN_SWAP_LINE eq ""} {
      continue
    }

    set ECO_PIN_SWAP_FIELDS [split $ECO_PIN_SWAP_LINE "\t"]
    set ECO_CELL_NAME [lindex $ECO_PIN_SWAP_FIELDS 0]
    set ECO_REF_NAME [lindex $ECO_PIN_SWAP_FIELDS 1]
    set ECO_PIN_A_NAME [lindex $ECO_PIN_SWAP_FIELDS 2]
    set ECO_PIN_B_NAME [lindex $ECO_PIN_SWAP_FIELDS 3]
    set ECO_REASON [lindex $ECO_PIN_SWAP_FIELDS 4]

    set ECO_PIN_A [get_pins -quiet ${ECO_CELL_NAME}/${ECO_PIN_A_NAME}]
    set ECO_PIN_B [get_pins -quiet ${ECO_CELL_NAME}/${ECO_PIN_B_NAME}]
    if {[sizeof_collection $ECO_PIN_A] == 0 || [sizeof_collection $ECO_PIN_B] == 0} {
      puts $ECO_PIN_SWAP_REPORT "MISS_PIN cell=$ECO_CELL_NAME ref=$ECO_REF_NAME pin_a=$ECO_PIN_A_NAME pin_b=$ECO_PIN_B_NAME reason=$ECO_REASON"
      continue
    }

    set ECO_NET_A [get_nets -quiet -of_objects $ECO_PIN_A]
    set ECO_NET_B [get_nets -quiet -of_objects $ECO_PIN_B]
    if {[sizeof_collection $ECO_NET_A] == 0 || [sizeof_collection $ECO_NET_B] == 0} {
      puts $ECO_PIN_SWAP_REPORT "MISS_NET cell=$ECO_CELL_NAME ref=$ECO_REF_NAME pin_a=$ECO_PIN_A_NAME pin_b=$ECO_PIN_B_NAME reason=$ECO_REASON"
      continue
    }

    set ECO_NET_A_NAME [get_object_name $ECO_NET_A]
    set ECO_NET_B_NAME [get_object_name $ECO_NET_B]
    set ECO_STATUS [catch {
      disconnect_net -net $ECO_NET_A $ECO_PIN_A
      disconnect_net -net $ECO_NET_B $ECO_PIN_B
      connect_net -net $ECO_NET_A $ECO_PIN_B
      connect_net -net $ECO_NET_B $ECO_PIN_A
    } ECO_MSG]

    if {$ECO_STATUS == 0} {
      puts $ECO_PIN_SWAP_REPORT "PASS cell=$ECO_CELL_NAME ref=$ECO_REF_NAME pin_a=$ECO_PIN_A_NAME net_a=$ECO_NET_A_NAME pin_b=$ECO_PIN_B_NAME net_b=$ECO_NET_B_NAME reason=$ECO_REASON"
    } else {
      puts $ECO_PIN_SWAP_REPORT "FAIL cell=$ECO_CELL_NAME ref=$ECO_REF_NAME pin_a=$ECO_PIN_A_NAME net_a=$ECO_NET_A_NAME pin_b=$ECO_PIN_B_NAME net_b=$ECO_NET_B_NAME reason=$ECO_REASON msg=$ECO_MSG"
    }
  }
  close $ECO_PIN_SWAP_FP
  close $ECO_PIN_SWAP_REPORT
}

if {$SCAN_DEF_FILE ne ""} {
  puts "Reading scan DEF: $SCAN_DEF_FILE"
  read_def \
    -include {scanchains} \
    $SCAN_DEF_FILE
}

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

# M2 PG mesh는 M1/M2/VIA1 DRC와 직접 맞물릴 수 있어 offset trial을 지원합니다.
set PG_MESH_LAYERS [subst {
  {{vertical_layer: M2}{width: 0.4}{spacing: interleaving}{pitch: 40.0}{offset: $PG_M2_MESH_OFFSET}}
  {{vertical_layer: M8}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 20.0}}
  {{horizontal_layer: M7}{width: 1.0}{spacing: interleaving}{pitch: 40.0}{offset: 28.0}}
}]

create_pg_mesh_pattern core_mesh_pattern \
  -layers $PG_MESH_LAYERS

# manual cut보다 먼저 tool-supported PG blockage를 시험합니다.
# 목표는 hotspot 안의 특정 net/layer M2 strap을 compile_pg 단계에서 만들지 않는 것입니다.
set PG_MESH_BLOCKAGE_OPTION ""
if {$PG_M2_HOTSPOT_BLOCKAGE_ENABLE ne ""} {
  if {[llength $PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY] == 1} {
    set PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY [lindex $PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY 0]
  }
  set BLOCK_LL [lindex $PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY 0]
  set BLOCK_UR [lindex $PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY 1]
  set BLOCK_X1 [lindex $BLOCK_LL 0]
  set BLOCK_Y1 [lindex $BLOCK_LL 1]
  set BLOCK_X2 [lindex $BLOCK_UR 0]
  set BLOCK_Y2 [lindex $BLOCK_UR 1]
  set PG_M2_HOTSPOT_BLOCKAGE_POLYGON [list \
    [list $BLOCK_X1 $BLOCK_Y1] \
    [list $BLOCK_X1 $BLOCK_Y2] \
    [list $BLOCK_X2 $BLOCK_Y2] \
    [list $BLOCK_X2 $BLOCK_Y1] \
  ]

  create_pg_region hotspot_pg_m2_blockage \
    -polygon $PG_M2_HOTSPOT_BLOCKAGE_POLYGON

  set PG_MESH_BLOCKAGE_OPTION [list \
    [list nets: $PG_M2_HOTSPOT_BLOCKAGE_NETS] \
    [list layers: $PG_M2_HOTSPOT_BLOCKAGE_LAYERS] \
    [list pg_regions: hotspot_pg_m2_blockage] \
  ]
}

if {$PG_MESH_BLOCKAGE_OPTION ne ""} {
  set_pg_strategy core_mesh_strategy \
    -core \
    -pattern {{name: core_mesh_pattern}{nets: {VDD VSS}}} \
    -extension {{stop: innermost_ring}} \
    -blockage $PG_MESH_BLOCKAGE_OPTION
} else {
  set_pg_strategy core_mesh_strategy \
    -core \
    -pattern {{name: core_mesh_pattern}{nets: {VDD VSS}}} \
    -extension {{stop: innermost_ring}}
}

set_pg_strategy_via_rule pg_via_all \
  -via_rule {{intersection: all}{via_master: default}} \
  -tag pg_initial_via

compile_pg \
  -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
  -via_rule pg_via_all

################################################################################
# Hotspot M2 PG stripe cut trial
# x=260um VSS M2 stripe가 SDFFARX1_RVT hotspot pin access와 겹치는지 봅니다.
# env로 켠 trial에서만 지정 boundary와 만나는 M2 PG stripe를 위/아래 segment로 나눕니다.
################################################################################

if {$PG_M2_HOTSPOT_CUT_ENABLE ne ""} {
  if {[llength $PG_M2_HOTSPOT_CUT_BOUNDARY] == 1} {
    set PG_M2_HOTSPOT_CUT_BOUNDARY [lindex $PG_M2_HOTSPOT_CUT_BOUNDARY 0]
  }
  set CUT_LL [lindex $PG_M2_HOTSPOT_CUT_BOUNDARY 0]
  set CUT_UR [lindex $PG_M2_HOTSPOT_CUT_BOUNDARY 1]
  set CUT_Y1 [lindex $CUT_LL 1]
  set CUT_Y2 [lindex $CUT_UR 1]

  set CUT_REPORT [open $TRIAL_POWER_DIR/pg_m2_hotspot_cut.rpt w]
  puts $CUT_REPORT "enable: $PG_M2_HOTSPOT_CUT_ENABLE"
  puts $CUT_REPORT "boundary: $PG_M2_HOTSPOT_CUT_BOUNDARY"
  puts $CUT_REPORT "nets: $PG_M2_HOTSPOT_CUT_NETS"

  set CUT_VIA_COUNT 0
  set CANDIDATE_VIAS [get_vias -quiet -intersect $PG_M2_HOTSPOT_CUT_BOUNDARY]
  foreach_in_collection via $CANDIDATE_VIAS {
    set via_net_obj [get_attribute -quiet $via net]
    set via_net_name ""
    if {[sizeof_collection $via_net_obj] > 0} {
      set via_net_name [get_object_name $via_net_obj]
    }
    if {[lsearch -exact $PG_M2_HOTSPOT_CUT_NETS $via_net_name] >= 0} {
      puts $CUT_REPORT "remove_via: [get_object_name $via] net=$via_net_name bbox=[get_attribute -quiet $via bbox]"
      remove_objects -force $via
      incr CUT_VIA_COUNT
    }
  }

  set CUT_SHAPE_COUNT 0
  set CUT_RECREATE_COUNT 0
  set CANDIDATE_SHAPES [get_shapes -quiet -intersect $PG_M2_HOTSPOT_CUT_BOUNDARY]
  foreach_in_collection shape $CANDIDATE_SHAPES {
    set layer [get_attribute -quiet $shape layer_name]
    set net_obj [get_attribute -quiet $shape net]
    set net_name ""
    if {[sizeof_collection $net_obj] > 0} {
      set net_name [get_object_name $net_obj]
    }
    if {$layer ne "M2"} {
      continue
    }
    if {[lsearch -exact $PG_M2_HOTSPOT_CUT_NETS $net_name] < 0} {
      continue
    }

    set bbox [get_attribute -quiet $shape bbox]
    set ll [lindex $bbox 0]
    set ur [lindex $bbox 1]
    set x1 [lindex $ll 0]
    set y1 [lindex $ll 1]
    set x2 [lindex $ur 0]
    set y2 [lindex $ur 1]

    puts $CUT_REPORT "cut_shape: [get_object_name $shape] net=$net_name layer=$layer bbox=$bbox"
    remove_objects -force $shape
    incr CUT_SHAPE_COUNT

    if {$y1 < $CUT_Y1} {
      create_shape \
        -shape_type rect \
        -layer M2 \
        -shape_use stripe \
        -net $net_obj \
        -boundary [list [list $x1 $y1] [list $x2 $CUT_Y1]]
      puts $CUT_REPORT "create_bottom_segment: net=$net_name bbox={{$x1 $y1} {$x2 $CUT_Y1}}"
      incr CUT_RECREATE_COUNT
    }

    if {$CUT_Y2 < $y2} {
      create_shape \
        -shape_type rect \
        -layer M2 \
        -shape_use stripe \
        -net $net_obj \
        -boundary [list [list $x1 $CUT_Y2] [list $x2 $y2]]
      puts $CUT_REPORT "create_top_segment: net=$net_name bbox={{$x1 $CUT_Y2} {$x2 $y2}}"
      incr CUT_RECREATE_COUNT
    }
  }

  puts $CUT_REPORT "removed_vias: $CUT_VIA_COUNT"
  puts $CUT_REPORT "removed_shapes: $CUT_SHAPE_COUNT"
  puts $CUT_REPORT "created_segments: $CUT_RECREATE_COUNT"
  close $CUT_REPORT
}

set PG_MESH_SETTING_REPORT [open $TRIAL_POWER_DIR/pg_mesh_trial_settings.rpt w]
puts $PG_MESH_SETTING_REPORT "M2_mesh_offset: $PG_M2_MESH_OFFSET"
puts $PG_MESH_SETTING_REPORT "M8_mesh_offset: 20.0"
puts $PG_MESH_SETTING_REPORT "M7_mesh_offset: 28.0"
puts $PG_MESH_SETTING_REPORT "M2_hotspot_blockage_enable: $PG_M2_HOTSPOT_BLOCKAGE_ENABLE"
puts $PG_MESH_SETTING_REPORT "M2_hotspot_blockage_boundary: $PG_M2_HOTSPOT_BLOCKAGE_BOUNDARY"
if {[info exists PG_M2_HOTSPOT_BLOCKAGE_POLYGON]} {
  puts $PG_MESH_SETTING_REPORT "M2_hotspot_blockage_polygon: $PG_M2_HOTSPOT_BLOCKAGE_POLYGON"
}
puts $PG_MESH_SETTING_REPORT "M2_hotspot_blockage_nets: $PG_M2_HOTSPOT_BLOCKAGE_NETS"
puts $PG_MESH_SETTING_REPORT "M2_hotspot_blockage_layers: $PG_M2_HOTSPOT_BLOCKAGE_LAYERS"
puts $PG_MESH_SETTING_REPORT "M2_hotspot_blockage_option: $PG_MESH_BLOCKAGE_OPTION"
puts $PG_MESH_SETTING_REPORT "M2_hotspot_cut_enable: $PG_M2_HOTSPOT_CUT_ENABLE"
puts $PG_MESH_SETTING_REPORT "M2_hotspot_cut_boundary: $PG_M2_HOTSPOT_CUT_BOUNDARY"
puts $PG_MESH_SETTING_REPORT "M2_hotspot_cut_nets: $PG_M2_HOTSPOT_CUT_NETS"
close $PG_MESH_SETTING_REPORT

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
# scan DEF가 있으면 read_def로 넣고, 없으면 기존 first-pass처럼 bypass합니다.
# pin access trial에서는 env로 placement/legalizer option을 하나씩 추가합니다.
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
if {$PLACE_ADVANCED_LEGALIZER ne ""} {
  set_app_options -name place.legalize.enable_advanced_legalizer -value $PLACE_ADVANCED_LEGALIZER
}
if {$PLACE_MULTI_CELL_PIN_ACCESS_CHECK ne ""} {
  set_app_options -name place.legalize.enable_multi_cell_pin_access_check -value $PLACE_MULTI_CELL_PIN_ACCESS_CHECK
}
if {$PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS ne ""} {
  set_app_options -name place.legalize.optimize_pin_access_access_points -value $PLACE_OPTIMIZE_PIN_ACCESS_ACCESS_POINTS
}
if {$PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS ne ""} {
  set_app_options -name place.legalize.optimize_pin_access_drc_variants -value $PLACE_OPTIMIZE_PIN_ACCESS_DRC_VARIANTS
}
if {$PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING ne ""} {
  set_app_options -name place.legalize.optimize_pin_access_using_cell_spacing -value $PLACE_OPTIMIZE_PIN_ACCESS_USING_CELL_SPACING
}
if {$PLACE_SUPPORT_OFF_TRACK_VIA_REGION ne ""} {
  set_app_options -name place.legalize.support_off_track_via_region -value $PLACE_SUPPORT_OFF_TRACK_VIA_REGION
}
if {$PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK ne ""} {
  set_app_options -name place.legalize.enable_pin_color_alignment_check -value $PLACE_ENABLE_PIN_COLOR_ALIGNMENT_CHECK
}

if {$HOTSPOT_BLOCKAGE_ENABLE ne ""} {
  # marker context에서 DRC가 몰린 영역 주변의 placement 밀도를 낮춥니다.
  # partial blockage는 coarse placement 단계에서만 직접 반영됩니다.
  set HOTSPOT_BLOCKAGE [create_placement_blockage \
    -name hotspot_drc_density_screen \
    -type partial \
    -blocked_percentage $HOTSPOT_BLOCKAGE_PERCENT \
    -boundary $HOTSPOT_BLOCKAGE_BOUNDARY]

  set HOTSPOT_BLOCKAGE_REPORT [open $TRIAL_PLACE_DIR/hotspot_blockage.rpt w]
  puts $HOTSPOT_BLOCKAGE_REPORT "name: hotspot_drc_density_screen"
  puts $HOTSPOT_BLOCKAGE_REPORT "type: partial"
  puts $HOTSPOT_BLOCKAGE_REPORT "blocked_percentage: $HOTSPOT_BLOCKAGE_PERCENT"
  puts $HOTSPOT_BLOCKAGE_REPORT "boundary: $HOTSPOT_BLOCKAGE_BOUNDARY"
  if {[catch {sizeof_collection $HOTSPOT_BLOCKAGE} HOTSPOT_BLOCKAGE_COUNT]} {
    puts $HOTSPOT_BLOCKAGE_REPORT "created_count: unknown"
  } else {
    puts $HOTSPOT_BLOCKAGE_REPORT "created_count: $HOTSPOT_BLOCKAGE_COUNT"
  }
  close $HOTSPOT_BLOCKAGE_REPORT
}

report_app_options place.coarse.* > $TRIAL_PLACE_DIR/place_coarse_app_options.rpt
report_app_options place.legalize.* > $TRIAL_PLACE_DIR/place_legalize_app_options.rpt

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

# route DRC 원인 확인용 option입니다.
# 한 trial에서 하나나 두 개만 켜서 DRC class 변화가 어디서 오는지 봅니다.
if {$ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS ne ""} {
  set_app_options \
    -name route.detail.generate_extra_off_grid_pin_tracks \
    -value $ROUTE_DETAIL_GENERATE_EXTRA_OFF_GRID_PIN_TRACKS
}
if {$ROUTE_DETAIL_FORCE_END_ON_PREFERRED_GRID ne ""} {
  set_app_options \
    -name route.detail.force_end_on_preferred_grid \
    -value $ROUTE_DETAIL_FORCE_END_ON_PREFERRED_GRID
}
if {$ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL ne ""} {
  set_app_options \
    -name route.detail.drc_convergence_effort_level \
    -value $ROUTE_DETAIL_DRC_CONVERGENCE_EFFORT_LEVEL
}
if {$ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL ne ""} {
  set_app_options \
    -name route.detail.optimize_wire_via_effort_level \
    -value $ROUTE_DETAIL_OPTIMIZE_WIRE_VIA_EFFORT_LEVEL
}
if {$ROUTE_COMMON_EXTRA_VIA_OFF_GRID_COST_BY_LAYER ne ""} {
  set_app_options \
    -name route.common.extra_via_off_grid_cost_multiplier_by_layer_name \
    -value $ROUTE_COMMON_EXTRA_VIA_OFF_GRID_COST_BY_LAYER
}
if {$ROUTE_COMMON_VIA_ON_GRID_BY_LAYER ne ""} {
  set_app_options \
    -name route.common.via_on_grid_by_layer_name \
    -value $ROUTE_COMMON_VIA_ON_GRID_BY_LAYER
}
if {$ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER ne ""} {
  set_app_options \
    -name route.common.wire_on_grid_by_layer_name \
    -value $ROUTE_COMMON_WIRE_ON_GRID_BY_LAYER
}
if {$ROUTE_COMMON_CONNECT_WITHIN_PINS_BY_LAYER ne ""} {
  # standard-cell pin 내부에서 via를 만들도록 제한해 A2 edge access DRC 변화를 봅니다.
  set_app_options \
    -name route.common.connect_within_pins_by_layer_name \
    -value $ROUTE_COMMON_CONNECT_WITHIN_PINS_BY_LAYER
}
if {$ROUTE_AUTO_VIA_LADDER_CENTER_TRACK_OFF_GRID_PMJ ne ""} {
  # off-track pattern_must_join pin shape에 via-ladder용 center track을 만들지 확인합니다.
  set_app_options \
    -name route.auto_via_ladder.generate_center_track_on_off_grid_pattern_must_join_pin_shapes \
    -value $ROUTE_AUTO_VIA_LADDER_CENTER_TRACK_OFF_GRID_PMJ
}

report_app_options route.common.* > $TRIAL_ROUTE_DIR/route_common_app_options.rpt
report_app_options route.detail.* > $TRIAL_ROUTE_DIR/route_detail_app_options.rpt
report_app_options route.auto_via_ladder.* > $TRIAL_ROUTE_DIR/route_auto_via_ladder_app_options.rpt

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
