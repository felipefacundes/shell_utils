#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
A bash script that toggles NVIDIA's ForceFullCompositionPipeline setting on or off for improved graphics performance and reduced screen tearing.
DOCUMENTATION

# Get current settings
current_settings=$(nvidia-settings --query CurrentMetaMode -t)

# Check if ForceFullCompositionPipeline is enabled
if [[ $current_settings == *ForceFullCompositionPipeline=On* ]]; then
    # Disable ForceFullCompositionPipeline
    nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = Off }"
    echo "ForceFullCompositionPipeline disabled."
else
    # Activate forcefullcompositionpipeline
    nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
    echo "ForceFullCompositionPipeline activated."
fi
