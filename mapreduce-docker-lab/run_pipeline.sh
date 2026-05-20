#!/usr/bin/env bash
# run_pipeline.sh — Orquesta el pipeline MapReduce completo.
# Uso: bash run_pipeline.sh [N_MAPPERS] [M_REDUCERS]
# Ejemplo: bash run_pipeline.sh 4 2

set -euo pipefail

N=${1:-4}   # número de mappers (= número de chunks)
M=${2:-2}   # número de reducers

echo "============================================"
echo "  MapReduce con Docker — Laboratorio"
echo "  Mappers: ${N}   Reducers: ${M}"
echo "============================================"

# ── 0. Preparar directorios ─────────────────────
mkdir -p shuffle output
rm -f shuffle/map_*.txt shuffle/sorted_all.txt shuffle/part_*.txt
rm -f output/result_*.txt output/top_words.txt

# ── 1. Construir imágenes ───────────────────────
echo ""
echo "[BUILD] Construyendo imágenes Docker..."
docker build -t lab-mapper  ./mapper  -q
docker build -t lab-reducer ./reducer -q
echo "[BUILD] Imágenes listas."

# ── 2. Split del corpus ─────────────────────────
echo ""
echo "[SPLIT] Dividiendo corpus en ${N} chunks..."
bash split_corpus.sh "$N"

# Listar chunks generados y mapearlos a sufijos
CHUNKS=($(ls data/chunks/chunk_* | sort))
if [[ ${#CHUNKS[@]} -lt $N ]]; then
    echo "ADVERTENCIA: Se generaron ${#CHUNKS[@]} chunks (pediste ${N})."
    N=${#CHUNKS[@]}
fi

# ── 3. MAP — contenedores en paralelo ──────────
echo ""
echo "[MAP] Lanzando ${N} mappers en paralelo..."
MAP_START=$(date +%s%N)

PIDS=()
for i in $(seq 0 $((N-1))); do
    CHUNK="${CHUNKS[$i]}"
    # La redirección (< y >) ocurre en el HOST (bash), no dentro del contenedor.
    # El contenedor solo lee stdin y escribe stdout; no necesita shell interno.
    docker run --rm -i \
        lab-mapper \
        < "${CHUNK}" \
        > "shuffle/map_${i}.txt" &
    PIDS+=($!)
    echo "  mapper-${i} lanzado (PID $!)"
done

# Esperar a todos los mappers y verificar código de salida
FAILED=0
for i in "${!PIDS[@]}"; do
    if ! wait "${PIDS[$i]}"; then
        echo "ERROR: mapper-${i} falló (PID ${PIDS[$i]})"
        FAILED=1
    fi
done
[[ $FAILED -eq 1 ]] && { echo "Abortando por fallo en mapper."; exit 1; }

# Verificar que se generaron los archivos
for i in $(seq 0 $((N-1))); do
    if [[ ! -f "shuffle/map_${i}.txt" ]]; then
        echo "ERROR: no se generó shuffle/map_${i}.txt"
        exit 1
    fi
done
echo "  Archivos generados: $(ls shuffle/map_*.txt | wc -l) de ${N}"

MAP_END=$(date +%s%N)
MAP_MS=$(( (MAP_END - MAP_START) / 1000000 ))
echo "[MAP] Completado en ${MAP_MS} ms."

# ── 4. SHUFFLE ──────────────────────────────────
echo ""
echo "[SHUFFLE] Ordenando y distribuyendo en ${M} particiones..."
SHUFFLE_START=$(date +%s%N)
bash shuffle.sh "$M"
SHUFFLE_END=$(date +%s%N)
SHUFFLE_MS=$(( (SHUFFLE_END - SHUFFLE_START) / 1000000 ))
echo "[SHUFFLE] Completado en ${SHUFFLE_MS} ms."

# ── 5. REDUCE — contenedores en paralelo ────────
echo ""
echo "[REDUCE] Lanzando ${M} reducers en paralelo..."
REDUCE_START=$(date +%s%N)

RPIDS=()
for j in $(seq 0 $((M-1))); do
    if [[ ! -f "shuffle/part_${j}.txt" ]]; then
        echo "  reducer-${j}: sin partición, saltando."
        continue
    fi
    # Redirección en el host: stdin desde part_j, stdout a result_j
    docker run --rm -i \
        lab-reducer \
        < "shuffle/part_${j}.txt" \
        > "output/result_${j}.txt" &
    RPIDS+=($!)
    echo "  reducer-${j} lanzado (PID $!)"
done

for pid in "${RPIDS[@]}"; do
    wait "$pid" || { echo "ERROR: reducer falló."; exit 1; }
done

REDUCE_END=$(date +%s%N)
REDUCE_MS=$(( (REDUCE_END - REDUCE_START) / 1000000 ))
echo "[REDUCE] Completado en ${REDUCE_MS} ms."

# ── 6. MERGE final ──────────────────────────────
echo ""
echo "[MERGE] Consolidando resultados..."
cat output/result_*.txt | sort -t$'\t' -k2 -rn > output/top_words.txt

TOTAL_WORDS=$(wc -l < output/top_words.txt)
echo "[MERGE] Palabras únicas encontradas: ${TOTAL_WORDS}"

# ── 7. Resumen ──────────────────────────────────
echo ""
echo "============================================"
echo "  RESUMEN DE TIEMPOS"
echo "  Map:     ${MAP_MS} ms"
echo "  Shuffle: ${SHUFFLE_MS} ms"
echo "  Reduce:  ${REDUCE_MS} ms"
echo "============================================"
echo ""
echo "Top 20 palabras más frecuentes:"
head -20 output/top_words.txt
