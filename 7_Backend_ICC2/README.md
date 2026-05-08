# 7_Backend_ICC2

ICC2 backend Phase 2 workspace.

## Stage Folders

```text
0_Script/
  00_setup/        tool, library, tech, TLU+ setup
  01_init_design/  read netlist/SDC, create/open design library
  02_floorplan/    core size, rows, ports, macro plan if any
  03_power/        VDD/VSS nets, rings, stripes, rails, PG checks
  04_place/        placement and pre-CTS optimization
  05_cts/          clock tree synthesis and post-CTS optimization
  06_route/        detailed routing and route optimization
  07_extract_sta/  extraction handoff and post-route STA collateral
  08_export/       DEF/GDS/netlist/SDF/SPEF/export scripts
  99_util/         small helper scripts

1_Input/
  netlist/         backend input netlist references or copy notes
  constraints/     backend input SDC references or copy notes
  tech/            tech, TLU+, map, layer setup notes
  lib/             physical/timing library setup notes
  reference/       FE handoff notes and source artifact references

2_Output/          generated ICC2 design outputs, ignored by git
3_Log/             tool logs, ignored by git
4_Report/          generated reports, ignored by git
work/              ICC2 work/cache area, ignored by git
```

## Initial Handoff

```text
Netlist:
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.vg

Constraint:
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.sdc

Reference:
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.ddc
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.sdf
  3_DFT/2_Output/post_dft_topo/cv32e40p_synth_wrap.post_dft_topo.spf
```

## First Backend Goal

```text
ICC2 setup -> init_design -> floorplan -> power planning -> placement sanity
```

Do not claim GDS or backend signoff until route, extraction, and post-route STA evidence exists.
