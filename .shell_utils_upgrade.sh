#!/bin/bash
cd ~/.shell_utils || exit
git add .
git commit -m "A Dynamic Collection of Shell Scripts with Educational Purpose"
git push

cat <<'EOF'
cd ~/.shell_utils || exit
git add .
git commit -m "A Dynamic Collection of Shell Scripts with Educational Purpose"
git push
EOF