################################################################################
# Formality N2N 검증 스크립트: no_mux41x_hvt 실험
#
# 목적:
#   MUX41X*_HVT를 synthesis dont_use 처리한 pre-DFT netlist와
#   그 netlist에서 scan 삽입한 post-DFT netlist가 functional mode에서 같은지 확인합니다.
#   N2N = Netlist-to-Netlist 입니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set TOP_NAME cv32e40p_synth_wrap

# DC/DFT와 같은 TT mixed-VT timing library입니다.
set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

# reference는 DFT 전 netlist, implementation은 DFT 후 netlist입니다.
set REF_NETLIST 2_Synthesis/2_Output/pre_dft_topo_no_mux41x_hvt/cv32e40p_synth_wrap.pre_dft_topo_no_mux41x_hvt.vg
set IMPL_NETLIST 3_DFT/2_Output/post_dft_topo_no_mux41x_hvt/cv32e40p_synth_wrap.post_dft_topo_no_mux41x_hvt.vg
set SVF_FILE 3_DFT/2_Output/svf_no_mux41x_hvt/cv32e40p_synth_wrap.post_dft_topo_no_mux41x_hvt.svf

# 리포트와 Formality session 저장 위치입니다.
set REPORT_DIR 5_FM_N2N/4_Report/no_mux41x_hvt
file mkdir 5_FM_N2N/2_Output
file mkdir 5_FM_N2N/3_Log
file mkdir $REPORT_DIR
file mkdir 5_FM_N2N/FM_WORK

# DFT Compiler가 만든 SVF를 읽어 scan insertion 변환을 추적합니다.
set_svf $SVF_FILE

# clock-gating 구조 차이를 등가 비교할 수 있게 합니다.
set verification_clock_gate_reverse_gating true

# gate netlist cell link용 library입니다.
read_db -technology_library [list $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

# reference side: no_mux41x_hvt pre-DFT topo netlist입니다.
read_verilog -r -netlist -libname WORK $REF_NETLIST
set_top r:/WORK/$TOP_NAME
set_clock r:/WORK/$TOP_NAME/clk_i

# functional mode 비교라 scan/test 포트는 0으로 고정합니다.
set_constant -type port r:/WORK/$TOP_NAME/scan_cg_en_i 0
set_constant -type port r:/WORK/$TOP_NAME/scan_en 0
set_constant -type port r:/WORK/$TOP_NAME/scan_in 0
set_dont_verify_points -directly_undriven_output

# implementation side: no_mux41x_hvt post-DFT topo netlist입니다.
read_verilog -i -netlist -libname WORK $IMPL_NETLIST
set_top i:/WORK/$TOP_NAME
set_clock i:/WORK/$TOP_NAME/clk_i

# reference와 같은 functional mode constant입니다.
set_constant -type port i:/WORK/$TOP_NAME/scan_cg_en_i 0
set_constant -type port i:/WORK/$TOP_NAME/scan_en 0
set_constant -type port i:/WORK/$TOP_NAME/scan_in 0

# compare point match 후 verify를 수행합니다.
match

report_unmatched_points > $REPORT_DIR/n2n_topo_no_mux41x_hvt.unmatched_points.rpt
report_passing_points > $REPORT_DIR/n2n_topo_no_mux41x_hvt.passing_points.rpt

verify

# 검증 evidence report입니다.
report_failing_points > $REPORT_DIR/n2n_topo_no_mux41x_hvt.failing_points.rpt
report_unmatched_points > $REPORT_DIR/n2n_topo_no_mux41x_hvt.unmatched_points.post_verify.rpt
report_passing_points > $REPORT_DIR/n2n_topo_no_mux41x_hvt.passing_points.post_verify.rpt

# 디버그 재현을 위한 session 저장입니다.
save_session -replace 5_FM_N2N/2_Output/n2n_topo_no_mux41x_hvt_fm_session

exit
