################################################################################
# DC/DFT Compiler topographical DFT 삽입 스크립트
#
# 목적:
#   pre-DFT topo DDC에 1개 muxed scan chain을 삽입합니다.
#   post-DFT netlist/DDC/SDC/SDF/SPF를 만들어 N2N, ATPG, STA로 넘깁니다.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

# DC 합성과 같은 timing library를 사용합니다.
source configs/library_setup.tcl

set TOP_NAME cv32e40p_synth_wrap

# DFT도 topo 기준으로 돌립니다.
# scan 삽입 뒤 SDF를 뽑기 위해 tech/Milkyway/TLU+를 다시 연결합니다.
set TECH_FILE /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
set TLUPLUS_MAX /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
set TLUPLUS_MIN /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
set TLUPLUS_MAP /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

# mixed-VT physical reference library입니다.
set MW_RVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
set MW_LVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m
set MW_HVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m
set MW_DESIGN_LIB 3_DFT/mw_lib/cv32e40p_post_dft_topo_mw

# 입력은 topo 합성 결과 DDC입니다.
set PRE_DFT_DDC 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.ddc
set POST_DFT_DIR 3_DFT/2_Output/post_dft_topo
set SVF_DIR 3_DFT/2_Output/svf
set REPORT_DIR 3_DFT/4_Report/topo

# 산출물/리포트/work directory입니다.
file mkdir $POST_DFT_DIR
file mkdir $SVF_DIR
file mkdir 3_DFT/3_Log
file mkdir $REPORT_DIR
file mkdir 3_DFT/work_topo
file mkdir 3_DFT/mw_lib

# DFT run용 WORK library입니다.
define_design_lib WORK -path 3_DFT/work_topo

# DFT용 Milkyway design lib를 새로 만듭니다.
file delete -force $MW_DESIGN_LIB
create_mw_lib \
  -technology $TECH_FILE \
  -mw_reference_library [list $MW_RVT $MW_LVT $MW_HVT] \
  -hier_separator {/} \
  -bus_naming_style {%d} \
  -open $MW_DESIGN_LIB

# topo RC 추정을 위한 TLU+ 설정입니다.
set_tlu_plus_files \
  -max_tluplus $TLUPLUS_MAX \
  -min_tluplus $TLUPLUS_MIN \
  -tech2itf_map $TLUPLUS_MAP

# library setup evidence입니다.
check_tlu_plus_files > $REPORT_DIR/tlu_plus.check.rpt
check_library > $REPORT_DIR/library.check.rpt

# pre-DFT DDC를 읽고 design을 link합니다.
read_ddc $PRE_DFT_DDC
current_design $TOP_NAME
link

# DFT DRC와 scan insertion에 필요한 기본 functional clock/reset 제약입니다.
create_clock -name clk_i -period 10.0 [get_ports clk_i]
set_clock_uncertainty 0.1 [get_clocks clk_i]
set_false_path -from [get_ports rst_ni]

# scan style: muxed scan FF, scan chain 1개.
# lockup latch는 clock skew/phase 문제 완화를 위해 허용합니다.
set_scan_configuration \
  -style multiplexed_flip_flop \
  -chain_count 1 \
  -clock_mixing no_mix \
  -add_lockup true

# scan 삽입과 clock-gating test 제어 연결을 활성화합니다.
set_dft_configuration \
  -scan enable \
  -connect_clock_gating enable

# 기존 design에 이미 존재하는 test 관련 포트 정의입니다.
set_dft_signal -view existing_dft -type ScanClock -port clk_i -timing {45 55}
set_dft_signal -view existing_dft -type Reset -port rst_ni -active_state 0
set_dft_signal -view existing_dft -type TestMode -port scan_cg_en_i -active_state 1

# 삽입할 scan chain의 scan enable/input/output 정의입니다.
set_dft_signal -view spec -type ScanEnable -port scan_en -active_state 1
set_dft_signal -view spec -type ScanDataIn -port scan_in
set_dft_signal -view spec -type ScanDataOut -port scan_out
set_scan_path chain0 -view spec -scan_data_in scan_in -scan_data_out scan_out

# scan 설정 evidence입니다.
report_scan_configuration > $REPORT_DIR/scan_configuration.rpt
report_dft_signal -view existing_dft > $REPORT_DIR/dft_signal.existing.rpt
report_dft_signal -view spec > $REPORT_DIR/dft_signal.spec.rpt
report_dft_clock_gating_pin > $REPORT_DIR/dft_clock_gating_pin.pre.rpt

# ATPG가 사용할 test protocol을 생성합니다.
create_test_protocol

# scan 삽입 전 DFT DRC입니다.
dft_drc > $REPORT_DIR/pre_dft.drc.rpt
dft_drc -verbose > $REPORT_DIR/pre_dft.drc.verbose.rpt

# SVF는 N2N Formality가 DFT 삽입 변환을 추적할 때 사용합니다.
set_svf $SVF_DIR/cv32e40p_synth_wrap.post_dft_topo.svf
insert_dft
set_svf -off

# scan 삽입 후 DFT DRC입니다.
current_test_mode Internal_scan
dft_drc > $REPORT_DIR/post_dft.drc.rpt
dft_drc -verbose > $REPORT_DIR/post_dft.drc.verbose.rpt

# post-DFT 구조와 scan path evidence를 저장합니다.
report_scan_path -view existing_dft > $REPORT_DIR/scan_path.existing.rpt
report_scan_path -view spec > $REPORT_DIR/scan_path.spec.rpt
report_dft_signal -view existing_dft > $REPORT_DIR/dft_signal.existing.post.rpt
report_dft_drc_violations > $REPORT_DIR/dft_drc_violations.rpt
write_test_protocol -output $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.spf

# ICC2 placement가 scan chain 정보를 읽을 수 있도록 scan DEF도 저장합니다.
# SPF는 ATPG용이고, scan DEF는 backend placement/reorder handoff용입니다.
write_scan_def \
  -version 5.8 \
  -output $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.scan.def

# post-DFT QoR/timing/area/power evidence입니다.
report_qor > $REPORT_DIR/post_dft.qor.rpt
report_timing -max_paths 20 > $REPORT_DIR/post_dft.timing.rpt
report_constraint -all_violators > $REPORT_DIR/post_dft.constraints.rpt
report_area -hierarchy > $REPORT_DIR/post_dft.area.rpt
report_power -hierarchy > $REPORT_DIR/post_dft.power.rpt

# downstream handoff 파일입니다.
# SPF는 TetraMAX, SDF는 PrimeTime post-DFT STA에서 사용합니다.
write -format ddc -hierarchy -output $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.ddc
write -format verilog -hierarchy -output $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.vg
write_sdc $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.sdc
write_sdf $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.sdf

close_mw_lib
exit
