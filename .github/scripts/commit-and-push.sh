#!/bin/bash
set -e
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add discord-members.json
if git diff --staged --quiet; then
  echo "No changes"
else
  git commit -m "Update Discord members list"
  git fetch origin main
  git rebase origin/main
  git push
fi
