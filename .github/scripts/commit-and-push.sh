#!/bin/bash
set -e
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Sauvegarde le fichier fraichement genere avant tout reset
cp discord-members.json /tmp/discord-members.json

for i in 1 2 3 4 5; do
  git fetch origin main
  git reset --hard origin/main
  cp /tmp/discord-members.json discord-members.json
  git add discord-members.json
  if git diff --staged --quiet; then
    echo "No changes"
    exit 0
  fi
  git commit -m "Update Discord members list"
  if git push origin HEAD:main; then
    echo "Pushed successfully on attempt $i"
    exit 0
  fi
  echo "Attempt $i failed (likely a push race), retrying..."
  sleep $((RANDOM % 5 + 2))
done

echo "Failed to push after 5 attempts"
exit 1
