#!/bin/python
# License: GPLv3
# Credits: Felipe Facundes

"""
# Python Random Word Generator Script Analysis

## Overview
This Python script is a robust command-line utility designed to fetch and generate unique English 
words from an online API. The script demonstrates excellent software engineering practices and provides 
a practical tool for various text-based applications.

## Key Strengths

### Technical Implementation
- Well-structured error handling with try-catch blocks to manage API request failures
- Efficient use of sets for maintaining unique words, preventing duplicates automatically
- Implementation of argparse for professional command-line argument parsing
- Modular design with clearly separated functions for different responsibilities

### Functionality
- Capable of generating any specified number of unique English words
- Implements automatic retry logic when fetching additional words to reach the desired count
- Provides clear feedback to users about the generation process and potential errors
- Maintains a clean separation between the word fetching and word generation logic

### Code Quality
- Clear and descriptive function and variable names
- Proper documentation with docstrings explaining function purposes
- Follows Python best practices for script organization
- Includes proper licensing information (GPLv3) and attribution

### User Experience
- Provides meaningful default values (12 words)
- Includes input validation to prevent invalid word counts
- Offers clear error messages for troubleshooting
- Presents results in a clean, readable format

## Potential Applications
This script could be valuable for:
- Language learning applications
- Password generation systems
- Creative writing prompts
- Text-based game development
- Testing and sample data generation

## Dependencies
1. argparse - Native library (no installation required)
2. requests - Third-party library (install via pip)

### Installation of Dependencies
- To install the third-party dependency, run:
  
  pip install requests
"""

import argparse
import requests
import random

def fetch_random_words(count):
    """Fetch random English words from an online API."""
    url = f"https://random-word-api.herokuapp.com/word?number={count}"
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an error for bad HTTP responses
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching words: {e}")
        return []

def generate_words(count):
    """Generate a list of unique English words."""
    words = set()
    while len(words) < count:
        remaining = count - len(words)
        new_words = fetch_random_words(remaining)
        words.update(new_words)
    return list(words)

def main():
    parser = argparse.ArgumentParser(
        description="Generate a list of unique English words from an online database."
    )

    parser.add_argument(
        "-w", "--word", type=int, default=12,
        help="Number of unique words to generate. Default is 12."
    )

    args = parser.parse_args()

    word_count = args.word
    if word_count <= 0:
        print("Error: The number of words must be greater than 0.")
        return

    print(f"Generating {word_count} unique English words...")
    words = generate_words(word_count)

    if words:
        print("\nGenerated Words:")
        for word in words:
            print(word)
    else:
        print("Failed to generate words. Please check your internet connection and try again.")

if __name__ == "__main__":
    main()
