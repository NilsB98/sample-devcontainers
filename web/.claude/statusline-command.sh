#!/bin/bash
# Status line mirroring devcontainer bash prompt style
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name // .model.model_id // "unknown"')
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0 | round')

# Git branch - cyan parens, red branch name
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
gitpart=""
if [ -n "$branch" ]; then
    gitpart=$(printf '\033[0;36m(\033[1;31m%s\033[0;36m) ' "$branch")
fi

printf '%s\033[0;35m[%s]\033[0m \033[0;33m%s%%\033[0m' "$gitpart" "$model" "$context_pct"
