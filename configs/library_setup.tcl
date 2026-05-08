################################################################################
# 공통 timing library 설정
#
# 목적:
#   DC/DFT/STA가 같은 SAED32 TT mixed-VT library를 쓰게 고정합니다.
################################################################################

# SAED32 라이브러리 루트입니다.
set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK

# TT 1.05V 25C NLDM timing DB입니다.
# RVT/LVT/HVT를 함께 넣어서 합성기가 cell Vt를 섞어 쓸 수 있게 합니다.
set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set LVT_TT_DB $SAED32_ROOT/lib/stdcell_lvt/db_nldm/saed32lvt_tt1p05v25c.db
set HVT_TT_DB $SAED32_ROOT/lib/stdcell_hvt/db_nldm/saed32hvt_tt1p05v25c.db

# target_library: 합성기가 새로 매핑할 수 있는 cell 목록입니다.
# link_library: 이미 들어온 netlist/RTL instance를 찾을 때 쓰는 library 목록입니다.
set_app_var target_library [list $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]
set_app_var link_library [list * $RVT_TT_DB $LVT_TT_DB $HVT_TT_DB]
