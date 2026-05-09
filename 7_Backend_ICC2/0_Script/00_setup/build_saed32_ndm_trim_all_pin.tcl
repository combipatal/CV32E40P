################################################################################
# ICC2용 SAED32 NDM reference library 생성 스크립트: trim_all_pin trial
#
# 목적:
#   configure_frame_options -mode keep_obs_and_trim_all_pin을 명시합니다.
#   Pin과 겹치는 OBS/blockage를 더 적극적으로 trim했을 때
#   남은 lower-metal route DRC가 줄어드는지 확인합니다.
#
# 비교 기준:
#   기존 NDM: 7_Backend_ICC2/2_Output/00_setup/ndm
#   새 NDM:   7_Backend_ICC2/2_Output/00_setup/ndm_trim_all_pin
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK

set TECH_FILE $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf

set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB $SAED32_ROOT/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB $SAED32_ROOT/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set RVT_LEF $SAED32_ROOT/lib/stdcell_rvt/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef
set LVT_LEF $SAED32_ROOT/lib/stdcell_lvt/lef/saed32nm_lvt_1p9m.lef
set HVT_LEF $SAED32_ROOT/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef

set NDM_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/00_setup/ndm_trim_all_pin
file mkdir $NDM_DIR

################################################################################
# RVT reference library 생성
################################################################################

create_workspace -technology $TECH_FILE -flow normal saed32rvt_tt_trim_all_pin
read_db $RVT_TT_DB
read_lef $RVT_LEF
configure_frame_options -mode keep_obs_and_trim_all_pin
check_workspace
commit_workspace -output $NDM_DIR/saed32rvt_tt.ndm -force

################################################################################
# LVT reference library 생성
################################################################################

create_workspace -technology $TECH_FILE -flow normal saed32lvt_tt_trim_all_pin
read_db $LVT_TT_DB
read_lef $LVT_LEF
configure_frame_options -mode keep_obs_and_trim_all_pin
check_workspace
commit_workspace -output $NDM_DIR/saed32lvt_tt.ndm -force

################################################################################
# HVT reference library 생성
################################################################################

create_workspace -technology $TECH_FILE -flow normal saed32hvt_tt_trim_all_pin
read_db $HVT_TT_DB
read_lef $HVT_LEF
configure_frame_options -mode keep_obs_and_trim_all_pin
check_workspace
commit_workspace -output $NDM_DIR/saed32hvt_tt.ndm -force

exit
