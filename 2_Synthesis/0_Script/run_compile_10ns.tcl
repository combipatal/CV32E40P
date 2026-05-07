set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

source configs/library_setup.tcl

file mkdir 2_Synthesis/2_Output/pre_dft
file mkdir 2_Synthesis/2_Output/svf
file mkdir 2_Synthesis/3_Log
file mkdir 2_Synthesis/4_Report
file mkdir 2_Synthesis/work

define_design_lib WORK -path 2_Synthesis/work

source filelists/cv32e40p_dc.tcl
set_app_var search_path [concat $search_path $RTL_INC_DIRS]
analyze -format sverilog $RTL_FILES
elaborate cv32e40p_synth_wrap
current_design cv32e40p_synth_wrap
link

check_design > 2_Synthesis/4_Report/pre_compile.check_design.rpt
read_sdc constraints/cv32e40p_func_10ns.sdc

set_svf 2_Synthesis/2_Output/svf/cv32e40p_synth_wrap.pre_dft.svf
compile_ultra -gate_clock
set_svf -off

check_design > 2_Synthesis/4_Report/post_compile.check_design.rpt
report_qor > 2_Synthesis/4_Report/post_compile.qor.rpt
report_timing -max_paths 20 > 2_Synthesis/4_Report/post_compile.timing.rpt
report_constraint -all_violators > 2_Synthesis/4_Report/post_compile.constraints.rpt
report_area -hierarchy > 2_Synthesis/4_Report/post_compile.area.rpt
report_power -hierarchy > 2_Synthesis/4_Report/post_compile.power.rpt

write -format ddc -hierarchy -output 2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.ddc
write -format verilog -hierarchy -output 2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.vg
write_sdc 2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.pre_dft.sdc

exit
