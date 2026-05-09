################################################################################
# Formality R2N 검증 실험 스크립트
#
# 목적:
#   RTL reference와 no_or2x1_nor2x012_or2x4_hvt pre-DFT netlist implementation이 기능적으로 같은지 확인합니다.
#   R2N = RTL-to-Netlist 입니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set TOP_NAME cv32e40p_synth_wrap

# DC 합성과 같은 TT mixed-VT timing library를 사용합니다.
set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

# implementation 쪽은 DC Graphical topo 합성 결과입니다.
set NETLIST 2_Synthesis/2_Output/pre_dft_topo_no_or2x1_nor2x012_or2x4_hvt/cv32e40p_synth_wrap.pre_dft_topo_no_or2x1_nor2x012_or2x4_hvt.vg
set SVF_FILE 2_Synthesis/2_Output/svf_no_or2x1_nor2x012_or2x4_hvt/cv32e40p_synth_wrap.pre_dft_topo_no_or2x1_nor2x012_or2x4_hvt.svf

# 리포트와 Formality session 저장 위치입니다.
file mkdir 2.5_FM_R2N/3_Log
file mkdir 2.5_FM_R2N/4_Report/no_or2x1_nor2x012_or2x4_hvt
file mkdir 2.5_FM_R2N/2_Output
file mkdir 2.5_FM_R2N/FM_WORK

# SVF는 DC 최적화/이름변경/clock-gating 정보를 Formality에 전달합니다.
set_svf $SVF_FILE

# 일부 package elaboration warning은 현재 flow에서 비교 실패 원인이 아니어서 숨깁니다.
suppress_message FMR_ELAB-116

# clock-gating 최적화를 역추적해서 RTL과 gate netlist를 맞춥니다.
set verification_clock_gate_reverse_gating true

# gate netlist cell을 link할 technology library입니다.
read_db -technology_library [list $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

# reference side: 원본 RTL을 읽습니다.
source filelists/cv32e40p_dc.tcl
read_sverilog -r -12 -libname WORK $RTL_FILES
set_top r:/WORK/$TOP_NAME
set_clock r:/WORK/$TOP_NAME/clk_i

# functional mode 비교입니다. scan/test 포트는 0으로 고정합니다.
set_constant -type port r:/WORK/$TOP_NAME/scan_cg_en_i 0
set_constant -type port r:/WORK/$TOP_NAME/scan_en 0
set_constant -type port r:/WORK/$TOP_NAME/scan_in 0

# 직접 구동되지 않는 output은 비교 대상에서 제외합니다.
set_dont_verify_points -directly_undriven_output

# implementation side: DC topo gate netlist를 읽습니다.
read_verilog -i -netlist -libname WORK $NETLIST
set_top i:/WORK/$TOP_NAME
set_clock i:/WORK/$TOP_NAME/clk_i

# reference와 같은 functional mode constant를 적용합니다.
set_constant -type port i:/WORK/$TOP_NAME/scan_cg_en_i 0
set_constant -type port i:/WORK/$TOP_NAME/scan_en 0
set_constant -type port i:/WORK/$TOP_NAME/scan_in 0

# compare point를 매칭한 뒤 검증합니다.
match

report_unmatched_points > 2.5_FM_R2N/4_Report/no_or2x1_nor2x012_or2x4_hvt/r2n_topo_no_or2x1_nor2x012_or2x4_hvt.unmatched_points.rpt
report_passing_points > 2.5_FM_R2N/4_Report/no_or2x1_nor2x012_or2x4_hvt/r2n_topo_no_or2x1_nor2x012_or2x4_hvt.passing_points.rpt

verify

# 검증 후 evidence report를 남깁니다.
report_failing_points > 2.5_FM_R2N/4_Report/no_or2x1_nor2x012_or2x4_hvt/r2n_topo_no_or2x1_nor2x012_or2x4_hvt.failing_points.rpt
report_unmatched_points > 2.5_FM_R2N/4_Report/no_or2x1_nor2x012_or2x4_hvt/r2n_topo_no_or2x1_nor2x012_or2x4_hvt.unmatched_points.post_verify.rpt
report_passing_points > 2.5_FM_R2N/4_Report/no_or2x1_nor2x012_or2x4_hvt/r2n_topo_no_or2x1_nor2x012_or2x4_hvt.passing_points.post_verify.rpt

# 문제가 생겼을 때 GUI/재현용으로 session을 저장합니다.
save_session -replace 2.5_FM_R2N/2_Output/r2n_topo_no_or2x1_nor2x012_or2x4_hvt_fm_session

exit
