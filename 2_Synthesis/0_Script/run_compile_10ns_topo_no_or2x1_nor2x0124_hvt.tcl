################################################################################
# DC Graphical topographical 합성 실험 스크립트
#
# 목적:
#   OR2X1_HVT 제거 후 남은 Off-grid DRC가 NOR2X0/1/2/4_HVT에서 오는지 확인합니다.
#   baseline 산출물을 덮어쓰지 않기 위해 별도 output/report/work 경로를 씁니다.
#
# 기준:
#   TT 1.05V 25C, RVT+LVT+HVT mixed-VT, clk_i 10 ns
#   OR2X1_HVT + NOR2X0_HVT + NOR2X1_HVT + NOR2X2_HVT + NOR2X4_HVT dont_use
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
set MW_DESIGN_LIB 2_Synthesis/mw_lib/cv32e40p_topo_no_or2x1_nor2x0124_hvt_mw

# 산출물/리포트/work directory를 만듭니다.
file mkdir 2_Synthesis/2_Output/pre_dft_topo_no_or2x1_nor2x0124_hvt
file mkdir 2_Synthesis/2_Output/svf_no_or2x1_nor2x0124_hvt
file mkdir 2_Synthesis/3_Log
file mkdir 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt
file mkdir 2_Synthesis/work_topo_no_or2x1_nor2x0124_hvt
file mkdir 2_Synthesis/mw_lib

# DC analyze/elaborate 결과가 저장될 logical work library입니다.
define_design_lib WORK -path 2_Synthesis/work_topo_no_or2x1_nor2x0124_hvt

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
check_tlu_plus_files > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/tlu_plus.check.rpt
check_library > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/library.check.rpt

# RTL filelist를 읽고 SystemVerilog를 analyze합니다.
source filelists/cv32e40p_dc.tcl
set_app_var search_path [concat $search_path $RTL_INC_DIRS]
analyze -format sverilog $RTL_FILES

# wrapper를 top으로 elaborate/link합니다.
# link에서 unresolved reference가 있으면 이후 compile이 의미 없습니다.
elaborate cv32e40p_synth_wrap
current_design cv32e40p_synth_wrap
link

# compile 전 구조 check와 10 ns functional SDC 적용입니다.
check_design > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/pre_compile.check_design.rpt
read_sdc constraints/cv32e40p_func_10ns.sdc

# no_or2x1_nor2x012_hvt route context에서 남은 대표 marker가
# NOR2X4_HVT 주변에 가장 많이 반복됩니다.
# 이 trial은 MVT는 유지하고 OR2X1_HVT와 NOR2X0/1/2/4_HVT만 금지합니다.
set_dont_use [get_lib_cells -quiet */OR2X1_HVT]
set_dont_use [get_lib_cells -quiet */NOR2X0_HVT]
set_dont_use [get_lib_cells -quiet */NOR2X1_HVT]
set_dont_use [get_lib_cells -quiet */NOR2X2_HVT]
set_dont_use [get_lib_cells -quiet */NOR2X4_HVT]

# SVF는 Formality R2N이 DC의 최적화 정보를 따라가게 해줍니다.
set_svf 2_Synthesis/2_Output/svf_no_or2x1_nor2x0124_hvt/cv32e40p_synth_wrap.pre_dft_topo_no_or2x1_nor2x0124_hvt.svf

# -spg는 topographical/physical guidance를 쓰는 compile입니다.
# -gate_clock은 clock gating cell 매핑/최적화를 허용합니다.
compile_ultra -spg -gate_clock
set_svf -off

# 합성 후 품질과 timing/area/power evidence를 남깁니다.
check_design > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.check_design.rpt
report_qor > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.qor.rpt
report_timing -max_paths 20 > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.timing.rpt
report_constraint -all_violators > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.constraints.rpt
report_area -hierarchy > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.area.rpt
report_power -hierarchy > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.power.rpt
report_reference -hierarchy > 2_Synthesis/4_Report/topo_no_or2x1_nor2x0124_hvt/post_compile.references.rpt

# 다음 단계가 사용할 handoff 파일입니다.
# DDC: Synopsys 내부 DB, VG: gate netlist, SDC: 제약, SDF: delay annotation.
write -format ddc -hierarchy -output 2_Synthesis/2_Output/pre_dft_topo_no_or2x1_nor2x0124_hvt/cv32e40p_synth_wrap.pre_dft_topo_no_or2x1_nor2x0124_hvt.ddc
write -format verilog -hierarchy -output 2_Synthesis/2_Output/pre_dft_topo_no_or2x1_nor2x0124_hvt/cv32e40p_synth_wrap.pre_dft_topo_no_or2x1_nor2x0124_hvt.vg
write_sdc 2_Synthesis/2_Output/pre_dft_topo_no_or2x1_nor2x0124_hvt/cv32e40p_synth_wrap.pre_dft_topo_no_or2x1_nor2x0124_hvt.sdc
write_sdf 2_Synthesis/2_Output/pre_dft_topo_no_or2x1_nor2x0124_hvt/cv32e40p_synth_wrap.pre_dft_topo_no_or2x1_nor2x0124_hvt.sdf

# Milkyway library를 닫고 batch run을 종료합니다.
close_mw_lib
exit
