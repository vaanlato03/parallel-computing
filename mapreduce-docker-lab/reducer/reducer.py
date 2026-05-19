#!/usr/bin/env python3
"""
reducer.py — Variante del reducer implementada en Python.
MODIFICACIÓN A (Fase 6 / Pregunta a posteriori 3):
  comparar tiempo de cómputo y startup vs. la versión en C.

Uso dentro del contenedor:
  python3 reducer.py < /data/part_0.txt > /output/result_0.txt

Dockerfile alternativo: ver reducer/Dockerfile.python
"""
import sys

prev_word = None
total = 0

for line in sys.stdin:
    line = line.rstrip('\n')
    if '\t' not in line:
        continue
    word, count_str = line.split('\t', 1)
    try:
        count = int(count_str)
    except ValueError:
        continue

    if word == prev_word:
        total += count
    else:
        if prev_word is not None:
            print(f"{prev_word}\t{total}")
        prev_word = word
        total = count

if prev_word is not None:
    print(f"{prev_word}\t{total}")
