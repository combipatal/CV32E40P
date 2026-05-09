################################################################################
# DC Graphical topographical 합성 스크립트
#
# 목적:
#   post-DFT 전 단계의 pre-DFT netlist/DDC/SDC/SDF를 만듭니다.
#   이후 R2N Formality, DFT 삽입, pre-DFT SDF STA가 이 결과를 사용합니다.
#
# 기준:
#   TT 1.05V 25C, RVT+LVT+HVT mixed-VT, clk_i 8.5 ns
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

# timing DB library 설정을 읽습니다.
source configs/library_setup.tcl

# topographical 합성은 timing DB만으로 부족합니다.
# cell 크기, pin 위치, metal layer 정보를 보기 위해 Milkyway/tech/TLU+를 씁니다.
set TECH_FILE /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
set TLUPLUS_MAX /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
set TLUPLUS_MIN /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
set TLUPLUS_MAP /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

# RVT/LVT/HVT physical reference library입니다.
# mixed-VT 합성이므로 세 VT 모두 physical view도 필요합니다.
set MW_RVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
set MW_LVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m
set MW_HVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m
set MW_DESIGN_LIB 2_Synthesis/mw_lib/cv32e40p_topo_8p5ns_mw

# 산출물/리포트/work directory를 만듭니다.
file mkdir 2_Synthesis/2_Output/pre_dft_topo_8p5ns
file mkdir 2_Synthesis/2_Output/svf
file mkdir 2_Synthesis/3_Log
file mkdir 2_Synthesis/4_Report/topo_8p5ns
file mkdir 2_Synthesis/work_topo_8p5ns
file mkdir 2_Synthesis/mw_lib

# DC analyze/elaborate 결과가 저장될 logical work library입니다.
define_design_lib WORK -path 2_Synthesis/work_topo_8p5ns

# 이전 Milkyway design lib가 있으면 새 run 기준으로 다시 만듭니다.
file delete -force $MW_DESIGN_LIB
create_mw_lib \
  -technology $TECH_FILE \
  -mw_reference_library [list $MW_RVT $MW_LVT $MW_HVT] \
  -hier_separator {/} \
  -bus_naming_style {%d} \
  -open $MW_DESIGN_LIB

# TLU+는 DC Graphical이 routing RC를 추정할 때 쓰는 parasitic table입니다.
set_tlu_plus_files \
  -max_tluplus $TLUPLUS_MAX \
  -min_tluplus $TLUPLUS_MIN \
  -tech2itf_map $TLUPLUS_MAP

# 물리 library와 TLU+가 tool에서 읽히는지 초기 확인 리포트를 남깁니다.
check_tlu_plus_files > 2_Synthesis/4_Report/topo_8p5ns/tlu_plus.check.rpt
check_library > 2_Synthesis/4_Report/topo_8p5ns/library.check.rpt

# RTL filelist를 읽고 SystemVerilog를 analyze합니다.
source filelists/cv32e40p_dc.tcl
set_app_var search_path [concat $search_path $RTL_INC_DIRS]
analyze -format sverilog $RTL_FILES

# wrapper를 top으로 elaborate/link합니다.
# link에서 unresolved reference가 있으면 이후 compile이 의미 없습니다.
elaborate cv32e40p_synth_wrap
current_design cv32e40p_synth_wrap
link

# compile 전 구조 check와 8.5 ns functional SDC 적용입니다.
check_design > 2_Synthesis/4_Report/topo_8p5ns/pre_compile.check_design.rpt
read_sdc constraints/cv32e40p_func_8p5ns.sdc

# SVF는 Formality R2N이 DC의 최적화 정보를 따라가게 해줍니다.
set_svf 2_Synthesis/2_Output/svf/cv32e40p_synth_wrap.pre_dft_topo_8p5ns.svf

# -spg는 topographical/physical guidance를 쓰는 compile입니다.
# -gate_clock은 clock gating cell 매핑/최적화를 허용합니다.
compile_ultra -spg -gate_clock
set_svf -off

# 합성 후 품질과 timing/area/power evidence를 남깁니다.
check_design > 2_Synthesis/4_Report/topo_8p5ns/post_compile.check_design.rpt
report_qor > 2_Synthesis/4_Report/topo_8p5ns/post_compile.qor.rpt
report_timing -max_paths 20 > 2_Synthesis/4_Report/topo_8p5ns/post_compile.timing.rpt
report_constraint -all_violators > 2_Synthesis/4_Report/topo_8p5ns/post_compile.constraints.rpt
report_area -hierarchy > 2_Synthesis/4_Report/topo_8p5ns/post_compile.area.rpt
report_power -hierarchy > 2_Synthesis/4_Report/topo_8p5ns/post_compile.power.rpt

# 다음 단계가 사용할 handoff 파일입니다.
# DDC: Synopsys 내부 DB, VG: gate netlist, SDC: 제약, SDF: delay annotation.
write -format ddc -hierarchy -output 2_Synthesis/2_Output/pre_dft_topo_8p5ns/cv32e40p_synth_wrap.pre_dft_topo_8p5ns.ddc
write -format verilog -hierarchy -output 2_Synthesis/2_Output/pre_dft_topo_8p5ns/cv32e40p_synth_wrap.pre_dft_topo_8p5ns.vg
write_sdc 2_Synthesis/2_Output/pre_dft_topo_8p5ns/cv32e40p_synth_wrap.pre_dft_topo_8p5ns.sdc
write_sdf 2_Synthesis/2_Output/pre_dft_topo_8p5ns/cv32e40p_synth_wrap.pre_dft_topo_8p5ns.sdf

# Milkyway library를 닫고 batch run을 종료합니다.
close_mw_lib
exit
