#!/bin/sh
PATH="$PATH:/opt/homebrew/bin:$HOME/.tmux/plugins/tmux-mem-cpu-load"

if [ "$(uname)" = Darwin ]; then
  mem=$((100 - $(sysctl -n kern.memorystatus_level)))
  case $(sysctl -n kern.memorystatus_vm_pressure_level) in
    0|1) mem_col=cyan ;;
    2) mem_col=colour208 ;;
    *) mem_col=red ;;
  esac
else
  mem=$(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print int(100 - a*100/t + 0.5)}' /proc/meminfo)
  psi=$(awk '/^some/{split($2, f, "="); print int(f[2])}' /proc/pressure/memory 2>/dev/null)
  mem_col=cyan
  [ "${psi:-0}" -ge 5 ] && mem_col=colour208
  [ "${psi:-0}" -ge 20 ] && mem_col=red
fi
out=" #[fg=$mem_col]$mem%#[default]"

bin=$(command -v tmux-mem-cpu-load)
cpu=${bin:+$("$bin" -i "${1:-3}" -m 2 -g 0 -a 0 | tr -d '\000' | awk '{print $2}')}
if [ -n "$cpu" ]; then
  pct=$(printf '%.0f' "${cpu%\%}")
  cpu_col=cyan
  [ "$pct" -ge 60 ] && cpu_col=colour208
  [ "$pct" -ge 85 ] && cpu_col=red
  out="󰉈 #[fg=$cpu_col]$pct%#[default] ∣ $out"
fi

echo "$out"
