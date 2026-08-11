#!/bin/bash
set -e
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add discord-members.json
if git diff --staged --quiet; then
  echo "No changes"
  exit 0
fi
git commit -m "Update Discord members list"

for i in 1 2 3 4 5; do
  git fetch origin main
  if git rebase origin/main && git push origin HEAD:main; then
    echo "Pushed successfully on attempt $i"
    exit 0
  fi
  echo "Attempt $i failed (likely a push race), retrying..."
  git rebase --abort >/dev/null 2>&1 || true
  sleep $((RANDOM % 5 + 2))
done

echo "Failed to push after 5 attempts"
exit 1
