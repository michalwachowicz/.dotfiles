#!/usr/bin/env bash
set -euo pipefail

# Source idea: https://stackoverflow.com/a/10312587
# Posted by Wookie88, modified by community (CC BY-SA 4.0).

remote="${1:-origin}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: run this script inside a git repository." >&2
  exit 1
fi

if ! git remote get-url "$remote" >/dev/null 2>&1; then
  echo "Error: remote '$remote' does not exist in this repository." >&2
  exit 1
fi

echo "Fetching remotes..."
git fetch --all --prune

echo "Tracking remote branches from '$remote'..."
git for-each-ref --format='%(refname:short)' "refs/remotes/$remote" \
  | while IFS= read -r remote_branch; do
      [ "$remote_branch" = "$remote/HEAD" ] && continue

      local_branch="${remote_branch#${remote}/}"

      if git show-ref --verify --quiet "refs/heads/$local_branch"; then
        echo "- exists: $local_branch"
        continue
      fi

      git branch --track "$local_branch" "$remote_branch"
      echo "- created: $local_branch -> $remote_branch"
    done

echo "Pulling all local branches with upstreams..."
git pull --all

echo "Done."
