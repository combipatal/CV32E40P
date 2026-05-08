################################################################################
# CV32E40P backend Phase 2용 ICC2 공통 설정
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set TOP_NAME cv32e40p_synth_wrap

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK

# Front-End baseline과 같은 TT mixed-VT timing library입니다.
set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB $SAED32_ROOT/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB $SAED32_ROOT/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

# Milkyway reference library입니다.
# 현재 ICC2 init은 NDM을 쓰지만, 원본 physical source 경로를 기록용으로 남깁니다.
set MW_RVT $SAED32_ROOT/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
set MW_LVT $SAED32_ROOT/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m
set MW_HVT $SAED32_ROOT/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m

# 00_setup/build_saed32_ndm.tcl로 만든 ICC2 reference library입니다.
# physical implementation에 필요한 timing + physical abstract를 제공합니다.
set NDM_RVT $PROJECT_ROOT/7_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm
set NDM_LVT $PROJECT_ROOT/7_Backend_ICC2/2_Output/00_setup/ndm/saed32lvt_tt.ndm
set NDM_HVT $PROJECT_ROOT/7_Backend_ICC2/2_Output/00_setup/ndm/saed32hvt_tt.ndm

# technology와 RC 관련 파일입니다.
set TECH_FILE $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf
set TLUPLUS_MAX $SAED32_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
set TLUPLUS_MIN $SAED32_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
set TLUPLUS_MAP $SAED32_ROOT/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

# Front-End가 넘겨준 post-DFT handoff 파일입니다.
set POST_DFT_NETLIST $PROJECT_ROOT/3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.vg
set POST_DFT_SDC     $PROJECT_ROOT/3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.sdc

# Backend 작업 directory입니다.
set SETUP_LOG_DIR $PROJECT_ROOT/7_Backend_ICC2/3_Log/00_setup
set ICC2_LIB_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/01_init_design/cv32e40p_icc2_lib
set INIT_REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/01_init_design
set FLOORPLAN_REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/02_floorplan
set POWER_REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/03_power
set PLACE_REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/04_place
set CTS_REPORT_DIR $PROJECT_ROOT/7_Backend_ICC2/4_Report/05_cts

file mkdir $PROJECT_ROOT/7_Backend_ICC2/2_Output/00_setup
file mkdir $SETUP_LOG_DIR
file mkdir $PROJECT_ROOT/7_Backend_ICC2/2_Output/01_init_design
file mkdir $PROJECT_ROOT/7_Backend_ICC2/2_Output/02_floorplan
file mkdir $PROJECT_ROOT/7_Backend_ICC2/2_Output/03_power
file mkdir $PROJECT_ROOT/7_Backend_ICC2/2_Output/04_place
file mkdir $PROJECT_ROOT/7_Backend_ICC2/2_Output/05_cts
file mkdir $PROJECT_ROOT/7_Backend_ICC2/3_Log/01_init_design
file mkdir $PROJECT_ROOT/7_Backend_ICC2/3_Log/02_floorplan
file mkdir $PROJECT_ROOT/7_Backend_ICC2/3_Log/03_power
file mkdir $PROJECT_ROOT/7_Backend_ICC2/3_Log/04_place
file mkdir $PROJECT_ROOT/7_Backend_ICC2/3_Log/05_cts
file mkdir $INIT_REPORT_DIR
file mkdir $FLOORPLAN_REPORT_DIR
file mkdir $POWER_REPORT_DIR
file mkdir $PLACE_REPORT_DIR
file mkdir $CTS_REPORT_DIR

# ICC2 link용 library 목록입니다.
set target_library [list $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]
set link_library [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]
