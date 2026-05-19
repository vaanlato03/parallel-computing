#!/usr/bin/env bash
# benchmark.sh — Mide el tiempo total para distintos valores de N (mappers).
# Genera una tabla de speedup para el análisis de la Ley de Amdahl.
# Uso: bash benchmark.sh
# Requiere: corpus en data/corpus.txt e imágenes Docker construidas.

set -euo pipefail

M=2   # reducers fijos durante el benchmark

echo "============================================"
echo "  Benchmark de Speedup — MapReduce"
echo "  Reducers fijos: ${M}"
echo "============================================"
echo ""
printf "%-10s %-15s %-12s\n" "Mappers" "Tiempo (ms)" "Speedup"
echo "----------------------------------------------"

BASE_TIME=0

for N in 1 2 4 8; do
    START=$(date +%s%N)

    # Ejecutar pipeline silenciosamente
    bash run_pipeline.sh "$N" "$M" > /tmp/bench_out.txt 2>&1

    END=$(date +%s%N)
    ELAPSED=$(( (END - START) / 1000000 ))

    if [[ $N -eq 1 ]]; then
        BASE_TIME=$ELAPSED
        SPEEDUP="1.00"
    else
        # Speedup con dos decimales
        SPEEDUP=$(awk "BEGIN { printf \"%.2f\", ${BASE_TIME}/${ELAPSED} }")
    fi

    printf "%-10s %-15s %-12s\n" "$N" "${ELAPSED} ms" "${SPEEDUP}x"
done

echo ""
echo "Resultados guardados en output/top_words.txt (última ejecución)."
echo ""
echo "Tip: compara tu Speedup real con la Ley de Amdahl:"
echo "  S(N) = 1 / ( (1-p) + p/N )"
echo "  donde p = fracción paralelizable del programa."
