set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

source configs/library_setup.tcl

set TECH_FILE /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
set TLUPLUS_MAX /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
set TLUPLUS_MIN /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
set TLUPLUS_MAP /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

set MW_RVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
set MW_LVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m
set MW_HVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m
set MW_DESIGN_LIB 2_Synthesis/mw_lib/cv32e40p_topo_mw

file mkdir 2_Synthesis/2_Output/pre_dft_topo
file mkdir 2_Synthesis/2_Output/svf
file mkdir 2_Synthesis/3_Log
file mkdir 2_Synthesis/4_Report/topo
file mkdir 2_Synthesis/work_topo
file mkdir 2_Synthesis/mw_lib

define_design_lib WORK -path 2_Synthesis/work_topo

file delete -force $MW_DESIGN_LIB
create_mw_lib \
  -technology $TECH_FILE \
  -mw_reference_library [list $MW_RVT $MW_LVT $MW_HVT] \
  -hier_separator {/} \
  -bus_naming_style {%d} \
  -open $MW_DESIGN_LIB

set_tlu_plus_files \
  -max_tluplus $TLUPLUS_MAX \
  -min_tluplus $TLUPLUS_MIN \
  -tech2itf_map $TLUPLUS_MAP

check_tlu_plus_files > 2_Synthesis/4_Report/topo/tlu_plus.check.rpt
check_library > 2_Synthesis/4_Report/topo/library.check.rpt

source filelists/cv32e40p_dc.tcl
set_app_var search_path [concat $search_path $RTL_INC_DIRS]
analyze -format sverilog $RTL_FILES
elaborate cv32e40p_synth_wrap
current_design cv32e40p_synth_wrap
link

check_design > 2_Synthesis/4_Report/topo/pre_compile.check_design.rpt
read_sdc constraints/cv32e40p_func_10ns.sdc

set_svf 2_Synthesis/2_Output/svf/cv32e40p_synth_wrap.pre_dft_topo.svf
compile_ultra -spg -gate_clock
set_svf -off

check_design > 2_Synthesis/4_Report/topo/post_compile.check_design.rpt
report_qor > 2_Synthesis/4_Report/topo/post_compile.qor.rpt
report_timing -max_paths 20 > 2_Synthesis/4_Report/topo/post_compile.timing.rpt
report_constraint -all_violators > 2_Synthesis/4_Report/topo/post_compile.constraints.rpt
report_area -hierarchy > 2_Synthesis/4_Report/topo/post_compile.area.rpt
report_power -hierarchy > 2_Synthesis/4_Report/topo/post_compile.power.rpt

write -format ddc -hierarchy -output 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.ddc
write -format verilog -hierarchy -output 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.vg
write_sdc 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.sdc
write_sdf 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.sdf

close_mw_lib
exit
