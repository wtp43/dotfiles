#!/usr/bin/env bash

input=$(cat)

# --- Colors ---
green="\033[32m"
teal="\033[36m"
white="\033[38;2;220;220;220m"
warning="\033[33m"
red="\033[31m"
dim="\033[90m"
reset="\033[0m"
sep=" \033[1m${white}∣${reset} "
dot=" ${white}·${reset} "

# --- Percentage with bar (colored by threshold) ---
make_pct() {
  local pct=$1 width=8
  local color="$green"
  [ "$pct" -ge 60 ] && color="$warning"
  [ "$pct" -ge 85 ] && color="$red"
  local filled=$(( (pct * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  local done_part="" todo_part="" i
  for ((i = 0; i < width; i++)); do
    # Termius's font has no U+1FB0B; it draws boxed "?".
    # [ "$i" -lt "$filled" ] && done_part+="🬋" || todo_part+="🬋"
    [ "$i" -lt "$filled" ] && done_part+="━" || todo_part+="━"
  done
  printf "${color}%s${dim}%s${color} %s%%${reset}" "$done_part" "$todo_part" "$pct"
}

# --- Base info ---
model=$(echo "$input" | jq -r '.model.display_name // "unknown"' | sed 's/^Claude //')
session=$(echo "$input" | jq -r '.session_id // empty')
session_name=$(echo "$input" | jq -r '.session_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_usd // empty')

# --- Git branch + dirty count ---
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$dirty" -gt 0 ]; then
    git_segment="${warning}${branch}${reset} +${dirty}"
  else
    git_segment="${warning}${branch}${reset}"
  fi
  git_segment="${dim}[${reset}${git_segment}${dim}]${reset}"
else
  git_segment=""
fi

# --- Device ---
host=$(hostname -s 2>/dev/null)
device_segment="${white}󰆦${reset} \033[1m${teal}${host}${reset}"

# --- Context window ---
if [ -n "$used_pct" ]; then
  pct=$(printf "%.0f" "$used_pct")
  context_pct=$(make_pct "$pct")
  context_segment="${dot}ctx: ${context_pct}"
else
  context_segment=""
fi

# --- Cost segment ---
if [ -n "$cost" ]; then
  cost_segment="${sep}${green}💰 Cost:\$${cost}${reset}"
else
  cost_segment=""
fi

# --- Plan usage (cached for 60s) ---
cache_file="/tmp/.claude-usage-cache"
cache_max_age=60
usage_segment=""

# BSD (macOS) first, GNU (Linux) fallback.
iso_to_epoch() {
  local ts
  ts=$(echo "$1" | sed 's/\.[^+]*//; s/+00:00//')
  TZ=UTC date -jf "%Y-%m-%dT%H:%M:%S" "$ts" +%s 2>/dev/null || TZ=UTC date -d "$ts" +%s 2>/dev/null
}

refresh_cache=false
if [ ! -f "$cache_file" ]; then
  refresh_cache=true
else
  cache_age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file") ))
  [ "$cache_age" -ge "$cache_max_age" ] && refresh_cache=true
fi

if [ "$refresh_cache" = true ]; then
  creds=$(security find-generic-password -s 'Claude Code-credentials' -w 2>/dev/null || cat ~/.claude/.credentials.json 2>/dev/null)
  token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)

  if [ -n "$token" ]; then
    response=$(curl -s --max-time 3 \
      -H "Authorization: Bearer $token" \
      -H "anthropic-beta: oauth-2025-04-20" \
      -H "Content-Type: application/json" \
      "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

    if [ $? -eq 0 ] && echo "$response" | jq -e '.five_hour' >/dev/null 2>&1; then
      echo "$response" > "$cache_file"
    fi
  fi
fi

if [ -f "$cache_file" ]; then
  five_h=$(jq -r '.five_hour.utilization // empty' "$cache_file" 2>/dev/null)
  seven_d=$(jq -r '.seven_day.utilization // empty' "$cache_file" 2>/dev/null)

  if [ -n "$five_h" ] && [ -n "$seven_d" ]; then
    five_pct=$(printf "%.0f" "$five_h")
    seven_pct=$(printf "%.0f" "$seven_d")

    # Compute time remaining until 5h reset
    resets_at=$(jq -r '.five_hour.resets_at // empty' "$cache_file" 2>/dev/null)
    five_label="5h"
    if [ -n "$resets_at" ]; then
      reset_epoch=$(iso_to_epoch "$resets_at")
      now_epoch=$(date +%s)
      if [ -n "$reset_epoch" ] && [ "$reset_epoch" -gt "$now_epoch" ]; then
        remaining=$(( reset_epoch - now_epoch ))
        hours=$(( remaining / 3600 ))
        mins=$(( (remaining % 3600) / 60 ))
        five_label="${hours}h ${mins}m"
      fi
    fi

    # Compute time remaining until 7d reset
    resets_at_7d=$(jq -r '.seven_day.resets_at // empty' "$cache_file" 2>/dev/null)
    seven_label="7d"
    if [ -n "$resets_at_7d" ]; then
      reset_epoch_7d=$(iso_to_epoch "$resets_at_7d")
      now_epoch_7d=$(date +%s)
      if [ -n "$reset_epoch_7d" ] && [ "$reset_epoch_7d" -gt "$now_epoch_7d" ]; then
        remaining_7d=$(( reset_epoch_7d - now_epoch_7d ))
        days_7d=$(( remaining_7d / 86400 ))
        hours_7d=$(( (remaining_7d % 86400) / 3600 ))
        mins_7d=$(( (remaining_7d % 3600) / 60 ))
        if [ "$days_7d" -gt 0 ]; then
          seven_label="${days_7d}d ${hours_7d}h"
        else
          seven_label="${hours_7d}h ${mins_7d}m"
        fi
      fi
    fi

    five_pct_str=$(make_pct "$five_pct")
    seven_pct_str=$(make_pct "$seven_pct")
    usage_segment="${dot}${five_label}: ${five_pct_str}${dot}${seven_label}: ${seven_pct_str}"
  fi
fi

# --- Line 1: device | model | git | cost ---
line1="${device_segment}${sep}${green}${model}${reset}"
[ -n "$git_segment" ] && line1="${line1}${sep}${git_segment}"
printf "%b" "$line1"
printf "%b\n" "$cost_segment"

# --- Line 2: session, context and usage ---
session_label="${session_name:-$session}"
line2=""
# U+FE0E after ✳: herdr reads a line starting with a Claude spinner glyph plus
# whitespace and cut off with "…" as a live turn, so the agent would never look
# idle. The invisible selector keeps the glyph but breaks that match.
[ -n "$session_label" ] && line2="${dot}✳\xef\xb8\x8e ${white}${session_label}${reset}"
line2="${line2}${context_segment}${usage_segment}"
line2="${line2#"$dot"}"
[ -n "$line2" ] && printf "%b\n" "$line2"
