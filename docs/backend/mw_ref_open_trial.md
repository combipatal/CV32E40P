# ICC2 Milkyway Reference Open Trial

## 목적

현재 backend는 SAED32 DB+LEF로 만든 NDM reference library를 사용한다.

```text
7_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm
7_Backend_ICC2/2_Output/00_setup/ndm/saed32lvt_tt.ndm
7_Backend_ICC2/2_Output/00_setup/ndm/saed32hvt_tt.ndm
```

남은 route DRC가 stdcell pin access 문제처럼 보이므로, 원본 SAED32 Milkyway reference library를 ICC2에서 직접 사용할 수 있는지 확인했다.

```text
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_lvt/milkyway/saed32nm_lvt_1p9m
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_hvt/milkyway/saed32nm_hvt_1p9m
```

## 실행

```text
Date: 2026-05-08
Command: icc2_shell -batch -f 7_Backend_ICC2/0_Script/99_util/run_mw_ref_open_trial.tcl | tee 7_Backend_ICC2/3_Log/trials/mw_ref_open_trial/mw_ref_open_trial.log
```

## 증거 파일

```text
7_Backend_ICC2/3_Log/trials/mw_ref_open_trial/mw_ref_open_trial.log
7_Backend_ICC2/3_Log/trials/mw_ref_open_trial/icc_milkyway_exec_wrapper.args.log
7_Backend_ICC2/2_Output/trials/mw_ref_open_trial/local_cell_libs/log/*_export_icc2_frame.log
7_Backend_ICC2/2_Output/trials/mw_ref_open_trial/local_cell_libs/log/*_import_icc_fram.log
```

## Trial 1

처음에는 `create_lib -ref_libs [list $MW_RVT $MW_LVT $MW_HVT]`에서 바로 멈췄다.

```text
Error: App option 'lib.configuration.icc_shell_exec or lib.setting.milkyway_exec' must be specified:
there are Milkyway library to convert. (LIB-090)
```

확인 결과 이 환경에는 IC Compiler 1 `icc_shell`이 PATH에 없고 설치 tree에서도 찾지 못했다.

사용 가능한 관련 executable:

```text
/tools/synopsys/syn/W-2024.09-SP5-5/bin/Milkyway
/tools/synopsys/syn/W-2024.09-SP5-5/icc2/bin/icc2_shell
/tools/synopsys/syn/W-2024.09-SP5-5/icc2/bin/lm_shell
```

## Trial 2

`lib.setting.milkyway_exec`에 Milkyway executable을 지정했다.

결과:

```text
same LIB-090 error
```

즉 `create_lib`의 Milkyway conversion path는 사실상 `lib.configuration.icc_shell_exec`를 요구했다.

## Trial 3

Milkyway executable을 `lib.configuration.icc_shell_exec`에도 지정했다.

결과:

```text
Error: Extra args on command line.
Usage: Milkyway [-tcl] [-log <filename>] [-cmd <filename>] [-file <tcl_file>] ...
```

ICC2가 넘기는 인자는 IC Compiler 계열 형식이다.

```text
-f <script>
-output_log_file <log>
```

Milkyway executable은 다음 형식을 요구한다.

```text
-file <script>
-log <log>
```

## Trial 4

`icc_milkyway_exec_wrapper.sh`를 만들어 인자를 변환했다.

```text
-f               -> -file
-output_log_file -> -log
-batch/-no_gui   -> -nogui
```

wrapper 이후 "Extra args" 문제는 사라졌다.

그러나 Milkyway export 단계가 license/GUI 문제로 실패했다.

`*_export_icc2_frame.log`:

```text
Failed to get license key 'Milkyway'.  (No such feature exists. (-5,234))
Failed to get license key 'MDataPrep'.  (No such feature exists. (-5,234))
License initialization failed
Cannot initialize GUI.
Exit Milkyway!
```

그 결과 export tarball이 생성되지 않았다.

`*_import_icc_fram.log`:

```text
import_icc_fram /tmp/.../icc2_frame_saed32nm_rvt_1p9m/data/LEF/saed32nm_rvt_1p9m.tar.gz
Error: File '...tar.gz' cannot be found
Error: No libraries to check (LM-010)
```

## 판단

현재 환경에서는 ICC2가 원본 Milkyway reference library를 자동 변환하여 NDM frame library로 만들 수 없다.

직접 원인:

```text
IC Compiler 1 icc_shell 없음
Milkyway/MDataPrep license 없음
Milkyway export tar.gz 생성 실패
```

따라서 지금은 Milkyway reference 기반 ICC2 backend와 LEF-built NDM backend의 route behavior를 직접 비교할 수 없다.

## 중요한 의미

이 결과가 "LEF-built NDM이 문제다"를 증명하지는 않는다.

증명된 것은 이것이다.

```text
현재 사용 가능한 ICC2 backend path는 DB+LEF -> NDM path다.
Milkyway reference direct path는 환경/tool/license 문제로 blocked다.
```

## 다음 액션

Milkyway 직접 비교가 막혔으므로 다음 debug는 현재 NDM path 안에서 진행한다.

우선순위:

```text
1. ICC2 pin-access 관련 report/check command 찾기
2. M1 routing track offset trial을 check_routability 기준으로 비교
3. lower-metal/VIA1 route option trial을 full route 전에 check_routability로 비교
4. 필요하면 SAED32 LEF-built NDM 생성 option을 바꿔 작은 reference library trial 생성
```

금지:

```text
stdcell LEF/NDM pin geometry 수동 수정
CO ContactCode 임의 추가
route_detail 무한 반복
```
