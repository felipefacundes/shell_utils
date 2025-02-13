#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script facilitates a chat interface with OpenAI's GPT-3.5-turbo model. 
It begins by importing necessary libraries and setting the OpenAI API key. 
The 'chat_with_gpt' function sends user prompts to the model and retrieves responses, 
allowing for interactive conversation. The script runs in a loop, continuously prompting 
the user for input until the user types "exit" to terminate the session. It prints the model's responses, 
creating a simple command-line chat experience. Overall, this script serves as a straightforward way to 
interact with the GPT model for conversational purposes.

Dependencies:
1. 'openai' - Third-party library for interacting with OpenAI's API (install via pip).
2. 'os' - Native library for interacting with the operating system (no installation needed).

Installation of Dependencies:
- Install the 'openai' library using pip:

  pip install openai

Note: Remember to replace "API Key Here" with your actual OpenAI API key for the script to function correctly.
"""

import os
import openai

openai.api_key = "API Key Here"

def chat_with_gpt(prompt):
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[prompt],
        temperature=1,
        max_tokens=256,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0
    )
    return response['message']

while True:
    prompt = input("You: ")
    if prompt.lower() == "exit":
        break
    response = chat_with_gpt(prompt)
    print("GPT: ", response)
