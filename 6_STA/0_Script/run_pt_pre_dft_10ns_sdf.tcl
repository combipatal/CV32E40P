################################################################################
# PrimeTime pre-DFT topo/SDF STA 스크립트
#
# 목적:
#   DC Graphical topo 합성 netlist에 합성 SDF delay를 annotate해서
#   pre-DFT setup/hold timing을 확인합니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

# DC 합성과 같은 TT mixed-VT timing DB입니다.
set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

# topo 합성 결과 netlist/SDC/SDF입니다.
set TOP_NAME cv32e40p_synth_wrap
set NETLIST 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.vg
set SDC_FILE constraints/cv32e40p_func_10ns.sdc
set SDF_FILE 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.sdf

# 리포트와 로그 directory입니다.
file mkdir 6_STA/4_Report/topo_sdf
file mkdir 6_STA/3_Log

# PrimeTime이 gate cell을 link할 library path입니다.
set link_path [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

# netlist를 읽고 top design을 link합니다.
read_verilog $NETLIST
current_design $TOP_NAME
link_design

# functional SDC와 SDF delay를 적용합니다.
read_sdc $SDC_FILE
read_sdf $SDF_FILE

# timing coverage, setup/hold, constraint, annotation evidence를 저장합니다.
check_timing -verbose > 6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.check_timing.rpt
report_global_timing > 6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.global_timing.rpt
report_timing -delay_type max -max_paths 20 -slack_lesser_than 100 > 6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.setup_timing.rpt
report_timing -delay_type min -max_paths 20 -slack_lesser_than 100 > 6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.hold_timing.rpt
report_constraint -all_violators > 6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.constraints.rpt
report_analysis_coverage > 6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.coverage.rpt
report_annotated_delay > 6_STA/4_Report/topo_sdf/pre_dft.func_tt_10ns_sdf.annotated_delay.rpt

exit
