#!/usr/bin/env bash
# Report each workspace's "$title" (icon + name) and each agent pane's
# "$agent_line" (icon + agent) for the sidebar rows (see herdr-plugin.toml).
PATH=$PATH:/opt/homebrew/bin
herdr=${HERDR_BIN_PATH:-herdr}
source_id=wt.sidebar-icons
state_dir=${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}/herdr-sidebar-icons}
mkdir -p "$state_dir"
reported=$state_dir/reported

# Nerd Font GitHub mark (U+F09B), shown before every git repo.
github_icon=$(printf '\357\202\233')

agent_icon() {
  case $1 in
    claude) printf '✳' ;;
  esac
}

snapshot=$("$herdr" api snapshot 2>/dev/null) || exit 0

# One "kind<TAB>id<TAB>name<TAB>value" line per token; value is the name for
# workspaces (filled in below) and the agent for panes.
want=$(jq -r '.result.snapshot as $s
  | ($s.workspaces[] as $w
     | ($s.panes | map(select(.workspace_id == $w.workspace_id)) | first | .cwd // "") as $cwd
     | ["workspace", $w.workspace_id, $w.label, $cwd]),
    ($s.agents[] | select(.agent != null) | ["pane", .pane_id, .agent, ""])
  | @tsv' <<<"$snapshot")

lines=()
while IFS=$'\t' read -r kind id name cwd; do
  [ -n "$id" ] || continue
  if [ "$kind" = workspace ]; then
    icon=
    git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1 && icon=$github_icon
    lines+=("$kind"$'\t'"$id"$'\t'"title"$'\t'"${icon:+$icon }$name")
  else
    icon=$(agent_icon "$name")
    lines+=("$kind"$'\t'"$id"$'\t'"agent_line"$'\t'"${icon:+$icon }$name")
  fi
done <<<"$want"

# Report only what changed since the last run; events arrive often.
for line in "${lines[@]}"; do
  grep -qxF "$line" "$reported" 2>/dev/null && continue
  IFS=$'\t' read -r kind id token value <<<"$line"
  "$herdr" "$kind" report-metadata "$id" --source "$source_id" --token "$token=$value" >/dev/null
done
printf '%s\n' "${lines[@]}" >"$reported.$$" && mv "$reported.$$" "$reported"
exit 0
