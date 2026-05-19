#!/usr/bin/env bash
# split_corpus.sh — Divide data/corpus.txt en N chunks de líneas completas.
# Uso: bash split_corpus.sh [N]
# Ejemplo: bash split_corpus.sh 4

set -euo pipefail

N=${1:-4}
CORPUS="data/corpus.txt"
CHUNKS_DIR="data/chunks"

if [[ ! -f "$CORPUS" ]]; then
    echo "ERROR: No se encontró $CORPUS"
    echo "Coloca un archivo de texto plano en data/corpus.txt antes de continuar."
    exit 1
fi

rm -rf "$CHUNKS_DIR"
mkdir -p "$CHUNKS_DIR"

split -n "l/${N}" "$CORPUS" "${CHUNKS_DIR}/chunk_"

echo "Corpus dividido en ${N} chunks:"
ls -lh "${CHUNKS_DIR}/"
echo ""
echo "Líneas por chunk:"
wc -l "${CHUNKS_DIR}/"*
