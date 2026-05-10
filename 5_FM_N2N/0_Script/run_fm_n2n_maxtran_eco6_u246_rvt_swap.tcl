################################################################################
# Formality N2N 검증 스크립트: post-DFT netlist vs maxtran ECO6 netlist
#
# 목적:
#   U246 RVT swap 이후 netlist가
#   post-DFT functional netlist와 같은지 확인합니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set TOP_NAME cv32e40p_synth_wrap
set TAG maxtran_eco6_u246_rvt_swap

# TT mixed-VT timing library입니다.
set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set REF_NETLIST 3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg
set IMPL_NETLIST 7_Backend_ICC2/2_Output/07_extract_sta/$TAG/cv32e40p_synth_wrap.$TAG.vg

set REPORT_DIR 5_FM_N2N/4_Report/$TAG
file mkdir 5_FM_N2N/2_Output
file mkdir 5_FM_N2N/3_Log
file mkdir $REPORT_DIR
file mkdir 5_FM_N2N/FM_WORK

# scan insertion 변환은 이미 post-DFT reference에 포함되어 있으므로 SVF는 쓰지 않습니다.
set verification_clock_gate_reverse_gating true

read_db -technology_library [list $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

# reference side
read_verilog -r -netlist -libname WORK $REF_NETLIST
set_top r:/WORK/$TOP_NAME
set_clock r:/WORK/$TOP_NAME/clk_i
set_constant -type port r:/WORK/$TOP_NAME/scan_cg_en_i 0
set_constant -type port r:/WORK/$TOP_NAME/scan_en 0
set_constant -type port r:/WORK/$TOP_NAME/scan_in 0
set_dont_verify_points -directly_undriven_output
set_dont_verify_points r:/WORK/$TOP_NAME/scan_out

# implementation side
read_verilog -i -netlist -libname WORK $IMPL_NETLIST
set_top i:/WORK/$TOP_NAME
set_clock i:/WORK/$TOP_NAME/clk_i
set_constant -type port i:/WORK/$TOP_NAME/scan_cg_en_i 0
set_constant -type port i:/WORK/$TOP_NAME/scan_en 0
set_constant -type port i:/WORK/$TOP_NAME/scan_in 0
set_dont_verify_points i:/WORK/$TOP_NAME/scan_out

match

report_unmatched_points > $REPORT_DIR/n2n_$TAG.unmatched_points.rpt
report_passing_points > $REPORT_DIR/n2n_$TAG.passing_points.rpt

verify

report_failing_points > $REPORT_DIR/n2n_$TAG.failing_points.rpt
report_unmatched_points > $REPORT_DIR/n2n_$TAG.unmatched_points.post_verify.rpt
report_passing_points > $REPORT_DIR/n2n_$TAG.passing_points.post_verify.rpt

save_session -replace 5_FM_N2N/2_Output/n2n_${TAG}_fm_session

exit
