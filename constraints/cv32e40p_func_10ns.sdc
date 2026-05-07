create_clock -name clk_i -period 10.0 [get_ports clk_i]
set_clock_uncertainty 0.1 [get_clocks clk_i]

set_case_analysis 0 [get_ports scan_cg_en_i]
set_case_analysis 0 [get_ports scan_en]
set_case_analysis 0 [get_ports scan_in]

set_false_path -from [get_ports rst_ni]

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

set_input_delay 0.0 -clock clk_i [get_ports scan_in]
set_input_delay 0.0 -clock clk_i [get_ports rst_ni]

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
