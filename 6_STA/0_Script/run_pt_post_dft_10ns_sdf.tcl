set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set TOP_NAME cv32e40p_synth_wrap
set NETLIST 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.vg
set SDC_FILE constraints/cv32e40p_func_10ns.sdc
set SDF_FILE 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.sdf

file mkdir 6_STA/4_Report/post_dft_topo_sdf
file mkdir 6_STA/3_Log

set link_path [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

read_verilog $NETLIST
current_design $TOP_NAME
link_design

read_sdc $SDC_FILE
read_sdf $SDF_FILE

check_timing -verbose > 6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.check_timing.rpt
report_global_timing > 6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.global_timing.rpt
report_timing -delay_type max -max_paths 20 -slack_lesser_than 100 > 6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.setup_timing.rpt
report_timing -delay_type min -max_paths 20 -slack_lesser_than 100 > 6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.hold_timing.rpt
report_constraint -all_violators > 6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.constraints.rpt
report_analysis_coverage > 6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.coverage.rpt
report_annotated_delay > 6_STA/4_Report/post_dft_topo_sdf/post_dft.func_tt_10ns_sdf.annotated_delay.rpt

exit
