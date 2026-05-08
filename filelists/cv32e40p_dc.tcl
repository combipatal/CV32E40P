################################################################################
# CV32E40P DC/Formality RTL filelist
#
# 목적:
#   합성 가능한 RTL만 정해진 순서로 읽습니다.
#   upstream simulation clock gate와 testbench wrapper는 제외합니다.
################################################################################

# SystemVerilog include directory입니다.
set RTL_INC_DIRS [list \
  rtl/cv32e40p/rtl/include \
]

# 패키지를 먼저 읽고, technology clock gate replacement와 core RTL을 읽은 뒤,
# 마지막에 합성용 wrapper를 읽습니다.
set RTL_FILES [list \
  rtl/cv32e40p/rtl/include/cv32e40p_apu_core_pkg.sv \
  rtl/cv32e40p/rtl/include/cv32e40p_fpu_pkg.sv \
  rtl/cv32e40p/rtl/include/cv32e40p_pkg.sv \
  rtl/tech/cv32e40p_clock_gate.sv \
  rtl/cv32e40p/rtl/cv32e40p_if_stage.sv \
  rtl/cv32e40p/rtl/cv32e40p_cs_registers.sv \
  rtl/cv32e40p/rtl/cv32e40p_register_file_ff.sv \
  rtl/cv32e40p/rtl/cv32e40p_load_store_unit.sv \
  rtl/cv32e40p/rtl/cv32e40p_id_stage.sv \
  rtl/cv32e40p/rtl/cv32e40p_aligner.sv \
  rtl/cv32e40p/rtl/cv32e40p_decoder.sv \
  rtl/cv32e40p/rtl/cv32e40p_compressed_decoder.sv \
  rtl/cv32e40p/rtl/cv32e40p_fifo.sv \
  rtl/cv32e40p/rtl/cv32e40p_prefetch_buffer.sv \
  rtl/cv32e40p/rtl/cv32e40p_hwloop_regs.sv \
  rtl/cv32e40p/rtl/cv32e40p_mult.sv \
  rtl/cv32e40p/rtl/cv32e40p_int_controller.sv \
  rtl/cv32e40p/rtl/cv32e40p_ex_stage.sv \
  rtl/cv32e40p/rtl/cv32e40p_alu_div.sv \
  rtl/cv32e40p/rtl/cv32e40p_alu.sv \
  rtl/cv32e40p/rtl/cv32e40p_ff_one.sv \
  rtl/cv32e40p/rtl/cv32e40p_popcnt.sv \
  rtl/cv32e40p/rtl/cv32e40p_apu_disp.sv \
  rtl/cv32e40p/rtl/cv32e40p_controller.sv \
  rtl/cv32e40p/rtl/cv32e40p_obi_interface.sv \
  rtl/cv32e40p/rtl/cv32e40p_prefetch_controller.sv \
  rtl/cv32e40p/rtl/cv32e40p_sleep_unit.sv \
  rtl/cv32e40p/rtl/cv32e40p_core.sv \
  rtl/cv32e40p/rtl/cv32e40p_top.sv \
  rtl/wrappers/cv32e40p_synth_wrap.sv \
]
