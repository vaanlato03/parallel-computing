#!/usr/bin/env bash
# shuffle.sh — Etapa SHUFFLE del pipeline MapReduce.
# Combina las salidas de todos los mappers, las ordena y las distribuye
# en M particiones para los reducers.
# Uso: bash shuffle.sh [M]
# Ejemplo: bash shuffle.sh 2

set -euo pipefail

M=${1:-2}
SHUFFLE_DIR="shuffle"
MAP_PATTERN="${SHUFFLE_DIR}/map_*.txt"

# Verificar que existan salidas de mappers
if ! ls ${MAP_PATTERN} 1>/dev/null 2>&1; then
    echo "ERROR: No se encontraron archivos ${MAP_PATTERN}"
    echo "Asegúrate de haber ejecutado los mappers primero."
    exit 1
fi

echo "[SHUFFLE] Combinando salidas de mappers..."
cat ${MAP_PATTERN} | sort > "${SHUFFLE_DIR}/sorted_all.txt"

TOTAL=$(wc -l < "${SHUFFLE_DIR}/sorted_all.txt")
echo "[SHUFFLE] Total de pares (palabra, 1): ${TOTAL}"

echo "[SHUFFLE] Distribuyendo en ${M} particiones..."

rm -f "${SHUFFLE_DIR}"/part_*.txt

if [[ $M -eq 1 ]]; then
    cp "${SHUFFLE_DIR}/sorted_all.txt" "${SHUFFLE_DIR}/part_0.txt"

elif [[ $M -eq 2 ]]; then
    grep -E '^[a-m]' "${SHUFFLE_DIR}/sorted_all.txt" > "${SHUFFLE_DIR}/part_0.txt" || true
    grep -E '^[n-z]' "${SHUFFLE_DIR}/sorted_all.txt" > "${SHUFFLE_DIR}/part_1.txt" || true

elif [[ $M -eq 3 ]]; then
    grep -E '^[a-h]' "${SHUFFLE_DIR}/sorted_all.txt" > "${SHUFFLE_DIR}/part_0.txt" || true
    grep -E '^[i-p]' "${SHUFFLE_DIR}/sorted_all.txt" > "${SHUFFLE_DIR}/part_1.txt" || true
    grep -E '^[q-z]' "${SHUFFLE_DIR}/sorted_all.txt" > "${SHUFFLE_DIR}/part_2.txt" || true

elif [[ $M -eq 4 ]]; then
    grep -E '^[a-f]' "${SHUFFLE_DIR}/sorted_all.txt" > "${SHUFFLE_DIR}/part_0.txt" || true
    grep -E '^[g-l]' "${SHUFFLE_DIR}/sorted_all.txt" > "${SHUFFLE_DIR}/part_1.txt" || true
    grep -E '^[m-r]' "${SHUFFLE_DIR}/sorted_all.txt" > "${SHUFFLE_DIR}/part_2.txt" || true
    grep -E '^[s-z]' "${SHUFFLE_DIR}/sorted_all.txt" > "${SHUFFLE_DIR}/part_3.txt" || true

else
    # Partición genérica por módulo de longitud de palabra
    for i in $(seq 0 $((M-1))); do
        touch "${SHUFFLE_DIR}/part_${i}.txt"
    done
    while IFS=$'\t' read -r word count; do
        idx=$(( ${#word} % M ))
        echo -e "${word}\t${count}" >> "${SHUFFLE_DIR}/part_${idx}.txt"
    done < "${SHUFFLE_DIR}/sorted_all.txt"
fi

echo "[SHUFFLE] Líneas por partición:"
wc -l "${SHUFFLE_DIR}"/part_*.txt
echo "[SHUFFLE] Completado."
