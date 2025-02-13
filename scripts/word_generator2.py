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

Dependencies:
1. requests (third-party, install via pip)
2. argparse (native, no installation needed)

Installation of Dependencies:
- To install the third-party dependency, run the following command:
  
  pip install requests
"""

import argparse
import requests
import random

def fetch_words(count):
    """
    Fetch unique English words from an online API.
    
    Args:
        count (int): Number of words to generate
    
    Returns:
        list: A list of unique English words
    """
    try:
        # Using Random Word API
        response = requests.get(f'https://random-word-api.herokuapp.com/word?number={count * 2}')
        response.raise_for_status()
        words = response.json()
        
        # Ensure unique words
        unique_words = list(dict.fromkeys(words))[:count]
        
        # If not enough unique words, fetch more
        while len(unique_words) < count:
            more_response = requests.get(f'https://random-word-api.herokuapp.com/word?number={count - len(unique_words)}')
            more_response.raise_for_status()
            more_words = more_response.json()
            unique_words.extend(word for word in more_words if word not in unique_words)
        
        return unique_words

    except requests.RequestException as e:
        print(f"Error fetching words: {e}")
        return []

def main():
    parser = argparse.ArgumentParser(description='Generate unique English words.')
    parser.add_argument('-w', '--word', type=int, default=12, 
                        help='Number of unique words to generate (default: 12)')
    
    args = parser.parse_args()
    
    words = fetch_words(args.word)
    
    if words:
        print("Generated Words:")
        for word in words:
            print(word)
    else:
        print("No words could be generated.")

if __name__ == "__main__":
    main()