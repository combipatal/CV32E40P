################################################################################
# CV32E40P functional 10 ns timing constraint
#
# 목적:
#   합성/STA/Formality functional mode의 기본 clock과 I/O timing을 정의합니다.
################################################################################

# 기본 functional clock입니다. 10 ns는 100 MHz 목표입니다.
create_clock -name clk_i -period 10.0 [get_ports clk_i]

# clock uncertainty는 jitter/skew 여유입니다.
set_clock_uncertainty 0.1 [get_clocks clk_i]

# functional mode에서는 scan/test enable을 0으로 고정합니다.
set_case_analysis 0 [get_ports scan_cg_en_i]
set_case_analysis 0 [get_ports scan_en]
set_case_analysis 0 [get_ports scan_in]

# reset은 비동기 제어 신호라 일반 data timing path로 보지 않습니다.
set_false_path -from [get_ports rst_ni]

# 외부 입력 포트가 clock edge 이후 1 ns 뒤에 도착한다고 가정합니다.
set_input_delay 1.0 -clock clk_i [get_ports {
  pulp_clock_en_i
  boot_addr_i
  mtvec_addr_i
  dm_halt_addr_i
  hart_id_i
  dm_exception_addr_i
  instr_gnt_i
  instr_rvalid_i
  instr_rdata_i
  data_gnt_i
  data_rvalid_i
  data_rdata_i
  irq_i
  debug_req_i
  fetch_enable_i
}]

# scan_in/reset은 functional timing에서 별도 0 ns delay로 둡니다.
set_input_delay 0.0 -clock clk_i [get_ports scan_in]
set_input_delay 0.0 -clock clk_i [get_ports rst_ni]

# 출력 포트는 다음 stage가 clock edge 기준 1 ns 뒤에 sample한다고 가정합니다.
set_output_delay 1.0 -clock clk_i [get_ports {
  instr_req_o
  instr_addr_o
  data_req_o
  data_we_o
  data_be_o
  data_addr_o
  data_wdata_o
  irq_ack_o
  irq_id_o
  debug_havereset_o
  debug_running_o
  debug_halted_o
  core_sleep_o
}]
