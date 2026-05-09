################################################################################
# PrimeTime post-DFT topo/SDF STA 스크립트
#
# 목적:
#   DFT 삽입 후 netlist에 post-DFT SDF delay를 annotate해서
#   scan 삽입 이후 functional setup/hold timing을 확인합니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

# DC/DFT와 같은 TT mixed-VT timing DB입니다.
set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

# DFT 삽입 후 netlist와 SDF입니다.
set TOP_NAME cv32e40p_synth_wrap
set NETLIST 3_DFT/2_Output/post_dft_topo_8p5ns/cv32e40p_synth_wrap.post_dft_topo_8p5ns.vg
set SDC_FILE constraints/cv32e40p_func_8p5ns.sdc
set SDF_FILE 3_DFT/2_Output/post_dft_topo_8p5ns/cv32e40p_synth_wrap.post_dft_topo_8p5ns.sdf

# 리포트와 로그 directory입니다.
file mkdir 6_STA/4_Report/post_dft_topo_8p5ns_sdf
file mkdir 6_STA/3_Log

# PrimeTime link library입니다.
set link_path [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

# post-DFT netlist를 읽고 top design을 link합니다.
read_verilog $NETLIST
current_design $TOP_NAME
link_design

# functional SDC와 post-DFT SDF delay를 적용합니다.
read_sdc $SDC_FILE
read_sdf $SDF_FILE

# timing coverage, setup/hold, constraint, annotation evidence를 저장합니다.
check_timing -verbose > 6_STA/4_Report/post_dft_topo_8p5ns_sdf/post_dft.func_tt_8p5ns_sdf.check_timing.rpt
report_global_timing > 6_STA/4_Report/post_dft_topo_8p5ns_sdf/post_dft.func_tt_8p5ns_sdf.global_timing.rpt
report_timing -delay_type max -max_paths 20 -slack_lesser_than 100 > 6_STA/4_Report/post_dft_topo_8p5ns_sdf/post_dft.func_tt_8p5ns_sdf.setup_timing.rpt
report_timing -delay_type min -max_paths 20 -slack_lesser_than 100 > 6_STA/4_Report/post_dft_topo_8p5ns_sdf/post_dft.func_tt_8p5ns_sdf.hold_timing.rpt
report_constraint -all_violators > 6_STA/4_Report/post_dft_topo_8p5ns_sdf/post_dft.func_tt_8p5ns_sdf.constraints.rpt
report_analysis_coverage > 6_STA/4_Report/post_dft_topo_8p5ns_sdf/post_dft.func_tt_8p5ns_sdf.coverage.rpt
report_annotated_delay > 6_STA/4_Report/post_dft_topo_8p5ns_sdf/post_dft.func_tt_8p5ns_sdf.annotated_delay.rpt

exit
