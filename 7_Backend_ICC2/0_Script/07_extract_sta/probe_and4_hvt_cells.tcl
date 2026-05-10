################################################################################
# AND4 HVT drive cell 확인
#
# 목적:
#   U246 driver upsize ECO에 사용할 수 있는 AND4*_HVT cell을 확인합니다.
################################################################################

source 7_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

open_lib $ICC2_LIB_DIR
open_block cv32e40p_synth_wrap_maxcap_eco5_route_repair

puts "AND4_HVT_CELLS_BEGIN"
puts [get_object_name [get_lib_cells */AND4*_HVT -quiet]]
puts "AND4_HVT_CELLS_END"

exit
