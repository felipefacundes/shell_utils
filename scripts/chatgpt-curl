#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script provides a command-line interface for interacting with OpenAI's API to generate text completions using a specified model. 
It allows users to set the temperature and model engine as command-line arguments, defaulting to a temperature of 0.8 and the "text-davinci-003"
model if not provided. The script continuously prompts the user for input, sending the prompt to the OpenAI API via a 'curl' command and retrieving 
the generated response. The results are displayed in the terminal, creating an interactive experience for generating text based on user prompts. 
Overall, it serves as a simple tool for leveraging OpenAI's text generation capabilities.
DOCUMENTATION

# Set the OpenAI API key
OPENAI_KEY="OpenAI API key Here"
TEMPERATURE=$1
MODEL=$2

[[ $1 == "-h" ]] && echo -e "Usage: ${0##*/} [temperature value] [model engine]" && exit 0
[[ -z $1 ]] && export TEMPERATURE="0.8" 
[[ -z $2 ]] && export MODEL="text-davinci-003"

echo "Temperature: $TEMPERATURE"
echo -e "Model: ${MODEL}\n"

# Chat with ChatGPT
while true; do
echo "Enter a prompt for ChatGPT: "
read prompt

response=$(cat <<EOF
curl https://api.openai.com/v1/completions \
-H 'Content-Type: application/json' \
-H "Authorization: Bearer $OPENAI_KEY" \
-d '{
"model": "$MODEL",
"prompt": "$prompt",
"max_tokens": 4000,
"temperature": $TEMPERATURE

}' \
--insecure | jq -r '.choices[]'.text
EOF
)

# Print the response
eval ${response}

done