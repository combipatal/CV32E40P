set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set TOP_NAME cv32e40p_synth_wrap
set NETLIST 2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.vg
set SDC_FILE constraints/cv32e40p_func_10ns.sdc

file mkdir 6_STA/4_Report
file mkdir 6_STA/3_Log

set link_path [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

read_verilog $NETLIST
current_design $TOP_NAME
link_design

set_wire_load_mode enclosed
set_wire_load_model -name 70000 [current_design]

read_sdc $SDC_FILE

check_timing -verbose > 6_STA/4_Report/pre_dft.func_tt_10ns.check_timing.rpt
report_wire_load > 6_STA/4_Report/pre_dft.func_tt_10ns.wire_load.rpt
report_global_timing > 6_STA/4_Report/pre_dft.func_tt_10ns.global_timing.rpt
report_timing -delay_type max -max_paths 20 -slack_lesser_than 100 > 6_STA/4_Report/pre_dft.func_tt_10ns.setup_timing.rpt
report_timing -delay_type min -max_paths 20 -slack_lesser_than 100 > 6_STA/4_Report/pre_dft.func_tt_10ns.hold_timing.rpt
report_constraint -all_violators > 6_STA/4_Report/pre_dft.func_tt_10ns.constraints.rpt
report_analysis_coverage > 6_STA/4_Report/pre_dft.func_tt_10ns.coverage.rpt

exit
