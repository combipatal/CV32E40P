set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set TOP_NAME cv32e40p_synth_wrap

set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set REF_NETLIST 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.vg
set IMPL_NETLIST 3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.vg
set SVF_FILE 3_DFT/2_Output/svf/cv32e40p_synth_wrap.post_dft_topo.svf

file mkdir 5_FM_N2N/2_Output
file mkdir 5_FM_N2N/3_Log
file mkdir 5_FM_N2N/4_Report
file mkdir 5_FM_N2N/FM_WORK

set_svf $SVF_FILE

set verification_clock_gate_reverse_gating true

read_db -technology_library [list $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

read_verilog -r -netlist -libname WORK $REF_NETLIST
set_top r:/WORK/$TOP_NAME
set_clock r:/WORK/$TOP_NAME/clk_i
set_constant -type port r:/WORK/$TOP_NAME/scan_cg_en_i 0
set_constant -type port r:/WORK/$TOP_NAME/scan_en 0
set_constant -type port r:/WORK/$TOP_NAME/scan_in 0
set_dont_verify_points -directly_undriven_output

read_verilog -i -netlist -libname WORK $IMPL_NETLIST
set_top i:/WORK/$TOP_NAME
set_clock i:/WORK/$TOP_NAME/clk_i
set_constant -type port i:/WORK/$TOP_NAME/scan_cg_en_i 0
set_constant -type port i:/WORK/$TOP_NAME/scan_en 0
set_constant -type port i:/WORK/$TOP_NAME/scan_in 0

match

report_unmatched_points > 5_FM_N2N/4_Report/n2n_topo.unmatched_points.rpt
report_passing_points > 5_FM_N2N/4_Report/n2n_topo.passing_points.rpt

verify

report_failing_points > 5_FM_N2N/4_Report/n2n_topo.failing_points.rpt
report_unmatched_points > 5_FM_N2N/4_Report/n2n_topo.unmatched_points.post_verify.rpt
report_passing_points > 5_FM_N2N/4_Report/n2n_topo.passing_points.post_verify.rpt

save_session -replace 5_FM_N2N/2_Output/n2n_topo_fm_session

exit
