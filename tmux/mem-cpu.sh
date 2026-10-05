#!/bin/sh
PATH="$PATH:/opt/homebrew/bin:$HOME/.tmux/plugins/tmux-mem-cpu-load"

# Same thresholds and colors as the Claude Code status line bars.
col() {
  if [ "$1" -ge 85 ]; then echo red
  elif [ "$1" -ge 60 ]; then echo yellow
  else echo green
  fi
}

if [ "$(uname)" = Darwin ]; then
  mem=$((100 - $(sysctl -n kern.memorystatus_level)))
  case $(sysctl -n kern.memorystatus_vm_pressure_level) in
    0|1) mem_col=green ;;
    2) mem_col=yellow ;;
    *) mem_col=red ;;
  esac
else
  mem=$(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print int(100 - a*100/t + 0.5)}' /proc/meminfo)
  mem_col=$(col "$mem")
fi
out=" #[fg=$mem_col]$mem%#[default]"

bin=$(command -v tmux-mem-cpu-load)
cpu=${bin:+$("$bin" -i "${1:-3}" -m 2 -g 0 -a 0 | tr -d '\000' | awk '{print $2}')}
if [ -n "$cpu" ]; then
  pct=$(printf '%.0f' "${cpu%\%}")
  out="󰉈 #[fg=$(col "$pct")]$pct%#[default] ∣ $out"
fi

echo "$out"
