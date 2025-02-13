#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
A Python script that provides a flexible command-line argument parsing template with five optional arguments for easy script customization.
"""

import argparse

parser = argparse.ArgumentParser()

parser.add_argument('-a', help='Argument a')
parser.add_argument('-b', help='Argument b')
parser.add_argument('-c', help='Argument c')
parser.add_argument('-d', help='Argument d')
parser.add_argument('-e', help='Argument e')

args = parser.parse_args()

print(f"a: {args.a}")
print(f"b: {args.b}")
print(f"c: {args.c}")
print(f"d: {args.d}")
print(f"e: {args.e}")
