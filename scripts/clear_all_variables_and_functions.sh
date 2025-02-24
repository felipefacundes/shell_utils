#!/usr/bin/env bash

# Clear all variables and functions
for VAR in $(grep -E '[a-zA-Z0-9"'\''\[\]]*=' "${0}" | grep -v '^#' | cut -d'=' -f1 | awk '{print $1}'); do
    eval unset "\${VAR}"
done