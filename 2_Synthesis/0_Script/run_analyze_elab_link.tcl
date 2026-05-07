set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

source configs/library_setup.tcl

file mkdir 2_Synthesis/2_Output/pre_dft
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

check_design > 2_Synthesis/4_Report/analyze_elab_link.check_design.rpt
report_design > 2_Synthesis/4_Report/analyze_elab_link.design.rpt

write -format ddc -hierarchy -output 2_Synthesis/2_Output/pre_dft/cv32e40p_synth_wrap.elab.ddc

exit
