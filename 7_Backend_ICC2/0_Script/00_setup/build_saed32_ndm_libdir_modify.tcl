################################################################################
# ICC2용 SAED32 NDM reference library 생성 스크립트: libdir/modify LEF trial
#
# 목적:
#   Front-End 결과는 그대로 두고, Backend physical abstract만 바꿔 봅니다.
#   timing DB는 기존 TT DB를 그대로 쓰고, LEF만 ../lib/libdir/LEF/modify를 씁니다.
#
# 비교 기준:
#   기존 NDM: 7_Backend_ICC2/2_Output/00_setup/ndm
#   새 NDM:   7_Backend_ICC2/2_Output/00_setup/ndm_libdir_modify
################################################################################

set PROJECT_ROOT /DATA/home/edu135/CV32E40P
cd $PROJECT_ROOT

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK
set LIBDIR_ROOT /DATA/home/edu135/lib/libdir

# 기술 파일은 기존 flow와 동일하게 둡니다.
# 이번 trial의 변수는 stdcell LEF만입니다.
set TECH_FILE $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf

set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB $SAED32_ROOT/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB $SAED32_ROOT/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

set RVT_LEF $LIBDIR_ROOT/LEF/modify/saed32nm_rvt_1p9m.lef
set LVT_LEF $LIBDIR_ROOT/LEF/modify/saed32nm_lvt_1p9m.lef
set HVT_LEF $LIBDIR_ROOT/LEF/modify/saed32nm_hvt_1p9m.lef

set NDM_DIR $PROJECT_ROOT/7_Backend_ICC2/2_Output/00_setup/ndm_libdir_modify
file mkdir $NDM_DIR

################################################################################
# RVT reference library 생성
################################################################################

create_workspace -technology $TECH_FILE -flow normal saed32rvt_tt_libdir_modify
read_db $RVT_TT_DB
read_lef $RVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32rvt_tt.ndm -force

################################################################################
# LVT reference library 생성
################################################################################

create_workspace -technology $TECH_FILE -flow normal saed32lvt_tt_libdir_modify
read_db $LVT_TT_DB
read_lef $LVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32lvt_tt.ndm -force

################################################################################
# HVT reference library 생성
################################################################################

create_workspace -technology $TECH_FILE -flow normal saed32hvt_tt_libdir_modify
read_db $HVT_TT_DB
read_lef $HVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32hvt_tt.ndm -force

exit
