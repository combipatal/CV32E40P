set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

source configs/library_setup.tcl

set TOP_NAME cv32e40p_synth_wrap

set TECH_FILE /DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
set TLUPLUS_MAX /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
set TLUPLUS_MIN /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
set TLUPLUS_MAP /DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

set MW_RVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
set MW_LVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m
set MW_HVT /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m
set MW_DESIGN_LIB 3_DFT/mw_lib/cv32e40p_post_dft_topo_mw

set PRE_DFT_DDC 2_Synthesis/2_Output/pre_dft_topo/cv32e40p_synth_wrap.pre_dft_topo.ddc
set POST_DFT_DIR 3_DFT/2_Output/post_dft_topo
set SVF_DIR 3_DFT/2_Output/svf
set REPORT_DIR 3_DFT/4_Report/topo

file mkdir $POST_DFT_DIR
file mkdir $SVF_DIR
file mkdir 3_DFT/3_Log
file mkdir $REPORT_DIR
file mkdir 3_DFT/work_topo
file mkdir 3_DFT/mw_lib

define_design_lib WORK -path 3_DFT/work_topo

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

check_tlu_plus_files > $REPORT_DIR/tlu_plus.check.rpt
check_library > $REPORT_DIR/library.check.rpt

read_ddc $PRE_DFT_DDC
current_design $TOP_NAME
link

create_clock -name clk_i -period 10.0 [get_ports clk_i]
set_clock_uncertainty 0.1 [get_clocks clk_i]
set_false_path -from [get_ports rst_ni]

set_scan_configuration \
  -style multiplexed_flip_flop \
  -chain_count 1 \
  -clock_mixing no_mix \
  -add_lockup true

set_dft_configuration \
  -scan enable \
  -connect_clock_gating enable

set_dft_signal -view existing_dft -type ScanClock -port clk_i -timing {45 55}
set_dft_signal -view existing_dft -type Reset -port rst_ni -active_state 0
set_dft_signal -view existing_dft -type TestMode -port scan_cg_en_i -active_state 1

set_dft_signal -view spec -type ScanEnable -port scan_en -active_state 1
set_dft_signal -view spec -type ScanDataIn -port scan_in
set_dft_signal -view spec -type ScanDataOut -port scan_out
set_scan_path chain0 -view spec -scan_data_in scan_in -scan_data_out scan_out

report_scan_configuration > $REPORT_DIR/scan_configuration.rpt
report_dft_signal -view existing_dft > $REPORT_DIR/dft_signal.existing.rpt
report_dft_signal -view spec > $REPORT_DIR/dft_signal.spec.rpt
report_dft_clock_gating_pin > $REPORT_DIR/dft_clock_gating_pin.pre.rpt

create_test_protocol

dft_drc > $REPORT_DIR/pre_dft.drc.rpt
dft_drc -verbose > $REPORT_DIR/pre_dft.drc.verbose.rpt

set_svf $SVF_DIR/cv32e40p_synth_wrap.post_dft_topo.svf
insert_dft
set_svf -off

current_test_mode Internal_scan
dft_drc > $REPORT_DIR/post_dft.drc.rpt
dft_drc -verbose > $REPORT_DIR/post_dft.drc.verbose.rpt

report_scan_path -view existing_dft > $REPORT_DIR/scan_path.existing.rpt
report_scan_path -view spec > $REPORT_DIR/scan_path.spec.rpt
report_dft_signal -view existing_dft > $REPORT_DIR/dft_signal.existing.post.rpt
report_dft_drc_violations > $REPORT_DIR/dft_drc_violations.rpt
write_test_protocol -output $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.spf
report_qor > $REPORT_DIR/post_dft.qor.rpt
report_timing -max_paths 20 > $REPORT_DIR/post_dft.timing.rpt
report_constraint -all_violators > $REPORT_DIR/post_dft.constraints.rpt
report_area -hierarchy > $REPORT_DIR/post_dft.area.rpt
report_power -hierarchy > $REPORT_DIR/post_dft.power.rpt

write -format ddc -hierarchy -output $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.ddc
write -format verilog -hierarchy -output $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.vg
write_sdc $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.sdc
write_sdf $POST_DFT_DIR/cv32e40p_synth_wrap.post_dft_topo.sdf

close_mw_lib
exit
