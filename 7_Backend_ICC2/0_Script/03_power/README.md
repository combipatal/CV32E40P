# 03_power

Power planning scripts for VDD/VSS nets, rings, stripes, rails, and PG connectivity checks.

## Notes

```text
run_power_initial.tcl
  stdcell rail, core ring, core mesh를 만들고 PG connectivity/DRC를 확인합니다.
  compile_pg 후 VDD/VSS top port에 작은 M8 terminal을 추가합니다.
  목적은 route 단계의 VDD/VSS no-pin/unplaced 경고 제거입니다.
```
