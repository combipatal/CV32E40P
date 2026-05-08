#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT=/DATA/home/edu135/CV32E40P
LOG_DIR="$PROJECT_ROOT/7_Backend_ICC2/3_Log/trials/mw_ref_open_trial"
MILKYWAY_EXEC=/tools/synopsys/syn/W-2024.09-SP5-5/bin/Milkyway

mkdir -p "$LOG_DIR"
{
  printf 'icc_milkyway_exec_wrapper args:'
  for arg in "$@"; do
    printf ' [%s]' "$arg"
  done
  printf '\n'
} >> "$LOG_DIR/icc_milkyway_exec_wrapper.args.log"

translated=()
while (($# > 0)); do
  case "$1" in
    -f)
      translated+=("-file")
      shift
      ;;
    -output_log_file)
      translated+=("-log")
      shift
      ;;
    -batch|-no_gui)
      translated+=("-nogui")
      shift
      ;;
    *)
      translated+=("$1")
      shift
      ;;
  esac
done

exec "$MILKYWAY_EXEC" "${translated[@]}"
