################################################################################
# Formality N2N 검증 스크립트: post-DFT netlist vs post-route ECO netlist
#
# 목적:
#   DRC clean backend trial에서 ICC2가 쓴 post-route ECO netlist가
#   원래 post-DFT functional netlist와 같은지 확인합니다.
#
# 비교:
#   reference      = post_dft_topo_no_or2x1_nor2x012_hvt netlist
#   implementation = ICC2 post-route ECO exported netlist
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set TOP_NAME cv32e40p_synth_wrap
set TAG post_route_eco_drc_clean

# TT mixed-VT timing library입니다.
set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

# reference는 backend handoff에 사용한 post-DFT netlist입니다.
set REF_NETLIST 3_DFT/2_Output/post_dft_topo_no_or2x1_nor2x012_hvt/cv32e40p_synth_wrap.post_dft_topo_no_or2x1_nor2x012_hvt.vg

# implementation은 ICC2 route-clean block에서 export한 post-route ECO netlist입니다.
set IMPL_NETLIST 7_Backend_ICC2/2_Output/08_export/$TAG/cv32e40p_synth_wrap.$TAG.vg

set REPORT_DIR 5_FM_N2N/4_Report/$TAG
file mkdir 5_FM_N2N/2_Output
file mkdir 5_FM_N2N/3_Log
file mkdir $REPORT_DIR
file mkdir 5_FM_N2N/FM_WORK

# backend ECO는 equivalent drive-strength resize입니다.
# scan insertion 변환은 이미 post-DFT reference에 포함되어 있으므로 SVF는 쓰지 않습니다.
set verification_clock_gate_reverse_gating true

# gate netlist cell link용 library입니다.
read_db -technology_library [list $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]

# reference side: post-DFT functional netlist입니다.
read_verilog -r -netlist -libname WORK $REF_NETLIST
set_top r:/WORK/$TOP_NAME
set_clock r:/WORK/$TOP_NAME/clk_i

# functional mode 비교라 scan/test 포트는 0으로 고정합니다.
set_constant -type port r:/WORK/$TOP_NAME/scan_cg_en_i 0
set_constant -type port r:/WORK/$TOP_NAME/scan_en 0
set_constant -type port r:/WORK/$TOP_NAME/scan_in 0
set_dont_verify_points -directly_undriven_output

# functional mode에서는 scan_out이 architectural output이 아닙니다.
# backend export 이후 scan chain wiring 차이가 보일 수 있어 비교 대상에서 제외합니다.
set_dont_verify_points r:/WORK/$TOP_NAME/scan_out

# implementation side: post-route ECO netlist입니다.
read_verilog -i -netlist -libname WORK $IMPL_NETLIST
set_top i:/WORK/$TOP_NAME
set_clock i:/WORK/$TOP_NAME/clk_i

# reference와 같은 functional mode constant입니다.
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
