################################################################################
# PrimeTime probe: maxcap ECO5 max_transition 상세 확인
#
# 목적:
#   PT cmax constraint report에 남은 max_transition 1개를
#   더 많은 자릿수로 확인합니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set TOP_NAME cv32e40p_synth_wrap
set TAG maxcap_eco5_route_repair

set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set NETLIST 7_Backend_ICC2/2_Output/07_extract_sta/$TAG/cv32e40p_synth_wrap.$TAG.vg
set SPEF_MAX_FILE 7_Backend_ICC2/2_Output/07_extract_sta/$TAG/cv32e40p_synth_wrap.$TAG.spef.saed32_cmax_25.spef
set SDC_FILE constraints/cv32e40p_func_10ns.sdc
set REPORT_DIR 6_STA/4_Report/maxcap_eco5_route_repair_spef
set REPORT_PREFIX maxcap_eco5.transition_probe

file mkdir $REPORT_DIR

set link_path [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

read_verilog $NETLIST
current_design $TOP_NAME
link_design
read_sdc $SDC_FILE
read_parasitics $SPEF_MAX_FILE

# violation report를 자릿수 4자리로 다시 출력합니다.
report_constraint -max_transition -all_violators -significant_digits 4 > $REPORT_DIR/$REPORT_PREFIX.cmax.max_transition_4digits.rpt

# 문제 pin의 driver/load 주변 정보를 확인합니다.
set BAD_PIN [get_pins u_core/core_i/id_stage_i/U246/Y]
set BAD_NET [get_nets -of_objects $BAD_PIN]
report_net -connections -verbose $BAD_NET > $REPORT_DIR/$REPORT_PREFIX.bad_net_connections.rpt
report_timing -through $BAD_PIN -delay_type max -max_paths 5 -significant_digits 4 > $REPORT_DIR/$REPORT_PREFIX.bad_pin_timing_paths.rpt

exit
