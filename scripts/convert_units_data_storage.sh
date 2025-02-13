#!/bin/bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script provides a utility for converting data sizes between various units, including bytes, kilobytes, 
megabytes, gigabytes, and more. It defines two main functions: one for converting a given value to bytes and another 
for converting between different units. The script checks for the correct number of command-line arguments and calls 
the conversion function with the provided values. If the input or output units are unsupported, it returns an appropriate error message. 
The script is designed to facilitate easy data size conversions in a command-line environment.
DOCUMENTATION

# Function to convert bytes to other units
convert_to_bytes() {
  declare -u input_unit="$1"
  local value="$2"
  
  case "$input_unit" in
    B)
      echo "$value"
      ;;
    KB)
      echo "$((value * 1024))"
      ;;
    MB)
      echo "$((value * 1024 * 1024))"
      ;;
    GB)
      echo "$((value * 1024 * 1024 * 1024))"
      ;;
    TB)
      echo "$((value * 1024 * 1024 * 1024 * 1024))"
      ;;
    PB)
      echo "$((value * 1024 * 1024 * 1024 * 1024 * 1024))"
      ;;
    EB)
      echo "$((value * 1024 * 1024 * 1024 * 1024 * 1024 * 1024))"
      ;;
    ZB)
      echo "$((value * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024))"
      ;;
    YB)
      echo "$((value * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024))"
      ;;
    *)
      echo "Unit unit not supported."
      ;;
  esac
}

# Function to convert from one unit to another
convert_units() {
  declare -u input_unit="$1"
  local value="$2"
  declare -u output_unit="$3"
  
  if [[ "$input_unit" == "$output_unit" ]]; then
    echo "$value $input_unit"
    return
  fi
  
  # Convert to Bytes First
  local bytes_input="$(convert_to_bytes "$input_unit" "$value")"
  
  # Convert from Bytes to the output unit
  case "$output_unit" in
    B)
      echo "$bytes_input Bytes"
      ;;
    KB)
      echo "$((bytes_input / 1024)) KB"
      ;;
    MB)
      echo "$((bytes_input / 1024 / 1024)) MB"
      ;;
    GB)
      echo "$((bytes_input / 1024 / 1024 / 1024)) GB"
      ;;
    TB)
      echo "$((bytes_input / 1024 / 1024 / 1024 / 1024)) TB"
      ;;
    PB)
      echo "$((bytes_input / 1024 / 1024 / 1024 / 1024 / 1024)) PB"
      ;;
    EB)
      echo "$((bytes_input / 1024 / 1024 / 1024 / 1024 / 1024 / 1024)) EB"
      ;;
    ZB)
      echo "$((bytes_input / 1024 / 1024 / 1024 / 1024 / 1024 / 1024 / 1024)) ZB"
      ;;
    YB)
      echo "$((bytes_input / 1024 / 1024 / 1024 / 1024 / 1024 / 1024 / 1024 / 1024)) YB"
      ;;
    *)
      echo "Unit of exit not supported."
      ;;
  esac
}

# Checks the arguments
if [[ $# -ne 3 ]]; then
  echo "Usage: ${0##*/} <value> <input unit> <output unit>"
  exit 1
fi

# Call the function to convert units
convert_units "$2" "$1" "$3"
