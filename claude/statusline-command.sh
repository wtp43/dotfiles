#!/usr/bin/env bash

input=$(cat)

# --- Colors ---
green="\033[32m"
teal="\033[36m"
white="\033[38;2;220;220;220m"
orange="\033[38;5;208m"
red="\033[31m"
dim="\033[90m"
reset="\033[0m"
sep=" \033[1m${white}∣${reset} "

# --- Percentage (colored by threshold) ---
make_pct() {
  local pct=$1
  local color="$green"
  [ "$pct" -ge 60 ] && color="$orange"
  [ "$pct" -ge 85 ] && color="$red"
  printf "${color}[%s%%]${reset}" "$pct"
}

# --- Base info ---
model=$(echo "$input" | jq -r '.model.display_name // "unknown"' | sed 's/^Claude //')
session=$(echo "$input" | jq -r '.session_id // empty')
session_name=$(echo "$input" | jq -r '.session_name // empty')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .cwd // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_usd // empty')

# --- Git branch + dirty count ---
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$dirty" -gt 0 ]; then
    git_segment="${green}${branch}${reset} +${dirty}"
  else
    git_segment="${green}${branch}${reset}"
  fi
else
  git_segment=""
fi

# --- Device ---
host=$(hostname -s 2>/dev/null)
device_segment="${white}󰒋${reset} \033[1m${teal}${host}${reset}"

# --- Context window ---
if [ -n "$used_pct" ]; then
  pct=$(printf "%.0f" "$used_pct")
  context_pct=$(make_pct "$pct")
  context_segment="${sep}ctx: ${context_pct}"
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
    usage_segment="${sep}${five_label}: ${five_pct_str}${sep}${seven_label}: ${seven_pct_str}"
  fi
fi

# --- Line 1: device | dir git | model | cost ---
line1="${device_segment}"
dir_segment=""
[ -n "$project_dir" ] && dir_segment="${green}${project_dir##*/}${reset}"
section="${dir_segment}${dir_segment:+${git_segment:+ ${white}-${reset} }}${git_segment}"
[ -n "$section" ] && line1="${line1}${sep}${section}"
printf "%b${sep}${green}%s${reset}" "$line1" "$model"
printf "%b\n" "$cost_segment"

# --- Line 2: session, context and usage ---
session_label="${session_name:-$session}"
line2=""
[ -n "$session_label" ] && line2="${sep}✳ ${session_label}"
line2="${line2}${context_segment}${usage_segment}"
line2="${line2#"$sep"}"
[ -n "$line2" ] && printf "%b\n" "$line2"
