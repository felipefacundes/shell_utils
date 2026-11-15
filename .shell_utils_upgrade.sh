#!/bin/bash
# Safe Git sync script for ~/.shell_utils
# Includes pre-flight checks to avoid operating on a corrupted or empty repo

REPO_DIR="$HOME/.shell_utils"
COMMIT_MSG="A Dynamic Collection of Shell Scripts with Educational Purpose"

cd "$REPO_DIR" || { echo "Error: cannot cd to $REPO_DIR"; exit 1; }

# Ensure we are inside a valid Git work tree
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: $REPO_DIR is not a valid Git repository."
    exit 1
fi

# Check whether the index is readable (prevent the "unknown index entry format" error)
if ! git status >/dev/null 2>&1; then
    echo "Error: Git index appears corrupted."
    echo "Run: rm -f .git/index && git reset"
    exit 1
fi

# Check for unresolved merge conflicts
if git ls-files -u | grep -q .; then
    echo "Error: unresolved merge conflicts detected."
    exit 1
fi

# Only stage and commit when there are actual changes
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to commit."
else
    git add -A
    if ! git diff --cached --quiet; then
        git commit -m "$COMMIT_MSG" || { echo "Commit failed."; exit 1; }
    else
        echo "Nothing staged after git add."
    fi
fi

# Push only if there are commits ahead of the remote
if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    if [ "$(git rev-list --count '@{u}..HEAD')" -gt 0 ]; then
        git push || { echo "Push failed."; exit 1; }
    else
        echo "Already up to date with remote."
    fi
else
    echo "No upstream configured. Skipping push."
fi